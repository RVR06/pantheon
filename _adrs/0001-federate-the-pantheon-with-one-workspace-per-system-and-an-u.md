# 0001. Federate the pantheon with one workspace per system and an umbrella

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-22

## Status

Accepted

## Decision Outcome

Each system owns an independent workspace.dsl (its own personas, views, deployments, styles and icons). The umbrella declares every system with a url and ingests only containers and components. No person, dynamic or deployment is imported.

## Context

A single shared model made every team wait on every other team and mixed styling decisions. Teams need autonomy over how they document their own system.

## Decision Drivers

- Team autonomy
- A consolidated landscape view
- Styles stay with the team that defines them

## Considered Options

### Option A: One monolithic workspace
Single view, constant conflicts.

### Option B: Includes of shared fragments
Shared files tie teams together.

### Option C: Federation by url (chosen)
Independent workspaces, ingestion by the umbrella.

## Decision Rationale

Federation scales with team count, and the umbrella needs no knowledge of how a team splits its files.

## Consequences

Names must match between umbrella and team workspace; remote urls are deferred (IDR 0013).
