#!/usr/bin/env python3
"""
Review a Frends Process export (proprietary JSON, as exported from the tenant or written by
frends-ipaas-developer's generate_process.py), a Template export, or a Frends MCP get_process_data
result saved as JSON, against the rules in ../references/rules.md. The input kind is detected.

Only the automatic ("auto") rules are checked here. The manual rules need a person or the model
reading the Process, its specification and the organisation's standards; SKILL.md covers them.

USAGE
  python review_process.py process.json [more.json ...]
  python review_process.py process.json --format json
  python review_process.py process.json --disable NAM-01,LOG-01     # house standard differs
  python review_process.py process.json --no-import-check           # skip the generator validator

EXIT CODE
  2 when any blocker is found, 1 when any major is found, 0 otherwise. Use it as a gate.

The file is read-only input. Nothing is modified.
"""
import argparse
import importlib.util
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

BPMN_NS = "http://www.omg.org/spec/BPMN/20100524/MODEL"
SEVERITY_ORDER = {"blocker": 0, "major": 1, "minor": 2, "info": 3}

T_START, T_TASK, T_GATEWAY, T_FLOW, T_RETURN, T_THROW, T_CALL = 0, 1, 2, 4, 5, 6, 7
T_SCOPE, T_FOREACH, T_WHILE, T_CODE, T_SCOPE_START, T_CATCH = 8, 10, 11, 12, 13, 14
T_HOOK = 18
LOOP_TYPES = {T_FOREACH, T_WHILE}
NON_EXECUTION = {T_START, T_SCOPE_START, T_RETURN, T_FLOW, T_CATCH, T_HOOK, 17, 22, 23}

FLOW_NODE_TAGS = {"startEvent", "endEvent", "task", "scriptTask", "exclusiveGateway",
                  "inclusiveGateway", "intermediateThrowEvent", "intermediateCatchEvent",
                  "callActivity", "subProcess", "businessRuleTask"}

DEFAULT_NAME = re.compile(
    r"^(HTTP ?Request|Code|Code ?Task|Task|Decision|Exclusive ?Decision|Inclusive ?Decision|"
    r"Scope|Call ?Subprocess|Assign ?Variable|Assign|Foreach|For ?each|While|Shared ?State)\s*\d*$",
    re.I)
ENV_TOKEN = re.compile(r"(?i)(^|[\s_\-\.\[\(])(dev|tst|acc|prd|prod)($|[\s_\-\.\]\)])")
BRACKETS = re.compile(r"[\[\]{}()<>]")
ENV_REF = re.compile(r"#env\.([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)")
SECRET_NAME = re.compile(r"(?i)(token|secret|password|passwd|pwd|apikey|api_key|privatekey|"
                         r"credential|connectionstring|sas)")
URL_KEY = re.compile(r"(?i)(url|uri|address|endpoint|route|path|query ?string)")
SECRET_FIELD = re.compile(r"(?i)(password|secret|token|key|credential|connectionstring)")
HARDCODED = [
    re.compile(r"(?i)\b(password|pwd|secret|api_?key|client_?secret|token)\b\s*[=:]\s*[\"']?"
               r"(?!\{\{|#env|#var|#trigger|#result|\$)[A-Za-z0-9+/_\-!@%^*.]{8,}"),
    re.compile(r"\bBearer\s+[A-Za-z0-9\-_]{10,}\.[A-Za-z0-9\-_]{10,}"),
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
]
SQL_KEY = re.compile(r"(?i)(query|sql|command ?text)")
ENDLESS = re.compile(r"while\s*\(\s*true\s*\)|for\s*\(\s*;\s*;\s*\)")
TRAILING_VERSION = re.compile(r"^.+ - \d+\.\d+(\.\d+)?$")
# Error-pipeline Processes (the shared handler and the error-event listener) swallow failures and
# leave the unhandled-error hook empty by design. Matched by name; extend with --pipeline.
PIPELINE_NAME = re.compile(r"(?i)(handle process error|generic error handler|error event listener|notify (platform )?error events)\s*$")


class Finding:
    def __init__(self, rule, severity, where, message, fix):
        self.rule, self.severity, self.where, self.message, self.fix = rule, severity, where, message, fix

    def as_dict(self):
        return {"rule": self.rule, "severity": self.severity, "where": self.where,
                "finding": self.message, "fix": self.fix}


# ---------------------------------------------------------------- helpers

def _load(path):
    with open(path, encoding="utf-8-sig") as f:
        return json.load(f)


