# 0001. Use Harp (Kafka) as the event backbone

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-01-20

## Status

Accepted

## Decision Outcome

Every domain event of Elysium flows through Harp, an Apache Kafka cluster. Feed Service writes, Muses and Ambrosia Search read.

## Context

Feed updates, recommendations and search indexing all need the same ordered stream, replayable when a consumer is rebuilt.

## Decision Drivers

- Replayable ordered log
- High throughput
- Multiple independent consumers

## Considered Options

### Option A: Queue per consumer
Duplicates publishing logic, no replay.

### Option B: Apache Kafka (chosen)
Log semantics and consumer groups.

## Decision Rationale

Replay is the deciding factor: rebuilding the search index must not require producers to re-send.

## Consequences

Operational cost of Kafka, partition design and schema governance.
