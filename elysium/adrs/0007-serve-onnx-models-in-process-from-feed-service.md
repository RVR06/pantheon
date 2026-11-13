# 0007. Serve ONNX models in-process from Feed Service

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-02

## Status

Proposed

## Decision Outcome

Run ONNX Runtime inside Feed Service for ranking instead of a separate model server.

## Context

A separate model service adds latency and another deployment to operate.

## Decision Drivers

- Low latency ranking
- Fewer moving parts
- Safe model rollout

## Considered Options

### Option A: Dedicated model server
Isolated scaling.

### Option B: In-process ONNX Runtime
Lowest latency.

## Decision Rationale

Awaiting benchmark results and a rollout plan.

## Consequences

Models ship with the service, so rollbacks tie model and code together.