def _from_mcp(data):
    """Wrap a Frends MCP get_process_data result in the export shape the rules read.

    The MCP result carries the diagram and the shape parameters only: no description, tags,
    promoted-variable list or task links, so the documentation rules and the structural
    validator are skipped for it."""
    ep = data.get("elementParametersJson")
    return {"Processes": [{
        "Name": data.get("name"),
        "IsSubprocess": data.get("isSubprocess"),
        "Bpmn": data.get("bpmnXml"),
        "ElementParameters": ep if isinstance(ep, str) else json.dumps(ep or []),
        "ProcessVariablesJson": json.dumps(data.get("processVariablesJson") or {}),
        "_source": "mcp",
    }]}


def _process(export):
    """Return the process record from a Process export, a Template export or an MCP result."""
    if "bpmnXml" in export and "elementParametersJson" in export:
        export = _from_mcp(export)
    if export.get("Processes"):
        return export["Processes"][0]
    templates = export.get("ProcessTemplates")
    if templates:
        info = templates[0].get("ProcessInfo")
        if isinstance(info, dict) and isinstance(info.get("Process"), dict):
            proc = dict(info["Process"])
            proc.setdefault("Name", templates[0].get("Name"))
            proc["_source"] = "template"
            return proc
        return templates[0]
    raise ValueError("not a Frends Process export, Template export or MCP get_process_data result")


def _json_field(p, key, default):
    v = p.get(key)
    if isinstance(v, str):
        try:
            return json.loads(v) if v.strip() else default
        except json.JSONDecodeError:
            return default
    return v if v is not None else default


def _leaves(obj, path=()):
    """Yield (path, mode, value) for every {mode, value} leaf in a Parameters tree."""
    if isinstance(obj, dict):
        if "mode" in obj and "value" in obj and not isinstance(obj.get("value"), dict):
            yield path, obj.get("mode"), obj.get("value")
            return
        for k, v in obj.items():
            yield from _leaves(v, path + (str(k),))
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            yield from _leaves(v, path + (str(i),))


def _truthy(v):
    if isinstance(v, dict):
        v = v.get("value")
    return v is True or (isinstance(v, str) and v.strip().lower() == "true")


class Graph:
    def __init__(self, bpmn):
        root = ET.fromstring(bpmn)
        proc = root.find(f"{{{BPMN_NS}}}process")
        self.nodes, self.parent, self.outgoing, self.flows = {}, {}, {}, {}
        self.top = proc
        self._walk(proc, None)

    def _walk(self, el, parent_id):
        for child in el:
            tag = child.tag.split("}")[-1]
            cid = child.get("id")
            if tag == "sequenceFlow":
                self.flows[cid] = (child.get("sourceRef"), child.get("targetRef"))
            elif tag in FLOW_NODE_TAGS:
                self.nodes[cid] = (tag, child.get("name"))
                self.parent[cid] = parent_id
                self.outgoing[cid] = [o.text.strip() for o in child.findall(f"{{{BPMN_NS}}}outgoing")
                                      if o.text]
                if tag == "subProcess":
                    self._walk(child, cid)

    def target(self, flow_id):
        return self.flows.get(flow_id, (None, None))[1]

    def targets(self, node_id):
        return [self.target(f) for f in self.outgoing.get(node_id, [])]

    def ancestors(self, node_id):
        p = self.parent.get(node_id)
        while p:
            yield p
            p = self.parent.get(p)

    def descendants(self, node_id):
        return [n for n in self.nodes if node_id in set(self.ancestors(n))]


# ---------------------------------------------------------------- review

