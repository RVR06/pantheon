# 0007. Use Spark Thrift with JDBC for BI tools

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-06-03

## Status

Rejected

## Decision Outcome

Do not expose Reaper through a Spark Thrift server for external BI tools.

## Context

A request asked for direct JDBC access to Spark.

## Decision Drivers

- Security
- Cost control
- Stability

## Considered Options

### Option A: Thrift server
Convenient, hard to govern.

### Option B: Serve from Warehouse only (chosen)
Governed and fast.

## Decision Rationale

Direct Spark access would bypass curated tables and risk expensive queries.

## Consequences

BI tools need Warehouse access; JDBC stays for controlled internal use.
