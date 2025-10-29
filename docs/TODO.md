# TODO.md — PaPa (Patungan Paket)

## Tujuan Sprint 0 (Persiapan)

- Setup repo & environment
- Desain skema DB & create SQL file
- Wireframe utama: Home, Create Package, Package Detail, Payments

### Week 1 — Setup & Auth

- [x] Init repo + license + README
- [x] Setup Supabase project (Auth + Database + Storage)
- [x] Import `supabase_schema.sql`
- [x] Implement Auth (phone OTP lokal + Google OAuth via Supabase)
- [x] Basic onboarding flow (profil singkat)
- [x] Enhanced Auth error handling (reactive `lastError` on all flows)
- [x] Improved loading states (modal overlay + disable inputs)
- [x] Add error banner in Login UI for clearer feedback
- [x] Add `dart_test.yaml` golden tag config to remove warnings
- [x] Update unit tests to validate error handling scenarios
- [x] Add loading spinner to buttons for better UX
- [x] Fix golden tests with SharedPreferences mocking

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

## Done ✅ — Progres Neumorphic UI

- [x] `NeumorphicActionButton`: tambah `enabled` + `icon` opsional
- [x] `NeumorphicActionButton`: tambah `isLoading` (spinner kecil + auto-disable)
- [x] `NeumorphicTextField`: widget input reusable untuk style konsisten
- [x] Refactor `LoginView` dan `OnboardingView` ke widget Neumorphic
- [x] Tambah widget tests untuk tombol & input; golden untuk dialog & views
- [x] Linting bersih (`flutter analyze`) dan semua test lulus (`flutter test`)

## Future Improvements 💡

- [ ] Evaluasi penggunaan paket fork `flutter_neumorphic_plus` (https://pub.dev/packages/flutter_neumorphic_plus)
  - Catatan: dapat mempercepat pengembangan UI, tetap jaga konsistensi dengan Stacked
