# Stylo AI — Technical Architecture

**Version:** 1.0
**Date:** 2026-03-30
**Status:** Authoritative reference

---

## Table of Contents

1. [High-Level Architecture](#1-high-level-architecture)
2. [Layer Diagram](#2-layer-diagram)
3. [Service Communication Patterns](#3-service-communication-patterns)
4. [Authentication Flow](#4-authentication-flow)
5. [Image Processing Pipeline](#5-image-processing-pipeline)
6. [Outfit Recommendation Data Flow](#6-outfit-recommendation-data-flow)
7. [Infrastructure Diagram](#7-infrastructure-diagram)
8. [Architectural Decision Records (ADRs)](#8-architectural-decision-records-adrs)
9. [Security Considerations](#9-security-considerations)
10. [Performance Strategy](#10-performance-strategy)
11. [MongoDB Collections Overview](#11-mongodb-collections-overview)
12. [API Gateway Patterns](#12-api-gateway-patterns)
13. [Error Handling Strategy](#13-error-handling-strategy)
14. [Monitoring and Observability](#14-monitoring-and-observability)
15. [CI/CD Pipeline](#15-cicd-pipeline)

---

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            CLIENTS                                      │
│                                                                         │
│   ┌──────────────────┐              ┌──────────────────────────────┐    │
│   │  Flutter Mobile  │              │   Next.js Landing Page       │    │
│   │  iOS / Android   │              │   (Vercel Edge Network)      │    │
│   └────────┬─────────┘              └──────────────┬───────────────┘    │
└────────────┼──────────────────────────────────────┼────────────────────┘
             │ HTTPS / REST + JWT                    │ HTTPS
             │                                       │
┌────────────▼───────────────────────────────────────▼────────────────────┐
│                         BACKEND — NestJS (Railway)                      │
│                                                                         │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────────┐  │
│  │   Auth   │ │ Wardrobe │ │ Outfits  │ │  Users   │ │Subscriptions│  │
│  │  Module  │ │  Module  │ │  Module  │ │  Module  │ │   Module    │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └─────────────┘  │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │              Swagger / OpenAPI  |  Bull Queue  |  Guards        │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└──────────┬──────────────────────────────────────┬──────────────────────┘
           │                                      │
    ┌──────▼──────┐                      ┌────────▼────────┐
    │  MongoDB    │                      │   AI Services   │
    │  (Railway)  │                      │   (Railway)     │
    │             │                      │                 │
    │  Mongoose   │                      │ ┌─────────────┐ │
    └─────────────┘                      │ │ Rembg       │ │
                                         │ │ FastAPI     │ │
    ┌─────────────┐                      │ └─────────────┘ │
    │ S3-compat.  │◄─────────────────────│ ┌─────────────┐ │
    │ MinIO/R2    │                      │ │ CLIP        │ │
    │             │                      │ │ FastAPI     │ │
    └─────────────┘                      │ └─────────────┘ │
                                         └─────────────────┘
```

---

## 2. Layer Diagram

```
╔══════════════════════════════════════════════════════════════════════════╗
║  LAYER 1 — PRESENTATION                                                  ║
║                                                                          ║
║  ┌─────────────────────────────────┐  ┌────────────────────────────┐    ║
║  │       Flutter Mobile App        │  │   Next.js 14+ (App Router) │    ║
║  │  ─────────────────────────────  │  │  ──────────────────────── │    ║
║  │  State:    Riverpod providers   │  │  Styling:   Tailwind CSS   │    ║
║  │  Routing:  GoRouter             │  │  UI:        shadcn/ui      │    ║
║  │  HTTP:     Dio + interceptors   │  │  Data:      React Query    │    ║
║  │  Storage:  flutter_secure_store │  │  Deploy:    Vercel         │    ║
║  │  Images:   image_picker         │  │                            │    ║
║  │  Build:    EAS Build            │  │  Pages:                    │    ║
║  │                                 │  │  / landing + waitlist      │    ║
║  │  Design System:                 │  │  /pricing                  │    ║
║  │  Plus Jakarta Sans — headings   │  │  /blog (future)            │    ║
║  │  Inter — body                   │  │                            │    ║
║  │  #C67A5C terracotta accent      │  │                            │    ║
║  │  #1A1A1A primary                │  │                            │    ║
║  │  #FAFAFA background             │  │                            │    ║
║  └─────────────────────────────────┘  └────────────────────────────┘    ║
╠══════════════════════════════════════════════════════════════════════════╣
║  LAYER 2 — API / ORCHESTRATION                                           ║
║                                                                          ║
║  ┌──────────────────────────────────────────────────────────────────┐   ║
║  │  NestJS Application (Railway)                                    │   ║
║  │  ────────────────────────────────────────────────────────────── │   ║
║  │  Transport:   REST/HTTP + JSON                                   │   ║
║  │  Validation:  class-validator + class-transformer                │   ║
║  │  Docs:        Swagger / OpenAPI 3.0                              │   ║
║  │  Auth guard:  Firebase Admin SDK (token verify) + JWT issue      │   ║
║  │  Queue:       Bull (Redis) — async AI job dispatch               │   ║
║  │  Throttle:    @nestjs/throttler per plan tier                    │   ║
║  │  ORM:         Mongoose 8.x                                       │   ║
║  └──────────────────────────────────────────────────────────────────┘   ║
╠══════════════════════════════════════════════════════════════════════════╣
║  LAYER 3 — DATA                                                          ║
║                                                                          ║
║  ┌─────────────────┐  ┌──────────────────┐  ┌───────────────────────┐  ║
║  │    MongoDB       │  │  S3-Compatible   │  │  Redis (Bull queues)  │  ║
║  │  (Railway)       │  │  Storage         │  │  (Railway)            │  ║
║  │                  │  │  MinIO (local)   │  │                       │  ║
║  │  Collections:    │  │  R2 (prod)       │  │  Queues:              ║
║  │  users           │  │                  │  │  garment-scan         │  ║
║  │  garments        │  │  Buckets:        │  │  outfit-reco          │  ║
║  │  outfits         │  │  garments-raw    │  │  notification         │  ║
║  │  style_profiles  │  │  garments-clean  │  │                       │  ║
║  │  waitlist        │  │  thumbnails      │  │                       │  ║
║  │  subscriptions   │  │                  │  │                       │  ║
║  └─────────────────┘  └──────────────────┘  └───────────────────────┘  ║
╠══════════════════════════════════════════════════════════════════════════╣
║  LAYER 4 — AI SERVICES                                                   ║
║                                                                          ║
║  ┌──────────────────────────────┐  ┌───────────────────────────────┐    ║
║  │  Rembg Service (FastAPI)     │  │  CLIP Service (FastAPI)       │    ║
║  │  ──────────────────────────  │  │  ─────────────────────────── │    ║
║  │  Input:  raw image bytes     │  │  Input:  clean PNG bytes      │    ║
║  │  Model:  u2net (rembg)       │  │  Model:  openai/clip-vit-b32  │    ║
║  │  Output: PNG w/ alpha        │  │  Output: embeddings +         │    ║
║  │                              │  │          classification JSON  │    ║
║  │  POST /remove-background     │  │                               │    ║
║  │                              │  │  POST /classify               │    ║
║  │  GPU: optional (CPU viable)  │  │  POST /search-similar         │    ║
║  └──────────────────────────────┘  └───────────────────────────────┘    ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

## 3. Service Communication Patterns

### 3.1 Synchronous (Request/Response)

| Client | Target | Protocol | Auth |
|--------|--------|----------|------|
| Flutter | NestJS | HTTPS REST | Bearer JWT |
| Next.js | NestJS | HTTPS REST | Bearer JWT |
| NestJS | Rembg Service | Internal HTTP | Service API key header |
| NestJS | CLIP Service | Internal HTTP | Service API key header |
| NestJS | Weather API | HTTPS REST | API key query param |

All internal service-to-service calls use a shared `X-Service-Key` header validated via a NestJS guard. This header is set via environment variable and rotated per deployment.

### 3.2 Asynchronous (Queue-Based)

```
Mobile Client
     │
     │  POST /garments/scan  (returns jobId immediately — 202 Accepted)
     ▼
NestJS ──► Bull Queue (garment-scan)
                │
                ▼
          Worker Process
          ├── 1. Download raw image from S3
          ├── 2. POST → Rembg Service
          ├── 3. Upload clean PNG to S3
          ├── 4. POST → CLIP Service
          ├── 5. Persist garment document (MongoDB)
          └── 6. Emit socket event (or push notification) → client
```

The client polls `GET /garments/jobs/:jobId` or receives a WebSocket push event on job completion.

### 3.3 Pattern Summary

- **Direct REST** — used for CRUD operations, profile, waitlist, subscription management.
- **Job Queue (Bull/Redis)** — used for all AI-heavy workloads to avoid gateway timeouts and enable retries.
- **WebSocket (Socket.IO)** — used to push job completion events back to mobile clients without polling.
- **Webhook** — Stripe webhook endpoint for subscription lifecycle events.

---

## 4. Authentication Flow

### 4.1 Sequence: Firebase Auth → NestJS JWT

```
User (Mobile/Web)
      │
      │  1. Sign in (email/password, Google, Apple)
      ▼
Firebase Auth SDK
      │
      │  2. Returns Firebase ID Token (short-lived, ~1h)
      ▼
NestJS  POST /auth/exchange
      │
      │  3. Firebase Admin SDK verifies ID token
      │     Checks uid, email, token expiry, revocation
      ▼
      │  4. Look up or create user document in MongoDB
      ▼
      │  5. Issue custom JWT
      │     Payload: { sub: userId, email, plan, iat, exp }
      │     Signed with: RS256 (private key in Railway secrets)
      │     Access token:  15 minutes
      │     Refresh token: 30 days (stored in DB, rotatable)
      ▼
Client stores:
  - Access JWT  → in-memory (mobile: flutter_secure_storage)
  - Refresh JWT → flutter_secure_storage / httpOnly cookie (web)

      │
      │  6. All subsequent API calls include:
      │     Authorization: Bearer <access_jwt>
      ▼
NestJS JwtAuthGuard
      │  Verifies signature, expiry, checks token not revoked
      ▼
Controller proceeds
```

### 4.2 Token Refresh Flow

```
Client detects 401 response
      │
      │  POST /auth/refresh  { refreshToken }
      ▼
NestJS validates refresh token in DB (not expired, not revoked)
      │
      ▼
Issues new access + refresh token pair
Old refresh token invalidated (rotation)
```

### 4.3 Plan Enforcement

The JWT payload includes `plan: "free" | "premium"`. The `PlanGuard` on protected routes reads this claim and enforces rate limits (30 garments, 5 scans/month, 3 recs/day for free; unlimited for premium) without an additional DB lookup on every request.

---

## 5. Image Processing Pipeline

### 5.1 Full Pipeline Sequence

```
Mobile Camera / Gallery
        │
        │  image_picker → compressed JPEG (max 2MB, 1080px long edge)
        ▼
Dio HTTP client
        │
        │  POST /garments/scan  (multipart/form-data)
        │  Headers: Authorization: Bearer <jwt>
        ▼
NestJS — GarmentsController
        │
        ├── 1. Validate file type (JPEG/PNG/WEBP only)
        ├── 2. Validate size (<= 10MB server-side)
        ├── 3. Generate deterministic key:
        │      garments/raw/{userId}/{uuid}.jpg
        ├── 4. Upload raw file → S3 bucket: garments-raw
        ├── 5. Enqueue Bull job { jobId, s3Key, userId }
        └── 6. Return 202 { jobId }

            ▼  (async worker picks up job)

Bull Worker — GarmentScanProcessor
        │
        ├── Step A: Download raw image from S3
        │
        ├── Step B: POST to Rembg Service
        │   ┌─────────────────────────────────────────────┐
        │   │  Rembg FastAPI                               │
        │   │  - Loads u2net model (warm, cached in RAM)   │
        │   │  - Removes background → PNG with alpha       │
        │   │  - Returns PNG bytes                         │
        │   └─────────────────────────────────────────────┘
        │   Upload clean PNG → S3 bucket: garments-clean
        │      key: garments/clean/{userId}/{uuid}.png
        │
        ├── Step C: Generate thumbnail
        │   Resize to 400×400, upload → S3 bucket: thumbnails
        │      key: garments/thumb/{userId}/{uuid}.webp
        │
        ├── Step D: POST to CLIP Service
        │   ┌─────────────────────────────────────────────┐
        │   │  CLIP FastAPI                                │
        │   │  Input: clean PNG bytes                      │
        │   │  Process:                                    │
        │   │   - Encode image → 512-dim embedding         │
        │   │   - Zero-shot classify against label sets:   │
        │   │     type:   [shirt, pants, dress, jacket…]   │
        │   │     color:  [black, white, red, terracotta…] │
        │   │     style:  [casual, formal, streetwear…]    │
        │   │     material:[cotton, denim, silk, wool…]    │
        │   │     season: [spring, summer, fall, winter]   │
        │   │  Output: {                                   │
        │   │    embedding: float[512],                    │
        │   │    type, color, style, material, season,     │
        │   │    confidences: { [label]: float }           │
        │   │  }                                           │
        │   └─────────────────────────────────────────────┘
        │
        ├── Step E: Persist to MongoDB
        │   garments collection document (see §11)
        │
        └── Step F: Emit socket event to client
            { event: "garment:scan:complete", jobId, garmentId }
```

### 5.2 S3 Key Naming Convention

```
garments/raw/{userId}/{uuid}.{ext}       — original upload
garments/clean/{userId}/{uuid}.png       — background removed
garments/thumb/{userId}/{uuid}.webp      — 400×400 thumbnail
```

All buckets are private. Clients receive pre-signed URLs with 1-hour TTL, generated by NestJS on each read request.

---

## 6. Outfit Recommendation Data Flow

```
Client: "Recommend an outfit for a casual Friday dinner, 18°C, rainy"
        │
        │  POST /outfits/recommend
        │  Body: { mood: "casual", event: "dinner", date: "2026-03-30" }
        ▼
NestJS — OutfitsController
        │
        ├── 1. Auth + plan guard (free: 3 recs/day, premium: unlimited)
        │
        ├── 2. Fetch weather context
        │   ┌─────────────────────────────────────────────┐
        │   │  Weather API (OpenWeatherMap or similar)     │
        │   │  Input: user's saved location (from profile) │
        │   │  Output: { temp: 18, condition: "rain" }     │
        │   │  Cached in Redis for 30 min by location key  │
        │   └─────────────────────────────────────────────┘
        │
        ├── 3. Load user's wardrobe embeddings from MongoDB
        │   garments collection: { embedding, type, color,
        │                          style, season, tags }
        │   (embeddings cached per user in Redis, 1h TTL,
        │    invalidated on wardrobe mutation)
        │
        ├── 4. Build CLIP query embedding
        │   POST /clip-service/embed-text
        │   Input: "casual dinner outfit rainy cold weather"
        │   Output: float[512]
        │
        ├── 5. Cosine similarity ranking
        │   Score each garment embedding against query embedding
        │   Filter by: season relevance, weather suitability
        │   Group into outfit slots: [top, bottom, outer, shoes, accessory]
        │   Select highest-scoring compatible combination
        │
        ├── 6. Persist recommended outfit to MongoDB
        │   outfits collection: { garmentIds[], context, score, userId }
        │
        └── 7. Return outfit with pre-signed thumbnail URLs
            {
              outfitId,
              garments: [{ id, thumbnailUrl, type, color, style }],
              rationale: "Light layers for cool rainy weather…",
              score: 0.87
            }
```

---

## 7. Infrastructure Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│  PRODUCTION INFRASTRUCTURE                                          │
│                                                                     │
│  ┌──────────────────────────────────────────┐                      │
│  │  Vercel (Edge Network)                   │                      │
│  │  Next.js 14 App — Landing + Waitlist     │                      │
│  │  Regions: Global edge                    │                      │
│  │  CDN: Vercel CDN (static assets)         │                      │
│  └──────────────────────────────────────────┘                      │
│                                                                     │
│  ┌──────────────────────────────────────────┐                      │
│  │  Railway (Primary Cluster)               │                      │
│  │                                          │                      │
│  │  ┌─────────────────┐                     │                      │
│  │  │  NestJS API     │  512MB RAM, 1 vCPU  │                      │
│  │  │  Auto-scale     │  (scale to 2 on     │                      │
│  │  │  via Railway    │   traffic spike)     │                      │
│  │  └────────┬────────┘                     │                      │
│  │           │                              │                      │
│  │  ┌────────▼────────┐                     │                      │
│  │  │  Redis          │  Bull queue store    │                      │
│  │  │  (Railway)      │  + response cache    │                      │
│  │  └─────────────────┘                     │                      │
│  │                                          │                      │
│  │  ┌─────────────────┐                     │                      │
│  │  │  MongoDB        │  Railway managed     │                      │
│  │  │  (Railway)      │  1GB storage MVP     │                      │
│  │  └─────────────────┘                     │                      │
│  │                                          │                      │
│  │  ┌──────────────────┐  ┌──────────────┐  │                      │
│  │  │  Rembg Service   │  │ CLIP Service │  │                      │
│  │  │  FastAPI         │  │ FastAPI      │  │                      │
│  │  │  1GB RAM, 1 vCPU │  │ 2GB RAM      │  │                      │
│  │  │  (CPU inference) │  │ (CPU infer.) │  │                      │
│  │  └──────────────────┘  └──────────────┘  │                      │
│  └──────────────────────────────────────────┘                      │
│                                                                     │
│  ┌──────────────────────────────────────────┐                      │
│  │  Cloudflare R2 (Object Storage)          │                      │
│  │  - garments-raw bucket                   │                      │
│  │  - garments-clean bucket                 │                      │
│  │  - thumbnails bucket                     │                      │
│  │  Zero egress cost, S3-compatible API     │                      │
│  └──────────────────────────────────────────┘                      │
│                                                                     │
│  ┌──────────────────────────────────────────┐                      │
│  │  Firebase (Google Cloud)                 │                      │
│  │  - Firebase Auth (identity provider)     │                      │
│  │  - FCM (push notifications)              │                      │
│  └──────────────────────────────────────────┘                      │
│                                                                     │
│  ┌──────────────────────────────────────────┐                      │
│  │  EAS Build (Expo Application Services)   │                      │
│  │  - iOS .ipa builds (TestFlight / App Store)                     │
│  │  - Android .aab builds (Play Store)      │                      │
│  │  - OTA updates via Expo Updates          │                      │
│  └──────────────────────────────────────────┘                      │
│                                                                     │
│  LOCAL DEVELOPMENT                                                  │
│  ┌──────────────────────────────────────────┐                      │
│  │  Docker Compose                          │                      │
│  │  - MinIO (S3 replacement)                │                      │
│  │  - MongoDB                               │                      │
│  │  - Redis                                 │                      │
│  │  - Rembg Service                         │                      │
│  │  - CLIP Service                          │                      │
│  └──────────────────────────────────────────┘                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 8. Architectural Decision Records (ADRs)

### ADR-001: Flutter for Mobile (vs React Native)

**Status:** Accepted
**Decision:** Use Flutter with Riverpod as the mobile framework.
**Rationale:**
- Single Dart codebase for iOS and Android with pixel-perfect rendering.
- Riverpod provides compile-time safe dependency injection and reactive state without boilerplate.
- image_picker and camera ecosystem are mature in Flutter.
- EAS Build integrates cleanly for CI distribution.

**Trade-offs:** Smaller talent pool than React Native; Dart learning curve. Acceptable given the team profile.

---

### ADR-002: NestJS for Backend (vs Express, Fastify, or Go)

**Status:** Accepted
**Decision:** Use NestJS with Mongoose as the primary backend.
**Rationale:**
- Opinionated module structure prevents architectural drift in a small team.
- First-class Swagger/OpenAPI generation via decorators eliminates a manual docs burden.
- class-validator + class-transformer give runtime DTO validation matching TypeScript types.
- Bull queue integration is first-class with @nestjs/bull.

**Trade-offs:** More boilerplate than bare Express. Acceptable given the productivity gains.

---

### ADR-003: Separate FastAPI Services for AI (vs Embedding in NestJS)

**Status:** Accepted
**Decision:** Run Rembg and CLIP as independent FastAPI microservices.
**Rationale:**
- Python ML ecosystem (PyTorch, Transformers, Rembg) does not belong in a Node.js process.
- Independent scaling: AI services can be scaled or swapped without redeploying the API.
- Model cold-start is isolated; NestJS remains always-warm.
- Clear failure boundary: AI failure does not crash the API.

**Trade-offs:** Two additional services to maintain and monitor. Mitigated by Railway's simple deployment model.

---

### ADR-004: Firebase Auth + Custom JWT (vs Auth0 or Supabase Auth)

**Status:** Accepted
**Decision:** Use Firebase Auth for identity, exchange for a custom NestJS-issued JWT.
**Rationale:**
- Firebase Auth handles social login (Google, Apple) and email/password out of the box.
- Custom JWT lets the backend embed plan-tier claims without a round-trip to Firebase on every request.
- Firebase Admin SDK validation is a one-time step at exchange; subsequent calls are pure JWT verify.
- FCM integration (push notifications) comes for free with Firebase.

**Trade-offs:** Dependency on Firebase; vendor lock-in for auth. Acceptable for MVP speed.

---

### ADR-005: MongoDB (vs PostgreSQL)

**Status:** Accepted
**Decision:** Use MongoDB via Mongoose.
**Rationale:**
- Garment documents have a variable schema (CLIP outputs vary by model version).
- CLIP embedding vectors (512 floats) are stored inline on the garment document for simplicity.
- Outfit recommendations are document-shaped (array of garment refs + metadata).
- Schema evolution during MVP without migrations is a key velocity requirement.

**Trade-offs:** No native vector search in MongoDB Atlas free tier (workaround: cosine similarity in application layer). Acceptable at MVP scale; migrate to Atlas Vector Search or Qdrant when needed.

---

### ADR-006: Cloudflare R2 for Object Storage (vs AWS S3)

**Status:** Accepted
**Decision:** Use Cloudflare R2 in production, MinIO in local development.
**Rationale:**
- R2 is S3-API compatible — zero code change between environments.
- Zero egress fees; garment images are read-heavy (every wardrobe load generates pre-signed URL calls).
- Cloudflare's global network provides low-latency reads.

**Trade-offs:** R2 does not support S3 event notifications natively (Lambda triggers). Irrelevant since the pipeline is queue-driven, not event-driven.

---

### ADR-007: Flat-Lay Composition for MVP Virtual Try-On (vs Diffusion Models)

**Status:** Accepted
**Decision:** MVP virtual try-on is a flat-lay image composition (layer cleaned garment PNGs on a neutral background), not a generative model try-on.
**Rationale:**
- Diffusion-based virtual try-on (e.g., IDM-VTON) requires significant GPU compute and latency.
- Flat-lay is immediately actionable with current infrastructure and provides real user value.
- Diffusion try-on is a post-MVP feature gated behind premium.

**Trade-offs:** Less visually impressive than generative try-on. Explicitly communicated to users.

---

### ADR-008: Bull + Redis for Job Queue (vs direct synchronous calls)

**Status:** Accepted
**Decision:** All AI processing jobs are dispatched asynchronously via Bull queues.
**Rationale:**
- Rembg + CLIP inference can take 2–10 seconds depending on hardware.
- HTTP gateways (Railway, load balancers) have 30s timeout defaults; async avoids this.
- Bull provides automatic retry with exponential backoff on failure.
- Job status is trackable without polling via WebSocket push.

---

## 9. Security Considerations

### 9.1 Authentication and Authorization

- All API endpoints (except `/auth/exchange`, `/waitlist`, `/health`) require a valid JWT.
- JWTs are signed with RS256 (asymmetric). The private key lives only in Railway environment secrets and is never committed.
- `PlanGuard` enforces per-user rate limits based on JWT `plan` claim. Free-tier limits are checked against daily/monthly counters stored in Redis.
- Token revocation list maintained in Redis for logout and account compromise scenarios.

### 9.2 File Upload Security

- Accepted MIME types: `image/jpeg`, `image/png`, `image/webp` only.
- File size capped at 10MB server-side (Multer config).
- Files are uploaded to S3 with a UUID key derived from `userId + uuid`. Users cannot guess other users' keys.
- All S3 URLs served as pre-signed URLs with 1-hour TTL. No public bucket ACLs.
- Uploaded files are scanned for malicious content via a lightweight ClamAV sidecar (post-MVP, pre-production hardening).

### 9.3 API Security

- HTTPS enforced everywhere. Railway enforces TLS; Vercel enforces TLS at edge.
- CORS restricted to known origins (`stylo.app`, `localhost:3000` in dev).
- Helmet.js enabled on NestJS (CSP, HSTS, X-Frame-Options, etc.).
- Rate limiting via `@nestjs/throttler`: 100 req/min per IP on unauthenticated endpoints, plan-based limits on authenticated routes.
- Internal service-to-service calls validated with `X-Service-Key` header (rotated secret).
- Swagger UI disabled in production.

### 9.4 Data Privacy

- PII (email, name, location) stored in MongoDB with field-level encryption at rest (MongoDB Encrypted Storage Engine or application-layer AES-256 for MVP).
- Garment image embeddings are per-user and not shared or used for cross-user inference.
- Users can request full data deletion (`DELETE /users/me`), which cascades to all garments, outfits, and S3 objects.
- No third-party analytics SDK with user PII; analytics are event-level and anonymized.

### 9.5 Secrets Management

- All secrets (DB URI, JWT private key, S3 credentials, service keys) are Railway environment variables.
- No secrets in source code or Docker images.
- `.env.example` in repo contains only placeholder values.

---

## 10. Performance Strategy

### 10.1 Caching Layers

| Cache Target | Store | TTL | Invalidation |
|---|---|---|---|
| Weather data by location | Redis | 30 min | Time-based expiry |
| User wardrobe embeddings | Redis | 1 hour | Invalidated on garment add/delete |
| Outfit recommendations | Redis | 15 min | Invalidated on wardrobe change |
| Pre-signed S3 URLs | Client-side (React Query) | 50 min | React Query staleTime |
| CLIP text embeddings for common queries | Redis | 24 hours | Manual cache warm |

### 10.2 Image Optimization

- **Upload:** Flutter compresses to max 2MB / 1080px before upload using `flutter_image_compress`.
- **Thumbnails:** NestJS worker generates WebP thumbnails (400×400) for wardrobe grid. WebP achieves ~30% smaller files vs JPEG at equivalent quality.
- **Delivery:** Thumbnails served from Cloudflare R2 via pre-signed URL. Cloudflare's edge caches public assets; private assets served direct from R2.
- **Clean images:** Full-resolution clean PNGs served only on demand (try-on, detail view).

### 10.3 CDN Strategy

- **Static assets (landing page):** Vercel Edge CDN — JS bundles, fonts, images.
- **Thumbnail images:** Cloudflare R2 with CDN layer enabled for frequently accessed thumbnails.
- **API responses:** Not CDN-cached (personalized, auth-gated). Redis handles hot-path caching instead.

### 10.4 Mobile Performance

- **Riverpod:** `AsyncNotifierProvider` prevents redundant rebuilds.
- **GoRouter:** Declarative routing with lazy-loaded screens.
- **Image grid:** `CachedNetworkImage` with progressive loading and placeholder skeletons.
- **Infinite scroll:** Cursor-based pagination on wardrobe endpoint (20 garments per page).

### 10.5 Backend Performance

- **Connection pooling:** Mongoose connection pool size 10 (adjustable).
- **MongoDB indexes:** Compound indexes on `(userId, createdAt)` for garments, `(userId, event)` for outfits.
- **Pagination:** All list endpoints use cursor-based pagination with `lastId` parameter.
- **Bull concurrency:** Garment scan worker concurrency = 3 (scales with CPU cores).

---

## 11. MongoDB Collections Overview

### 11.1 `users`

```json
{
  "_id": "ObjectId",
  "firebaseUid": "string (indexed, unique)",
  "email": "string (indexed)",
  "displayName": "string",
  "avatarUrl": "string | null",
  "plan": "free | premium",
  "planExpiresAt": "Date | null",
  "stripeCustomerId": "string | null",
  "location": { "lat": "number", "lon": "number", "city": "string" },
  "refreshTokenHash": "string",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### 11.2 `garments`

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId (ref: users, indexed)",
  "jobId": "string",
  "status": "pending | processing | complete | failed",
  "rawS3Key": "string",
  "cleanS3Key": "string",
  "thumbnailS3Key": "string",
  "classification": {
    "type": "string",
    "color": "string",
    "style": "string",
    "material": "string",
    "season": ["string"],
    "confidences": {}
  },
  "embedding": "[number] (512 floats)",
  "userTags": ["string"],
  "userNotes": "string",
  "isFavorite": "boolean",
  "wornCount": "number",
  "lastWornAt": "Date | null",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

Indexes: `{ userId: 1, createdAt: -1 }`, `{ userId: 1, 'classification.type': 1 }`, `{ userId: 1, isFavorite: 1 }`

### 11.3 `outfits`

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId (ref: users, indexed)",
  "name": "string | null",
  "garmentIds": ["ObjectId (ref: garments)"],
  "context": {
    "mood": "string",
    "event": "string",
    "weather": { "temp": "number", "condition": "string" },
    "date": "Date"
  },
  "score": "number",
  "rationale": "string",
  "isSaved": "boolean",
  "flatLayS3Key": "string | null",
  "createdAt": "Date"
}
```

### 11.4 `style_profiles`

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId (ref: users, unique)",
  "onboardingCompleted": "boolean",
  "stylePersonas": ["minimalist", "streetwear", "classic", "boho"],
  "preferredColors": ["string"],
  "avoidedColors": ["string"],
  "bodyType": "string",
  "budgetRange": { "min": "number", "max": "number", "currency": "string" },
  "favoritebrands": ["string"],
  "climateZone": "tropical | temperate | cold | arid",
  "updatedAt": "Date"
}
```

### 11.5 `subscriptions`

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId (ref: users, unique, indexed)",
  "stripeSubscriptionId": "string",
  "stripeCustomerId": "string",
  "plan": "free | premium",
  "status": "active | canceled | past_due | trialing",
  "currentPeriodStart": "Date",
  "currentPeriodEnd": "Date",
  "cancelAtPeriodEnd": "boolean",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### 11.6 `waitlist`

```json
{
  "_id": "ObjectId",
  "email": "string (indexed, unique)",
  "referralCode": "string",
  "referredBy": "string | null",
  "position": "number",
  "source": "string",
  "createdAt": "Date"
}
```

---

## 12. API Gateway Patterns

### 12.1 Routing Convention

```
/api/v1/auth/*           — Authentication (public + protected)
/api/v1/users/*          — User profile management
/api/v1/garments/*       — Wardrobe CRUD + scanning
/api/v1/outfits/*        — Outfit recommendations + saves
/api/v1/style-profile/*  — Onboarding quiz + preferences
/api/v1/subscriptions/*  — Plan management
/api/v1/waitlist/*       — Public waitlist signup
/api/v1/health           — Health check (public)
/api/v1/webhooks/stripe  — Stripe webhook (verified via signature)
```

### 12.2 Request/Response Envelope

All API responses follow a consistent envelope:

```json
// Success
{
  "success": true,
  "data": { ... },
  "meta": { "page": 1, "limit": 20, "total": 143, "nextCursor": "..." }
}

// Error
{
  "success": false,
  "error": {
    "code": "GARMENT_LIMIT_EXCEEDED",
    "message": "Free plan allows up to 30 garments. Upgrade to Premium.",
    "statusCode": 403
  }
}
```

### 12.3 Versioning Strategy

- URL path versioning (`/api/v1/`).
- Breaking changes increment the version (`/api/v2/`).
- Old versions deprecated with `Deprecation` and `Sunset` response headers before removal.

### 12.4 Pagination

All list endpoints use cursor-based pagination:

```
GET /api/v1/garments?limit=20&cursor=<lastId>

Response meta:
{
  "nextCursor": "67f0a3b2...",
  "hasMore": true,
  "total": 143
}
```

### 12.5 Pre-signed URL Pattern

Garment images are never served as direct S3 URLs in API responses. Instead:

```
GET /api/v1/garments/:id

Response includes:
{
  "thumbnailUrl": "https://r2.stylo.app/sign?key=...&expires=...",
  "cleanUrl": null   // only included when explicitly requested
}
```

Pre-signed URLs are generated server-side with 1-hour TTL. The client caches them via React Query `staleTime: 50 * 60 * 1000`.

---

## 13. Error Handling Strategy

### 13.1 HTTP Status Codes

| Status | Scenario |
|--------|----------|
| 200 | Successful read or update |
| 201 | Successful creation |
| 202 | Job accepted (async processing started) |
| 400 | Validation error (DTO fails class-validator) |
| 401 | Missing or invalid JWT |
| 403 | Valid JWT but insufficient plan or permissions |
| 404 | Resource not found (only for resources owned by the requesting user) |
| 409 | Conflict (duplicate email in waitlist) |
| 413 | Payload too large (image exceeds 10MB) |
| 422 | Business logic violation (garment limit exceeded) |
| 429 | Rate limit exceeded |
| 500 | Unhandled internal error |
| 503 | AI service unavailable (circuit breaker open) |

### 13.2 NestJS Global Exception Filter

A global `AllExceptionsFilter` intercepts all thrown exceptions and:
1. Logs the full stack trace to Railway structured logs.
2. Maps to the error envelope format above.
3. Strips internal details from 500 responses in production.

### 13.3 AI Service Circuit Breaker

The NestJS → AI service calls are wrapped with `opossum` (or `cockatiel`) circuit breaker:
- **Threshold:** 50% failure rate over 10 requests.
- **Open duration:** 30 seconds.
- **Fallback:** Return a `503` with `RETRY_LATER` error code. The Bull job is re-queued with a 30-second delay.

### 13.4 Bull Job Retry Policy

```typescript
@Processor('garment-scan')
export class GarmentScanProcessor {
  @Process({ concurrency: 3 })
  async process(job: Job) { ... }
}

// Job options:
{
  attempts: 3,
  backoff: { type: 'exponential', delay: 5000 }
}
```

On final failure (after 3 attempts), the garment document status is set to `"failed"` and a notification is sent to the user.

### 13.5 Client-Side Error Handling

- **Flutter:** Dio interceptor catches 401 → triggers token refresh → retries original request once.
- **Flutter:** `AsyncValue.error` states render contextual error widgets with retry CTAs.
- **Next.js:** React Query `onError` callbacks show toast notifications via shadcn/ui `<Sonner>`.

---

## 14. Monitoring and Observability

### 14.1 Structured Logging

NestJS uses `winston` with JSON formatting. Every log entry includes:

```json
{
  "level": "info",
  "timestamp": "2026-03-30T12:00:00.000Z",
  "service": "stylo-api",
  "requestId": "uuid",
  "userId": "objectId",
  "method": "POST",
  "path": "/api/v1/garments/scan",
  "statusCode": 202,
  "durationMs": 143,
  "message": "Garment scan job enqueued"
}
```

FastAPI services use `structlog` with the same JSON schema.

### 14.2 Health Checks

```
GET /api/v1/health

Response:
{
  "status": "ok",
  "checks": {
    "database": "ok",
    "redis": "ok",
    "rembgService": "ok",
    "clipService": "ok",
    "storage": "ok"
  },
  "uptime": 86400
}
```

Railway uses this endpoint for automatic restarts on failure.

### 14.3 Metrics

- **Railway Metrics Dashboard:** CPU, RAM, request count, error rate per service.
- **Bull Board:** Visual dashboard for queue depth, job success/failure rates, worker throughput (deployed as a protected route `/admin/queues`).
- **Custom counters:** Track plan-tier usage (scans/month per user) in Redis. Exposed as an internal metrics endpoint for alerting.

### 14.4 Alerting (MVP)

- Railway alerts configured for: pod restart loops, memory > 90%, error rate > 5% sustained for 2 minutes.
- Email alerts to on-call (Postmark transactional email).

### 14.5 Error Tracking

- **Sentry** integrated in NestJS (`@sentry/node`) and Flutter (`sentry_flutter`) for exception capture with full context.
- Source maps uploaded during CI for readable stack traces.
- Release tracking: Sentry release created per EAS build / Railway deployment.

### 14.6 Future Observability (Post-MVP)

- OpenTelemetry instrumentation for distributed tracing across NestJS → AI services.
- Grafana + Prometheus for time-series metrics.
- PagerDuty for on-call escalation.

---

## 15. CI/CD Pipeline

### 15.1 Repository Structure

```
stylo-ai/
├── apps/
│   ├── mobile/          — Flutter app
│   ├── web/             — Next.js landing page
│   └── api/             — NestJS backend
├── services/
│   ├── rembg-service/   — FastAPI background removal
│   └── clip-service/    — FastAPI CLIP classification
├── docker-compose.yml   — Local development stack
└── .github/workflows/   — CI/CD pipelines
```

### 15.2 Branch Strategy

```
main           — production-ready, protected
├── staging    — pre-production integration testing
└── feature/*  — individual feature branches
    └── fix/*  — bug fix branches
```

PRs target `staging`. Merges to `main` trigger production deployments.

### 15.3 CI Pipeline (GitHub Actions)

**On every PR:**

```yaml
jobs:
  api-lint-test:
    - npm run lint
    - npm run test          # Jest unit tests
    - npm run test:e2e      # NestJS e2e tests (against test MongoDB)

  mobile-lint-test:
    - flutter analyze
    - flutter test

  web-lint-test:
    - npm run lint
    - npm run build         # Type check + build

  ai-services-test:
    - pip install -r requirements.txt
    - pytest services/rembg-service/tests/
    - pytest services/clip-service/tests/
```

**On merge to `staging`:**

```yaml
  deploy-staging:
    - Railway deploy (api, rembg-service, clip-service) → staging environment
    - Vercel deploy preview (web) → preview URL
```

**On merge to `main`:**

```yaml
  deploy-production:
    - Railway deploy (api) → production
    - Railway deploy (rembg-service) → production
    - Railway deploy (clip-service) → production
    - Vercel deploy (web) → production
    - Sentry release create
    - Notify Slack #deployments
```

### 15.4 Mobile CI/CD (EAS)

```yaml
  eas-build-ios:
    trigger: git tag v*
    - eas build --platform ios --profile production
    - eas submit --platform ios        # TestFlight

  eas-build-android:
    trigger: git tag v*
    - eas build --platform android --profile production
    - eas submit --platform android    # Play Store internal track
```

**OTA Updates (non-breaking JS changes):**

```yaml
  eas-update:
    trigger: merge to main (non-native changes)
    - eas update --branch production --message "..."
```

### 15.5 Environment Variables Management

| Variable | Dev | Staging | Prod |
|----------|-----|---------|------|
| `DATABASE_URL` | Docker Compose MongoDB | Railway staging DB | Railway prod DB |
| `REDIS_URL` | Docker Compose Redis | Railway staging Redis | Railway prod Redis |
| `S3_ENDPOINT` | MinIO localhost | R2 staging bucket | R2 prod bucket |
| `JWT_PRIVATE_KEY` | Local generated key | Railway secret | Railway secret |
| `FIREBASE_SERVICE_ACCOUNT` | Local JSON | Railway secret | Railway secret |
| `REMBG_SERVICE_URL` | `http://localhost:8001` | Internal Railway URL | Internal Railway URL |
| `CLIP_SERVICE_URL` | `http://localhost:8002` | Internal Railway URL | Internal Railway URL |

All production secrets are stored in Railway's encrypted environment variable store and never committed to the repository.

---

*Document maintained by the Stylo AI engineering team. Update this file when making significant architectural changes. For feature-level decisions, create a new ADR entry in §8.*
