#!/usr/bin/env python3
"""
Generate an importable Frends 6.2 Process JSON from a small flow spec, and validate one.

This encodes the schema confirmed from real 6.2 exports (see
references/process-file-format/ and its examples/). It builds the three coupled
pieces consistently: the Bpmn XML (structure + layout), the ElementParameters (per-shape
behavior), and the TriggersJson (the start), then wraps them in the `Processes` envelope and
writes UTF-8 with a BOM, exactly as a tenant export.

Scope (v1): linear flows. A trigger, then an ordered list of steps (Code Tasks and Tasks),
ending in a Return (expression or HTTP) or a Throw. Exclusive decisions, embedded scopes, and
subprocess calls are documented in the reference for hand-authoring and are the planned next
increment; this generator does not emit them yet, and validate() will still correctly check a
hand-authored file that contains them.

USAGE
  Harvest:   python generate_process.py --harvest tenant_export.json   # capture real task refs
  Generate:  python generate_process.py spec.json -o my_process.json
  Validate:  python generate_process.py --validate my_process.json

TASK GUIDS ARE TENANT-SPECIFIC. The /ProcessTask/{guid}/v{n} GUID is assigned per tenant and is
NOT portable between tenants (it also can change by package version). Do not synthesize or copy
one. Export a process from the target tenant that uses the Task and --harvest it; that records
the real ref plus a full parameter skeleton in tenant_tasks.json, which the generator prefers when
a step uses "package". task_registry.json holds marketplace-tenant GUIDs as a last-resort hint
only (the generator warns when it uses them).

SPEC FORMAT (JSON)
{
  "name": "My Process",
  "isSubprocess": false,
  "frendsVersion": "6.2.3.3649",            # optional, defaults below; copy from a tenant export
  "targetFramework": "net8.0",              # optional; a 6.3 tenant exports net10.0
  "processExecutionVersion": "6.2.10",      # optional
  "trigger": { "type": "manual" }
             | { "type": "http", "route": "api/x/v1/things", "method": "POST",
                 "references": ["data.body.id"], "openApiDocument": "" },
  "steps": [
    { "type": "codeTask", "name": "Build message",
      "code": "return new JObject { [\"hello\"] = \"world\" };",
      "assignTo": "message" },               # assignTo optional; omit for a void Code Task
    { "type": "task", "name": "HTTP Request",
      "package": "Frends.HTTP.Request",      # PREFERRED: GUID/ref/name resolved from task_registry.json
      "packageVersion": "1.11.0",            # match the version installed in the target tenant
      "parameters": { "input": { "Url": { "mode": "text", "value": "https://example.org" } } } },
    { "type": "task", "name": "Slack SendMessage",
      "taskRef": "/ProcessTask/<guid>/v1",   # FALLBACK for tasks not in the registry / custom tasks
      "parameters": { "input": { "Text": { "mode": "text", "value": "{{#var.message}}" } } },
      "linkedTask": { "Id": "<guid>", "PackageId": "Frends.Slack.SendMessage",
                      "PackageVersion": "2.0.0",
                      "Name": "Frends.Slack.SendMessage.Slack.SendMessage(Input, Connection, Options, CancellationToken)",
                      "FrameworkIdentifier": ".NETCoreApp" } }
  ],
  "return": { "type": "expression", "value": "#var.message" }
           | { "type": "http", "statusCode": 200, "contentType": "application/json",
               "content": "{ \"id\": \"string\" }" }
           | { "type": "throw", "statusCode": 500, "content": "error" }
}

Parameter values: pass each editable field as a {"mode": ..., "value": ...} leaf, using the
mode that matches the field (csharp = Expression, text = text+Handlebars, plus select, toggle,
integer, json, sql, xml). Reference Environment Variables as {{#env.Group.Name}} in text fields;
the generator auto-collects them into RequiredEnvironmentVariables.
"""

import argparse
import datetime
import json
import random
import re
import string
import sys
import uuid
import xml.etree.ElementTree as ET

DEFAULT_FRENDS_VERSION = "6.2.3.3649"
DEFAULT_EXEC_VERSION = "6.2.10"
TARGET_FRAMEWORK = "net8.0"
SCHEMA_VERSION = "Acc41"

BPMN_NS = "http://www.omg.org/spec/BPMN/20100524/MODEL"

# Type codes confirmed from real 6.2 / 5.7 exports.
TYPE_TRIGGER = 0
TYPE_TASK = 1
TYPE_GATEWAY = 2
TYPE_FLOW = 4
TYPE_RETURN = 5
TYPE_THROW = 6
TYPE_CODE_TASK = 12


