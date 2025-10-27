# PaPa (Patungan Paket)

**PaPa** adalah aplikasi mobile/web untuk membuat **paket patungan privat** (by-invitation) dengan sistem cicilan bulanan. Pengelola (host) membuat paket dengan `total_harga`, `durasi_bulan`, dan `target_anggota`. Paket hanya akan **aktif** jika jumlah anggota yang bergabung **sama persis** dengan `target_anggota`.

Target pengguna: komunitas ibu-ibu, RT/RW, keluarga, arisan.

---

## Fitur Utama (MVP)
- Register / Login (Phone & Google)
- Role: Pengelola (Host) & Anggota (Member)
- Buat paket privat (host) — set total_harga, durasi_bulan, target_anggota
- Undang anggota via kode/link
- Hitung otomatis cicilan per anggota
- Status paket: Draft → Menunggu Anggota → Aktif → Selesai
- Sistem pembayaran: desain integrasi payment gateway (Xendit/Midtrans) + manual transfer (konfirmasi oleh host atau otomatis jika ada webhook)
- Generate jadwal pembayaran bulanan setelah paket aktif
- Notifikasi pengingat jatuh tempo (FCM) dan reminder via webhook/WA gateway (opsional)

---

## Arsitektur & Stack
- Frontend: Flutter (MVVM + Stacked Architecture)
- Backend: Supabase (Auth, DB, Storage, Functions)
- Database: PostgreSQL (melalui Supabase)
- Payment Gateway: Xendit / Midtrans (design-ready)
- Deployment: GitHub Actions + Supabase Hosting

---

## Data Model (ringkas)
- `users`
- `packages`
- `package_members`
- `payments`
- `invitations`
- `audit_logs`

---

## Business Rules Penting
1. **Strict Activation:** Paket hanya berpindah ke `aktif` jika jumlah anggota == `target_anggota`.
2. **Tidak bisa ubah `total_harga` atau `durasi_bulan` setelah paket `aktif`.**
3. **Perhitungan nominal per anggota per bulan:**
   - `nominal_per_anggota_per_bulan = total_harga / durasi_bulan / target_anggota`
   - Terapkan pembulatan yang konsisten (mis. round ke 2 desimal, handle sisa cent).
4. **Jika ada pembayaran terlambat → notifikasi & kebijakan denda opsional** (atur di pengaturan paket).

---

## Flow Pembayaran (Desain)

### Manual Transfer
1. Anggota melihat jadwal cicilan (bulan ke N, nominal, due_date)
2. Melakukan transfer manual ke rekening yang tertera
3. Upload bukti pembayaran pada aplikasi
4. Pengelola (host) memverifikasi bukti dan menandai `payments.status = 'paid'`

### Payment Gateway (Xendit/Midtrans)
- Integrasi webhook untuk verifikasi otomatis
- Gunakan recurring invoice atau create invoice per cicilan
- Flow:
  1. Backend membuat invoice untuk tiap pembayaran (payment record) + callback URL
  2. User membayar via metode yang dipilih
  3. Gateway memanggil webhook → backend set `payments.status = 'paid'`

---

## Setup Lokal (developer)
1. Clone repo:
```bash
git clone https://github.com/<username>/papa.git
cd papa
```
2. Setup Supabase:
```bash
# pastikan supabase cli terinstall
supabase login
supabase init
# import schema lewat SQL UI atau supabase db push (jika pake migrations)
```
3. Import `supabase_schema.sql` ke database
4. Konfigurasi `.env` (lihat bagian ENVs)
5. Jalankan Edge Functions (jika pake) atau siapkan endpoint webhook
6. Jalankan Flutter app:
```bash
flutter pub get
flutter run
```

---

## ENV yang perlu diset
- `SUPABASE_URL`
- `SUPABASE_KEY`
- `PAYMENT_GATEWAY_KEY` (XENDIT/Midtrans, sandbox keys)
- `FCM_SERVER_KEY`
- `HOST_REKENING_INFO` (untuk manual transfer string)
- `BASE_URL` (backend / edge functions)

---

## Deployment
- Deploy Supabase (managed)
- Deploy Edge Functions / webhook ke Vercel / Supabase Functions
- Setup webhook di Payment Gateway
- Release Flutter app ke Play Store / App Store

---

## Testing
- Unit test untuk kalkulasi cicilan
- Integration test untuk flow activation & payment webhook
- End-to-end test: create package → invite members → package aktif → generate payments → bayar semua → paket selesai

---

## Roadmap singkat (high level)
- MVP (3 bulan): core flow + manual payment
- Integrasi gateway + automation (bulan 4)
- Fitur komunitas & WA reminder (bulan 5–6)

---

## Contributing
- Gunakan branching model `feature/*`, `fix/*`, `hotfix/*`
- Buat PR, sertakan screenshot & test case

---

_Dokumen ini berbahasa Indonesia sesuai permintaan._
Generated on: 2025-10-27 05:12:09Z
