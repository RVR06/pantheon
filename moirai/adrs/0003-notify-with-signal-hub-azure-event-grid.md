# 0003. Notify with Signal Hub (Azure Event Grid)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-03-30

## Status

Accepted

## Decision Outcome

Atropos and other components publish lifecycle events to Signal Hub, an Azure Event Grid topic.

## Context

Many consumers react to workflow completion; point-to-point wiring does not scale.

## Decision Drivers

- Push-based fan-out
- Serverless integration
- Low operation

## Considered Options

### Option A: Service Bus topics
Heavier for notifications.

### Option B: Event Grid (chosen)
Cheap, push-based.

## Decision Rationale

Event Grid fits discrete event notification; durable queues are not needed here.

## Consequences

Delivery is at-least-once without ordering guarantees.