def _sid(prefix):
    """A bpmn.io-style id: prefix + 7 lowercase alphanumerics."""
    return prefix + "_" + "".join(random.choices(string.ascii_lowercase + string.digits, k=7))


import os

_PLACEHOLDER_GUID = "00000000-0000-0000-0000-000000000000"


def _load_task_registry():
    """Load the stable official-task GUID registry that ships next to this script.

    Returns a dict PackageId -> {guid, taskVersion, name, framework}, or {} if absent.
    CAUTION: these are marketplace-authoring-tenant GUIDs only. Task-definition GUIDs are
    assigned per tenant (and can vary by version), so they are NOT portable; this registry is a
    last-resort hint. Prefer tenant_tasks.json, harvested from the target tenant's own exports.
    """
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "task_registry.json")
    try:
        with open(path, "r", encoding="utf-8") as f:
            return json.load(f).get("tasks", {})
    except Exception:
        return {}


_TASK_REGISTRY = _load_task_registry()


def _tenant_tasks_path():
    return os.path.join(os.path.dirname(os.path.abspath(__file__)), "tenant_tasks.json")


def _load_tenant_tasks():
    """Per-tenant task registry, built by --harvest from your own exports.

    Task-definition GUIDs are assigned per tenant (and can vary by package version), so they
    are NOT portable: the same package has a different GUID in a different tenant. The only
    reliable ref for an import is one taken from the target tenant. This registry holds those
    real refs plus a full, version-correct parameter skeleton, keyed PackageId -> version.
    """
    try:
        with open(_tenant_tasks_path(), "r", encoding="utf-8") as f:
            return json.load(f).get("tasks", {})
    except Exception:
        return {}


def harvest(export_paths):
    """Read tenant Process exports and merge their real task refs + parameter skeletons into
    tenant_tasks.json, so future generations target this tenant correctly."""
    store = {}
    if os.path.exists(_tenant_tasks_path()):
        with open(_tenant_tasks_path(), encoding="utf-8") as f:
            store = json.load(f)
    tasks = store.setdefault("tasks", {})
    store.setdefault("_README",
        "Per-tenant Frends task refs harvested from real exports. GUIDs are tenant- and "
        "version-specific; do not assume they transfer between tenants. Keyed PackageId -> "
        "PackageVersion. Regenerate with: generate_process.py --harvest <export.json>")
    added = 0
    for path in export_paths:
        with open(path, encoding="utf-8-sig") as f:
            d = json.load(f)
        procs = d.get("Processes", [])
        # task GUID -> linked metadata
        meta_by_id = {}
        for _k, _v in (d.get("LinkedTasks") or {}).items():
            for m in (_v if isinstance(_v, list) else [_v]):
                if isinstance(m, dict) and m.get("Id"):
                    meta_by_id[m["Id"]] = m
        for proc in procs:
            for e in json.loads(proc.get("ElementParameters") or "[]"):
                if e.get("Type") != TYPE_TASK:
                    continue
                ref = e.get("SelectedTypeId") or ""
                guid = _guid_from_ref(ref)
                meta = meta_by_id.get(guid)
                if not meta:
                    continue
                pid = meta.get("PackageId")
                ver = meta.get("PackageVersion") or ""
                tasks.setdefault(pid, {})[ver] = {
                    "ref": ref,
                    "guid": guid,
                    "name": meta.get("Name"),
                    "framework": meta.get("FrameworkIdentifier", ".NETCoreApp"),
                    "parameterSkeleton": e.get("Parameters", {}),
                }
                added += 1
    with open(_tenant_tasks_path(), "w", encoding="utf-8") as f:
        json.dump(store, f, ensure_ascii=False, indent=2)
    return added, sorted({p for p in tasks})


_TENANT_TASKS = _load_tenant_tasks()


def _entry(eid, etype, selected, params, name=None, should_retry=None):
    """Build an ElementParameters entry with the full standard field set.

    Confirmed against real 6.2 tenant exports: every entry carries these keys. Emitting only
    Id/Type/Parameters/SelectedTypeId makes the importer fail with "Sequence contains no
    matching element". Tasks (Type 1) use ShouldRetry=False; other shapes use None.
    """
    return {
        "Id": eid, "Type": etype, "Parameters": params, "SelectedTypeId": selected,
        "PromoteResultAs": None, "Name": name, "Description": None, "IsDefault": None,
        "ShouldRetry": should_retry, "MaxRetryCount": None,
        "ShouldNotLogResult": None, "ShouldDispose": None,
    }