def review(export, path, disabled, import_check=True, pipeline=()):
    out = []

    def add(rule, sev, where, msg, fix):
        if rule not in disabled:
            out.append(Finding(rule, sev, where, msg, fix))

    p = _process(export)
    source = p.get("_source", "export")
    if source != "export":
        import_check = False
    name = p.get("Name") or os.path.basename(path)
    is_sub = bool(p.get("IsSubprocess"))
    is_pipeline = bool(PIPELINE_NAME.search(name)) or name in pipeline
    ep = _json_field(p, "ElementParameters", [])
    by_id = {e.get("Id"): e for e in ep}
    try:
        g = Graph(p["Bpmn"])
    except (ET.ParseError, KeyError) as e:
        add("IMP-05", "blocker", name, f"Bpmn missing or not well-formed: {e}", "re-export the Process")
        return name, out

    def etype(nid):
        return (by_id.get(nid) or {}).get("Type")

    def label(nid):
        n = g.nodes.get(nid, ("", None))[1] or (by_id.get(nid) or {}).get("Name")
        return f"'{n}' ({nid})" if n else nid

    # ---- IMP-05: the generator's structural validator
    if import_check:
        gen = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..",
                                            "frends-ipaas-developer", "scripts", "generate_process.py"))
        if os.path.exists(gen):
            try:
                spec = importlib.util.spec_from_file_location("frends_generate_process", gen)
                mod = importlib.util.module_from_spec(spec)
                spec.loader.exec_module(mod)
                ok, msgs = mod.validate(export)
                for m in msgs:
                    if m.startswith("ERROR"):
                        add("IMP-05", "blocker", name, m[7:], "fix before import; see generation-checklist.md")
            except Exception as e:  # validator unavailable: note, do not fail the review
                add("IMP-05", "info", name, f"structural validator not run: {e}", "run generate_process.py --validate")

    # ---- IMP-04: unique names
    seen = {}
    for nid, (tag, nm) in g.nodes.items():
        nm = nm or (by_id.get(nid) or {}).get("Name")
        if nm:
            seen.setdefault(nm.strip(), []).append(nid)
    for nm, ids in seen.items():
        if len(ids) < 2:
            continue
        # Duplicate names on Returns and Throws occur in public templates that import through the
        # template path; duplicates on activities, gateways and scopes fail a Process import.
        events_only = all(g.nodes[i][0] in ("endEvent", "intermediateThrowEvent") for i in ids)
        if events_only:
            add("IMP-04", "minor", f"'{nm}'", f"Return or Throw name used {len(ids)} times: {', '.join(ids)}",
                "qualify each instance; confirm by importing as a Process")
        else:
            add("IMP-04", "blocker", f"'{nm}'", f"shape name used {len(ids)} times: {', '.join(ids)}",
                "qualify each instance with what it handles")

    # ---- scopes with a catch: IMP-01..03, ERR-01, ERR-04
    hook = by_id.get("globalErrorHandler")
    catches = [n for n in g.nodes if etype(n) == T_CATCH]
    for scope in [n for n in g.nodes if g.nodes[n][0] == "subProcess"]:
        tg = g.targets(scope)
        catch_ids = [t for t in tg if t in catches]
        if not catch_ids:
            continue
        c = catch_ids[0]
        if len(tg) != 2:
            add("IMP-01", "blocker", label(scope), f"caught scope has {len(tg)} outgoing flows; exactly 2 required",
                "one flow to the Catch, one to the end shape")
        elif tg[0] != c:
            add("IMP-01", "blocker", label(scope), "flow to the Catch is not listed first",
                "emit the <outgoing> to the Catch before the one to the end shape")
        other = [t for t in tg if t != c]
        succ = g.targets(c)
        if len(succ) != 1:
            add("IMP-02", "blocker", label(c), f"Catch has {len(succ)} outgoing flows; exactly 1 required",
                "wrap the handler shapes in one Scope")
        else:
            n = succ[0]
            nt = g.targets(n)
            if len(nt) != 1 or (other and nt[0] != other[0]):
                add("IMP-02", "blocker", label(n),
                    "catch branch does not reach the scope's own end shape in one hop",
                    "put every handler shape inside one Scope that flows to the scope's end shape")
            # ERR-01: does the catch branch fail the run?
            in_catch = [n] + (g.descendants(n) if g.nodes.get(n, ("",))[0] == "subProcess" else [])
            throws = [x for x in in_catch if etype(x) == T_THROW]
            loop = next((a for a in g.ancestors(scope) if etype(a) in LOOP_TYPES), None)
            if not throws and is_pipeline:
                pass  # the error pipeline must never throw
            elif not throws:
                if loop:
                    top_throw = any(etype(x) == T_THROW and g.parent.get(x) is None for x in g.nodes)
                    if not top_throw:
                        add("ERR-01", "major", label(c),
                            "per-entity catch continues the loop, but no Throw after the loop fails the run",
                            "record failures in a #var; after the loop, Throw when any entity failed")
                else:
                    add("ERR-01", "major", label(c),
                        "catch branch ends without a Throw: the handled failure is recorded as a successful run",
                        "end the catch Scope in a Throw after calling the handler")
            elif hook:
                calls = any(etype(x) == T_CALL for x in in_catch)
                for t in throws:
                    if calls and not _truthy(((by_id.get(t) or {}).get("Parameters") or {}).get("bypassGlobalExceptionHandler")):
                        add("ERR-04", "minor", label(t),
                            "Throw after the handler call without bypassGlobalExceptionHandler: the hook reports the failure again",
                            "set bypassGlobalExceptionHandler = true on this Throw")
        if other:
            ot = g.nodes.get(other[0], ("",))[0]
            if ot not in ("endEvent", "intermediateThrowEvent"):
                add("IMP-03", "blocker", label(scope), f"caught scope flows to a {ot}; nothing may branch after it",
                    "move the decision inside the scope or before it")

    # ---- ERR-05: unhandled-error hook
    if is_pipeline and hook:
        add("ERR-06", "major", name, "error-pipeline Process has an unhandled-error hook: a failure here can loop",
            "leave the hook empty on the shared handler and the error-event listener")
    if not is_sub and not hook and not is_pipeline:
        add("ERR-05", "major", name, "no Subprocess set for unhandled errors",
            "set the shared error handler as the unhandled-error hook (leave empty only on the handler and the error listener)")

    # ---- ERR-02 / ERR-03: status vs end shape
    for e in ep:
        hr = ((e.get("Parameters") or {}).get("httpResult") or {})
        code = (hr.get("httpStatusCode") or {}).get("value") if isinstance(hr, dict) else None
        try:
            code = int(code)
        except (TypeError, ValueError):
            continue
        if e.get("Type") == T_THROW and 400 <= code < 500:
            add("ERR-02", "major", label(e["Id"]), f"answers {code} through a Throw: a validated and answered request is recorded as failed",
                "end the rejection branch in a Return with the error envelope")
        if e.get("Type") == T_RETURN and code >= 500:
            add("ERR-03", "major", label(e["Id"]), f"answers {code} through a Return: the failure is hidden from monitoring",
                "end this path in a Throw")

    # ---- per-shape checks
    exec_count = 0
    promoted = _json_field(p, "PromotedResultVariablesJson", [])
    any_promote = bool(promoted) or any(e.get("PromoteResultAs") for e in ep)
    for e in ep:
        t, nid, params = e.get("Type"), e.get("Id"), e.get("Parameters") or {}
        nm = e.get("Name")
        if nid in g.nodes and t not in NON_EXECUTION:
            exec_count += 1

        # NAM-03 default or missing names
        if t in (T_TASK, T_CODE, T_GATEWAY, T_CALL) and nid in g.nodes:
            gname = g.nodes[nid][1] or nm
            if not gname:
                if t != T_GATEWAY:
                    add("NAM-03", "minor", label(nid), "shape has no name; its result cannot be referenced readably",
                        "name it for what it produces")
            elif DEFAULT_NAME.match(gname.strip()):
                add("NAM-03", "minor", label(nid), "editor default name", "name it for what it produces")

        # NAM-01 / NAM-02 on called Subprocess names
        if t == T_CALL and nm:
            if BRACKETS.search(nm):
                add("NAM-01", "minor", label(nid), "called Subprocess name contains brackets",
                    "rename the Subprocess, e.g. 'Shared - Handle process error'")

        # Retry
        if e.get("ShouldRetry") is True:
            opts = params.get("options") if isinstance(params, dict) else None
            if isinstance(opts, dict) and "ThrowExceptionOnErrorResponse" in opts \
                    and not _truthy(opts["ThrowExceptionOnErrorResponse"]):
                add("RTY-01", "major", label(nid), "retry enabled but the Task returns failures as results: retry never fires",
                    "set options.ThrowExceptionOnErrorResponse = true, or use the retry wrapper")
            mrc = e.get("MaxRetryCount")
            if isinstance(mrc, int) and mrc > 5:
                add("RTY-02", "minor", label(nid), f"MaxRetryCount {mrc}; default is 5",
                    "state the reason in the design or lower it")
            for pth, mode, val in _leaves(params):
                if pth and pth[-1].lower() == "method" and str(val).upper() == "POST":
                    add("RTY-03", "minor", label(nid), "retry on a POST", "confirm the call is idempotent or has duplicate protection")

        # While
        if t == T_WHILE:
            mi = params.get("maxIterations")
            if not mi:
                add("LOOP-01", "major", label(nid), "While without maxIterations", "set it from the design")
            elif str((mi or {}).get("value")) == "1000":
                add("LOOP-01", "info", label(nid), "maxIterations is 1000, the usual default",
                    "confirm it is derived from the design")

        # Call Subprocess in a loop
        if t == T_CALL and nid in g.nodes and any(etype(a) in LOOP_TYPES for a in g.ancestors(nid)):
            add("LOOP-02", "minor", label(nid), "Subprocess called inside a loop: serialisation cost per iteration",
                "keep it only if the Subprocess does substantial work; otherwise inline it")

        # Code Task content
        if t == T_CODE:
            code = str(((params.get("variableExpression") or {}).get("value")) or "")
            if ENDLESS.search(code):
                add("LOOP-04", "major", label(nid), "endless loop construct in a Code Task",
                    "loop in shapes, or add an explicit bound")
            lines = code.count("\n") + 1 if code else 0
            if lines > 40:
                add("STR-02", "info", label(nid), f"Code Task of {lines} lines", "split into shapes with one action each")

        # Security and SQL on every leaf
        skip_log = _truthy(e.get("ShouldNotLogResult"))
        for pth, mode, val in _leaves(params):
            if not isinstance(val, str):
                continue
            key = pth[-1] if pth else ""
            joined = "/".join(pth)
            for grp, var in ENV_REF.findall(val):
                if SECRET_NAME.search(var) or SECRET_NAME.search(grp + var):
                    if URL_KEY.search(key):
                        add("SEC-01", "major", f"{label(nid)} {joined}", f"secret-like #env.{grp}.{var} in a URL field",
                            "move it to a header or a secret field; never in a URL")
                    elif not SECRET_FIELD.search(key) and not skip_log:
                        add("SEC-03", "minor", f"{label(nid)} {joined}",
                            f"secret-like #env.{grp}.{var} in an ordinary field of a logged shape",
                            "use the Task's secret field, or enable Skip logging result and parameters")
            if "#env" not in val and "{{" not in val:
                for rx in HARDCODED:
                    if rx.search(val):
                        add("SEC-02", "blocker", f"{label(nid)} {joined}", "hard-coded credential",
                            "move the value to a secret Environment Variable")
                        break
            if SQL_KEY.search(key):
                if re.search(r"\{\{[^}]*#trigger|\+\s*#trigger", val):
                    add("SEC-04", "major", f"{label(nid)} {joined}", "trigger input concatenated into SQL text",
                        "use the Task's query parameters")
                elif re.search(r"\{\{\s*#(var|result)|\+\s*#(var|result)", val):
                    add("SEC-04", "minor", f"{label(nid)} {joined}", "variable concatenated into SQL text",
                        "confirm the value never comes from a caller; otherwise use query parameters")

    # ---- Inclusive gateway
    for nid, (tag, _) in g.nodes.items():
        if tag == "inclusiveGateway":
            add("LOOP-03", "info", label(nid), "Inclusive Decision runs its branches serially",
                "do not rely on it for parallelism")

    # ---- size
    if exec_count > 50:
        add("STR-01", "minor", name, f"{exec_count} execution shapes", "split along a narrow interface")

    # ---- logging
    if not any_promote:
        add("LOG-01", "minor", name, "no promoted values",
            "promote the correlation id and the primary business key")
    if "correlationid" not in json.dumps(ep).lower():
        add("LOG-02", "minor", name, "no correlation id in the Process",
            "create it at the entry point, pass it on, promote it")

    # ---- naming of the Process itself
    if BRACKETS.search(name) and not name.startswith("/"):
        add("NAM-01", "minor", name, "Process name contains brackets", "e.g. 'Shared - Handle process error'")
    if ENV_TOKEN.search(name):
        add("NAM-02", "minor", name, "Process name carries an environment token", "remove it")

    # ---- documentation (an MCP result carries no description or tags)
    desc = (p.get("Description") or "").strip()
    if source == "mcp":
        add("DOC-01", "info", name, "description and tags not in the MCP result",
            "check them in the Control Panel or review an API export")
    elif not desc:
        add("DOC-01", "minor", name, "empty description", "state purpose, interface id and specification version")
    elif TRAILING_VERSION.match(desc):
        add("DOC-01", "minor", name, f"description is the OpenAPI title and version ('{desc}')",
            "replace it with a one-line purpose; keep the version as a footnote")
    if source != "mcp" and not p.get("Tags") and not (p.get("TagString") or "").strip():
        add("DOC-02", "info", name, "no tags", "one tag per external system")

    # ---- embedded OpenAPI document
    for e in ep:
        if e.get("Type") != T_START:
            continue
        doc = (e.get("Parameters") or {}).get("openApiDocument")
        if isinstance(doc, dict):
            doc = doc.get("value")
        if not isinstance(doc, str) or not doc.strip():
            continue
        where = f"{label(e['Id'])} openApiDocument"
        if re.search(r"\b(allOf|oneOf|anyOf)\b", doc):
            add("API-02", "blocker", where, "schema composition (allOf/oneOf/anyOf)",
                "flatten into standalone schemas with literal properties")
        if re.search(r"(?m)(:\s*|^\s*-\s*)&[A-Za-z0-9_-]+\s*$", doc) or re.search(r"(?m):\s*\*[A-Za-z0-9_-]+\s*$", doc):
            add("API-03", "blocker", where, "YAML anchor or alias", "expand the aliased nodes")
        if re.search(r"""(?m)^\s*["']?default["']?\s*:""", doc):
            add("API-04", "minor", where, "'default' response", "enumerate concrete status codes")
        ops = None
        try:
            spec = json.loads(doc)
        except json.JSONDecodeError:
            try:
                import yaml  # optional
                spec = yaml.safe_load(doc)
            except Exception:
                spec = None
        if isinstance(spec, dict) and isinstance(spec.get("paths"), dict):
            methods = {"get", "put", "post", "delete", "patch", "head", "options"}
            ops = sum(1 for v in spec["paths"].values() if isinstance(v, dict) for m in v if m.lower() in methods)
            if ops > 1:
                add("API-01", "blocker", where, f"embedded document has {ops} operations; exactly 1 required",
                    "narrow paths to this Process's path and method")
        elif ops is None:
            add("API-01", "info", where, "embedded document not parsed", "check by hand: one path, one method")

    out.sort(key=lambda f: (SEVERITY_ORDER[f.severity], f.rule))
    return name, out


