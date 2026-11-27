# Certificates

Category: concept · Baseline: Frends 6.4.0 (docs; not yet exercised on a tenant)

## Purpose
From 6.4, Frends manages certificates per [Agent Group](agent-and-agent-group.md). A certificate is
uploaded once and installed on every Agent in the group, so a Process no longer needs a certificate
pasted into an Environment Variable or installed by hand on each Agent host.

## Key facts
- Three kinds (docs):
  - HTTPS server certificates. Several can be active per Agent Group; the Agent picks one by SNI
    host name.
  - Client certificates, for calls to partner systems that require mutual TLS.
  - Issuer certificates, which HTTP Triggers use to authenticate callers by client certificate.
    The Agent picks up a new issuer certificate without a restart.
- Upload goes through the Frends Platform API. The companion's scripts do not cover these
  operations yet: check the tenant's OpenAPI document with `scripts/check_api_drift.py` first.
- ACME ordering from Let's Encrypt, ZeroSSL or any ACME directory, with the `http-01`, `dns-01` and
  `dns-persist-01` challenges (wildcards with the DNS challenges). Renewal is automatic at two
  thirds of the validity period for `http-01` and `dns-persist-01`.
- Private keys and ACME account keys can be encrypted at rest with a key-encryption certificate
  that you supply.
- Certificates reach Agents on 6.4 or newer only, including Agents that join the group later.
- An issuer certificate for a private CA no longer has to be installed on the Agent servers.
- A certificate cannot be deleted while a deployed Process still uses it.
- An ACME certificate can be revoked at the CA. The status of each certificate on each Agent is
  reported in the Web Portal.
- A new HTTPS server certificate takes effect without restarting the Agent.

## Expressions and references
A Process, a Trigger or a Process Variable refers to a managed client certificate as
`#cert.<name>.<property>`, for example `#cert.partnerapi.thumbprint` (docs). Confirm the available
properties in the editor's auto-complete before relying on one; the release notes name only
`thumbprint`. The editor and the deployment both check the reference, so a misspelt name or a
certificate missing from the target Agent Group stops the deployment rather than failing at run
time.

## Conventions
- Name a certificate after the partner or system it serves (`partnerapi`), like an Environment
  Variable group.
- Prefer a managed certificate over a certificate or its password in an Environment Variable.

## Source of truth
- `https://docs.frends.com/release-notes/frends-6.4/version-6.4.0.md`
- `https://docs.frends.com/release-notes/frends-6.4/new-features.md`
