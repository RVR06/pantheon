# 0012. Track the committed chart at Aspire's own output path

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-21

## Status

Accepted

## Decision Outcome

Move the hand-authored, version-controlled Helm chart (`Chart.yaml`, `values.yaml`, `values.xxx.yaml`, and every `templates/<resource>/*.yaml`, including the three hand-authored `ingressroute.yaml` files from ADR-0011) from a repo-root `_helm/` folder - reached only via an explicit scratch `aspire publish -o ../_helm` run used purely for verification - to `Hades/aspire-output`, the exact directory `aspire publish`/`aspire deploy` write to by default when invoked with no `-o`/`--output-path` flag from inside `Hades/`. `.gitignore`'s former blanket `**/aspire-output` pattern is narrowed to `**/aspire-output/values.*.yaml` with `!Hades/aspire-output/values.xxx.yaml` as an explicit exception, so every file in the chart stays tracked except the one file that holds fully-resolved parameter values (and, for `aspire deploy` specifically, freshly-built image tags and plaintext secrets): `values.<kubernetes-environment-resource-name>.yaml` (here, `values.tartarus.yaml`, named after `AddKubernetesEnvironment("tartarus")`).

## Context

A real `aspire deploy` run from the deployer's own clone - with no scratch flags, run exactly as documented - silently reused ingress hostnames/entry-point/cert-resolver/middleware values from an entirely unrelated, throwaway verification session, and never deployed any of the three `IngressRoute` manifests ADR-0011 describes, even though they were present and correct in the repo.

Root cause was two compounding issues, both a direct consequence of `_helm/` and `Hades/aspire-output` being two separate, disconnected directories:

1. **Stale deployment-state leakage.** Earlier scratch verification runs (`aspire publish -o ../_helm` with throwaway `$env:Parameters__*` values, used to confirm ADR-0011's chart changes render correctly) also wrote a `values.tartarus.yaml` deployment-state file into `Hades/aspire-output` as a side effect - *even though* `-o` pointed the actual chart output elsewhere. Because `Hades/aspire-output` was blanket-gitignored, this leftover file was invisible to `git status` and never cleaned up. The deployer's subsequent real `aspire deploy` run (no scratch flags) found this file already sitting at its own default output path and reused its throwaway values instead of prompting for real ones.
2. **Structural output-directory mismatch.** `aspire publish`/`aspire deploy` write to `<AppHost-dir>/aspire-output` by default. The committed chart carrying ADR-0011's hand-authored `IngressRoute` templates lived only at the repo-root `_helm/`, a path no un-flagged Aspire CLI invocation ever reads from or writes to. The deployer's real deploy run regenerated a chart at `Hades/aspire-output` from scratch, inheriting none of `_helm/`'s hand-authored extras - so the `IngressRoute` manifests were never part of what got deployed, regardless of the deployment-state issue above.

Either issue alone would have caused a failure class like this; together they fully explain the deployer's reported symptoms (wrong ingress values applied, IngressRoutes missing, no new-parameter prompts).

## Decision Drivers

- `aspire publish`/`aspire deploy`, run exactly as documented (no `-o` flag), must operate on the same tracked directory that carries the chart's hand-authored extras - there must be only one directory, not two kept manually in sync.
- The deployment-state/resolved-parameter file (`values.<environment>.yaml`) holds plaintext secrets and must never be committed, even once its containing directory is otherwise tracked.
- Verified in ADR-0011 that `aspire publish`/`aspire deploy` only ever (re)write their own known per-resource filenames inside each `templates/<resource>/` folder, leaving any other file (like a hand-authored `ingressroute.yaml`) untouched across regenerations - this property must continue to hold at the new location, since it's the entire reason hand-authoring extra files inside the chart is viable at all.

## Considered Options

### Option A: Keep `_helm/` as the tracked chart, document "always pass `-o ../_helm`" as a required deploy step
Rejected: this is exactly the convention that already failed once, silently, with no error - it depends entirely on every deployer (now and in the future) remembering an undocumented-at-the-CLI-level flag, with no guard rail if they forget. The whole point of `aspire deploy`'s parameter-prompt mechanism is that a plain, flagless run is supposed to be correct and complete.

### Option B: Track `Hades/aspire-output` directly, carve out only the resolved-state file via `.gitignore` (chosen)
A plain `aspire publish`/`aspire deploy` run (no flags) now reads and writes the same tracked directory the hand-authored `IngressRoute` templates live in, by construction - there is no second path to remember, pass, or drift out of sync. The one thing that must stay untracked - the fully-resolved, secret-bearing `values.<environment>.yaml` - is excluded by an explicit, narrow `.gitignore` pattern instead of a directory-wide blanket exclusion, so nothing else in the chart is accidentally hidden from `git status` again.

## Decision Rationale

Option B removes the dual-directory disconnect at its root: there is now exactly one chart directory, it is Aspire's own default, and the only thing excluded from version control is the one file that is genuinely sensitive (and was already understood to be sensitive even under the old `_helm/` convention - it just happened to live somewhere `git status` couldn't see it).

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| A plain, flagless `aspire publish`/`aspire deploy` run operates on the same tracked chart that carries the hand-authored `IngressRoute` extras - no separate `-o` convention to remember or document | A directory historically treated as pure generated/ephemeral output (`aspire-output`, gitignored by the Aspire project template convention) is now partially version-controlled, which may look unusual to anyone expecting the whole folder to be disposable |
| `.gitignore` now excludes only the one genuinely sensitive file (`values.<environment>.yaml`), instead of an entire directory - future stray files left behind by a scratch run are visible to `git status` again, not silently hidden | A deployer must remember that *most* of `Hades/aspire-output` is tracked and reviewable, but the resolved-state `values.*.yaml` file (other than the explicitly-excepted `values.xxx.yaml` manual-install example) is not - a subtler rule than "the whole folder is generated, ignore it" |

