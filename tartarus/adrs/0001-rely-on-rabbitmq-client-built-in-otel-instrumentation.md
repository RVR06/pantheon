# 0001. Rely on RabbitMQ.Client's built-in OTEL instrumentation

![](https://img.shields.io/badge/author-romain.vasseur-ef8d22)

Date: 2026-09-21

## Status

Accepted

## Decision Outcome

Use RabbitMQ.Client v7's built-in OpenTelemetry auto-instrumentation to propagate trace context across the Styx broker, rather than manually reading and writing W3C trace-context headers on publish/consume.

## Context

Charon publishes a `SoulArrival` message onto the `asphodel-meadows` queue every time an authenticated soul visits `/underworld`; Minos consumes it and judges the soul into a circle of hell. To satisfy the goal of tracing a call end-to-end — from the original HTTP request in Charon, across the broker, to the judgment logged by Minos — the trace context has to survive the hop through RabbitMQ, which is normally an explicit, easy-to-get-wrong plumbing concern (message headers must be written on publish and read back on consume, and the consumer's span must be parented correctly).

## Decision Drivers

- The distributed trace must show one continuous parent/child chain from the HTTP request in Cerberus/Charon through Charon's publish, the Styx broker, and Minos's consume/judge — not two disconnected traces.
- Spike-scope: minimize custom instrumentation code (`ServiceDefaults`/Chaos already wires ASP.NET Core, HTTP client, and runtime instrumentation via `AddServiceDefaults()`; anything RabbitMQ-specific should not require a parallel hand-rolled propagation layer).
- Must not require touching the AMQP message headers directly in either `Charon.cs` or `MinosTribunal.cs`.

## Considered Options

### Option A: Manual trace-context header propagation
Read `Activity.Current` on publish, serialize `traceparent`/`tracestate` into `BasicProperties.Headers`, then extract and restore them as the parent context when starting the consumer's span in Minos.

### Option B: RabbitMQ.Client v7 built-in OpenTelemetry instrumentation
RabbitMQ.Client v7 ships its own `ActivitySource` producing `publish` and `deliver` spans, and automatically injects/extracts W3C trace-context headers on the message when an `Activity` is active — no manual header code required.

### Option C: No distributed tracing across the broker
Treat Charon's HTTP-triggered publish and Minos's consume/judge as two independent, unlinked traces, correlating them only via log fields like `Soul`.

## Decision Rationale

Option B was chosen because RabbitMQ.Client v7 (the version already pinned via `Aspire.RabbitMQ.Client`) already implements exactly what Option A would otherwise hand-roll: it auto-creates `publish`/`deliver` spans and threads W3C trace-context headers through `BasicProperties`. Adding two small business-level spans on top (`charon.ferry-soul` as parent of the library's `publish` span, `minos.judge-soul` as child of the library's `deliver` span) gives a fully connected trace with almost no extra code, while Option A would duplicate library behavior and Option C would defeat the stated goal of tracing the call end-to-end.

## Tradeoffs

| What we gain | What we give up |
|-------------|-----------------|
| Zero manual header-plumbing code; trace correctness is the library's responsibility, not ours | Less control over the exact shape/semantics of the auto-generated `publish`/`deliver` spans (naming, tag set) |
| One continuous trace from HTTP request to judgment, visible in the Aspire dashboard / OTLP backend | Implicit coupling to RabbitMQ.Client's own instrumentation behavior — an upgrade that changes or drops it would silently break tracing |

## Consequences

### Positive
- Distributed traces for a login → ferry → judge flow are visible as a single connected trace tree without any header-serialization code.
- Business context (`underworld.soul`, `underworld.circle.number/name`) rides alongside the library's own transport-level spans as tags on `charon.ferry-soul` / `minos.judge-soul`.

### Negative
- No fallback path exists if a future RabbitMQ.Client version changes its instrumentation defaults — would need to be re-verified on upgrade.

### Neutral
- Both `Charon.cs` and `MinosTribunal.cs` still each declare their own `ActivitySource` for the extra business span; this is intentional and unrelated to the propagation mechanism itself.

## Related Decisions

- [ADR-0002](./0002-persist-underworld-circles.md) — the circles judged against in `minos.judge-soul` come from Mnemosyne, not a hardcoded array.
