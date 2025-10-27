# TODO.md — PaPa (Patungan Paket)

## Tujuan Sprint 0 (Persiapan)

- Setup repo & environment
- Desain skema DB & create SQL file
- Wireframe utama: Home, Create Package, Package Detail, Payments

### Week 1 — Setup & Auth

- [x] Init repo + license + README
- [ ] Setup Supabase project (Auth + Database + Storage)
- [ ] Import `supabase_schema.sql`
- [ ] Implement Auth (phone(H95R835GLE543KKMV7YMJ1MM) + Google)
- [ ] Basic onboarding flow (profil singkat)

### Week 2 — Core Models & CRUD

- [ ] Table `packages` CRUD (create draft, edit draft)
- [ ] Implement `invite code` generation & invitation flow
- [ ] Join package by code (validasi unique)
- [ ] UI: form create package + validation (total_harga, durasi, target anggota)

### Week 3 — Activation Logic & Members

- [ ] Implement strict activation logic (trigger after join)
- [ ] Trigger/function: generate payment schedule when package aktif
- [ ] UI: package detail (members list, status, progress)
- [ ] Validations: prevent duplicate join, prevent edit after aktif

### Week 4 — Payment Flow (Manual)

- [ ] Implement payments table & upload bukti (storage)
- [ ] Host verification UI (approve/reject payment)
- [ ] Notifikasi untuk upload & verifikasi (FCM + in-app)
- [ ] Handle overdue payments (status + reminder)

### Week 5 — Payment Gateway Design + Integration Prep

- [ ] Integrasi sandbox gateway (Xendit/Midtrans) — desain API
- [ ] Implement invoice creation endpoints
- [ ] Implement webhook endpoint untuk verifikasi otomatis
- [ ] Mapping gateway event -> pembayaran status

### Week 6 — Polish & Testing

- [ ] End-to-end testing (create→join→activate→payments)
- [ ] UI polish (large typography, accessible colors)
- [ ] Prepare Play Store / App Store assets
- [ ] Setup basic CI (GitHub Actions) for lint & tests

## Fitur Tambahan (Roadmap)

- [ ] Referral & join via link
- [ ] Grup chat internal per paket
- [ ] Auto WA reminder via gateway/webhook
- [ ] Dashboard admin & reporting
- [ ] Analytics & user retention metrics

## Acceptance Criteria (sample)

- Paket hanya aktif jika jumlah anggota == target_anggota
- Cicilan yang dihitung per anggota harus konsisten dan dapat diverifikasi
- Manual payment flow: upload bukti → host approve → status updated
