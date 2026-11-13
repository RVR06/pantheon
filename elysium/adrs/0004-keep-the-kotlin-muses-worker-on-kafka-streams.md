# 0004. Keep the Kotlin Muses worker on Kafka Streams

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-04-14

## Status

Accepted

## Decision Outcome

Muses is a Kotlin worker built on Kafka Streams for recommendation enrichment.

## Context

Stateful stream processing with exactly-once semantics was required for recommendation scores.

## Decision Drivers

- Exactly-once semantics
- State stores close to compute
- JVM skills available

## Considered Options

### Option A: Apache Spark Structured Streaming
Powerful but heavier.

### Option B: Kafka Streams (chosen)
Library, no cluster.

## Decision Rationale

A library keeps deployment simple and aligns with Harp.

## Consequences

Rebalancing pauses; state recovery needs monitoring.
