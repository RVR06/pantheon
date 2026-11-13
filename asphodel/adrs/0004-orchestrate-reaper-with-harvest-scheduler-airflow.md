# 0004. Orchestrate Reaper with Harvest Scheduler (Airflow)

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-02-23

## Status

Accepted

## Decision Outcome

Harvest Scheduler is Airflow. DAGs trigger Reaper jobs and publish lineage.

## Context

Pipelines have dependencies, retries and backfills that cron cannot express.

## Decision Drivers

- Dependency management
- Backfills
- Visibility of pipeline runs

## Considered Options

### Option A: Cron
Cheap, brittle.

### Option B: Airflow (chosen)
DAGs, retries, UI.

### Option C: Temporal
Strong workflows, but data-tool integrations are thinner.

## Decision Rationale

Airflow is the data engineering standard with ready operators for Spark.

## Consequences

Scheduler is a single point to watch; DAG code needs reviews.
