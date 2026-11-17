# 0006. Converge on a single message broker

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-10-02

## Status

Proposed

## Decision Outcome

Evaluate converging realm messaging on fewer brokers. Today the landscape runs RabbitMQ, NATS JetStream, Apache Kafka, Azure Service Bus and Azure Event Grid.

## Context

Five broker technologies are used across seven systems; the radar twin findings highlight the overlap.

## Decision Drivers

- Operational cost
- Skills overlap
- Fit for each workload

## Considered Options

### Option A: Do nothing
Zero migration, maximum diversity.

### Option B: Kafka for streams, Service Bus for commands
Two technologies.

### Option C: Single broker
Simplest, does not fit every workload.

## Decision Rationale

Proposed for discussion with the architecture board.

## Consequences

Migration effort for Tartarus Styx and Lethe River if accepted.
