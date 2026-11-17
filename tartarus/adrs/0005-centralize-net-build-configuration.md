# 0005. Centralize .NET build configuration

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-21

## Status

Accepted

## Decision Outcome

Introduce a root `Directory.Build.props` (shared `TargetFramework`, `ImplicitUsings`, `Nullable`) and a root `Directory.Packages.props` with Central Package Management (`ManagePackageVersionsCentrally=true`) so every `.csproj` references packages by name only, with versions pinned in exactly one place.

## Context

With five projects (Hades, Charon, Cerberus, Minos, and the shared library), each `.csproj` independently declared `<TargetFramework>`, `<ImplicitUsings>`, `<Nullable>`, and explicit `Version=` attributes on every `PackageReference` — including packages shared across multiple projects (`Aspire.RabbitMQ.Client`, `Aspire.Npgsql`, the OpenTelemetry instrumentation packages in the shared library). Nothing enforced that two projects referencing the same package used the same version, and every new project had to repeat the same boilerplate `PropertyGroup`.

## Decision Drivers

- A single version bump (e.g. an Aspire integration patch release) must only require editing one file, not grep-and-replace across five `.csproj` files.
- New projects added to the solution should not need to repeat `TargetFramework`/`ImplicitUsings`/`Nullable` boilerplate.
- Must not change any resolved package version or behavior — this is a build-configuration refactor, not a dependency upgrade.

## Considered Options

### Option A: Leave per-project configuration as-is
No new files; every `.csproj` keeps its own `PropertyGroup` and explicit `PackageReference Version=` values. Zero migration effort, but the duplication (and version-drift risk) identified above remains unaddressed.

### Option B: `Directory.Build.props` + `Directory.Packages.props` (MSBuild Central Package Management)
Move shared `PropertyGroup` settings to `Directory.Build.props` (implicitly imported by every project in and under the repo root) and all package versions to `Directory.Packages.props` via `<PackageVersion>` entries, with `ManagePackageVersionsCentrally=true`; each `.csproj`'s `PackageReference` elements drop their `Version=` attribute.

### Option C: A custom MSBuild `.props` per project category
Introduce category-specific shared props files (e.g. one for "Aspire integration" projects, one for "ASP.NET" projects) instead of a single root file. More granular, but over-engineered for a five-project spike where all projects share the same `TargetFramework`.

## Decision Rationale

Option B was chosen as the standard, first-class MSBuild mechanism for exactly this problem (both `Directory.Build.props` auto-import and Central Package Management are built into the SDK, requiring no custom tooling), fully satisfying the "one place to bump a version" driver without the added complexity Option C would introduce for a solution this size. Option A was rejected because it leaves the duplication/version-drift risk that motivated this decision unaddressed.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| One file (`Directory.Packages.props`) is the single source of truth for every package version in the solution | An extra layer of indirection when reading a single `.csproj` in isolation — the version isn't visible without also opening `Directory.Packages.props` |
| New projects inherit `TargetFramework`/`ImplicitUsings`/`Nullable` automatically from `Directory.Build.props` | Any project that legitimately needs a different `TargetFramework` must explicitly override it, rather than it being self-evident in its own file |

## Consequences

### Positive
- All five `.csproj` files now list bare `<PackageReference Include="..." />` elements with no version drift possible between projects sharing a package.
- Adding a sixth project to the solution requires zero `TargetFramework`/`Nullable` boilerplate.

### Negative
- None observed at this solution size; the indirection cost noted above is the only real downside and is standard/expected for CPM-managed solutions.

### Neutral
- No package versions changed as part of this migration — purely a structural refactor, verified by a clean `dotnet build` afterward.

## Related Decisions

- None — this decision is orthogonal to the naming/persistence/messaging decisions above; it's a pure build-tooling change.
