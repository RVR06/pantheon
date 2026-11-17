# 0002. Use Hermes (Azure Service Bus) for asynchronous work

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-02-18

## Status

Accepted

## Decision Outcome

Athena Planner publishes plan requests to Hermes; Forge Worker consumes them. Hermes is Azure Service Bus with topics for fan-out and queues for work items.

## Context

Planning can take minutes and must not hold an HTTP request. The Forge Worker needs retries, dead-lettering and scheduled delivery.

## Decision Drivers

- Reliable delivery with dead-letter queues
- Native sessions and scheduled messages
- Managed service, no broker to patch

## Considered Options

### Option A: Synchronous HTTP
Rejected: long calls time out and cannot be retried safely.

### Option B: Azure Service Bus (chosen)
Topics, sessions, dead-lettering, managed.

### Option C: Self-hosted RabbitMQ
Cheaper to run locally but needs operation and patching.

## Decision Rationale

Service Bus gives the delivery guarantees out of the box and fits the Azure footprint already used by Olympus.

## Consequences

Lock-in to Azure messaging semantics; local development needs an emulator or a real namespace.