def _guid_from_ref(ref):
    """Pull the GUID out of a /ProcessTask/{guid}/v{n} ref string, or None."""
    m = re.search(r"/ProcessTask/([0-9a-fA-F-]+)/v\d+", ref or "")
    return m.group(1) if m else None


def _deep_merge(base, override):
    """Overlay `override` onto `base` recursively. Used to apply the caller's parameter values
    on top of a harvested full parameter skeleton, so all method parameter groups stay present
    and version-correct while the caller only specifies what changes."""
    for k, v in (override or {}).items():
        if isinstance(v, dict) and isinstance(base.get(k), dict):
            base[k] = _deep_merge(dict(base[k]), v)
        else:
            base[k] = v
    return base


def _cjson(obj):
    """Compact JSON (no spaces after separators), matching how the Frends editor serializes the
    stringified-JSON fields (ElementParameters, TriggersJson, etc.)."""
    return json.dumps(obj, ensure_ascii=False, separators=(",", ":"))


def _resolve_task(step):
    """Resolve a task step to (task_ref, linked_task_metadata).

    Two ways to specify a task:
      1. "package": "Frends.HTTP.Request" [+ optional "packageVersion", "taskVersion"]
         -> GUID, ref, name, and framework are filled from the registry. Preferred.
      2. Explicit "taskRef" + "linkedTask" (for tasks not in the registry / custom tasks).
         Read the real ref from an existing process export's UsedTasksJson.

    A placeholder / empty GUID is rejected, because the importer resolves the ref against
    installed tasks and an invented GUID fails with "key ... not present in the dictionary".
    """
    pkg = step.get("package")
    if pkg:
        ver = step.get("packageVersion")
        # 1) Prefer the per-tenant registry (real, importable refs harvested from your exports).
        tver = _TENANT_TASKS.get(pkg, {})
        chosen = None
        if ver and ver in tver:
            chosen = tver[ver]
        elif len(tver) == 1:
            chosen = next(iter(tver.values()))
        elif tver:
            chosen = tver[sorted(tver)[-1]]  # newest harvested version
        if chosen:
            params = _deep_merge(dict(chosen.get("parameterSkeleton") or {}),
                                 step.get("parameters") or {})
            linked = {
                "Id": chosen["guid"], "PackageId": pkg,
                "PackageVersion": ver or "",
                "Name": chosen.get("name"),
                "FrameworkIdentifier": chosen.get("framework", ".NETCoreApp"),
            }
            step["parameters"] = params  # generator reads step['parameters'] downstream
            return chosen["ref"], linked

        # 2) Fall back to the marketplace registry, but warn: its GUID is from the Frends
        #    template-authoring tenant and is usually WRONG for another tenant. The GUID is
        #    assigned per tenant, so this will likely fail on import. Harvest instead.
        entry = _TASK_REGISTRY.get(pkg)
        if entry:
            import sys as _sys
            print(
                f"WARNING: resolving '{pkg}' from the marketplace registry "
                f"(GUID {entry['guid']}). Task GUIDs are tenant-specific, so this GUID is "
                f"probably not the one your tenant uses and the import may fail. Run "
                f"'generate_process.py --harvest <an export from your tenant that uses this "
                f"task>' to capture the real ref, then regenerate.", file=_sys.stderr)
            guid = entry["guid"]
            tv = step.get("taskVersion", entry.get("taskVersion", 1))
            return f"/ProcessTask/{guid}/v{tv}", {
                "Id": guid, "PackageId": pkg,
                "PackageVersion": ver or entry.get("packageVersion", ""),
                "Name": entry.get("name"),
                "FrameworkIdentifier": entry.get("framework", ".NETCoreApp"),
            }
        raise ValueError(
            f"task '{step.get('name')}' references package '{pkg}', which is in neither the "
            f"tenant registry nor the marketplace registry. Harvest it from a tenant export "
            f"(generate_process.py --harvest <export.json>) or supply explicit taskRef/linkedTask.")

    task_ref = step.get("taskRef")
    if not task_ref:
        raise ValueError(
            f"task '{step.get('name')}' needs either 'package' (resolved via the registry) "
            f"or an explicit 'taskRef' (e.g. /ProcessTask/<guid>/v1).")
    guid = _guid_from_ref(task_ref)
    if not guid or guid == _PLACEHOLDER_GUID:
        raise ValueError(
            f"task '{step.get('name')}' has a placeholder or malformed GUID in taskRef "
            f"({task_ref!r}). The importer resolves this ref against installed tasks, so a "
            f"fabricated GUID fails on import. Use 'package' to resolve a known GUID, or paste "
            f"the real ref from an existing export's UsedTasksJson.")
    linked = step.get("linkedTask")
    if linked and linked.get("Id") and _guid_from_ref(task_ref) != linked.get("Id"):
        raise ValueError(
            f"task '{step.get('name')}': linkedTask.Id ({linked.get('Id')}) must equal the GUID "
            f"in taskRef ({guid}). The LinkedTasks dictionary KEY is separate (it is the process "
            f"UniqueIdentifier); the inner Id is what must match the ref.")
    return task_ref, linked


