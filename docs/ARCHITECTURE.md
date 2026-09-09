# Surplus → Served — Architecture & Repository Layout

The product constraint drives the architecture, not the other way round: **allocation must
resolve within seconds of a donation going Live** (scope §15), and the allocation and
notification paths are the two flows that cannot be allowed to silently fail.

Everything below is organised so that those two paths are short, observable, and testable
in isolation.

---

## 1. Monorepo layout

```
surplus-served/
├── design/                        # ← the design system lives at the root, not
│   ├── tokens/tokens.json         #   inside one app, because three surfaces consume it
│   └── tools/
│       ├── generate.mjs           # tokens → Dart / TS / CSS
│       └── check-contrast.mjs     # WCAG gate, runs in CI
│
├── packages/
│   ├── ss_design_system/          # Flutter: theme + components (generated tokens inside)
│   ├── web-ui/                    # Next.js: MUI theme + CSS vars (generated tokens inside)
│   └── contracts/                 # OpenAPI spec + generated TS/Dart clients — one source
│
├── apps/
│   ├── mobile/                    # Flutter — Donor + Receiver
│   ├── admin/                     # Next.js — Admin console
│   └── api/                       # NestJS — REST + WebSockets
│
├── infra/
│   ├── terraform/                 # AWS: ECS Fargate, RDS, ElastiCache, S3, CloudFront
│   └── docker/
│
└── docs/
    ├── DESIGN_SYSTEM.md
    └── ARCHITECTURE.md
```

Why a monorepo: the pickup-code contract, the donation state machine and the status
vocabulary have to be identical in three languages. One repo means one place to change them
and one CI run that proves all three still agree.

---

## 2. Flutter app — `apps/mobile`

Feature-first, with a strict dependency direction: `presentation → domain ← data`.
Nothing in `domain` imports Flutter.

```
apps/mobile/lib/
├── main.dart
├── bootstrap.dart                 # Sentry, Firebase, Drift, DI overrides
│
├── core/
│   ├── router/                    # go_router: routes, guards, deep links
│   ├── network/                   # Dio: interceptors (auth, retry, logging), error mapping
│   ├── storage/                   # Drift database + flutter_secure_storage
│   ├── location/                  # Geolocator wrapper, permission state
│   ├── notifications/             # FCM handlers, local notifications
│   ├── analytics/                 # PostHog
│   ├── error/                     # Failure types, global error boundary
│   └── l10n/                      # ARB files — en + te at parity
│
├── features/
│   ├── auth/                      # phone OTP, role selection
│   ├── donation/                  # create, manage, cancel, pickup code (donor)
│   ├── discovery/                 # feed, map, filters, request (receiver)
│   ├── allocation/                # allocation state, live updates, reallocation
│   ├── recurring/                 # templates, confirm-or-skip
│   ├── history/
│   └── profile/
│
└── shared/                        # widgets and utilities used by 3+ features only
```

Each feature is the same three layers:

```
features/donation/
├── data/
│   ├── donation_api.dart          # Dio calls, DTO ↔ domain mapping
│   ├── donation_dao.dart          # Drift — offline cache
│   └── donation_repository_impl.dart
├── domain/
│   ├── donation.dart              # Freezed model — no JSON, no Flutter
│   ├── donation_status.dart       # the state machine, as a sealed type
│   └── donation_repository.dart   # abstract interface
└── presentation/
    ├── controllers/               # Riverpod AsyncNotifier — one per screen
    ├── screens/
    └── widgets/
```

**Riverpod conventions**

- `@riverpod` code generation everywhere; no manual `Provider` declarations.
- Repositories are `Provider`; screen state is `AsyncNotifier`.
- `ref.watch` in `build`, `ref.read` in callbacks — never the reverse.
- Every provider that touches the network is `keepAlive: false` unless it backs a cache.

**Performance rules that matter here**

- `const` constructors on every leaf widget (the feed rebuilds constantly).
- Feed and map are `ListView.builder` / clustered markers — never a materialised list.
- Images through `cached_network_image`, sized at request time via CloudFront.
- Drift-first reads: the feed paints from cache, then reconciles over the socket. An NGO on
  a two-bar connection sees food, not a spinner.

---

## 3. NestJS API — `apps/api`

Module-per-bounded-context. The allocation engine is deliberately its own module with no
HTTP surface of its own — it is driven by events and by BullMQ, so it can never be blocked
behind a slow request.