def _markdown(results):
    lines = []
    for path, name, findings in results:
        counts = {s: sum(1 for f in findings if f.severity == s) for s in SEVERITY_ORDER}
        lines.append(f"## {name}")
        lines.append(f"`{path}`: {counts['blocker']} blocker, {counts['major']} major, "
                     f"{counts['minor']} minor, {counts['info']} info")
        lines.append("")
        if not findings:
            lines.append("No automatic findings. Manual rules still apply.")
        else:
            lines.append("| Rule | Severity | Where | Finding | Fix |")
            lines.append("| --- | --- | --- | --- | --- |")
            for f in findings:
                cells = [f.rule, f.severity, f.where, f.message, f.fix]
                lines.append("| " + " | ".join(str(c).replace("|", "\\|") for c in cells) + " |")
        lines.append("")
    return "\n".join(lines)


def main(argv=None):
    ap = argparse.ArgumentParser(description="Review Frends Process exports against the frends-reviewer rules.")
    ap.add_argument("files", nargs="+", help="Process export JSON files")
    ap.add_argument("--format", choices=["md", "json"], default="md")
    ap.add_argument("--disable", default="", help="comma-separated rule ids to skip")
    ap.add_argument("--pipeline", action="append", default=[],
                    help="Process name to treat as error pipeline (repeatable); names matching "
                         "'handle process error', 'generic error handler', 'error event listener' and 'notify error events' are recognised already")
    ap.add_argument("--no-import-check", action="store_true", help="skip the generator's structural validator")
    args = ap.parse_args(argv)
    disabled = {r.strip() for r in args.disable.split(",") if r.strip()}

    results, worst = [], 3
    for path in args.files:
        if path.lower().endswith(".bpmn"):
            print(f"{path}: BPMN-only export carries no ElementParameters; export the JSON for a full review",
                  file=sys.stderr)
            continue
        try:
            name, findings = review(_load(path), path, disabled, not args.no_import_check, tuple(args.pipeline))
        except (OSError, ValueError, json.JSONDecodeError) as e:
            print(f"{path}: {e}", file=sys.stderr)
            continue
        results.append((path, name, findings))
        for f in findings:
            worst = min(worst, SEVERITY_ORDER[f.severity])

    if args.format == "json":
        print(json.dumps([{"file": p, "process": n, "findings": [f.as_dict() for f in fs]}
                          for p, n, fs in results], indent=2, ensure_ascii=False))
    else:
        print(_markdown(results))
    return 2 if worst == 0 else 1 if worst == 1 else 0


if __name__ == "__main__":
    raise SystemExit(main())
