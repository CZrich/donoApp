# Complete AlimentoRed MVP

Objective: deliver the authenticated end-to-end donation workflow defined in `plan.md`.
Branch: `feat/complete-mvp`. Delivery strategy: `ask-on-risk`; chain strategy: `stacked-to-main`; forecast exceeds 400 authored lines and will use reviewable slices.
Runners: `flutter analyze`, `flutter test`, `dart analyze`, `dart test`, Docker Compose integration checks.

## Specs

S1. The user requested: "registro y autenticacion por el momento email y passsword".

S2. Any authenticated user may create an organization. Its creator is the responsible owner, and only authorized users may administer it.

S3. Users must be able to view and edit their profile without changing account ownership or role accidentally.

S4. Organization flows must include creation forms, public listing and detail, authorized editing, and validation.

S5. Donation flows must include creation, images, listing, detail, filtering, owner editing/cancellation, reservation, delivery, and history.

S6. Images for profiles, organizations, and donations must use Cloudinary. The repository must contain placeholders only so the maintainer can later provide the required Cloudinary configuration safely.

S7. Every requirement in the `plan.md` "Lista maestra de validación del MVP" must have observable validation evidence before the application is considered complete.

S8. The application must remain runnable with Docker Compose and support Flutter web and Android.

## Tasks

- [ ] T1 — S1: Implement identity schema, secure email/password registration, login, session renewal/logout, `/me`, Flutter session persistence, guarded navigation, and tests. Route: inline; Risk: item 2 (authentication and credentials); Commit: pending.
- [ ] T2 — S3: Implement owner-scoped profile API and editable profile UI with validation and tests. Route: inline; Risk: item 2 (authorization); Commit: pending.
- [ ] T3 — S2, S4: Remodel organizations with independent ownership/membership, public read endpoints, authorized CRUD, Flutter forms/list/detail, and tests. Route: inline; Risk: items 1 and 2 (persisted schema and authorization); Commit: pending.
- [ ] T4 — S5: Implement authenticated donation CRUD, ownership, listing/detail/filtering, Flutter publication flows, and tests. Route: inline; Risk: item 2 (authorization); Commit: pending.
- [ ] T5 — S5: Implement transactional reservation lifecycle, delivery/history UI, and concurrency tests. Route: inline; Risk: items 1, 2, and 4 (persistent transitions, authorization, concurrency); Commit: pending.
- [ ] T6 — S6: Implement secure Cloudinary upload integration, validation, replacement/cleanup, Flutter image selection/progress/error handling, environment template, and tests. Route: inline; Risk: items 2 and 5 (credentials and external dependency); Commit: pending.
- [ ] T7 — S7, S8: Complete accessibility and async states, harden CORS/rate limits/logging, replace stale Supabase documentation, run Android/web/backend/integration verification, and record evidence. Route: inline; Risk: items 2 and 5 (security and delivery environment); Commit: pending.

## Log

L1. 2026-11-23 — User request: "ya vi que  hay perfil , donaciones , ver organiaciones epro nose peude registrar el perfil incicar secion ,crear  organizacion etc, culmina eso todo eso  haste un app 100% profesional"

L2. 2026-11-23 — User requirement: "1. registro  y autenticacion por el momento email y passsword . 2.formularios par ael registro de organizacion , generar donacioen s,etc las imagenes se subiran a clodinary asis quqe deja todo lsito solo apra que yo pegeu el repset l url api  o loque se pida pra su funcionameitno"

L3. 2026-11-23 — Product decision: any authenticated user may create an organization for now.

L4. 2026-11-23 — Audit found an executable scaffold: health and public donation listing exist, while authentication, authorization, forms, Cloudinary, transactional reservation workflows, and meaningful test coverage are missing.

L5. 2026-11-23 — Implementation order starts with identity and authorization to avoid insecure CRUD and later cross-cutting rework.

L6. 2026-11-23 — Maintainer selected stacked-to-main delivery: each coherent unit is reviewed and merged to main in order.

L7. 2026-11-23 — T1 credential core reached RED→GREEN: normalized email registration, bcrypt hashing at production cost 12, duplicate translation, uniform invalid-credential errors, constant expensive verification for unknown accounts, and bcrypt's 72-byte boundary. Evidence: 7 focused tests passed, `dart analyze` passed, and the independent security recheck resolved both reported blockers. T1 remains open pending PostgreSQL persistence, HTTP endpoints, sessions, Flutter UI, and route guards.

L8. 2026-11-23 — T1 PostgreSQL persistence completed: credentials now live in independent accounts, existing profile-based installations migrate transactionally at API startup without deleting their volume, duplicate emails translate at the repository boundary, and Docker packages the migrations. Evidence: PostgreSQL 17 integration tests passed for fresh persistence and legacy profile/organization/donation/reservation migration; `dart analyze` and the backend suite passed; independent recheck resolved the existing-volume blocker. T1 remains open pending HTTP endpoints, sessions, Flutter UI, and route guards.

L9. 2026-11-23 — Follow-up hardening preserved legacy credential columns for rolling-deployment and rollback compatibility, serialized concurrent migration starts with a transaction-scoped PostgreSQL advisory lock, exercised concurrent and repeated migration startup, and added CI-backed PostgreSQL integration execution. The candidate review was declined after its OpenCode refuter transport failed; corroborated findings were corrected under ordinary repository policy.