```
apps/api/src/
├── main.ts
├── app.module.ts
│
├── common/
│   ├── guards/                    # JWT, role (donor | receiver | admin)
│   ├── interceptors/              # logging, timeout, serialization
│   ├── filters/                   # exception → RFC7807 problem+json
│   └── decorators/
│
├── modules/
│   ├── auth/                      # phone OTP (MSG91), JWT, refresh rotation
│   ├── users/
│   ├── ngo-verification/          # proof docs → S3, admin approve/reject/revoke
│   ├── donations/                 # CRUD + the lifecycle state machine
│   ├── portions/                  # split donations (§9)
│   ├── allocation/                # ← the ranking engine. Pure functions + a queue.
│   │   ├── allocation.service.ts
│   │   ├── ranking.ts             # score = proximity·w1 + capacity·w2 + order·w3 + fairness·w4
│   │   ├── allocation.processor.ts# BullMQ worker: allocate, expire, reallocate
│   │   └── ranking.spec.ts        # the weights are configurable, so this is heavily tested
│   ├── recurring/                 # templates + the daily confirm-or-skip job
│   ├── notifications/             # FCM push, MSG91 SMS fallback, SES email, Exotel IVR
│   ├── realtime/                  # Socket.IO gateway — donation + allocation rooms
│   ├── admin-config/              # rule weights, timers, radius rings, split threshold
│   └── admin/                     # verification queue, overrides, dashboard
│
├── prisma/
│   ├── schema.prisma
│   └── migrations/
│
└── jobs/                          # BullMQ queue definitions and schedules
```

**Allocation path — the one that must not be slow**

1. Donation goes `LIVE` → domain event, published synchronously to Redis.
2. BullMQ `allocate` job picks it up. Candidate NGOs come from a **PostGIS** query
   (`ST_DWithin` on a GiST index) bounded to the current radius ring — never a table scan.
3. Ranking runs in memory over the candidate set. Weights are read from `AdminConfig`,
   cached in Redis with a short TTL so an admin change takes effect without a deploy.
4. Allocation is written in a transaction that also generates the pickup code, then pushed
   over Socket.IO and FCM in parallel.
5. A delayed job is scheduled at `allocatedAt + pickupWindow`. If the code has not been
   entered by then, it reallocates to the next NGO in the queue — no admin action.

Steps 2–4 are what the "within seconds" requirement actually constrains. They get their own
p99 latency alarm in CloudWatch, and the notification dispatch has a dead-letter queue,
because §15 names these two as the flows that must never fail silently.

**Data model** — mirrors scope §16: `User`, `NgoProfile`, `Donation`, `DonationPortion`,
`RequestQueue`, `RecurringTemplate`, `Rating`, `AdminConfig`.

**Address privacy (§11)** is enforced at the serializer, not the client: while `LIVE`, a
donation serialises only an approximate locality; exact address, contact person and phone
are added to the payload only for the NGO holding that allocation or portion.

---

## 4. Next.js admin — `apps/admin`

App Router, server components by default, MUI for the UI.

```
apps/admin/src/
├── app/
│   ├── (auth)/login/
│   └── (dashboard)/
│       ├── verification/          # NGO approval queue
│       ├── operations/            # live + allocated feed, manual override
│       ├── config/                # rule weights, timers, radius rings, split threshold
│       ├── disputes/
│       └── analytics/
├── components/                    # composed from @surplus-served/web-ui
├── lib/
│   ├── api/                       # generated client from packages/contracts
│   └── socket/                    # live ops feed
└── theme/                         # re-exports web-ui, adds admin-only overrides
```

Server components fetch; client components are only used where there is genuine
interactivity (the live feed, the config sliders, the map). The admin console is internal
and low-traffic — it optimises for correctness and auditability, not for bundle size.

---

## 5. Cross-cutting

| Concern | Approach |
| --- | --- |
| **API contract** | OpenAPI generated from NestJS decorators → `packages/contracts` → typed Dart + TS clients. A breaking change fails CI in all three apps at once. |
| **State machine** | Defined once in `packages/contracts`, generated into Dart and TS. `SsStatus` in the design system carries only presentation concerns. |
| **Realtime** | Socket.IO rooms per donation and per NGO. Push (FCM) is the primary channel; the socket is an optimisation for users with the app open. |
| **i18n** | Server sends message *keys* plus data for push and SMS; the client renders in the user's language. Telugu parity is a build-time check, not a review checklist. |
| **Secrets** | AWS Secrets Manager, injected at task start. Nothing in the repo, nothing in the image. |
| **Observability** | Sentry (mobile + API), CloudWatch (infra), PostHog (product). Allocation latency and notification delivery each get an alarm. |
| **Testing** | Flutter widget + golden tests for the design system; Jest unit tests with a heavy focus on `ranking.ts`; Bruno collections for the API; Maestro for the mobile happy paths (post donation → allocate → enter code → collected). |
| **CI/CD** | GitHub Actions: token generation + contrast gate → lint → test → build → Terraform plan. Deploys to ECS Fargate on merge to `main`. |

---

## 6. Design system in the pipeline

`design/tokens/tokens.json` is regenerated and verified on every CI run:

```yaml
- run: node design/tools/generate.mjs
- run: node design/tools/check-contrast.mjs
- run: git diff --exit-code   # generated output must be committed and current
```

The last line is the important one. It makes a stale `tokens.g.dart` a build failure rather
than a slow visual drift nobody notices until an NGO cannot read a status badge.