## Consequences

### Positive
- A fresh `aspire publish` run with no `-o` flag and no parameter overrides, executed from `Hades/`, was confirmed to write in place to `Hades/aspire-output`, leave `values.yaml` at its usual blank-placeholder defaults, and leave all three hand-authored `ingressroute.yaml` files untouched; `helm lint` and a `helm template --set ...` render of `templates/hecate/ingressroute.yaml` both passed against the regenerated chart at its new location.
- The stray `values.tartarus.yaml` deployment-state file left behind by this session's own earlier scratch verification was deleted, and the equivalent contamination found in the deployer's per-machine global deployment-state cache (`%USERPROFILE%\.aspire\deployments\<hash>\production.json`) - the throwaway `ingress-hostname-*`/`ingress-entry-point`/`ingress-cert-resolver`/`ingress-middleware-*` entries, plus two unrelated orphaned keys (`experiment-hostname`, `ingress-oauth2-proxy-middleware`) left over from an earlier parameter design - was removed by hand, leaving only the legitimate, already-in-production values (passwords, registry endpoint/repository, namespace, Helm release name) in place.

### Negative
- The live cluster's `production` Helm release, deployed while the deployment-state cache was still contaminated, remains in a broken state (Hecate and the dashboard pods crash-looping on bad/empty config) until the next `aspire deploy` run, which will now prompt properly for the real ingress parameter values and redeploy correctly.
- Nothing prevents a future scratch/verification run from leaving another untracked stray file behind at this same default path; this decision makes such a leftover visible to `git status` again (it previously was not, under the old blanket-ignore), but does not prevent it from happening in the first place.

### Neutral
- `Hades/aspire-output/values.xxx.yaml` (the ADR-0008 manual-install example overlay) keeps its own explicit `.gitignore` exception, unaffected by this decision beyond its path changing alongside the rest of the chart.

## Related Decisions

- [ADR-0008](./0008-configure-the-kubernetes-container-registry.md) — established the `values.xxx.yaml`-for-manual-installs-only convention and the original `_helm/` chart location this decision relocates.
- [ADR-0011](./0011-front-hecate-cerberus-and-the-dashboard-with-traefik-ingressroutes.md) — established the hand-authored `IngressRoute` templates and the "extra files inside `templates/<resource>/` survive regeneration" property this decision depends on continuing to hold at the new location.