def _now_iso():
    return datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None).isoformat()


def _collect_env_vars(obj, found):
    """Recursively find #env.Group.Name references in parameter values."""
    if isinstance(obj, dict):
        for v in obj.values():
            _collect_env_vars(v, found)
    elif isinstance(obj, list):
        for v in obj:
            _collect_env_vars(v, found)
    elif isinstance(obj, str):
        for m in re.finditer(r"#env\.([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)", obj):
            found.add(f"{m.group(1)}.{m.group(2)}")


def generate(spec):
    """Build the full export dict from a spec. Returns (export_dict, warnings)."""
    warnings = []
    name = spec.get("name", "Generated Process")
    is_sub = bool(spec.get("isSubprocess", False))
    process_guid = str(uuid.uuid4())

    nodes = []          # (id, kind, name, width, height) for layout, in order
    ep = []             # ElementParameters entries
    flows = []          # (flow_id, source_id, target_id, name)
    used_tasks = []
    linked_tasks = []
    env_found = set()

    # --- Trigger / start event ---
    start_id = "StartEvent_1"
    trig = spec.get("trigger", {"type": "manual"})
    ttype = trig.get("type", "manual")
    if ttype == "manual":
        triggers_json = [{"$type": "ManualTrigger", "config": {}, "name": "Manual",
                          "id": start_id, "shouldNotLogParameters": None}]
        ep.append(_entry(start_id, TYPE_TRIGGER, "ManualTrigger", {}, name="Manual"))
        start_name = "Manual"
    elif ttype == "http":
        cfg = {
            "routeTemplate": trig.get("route", "api/v1/resource"),
            "isPrivate": bool(trig.get("isPrivate", False)),
            "corsEnabled": bool(trig.get("corsEnabled", False)),
            "allowedOrigins": trig.get("allowedOrigins", ""),
            "allowedSchemes": trig.get("allowedSchemes", "HTTP,HTTPS"),
            "httpMethod": trig.get("method", "POST"),
            "references": trig.get("references", []),
            "openApiDocument": trig.get("openApiDocument", ""),
        }
        triggers_json = [{"$type": "HttpApiTrigger", "config": cfg,
                          "name": cfg["routeTemplate"], "id": start_id,
                          "shouldNotLogParameters": None}]
        ep.append(_entry(start_id, TYPE_TRIGGER, "HttpApiTrigger", {}, name=cfg["routeTemplate"]))
        start_name = cfg["routeTemplate"]
    else:
        raise ValueError(f"Unsupported trigger type: {ttype!r} (use 'manual' or 'http')")
    nodes.append((start_id, "startEvent", start_name, 36, 36))

    prev_id = start_id

    # --- Steps ---
    for step in spec.get("steps", []):
        stype = step.get("type")
        if stype == "codeTask":
            nid = _sid("Activity")
            assign_to = step.get("assignTo")
            params = {
                "useStatementMode": {"mode": "toggle", "value": bool(step.get("useStatementMode", True))},
                "variableExpression": {"mode": "csharp", "value": step.get("code", "")},
                "shouldAssignVariable": {"mode": "toggle", "value": assign_to is not None},
                "variableName": assign_to if assign_to is not None else "",
            }
            _collect_env_vars(params, env_found)
            ep.append(_entry(nid, TYPE_CODE_TASK, None, params, name=step.get("name", "Code Task")))
            nodes.append((nid, "scriptTask", step.get("name", "Code Task"), 100, 80))
        elif stype == "task":
            nid = _sid("Activity")
            task_ref, linked = _resolve_task(step)
            params = step.get("parameters", {})
            _collect_env_vars(params, env_found)
            ep.append(_entry(nid, TYPE_TASK, task_ref, params, name=step.get("name", "Task"),
                             should_retry=False))
            nodes.append((nid, "task", step.get("name", "Task"), 100, 80))
            used_tasks.append(task_ref)
            if linked:
                linked_tasks.append(linked)
            else:
                warnings.append(
                    f"task '{step.get('name')}' has no 'linkedTask' metadata; LinkedTasks "
                    f"will be incomplete. Import needs the Task installed in the tenant.")
        else:
            raise ValueError(f"Unsupported step type: {stype!r} (use 'codeTask' or 'task')")
        flows.append((_sid("Flow"), prev_id, nid, None))
        prev_id = nid

    # --- Return / Throw terminal ---
    ret = spec.get("return", {"type": "expression", "value": "#result"})
    rtype = ret.get("type", "expression")
    end_id = _sid("Event")
    if rtype == "expression":
        mode = ret.get("mode", "text")
        params = {"expression": {"mode": mode, "value": ret.get("value", "#result")}}
        _collect_env_vars(params, env_found)
        ep.append(_entry(end_id, TYPE_RETURN, None, params))
        nodes.append((end_id, "endEvent", "Return", 36, 36))
    elif rtype == "http":
        params = {"httpResult": {
            "httpStatusCode": {"mode": "integer", "value": int(ret.get("statusCode", 200))},
            "httpContentType": {"mode": "text", "value": ret.get("contentType", "application/json")},
            "httpContent": {"mode": ret.get("contentMode", "json"), "value": ret.get("content", "")},
            "httpContentEncoding": {"mode": "text", "value": ret.get("encoding", "utf-8")},
            "httpHeaders": ret.get("headers", []),
        }}
        _collect_env_vars(params, env_found)
        ep.append(_entry(end_id, TYPE_RETURN, "HttpResult", params))
        nodes.append((end_id, "endEvent", "Return", 36, 36))
    elif rtype == "throw":
        params = {"httpResult": {
            "httpStatusCode": {"mode": "integer", "value": int(ret.get("statusCode", 500))},
            "httpContentType": {"mode": "text", "value": ret.get("contentType", "application/json")},
            "httpContent": {"mode": ret.get("contentMode", "text"), "value": ret.get("content", "")},
            "httpContentEncoding": {"mode": "text", "value": ret.get("encoding", "utf-8")},
            "httpHeaders": ret.get("headers", []),
        }}
        ep.append(_entry(end_id, TYPE_THROW, "HttpResult", params))
        nodes.append((end_id, "intermediateThrowEvent", "Throw", 36, 36))
    else:
        raise ValueError(f"Unsupported return type: {rtype!r}")
    flows.append((_sid("Flow"), prev_id, end_id, None))

    bpmn = _build_bpmn(nodes, flows)

    env_vars = sorted(env_found)
    pkg_name = re.sub(r"[^A-Za-z0-9]", "", name)[:24] or "Process"
    process = {
        "Name": name,
        "Modified": _now_iso(),
        "Modifier": spec.get("modifier", ""),
        "TagString": None, "Tags": [],
        "Description": spec.get("description", ""),
        "Version": 1,
        "UniqueIdentifier": process_guid,
        "GraphJson": "",
        "Bpmn": bpmn,
        "ElementParameters": _cjson(ep),
        "ManualTriggerJson": _cjson([]),
        "IsSubprocess": is_sub,
        "TriggersJson": _cjson(triggers_json),
        "AssemblyName": f"Frends.ExecutableProcess.frends_{pkg_name}",
        "PackageId": f"{pkg_name}{process_guid.replace('-', '')}",
        "PackageVersion": "0.1.1",
        "UsedTasksJson": _cjson(used_tasks),
        "UsedSubprocessesJson": _cjson({}),
        "ProcessExecutionVersion": spec.get("processExecutionVersion", DEFAULT_EXEC_VERSION),
        "FrendsVersion": spec.get("frendsVersion", DEFAULT_FRENDS_VERSION),
        "TargetFramework": spec.get("targetFramework", TARGET_FRAMEWORK),
        "StaticRequiredEnvironmentVariables": env_vars,
        "RequiredEnvironmentVariables": env_vars,
        "PromotedResultVariablesJson": _cjson([]),
        "MajorVersion": 0, "MinorVersion": 1,
        "IsForMonitoringRule": False,
        "ProcessVariablesJson": None,
        "PreserveReferencesAtCheckpoint": True,
    }
    export = {
        "Processes": [process],
        # The LinkedTasks dictionary key MUST equal the process UniqueIdentifier: the importer
        # looks up a process's linked tasks by its own GUID. A mismatched key makes the import
        # fail with "Sequence contains no matching element". Confirmed across all real exports.
        "LinkedTasks": {process_guid: linked_tasks} if linked_tasks else {},
        "LinkedSubProcess": {},
        "Version": SCHEMA_VERSION,
    }
    return export, warnings


