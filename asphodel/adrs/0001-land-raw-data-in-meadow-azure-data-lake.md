# 0001. Land raw data in Meadow (Azure Data Lake)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-01-12

## Status

Accepted

## Decision Outcome

Every raw dataset is ingested into Meadow, an Azure Data Lake, before any transformation.

## Context

Analytics needs the ability to reprocess history when business rules change.

## Decision Drivers

- Cheap immutable storage
- Reprocessing ability
- Decouple ingestion from transformation

## Considered Options

### Option A: Load straight into Warehouse
Loses raw history.

### Option B: Meadow first (chosen)
Keeps raw data cheaply.

## Decision Rationale

Raw landing makes every downstream pipeline replayable.

## Consequences

Storage grows continuously; retention rules are needed.
