---
title: "Central Package Management (.NET)"
ring: "trial"
quadrant: "tools-and-patterns"
tags: [dotnet, tooling]
---

Central Package Management (CPM) is a built-in MSBuild feature that lets a solution pin every NuGet package version in one `Directory.Packages.props` file, with each project's `PackageReference` entries dropping their own `Version=` attribute.

We adopted it for the Tartarus spike alongside a shared `Directory.Build.props` (for common `TargetFramework`/`ImplicitUsings`/`Nullable` settings) once the solution grew to five projects sharing several of the same packages (Aspire integrations, OpenTelemetry instrumentation).

## Context

With five projects, several packages (`Aspire.RabbitMQ.Client`, `Aspire.Npgsql`, the OpenTelemetry instrumentation set) were referenced from more than one `.csproj`, each with its own explicit version string and no guarantee they'd stay aligned. See [ADR-0005](../../../_archi/adrs/0005-centralize-net-build-configuration-with-directory-build-and-packages-props.md) for the full decision record.

## Assessment

CPM and `Directory.Build.props` are both first-class, SDK-native MSBuild features requiring no additional tooling or NuGet packages — the migration was a pure refactor (moving `Version=` attributes into one file) with zero resolved-version changes, verified by a clean rebuild. For a solution this size, the benefit (one file to bump a version) was immediately tangible; the main cost is one extra file to open when checking what version a given package resolves to.

## Recommendation

The pattern sits in trial: it solved the specific version-drift risk this spike hit, with a low, one-time migration cost and no observed downside at this solution size. Worth adopting by default in any future multi-project Aspire spike from the start, rather than retrofitting it once drift risk has already appeared.

## Next Steps

- Default new multi-project spikes to scaffolding `Directory.Build.props`/`Directory.Packages.props` from the first commit, rather than retrofitting later
