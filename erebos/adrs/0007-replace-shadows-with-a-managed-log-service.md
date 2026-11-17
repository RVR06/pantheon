# 0007. Replace Shadows with a managed log service

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-06-18

## Status

Rejected

## Decision Outcome

Keep Shadows self-hosted on Elasticsearch.

## Context

A managed log service was proposed to cut operations.

## Decision Drivers

- Operations load
- Data residency
- Cost

## Considered Options

### Option A: Managed service
Less ops, data leaves the realm.

### Option B: Keep Shadows (chosen)
Control.

## Decision Rationale

Data residency and cost outweigh the operational saving.

## Consequences

Elasticsearch operations remain with the team.