def _build_bpmn(nodes, flows):
    """Build BPMN XML in the same shape the Frends editor (bpmn.io) emits, so it round-trips
    on import. Confirmed against a real tenant export: compact (no pretty-print), process
    elements interleaved as startEvent then [node, inbound-flow] per following node, activity
    shapes carry an empty <BPMNLabel/>, the start shape uses the _BPMNShape_StartEvent_ id
    convention, and the end event has no name attribute.
    """
    by_id = {n[0]: n for n in nodes}
    incoming = {nid: [] for nid, *_ in nodes}
    outgoing = {nid: [] for nid, *_ in nodes}
    inbound_flow = {}
    for fid, src, tgt, _ in flows:
        outgoing[src].append(fid)
        incoming[tgt].append(fid)
        inbound_flow[tgt] = fid

    # Layout left to right, centers at y=120.
    pos = {}
    x = 160
    for nid, kind, name, w, h in nodes:
        pos[nid] = (x, 120 - h // 2, w, h)
        x += w + 80

    def node_xml(nid, kind, name):
        nm = "" if kind == "endEvent" else (f' name="{_esc(name)}"' if name else "")
        parts = [f'<bpmn2:{kind} id="{nid}"{nm}>']
        for fid in incoming[nid]:
            parts.append(f'<bpmn2:incoming>{fid}</bpmn2:incoming>')
        for fid in outgoing[nid]:
            parts.append(f'<bpmn2:outgoing>{fid}</bpmn2:outgoing>')
        if kind == "intermediateThrowEvent":
            parts.append('<bpmn2:signalEventDefinition />')
        parts.append(f'</bpmn2:{kind}>')
        return "".join(parts)

    def flow_xml(fid, src, tgt, fname):
        nm = f' name="{_esc(fname)}"' if fname else ""
        return f'<bpmn2:sequenceFlow id="{fid}"{nm} sourceRef="{src}" targetRef="{tgt}" />'

    flow_by_id = {f[0]: f for f in flows}
    proc = ['<bpmn2:process id="Process_1" isExecutable="false">']
    # startEvent first, then each following node immediately followed by its inbound flow.
    proc.append(node_xml(*nodes[0][:3]))
    for nid, kind, name, w, h in nodes[1:]:
        proc.append(node_xml(nid, kind, name))
        fid = inbound_flow.get(nid)
        if fid:
            proc.append(flow_xml(*flow_by_id[fid]))
    proc.append('</bpmn2:process>')

    di = ['<bpmndi:BPMNDiagram id="BPMNDiagram_1">',
          '<bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Process_1">']
    for idx, (nid, kind, name, w, h) in enumerate(nodes):
        x, y, w, h = pos[nid]
        shape_id = "_BPMNShape_StartEvent_2" if kind == "startEvent" else f"{nid}_di"
        label = '<bpmndi:BPMNLabel />' if kind in ("task", "scriptTask") else ''
        di.append(f'<bpmndi:BPMNShape id="{shape_id}" bpmnElement="{nid}">'
                  f'<dc:Bounds x="{x}" y="{y}" width="{w}" height="{h}" />{label}'
                  f'</bpmndi:BPMNShape>')
    for fid, src, tgt, _ in flows:
        sx, sy, sw, sh = pos[src]; tx, ty, tw, th = pos[tgt]
        di.append(f'<bpmndi:BPMNEdge id="{fid}_di" bpmnElement="{fid}">'
                  f'<di:waypoint x="{sx + sw}" y="{sy + sh // 2}" />'
                  f'<di:waypoint x="{tx}" y="{ty + th // 2}" />'
                  f'</bpmndi:BPMNEdge>')
    di.append('</bpmndi:BPMNPlane>')
    di.append('</bpmndi:BPMNDiagram>')

    header = ('<?xml version="1.0" encoding="UTF-8"?>\n'
              '<bpmn2:definitions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
              'xmlns:bpmn2="http://www.omg.org/spec/BPMN/20100524/MODEL" '
              'xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" '
              'xmlns:dc="http://www.omg.org/spec/DD/20100524/DC" '
              'xmlns:di="http://www.omg.org/spec/DD/20100524/DI" '
              'id="sample-diagram" targetNamespace="http://bpmn.io/schema/bpmn" '
              'xsi:schemaLocation="http://www.omg.org/spec/BPMN/20100524/MODEL BPMN20.xsd">')
    return header + "".join(proc) + "".join(di) + "</bpmn2:definitions>"


def _esc(s):
    return (str(s).replace("&", "&amp;").replace("<", "&lt;")
            .replace(">", "&gt;").replace('"', "&quot;"))


# --- Validation -------------------------------------------------------------

FLOW_NODE_TAGS = {"startEvent", "endEvent", "task", "scriptTask", "exclusiveGateway",
                  "inclusiveGateway", "intermediateThrowEvent", "intermediateCatchEvent",
                  "callActivity", "subProcess", "businessRuleTask"}


def validate(export):
    """Structural checks against the invariants seen in real exports. Returns (ok, messages)."""
    msgs = []

    def err(m): msgs.append("ERROR: " + m)
    def ok(m): msgs.append("ok: " + m)

    if not isinstance(export, dict) or "Processes" not in export:
        return False, ["ERROR: top level must have a 'Processes' array"]
    for key in ("LinkedTasks", "LinkedSubProcess", "Version"):
        if key not in export:
            err(f"top level missing '{key}'")
    if export.get("Version") != SCHEMA_VERSION:
        msgs.append(f"note: Version is {export.get('Version')!r} (expected {SCHEMA_VERSION!r})")

    p = export["Processes"][0]
    for f in ("Bpmn", "ElementParameters", "TriggersJson", "UniqueIdentifier",
              "FrendsVersion", "TargetFramework", "IsSubprocess"):
        if f not in p:
            err(f"Process missing '{f}'")

    # Parse BPMN
    try:
        root = ET.fromstring(p["Bpmn"])
        ok("Bpmn is well-formed XML")
    except ET.ParseError as e:
        err(f"Bpmn is not well-formed: {e}")
        return False, msgs

    ns = {"b": BPMN_NS}
    proc_el = root.find("b:process", ns)
    node_ids, flow_ids, srcs_tgts = set(), set(), []
    for child in proc_el.iter():  # recurse so embedded subProcess scopes are included
        tag = child.tag.split("}")[-1]
        cid = child.get("id")
        if tag == "sequenceFlow":
            flow_ids.add(cid)
            srcs_tgts.append((cid, child.get("sourceRef"), child.get("targetRef")))
        elif tag in FLOW_NODE_TAGS:
            node_ids.add(cid)

    # Sequence flow endpoints must exist
    all_targets = node_ids | flow_ids
    for fid, s, t in srcs_tgts:
        if s not in all_targets:
            err(f"sequenceFlow {fid} sourceRef {s} is not a known element")
        if t not in all_targets:
            err(f"sequenceFlow {fid} targetRef {t} is not a known element")
    if srcs_tgts:
        ok(f"{len(srcs_tgts)} sequence flows reference valid endpoints")

    # ElementParameters <-> BPMN bijection (flow nodes must all be present;
    # non-flow EP ids must be flow nodes or conditional flows of type 4)
    try:
        ep = json.loads(p["ElementParameters"])
        ok(f"ElementParameters parses ({len(ep)} entries)")
    except json.JSONDecodeError as e:
        err(f"ElementParameters is not valid JSON: {e}")
        return False, msgs
    ep_ids = {e["Id"]: e.get("Type") for e in ep}
    for nid in node_ids:
        if nid not in ep_ids:
            err(f"BPMN node {nid} has no ElementParameters entry")
    for eid, etype in ep_ids.items():
        if eid in node_ids:
            continue
        if eid in flow_ids and etype == TYPE_FLOW:
            continue  # conditional branch flow, allowed
        # Uncatalogued element types (data objects, annotations, etc.) -> note, not error.
        msgs.append(f"note: ElementParameters entry {eid} (Type {etype}) has no matching "
                    f"flow node tag (may be a data/annotation/scope element)")
    if not any(m.startswith("ERROR") and "no ElementParameters" in m for m in msgs):
        ok("every BPMN flow node has an ElementParameters entry")

    # Trigger id matches the start event
    try:
        trigs = json.loads(p["TriggersJson"])
        start = proc_el.find("b:startEvent", ns)
        if trigs and start is not None and trigs[0].get("id") != start.get("id"):
            err(f"TriggersJson id {trigs[0].get('id')} != startEvent id {start.get('id')}")
        else:
            ok("Trigger id matches the start event")
    except json.JSONDecodeError as e:
        err(f"TriggersJson is not valid JSON: {e}")

    # UsedTasksJson matches Task shapes' SelectedTypeId
    used = set(json.loads(p.get("UsedTasksJson") or "[]"))
    task_refs = {e.get("SelectedTypeId") for e in ep if e.get("Type") == TYPE_TASK}
    missing = task_refs - used
    if missing:
        err(f"Task refs not listed in UsedTasksJson: {missing}")
    else:
        ok("UsedTasksJson covers all Task references")

    # Task ref GUIDs must be real, and LinkedTasks must carry a matching inner Id.
    # The importer resolves /ProcessTask/{guid}/v{n} against installed tasks; a placeholder
    # GUID fails with "key ... not present in the dictionary". The LinkedTasks dictionary KEY
    # is the process UniqueIdentifier (checked separately below), so we match the ref against
    # the inner Id, not the key.
    linked = export.get("LinkedTasks") or {}
    linked_ids = set()
    for _k, _v in linked.items():
        for _m in (_v if isinstance(_v, list) else [_v]):
            if isinstance(_m, dict) and _m.get("Id"):
                linked_ids.add(_m["Id"])
    bad_guid = False
    for ref in task_refs:
        g = _guid_from_ref(ref)
        if not g or g == _PLACEHOLDER_GUID:
            err(f"Task ref has a placeholder/empty GUID ({ref}); it will fail on import. "
                f"Use a real task GUID (see task_registry.json or an existing export).")
            bad_guid = True
        elif g not in linked_ids:
            err(f"Task ref GUID {g} has no matching LinkedTasks inner Id "
                f"(inner Ids present: {sorted(linked_ids) or 'none'}). The ref GUID must equal "
                f"a LinkedTasks .Id; the dictionary key is separate (the process UniqueIdentifier).")
            bad_guid = True
        elif g not in {t.get("guid") for t in _TASK_REGISTRY.values()}:
            ok(f"Task ref {g} resolves to LinkedTasks (not a known official task; "
               f"confirm it is installed in the tenant)")
    if task_refs and not bad_guid:
        ok("all Task ref GUIDs are real and matched in LinkedTasks")

    # LinkedTasks dictionary key must equal the process UniqueIdentifier: the importer looks up
    # a process's tasks by its own GUID, and a mismatch fails with "Sequence contains no
    # matching element". Confirmed across every real export.
    if linked:
        uid = p.get("UniqueIdentifier")
        if uid not in linked:
            err(f"LinkedTasks key {sorted(linked)} != process UniqueIdentifier {uid}; "
                f"import will fail with 'Sequence contains no matching element'.")
        else:
            ok("LinkedTasks key matches the process UniqueIdentifier")

    # Stringified-JSON fields must be strings containing valid JSON, not native objects.
    # (A native object/array here makes the importer reject the file as "not JSON format".)
    string_json_fields = ["ElementParameters", "TriggersJson", "ManualTriggerJson",
                          "UsedTasksJson", "UsedSubprocessesJson", "PromotedResultVariablesJson"]
    bad_type = False
    for f in string_json_fields:
        v = p.get(f)
        if not isinstance(v, str):
            err(f"'{f}' must be a JSON string, found {type(v).__name__} (this breaks import)")
            bad_type = True
        else:
            try:
                json.loads(v)
            except json.JSONDecodeError as e:
                err(f"'{f}' is a string but not valid JSON: {e}")
                bad_type = True
    if not bad_type:
        ok("all stringified-JSON fields are strings containing valid JSON")

    ok_flag = not any(m.startswith("ERROR") for m in msgs)
    return ok_flag, msgs


def _write(export, path):
    # Tenant exports are UTF-8 with a BOM.
    with open(path, "w", encoding="utf-8-sig") as f:
        json.dump(export, f, ensure_ascii=False, indent=2)


def main(argv=None):
    ap = argparse.ArgumentParser(description="Generate or validate a Frends 6.2 Process JSON.")
    ap.add_argument("input", nargs="*", help="spec JSON to generate from, a Process JSON with "
                    "--validate, or one or more tenant exports with --harvest")
    ap.add_argument("-o", "--output", help="output path for the generated Process JSON")
    ap.add_argument("--validate", action="store_true", help="validate INPUT instead of generating")
    ap.add_argument("--harvest", action="store_true",
                    help="read tenant export(s) and merge their real task refs + parameter "
                         "skeletons into tenant_tasks.json (GUIDs are tenant-specific)")
    args = ap.parse_args(argv)

    if args.harvest:
        if not args.input:
            ap.error("--harvest needs at least one export file")
        n, pkgs = harvest(args.input)
        print(f"Harvested {n} task ref(s) into {_tenant_tasks_path()}")
        print("Packages now known for this tenant:", ", ".join(pkgs) or "(none)")
        return 0

    if args.validate:
        with open(args.input[0], encoding="utf-8-sig") as f:
            export = json.load(f)
        ok, msgs = validate(export)
        for m in msgs:
            print(m)
        print("\nVALID" if ok else "\nINVALID")
        return 0 if ok else 1

    with open(args.input[0], encoding="utf-8-sig") as f:
        spec = json.load(f)
    export, warnings = generate(spec)
    for w in warnings:
        print("warning:", w, file=sys.stderr)
    out = args.output or "generated_process.json"
    _write(export, out)
    ok, _ = validate(export)
    print(f"Wrote {out} ({'valid' if ok else 'INVALID - run --validate'})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
