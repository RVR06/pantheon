# 0002. Hold encryption keys in Vault

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-01-30

## Status

Accepted

## Decision Outcome

Vault (HashiCorp Vault) holds per-subject encryption keys; deleting the key crypto-shreds the data.

## Context

Backups and archives cannot be rewritten per erasure request.

## Decision Drivers

- Crypto-shredding
- Key access auditing
- Rotation support

## Considered Options

### Option A: Cloud KMS only
Managed but limited per-subject granularity.

### Option B: HashiCorp Vault (chosen)
Transit engine, per-subject keys.

## Decision Rationale

Per-subject keys are what makes erasure of backups possible.

## Consequences

Vault becomes critical infrastructure with strict availability needs.
