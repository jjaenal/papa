# PaPa (Patungan Paket)

## 👨‍💻 Developer

- **Name**: PaPa Team
- **Contact**: papa.team@example.com

## 📱 About

PaPa adalah aplikasi mobile/web untuk membuat paket patungan privat (by-invitation) dengan sistem cicilan bulanan. Target pengguna: komunitas ibu-ibu, RT/RW, keluarga, arisan.

## 🚀 Features

- Buat paket privat dengan total harga, durasi, dan target anggota
- Undang anggota via kode/link
- Hitung otomatis cicilan per anggota
- Status paket: Draft → Menunggu Anggota → Aktif → Selesai
- Sistem pembayaran manual dan payment gateway

## 🛠 Tech Stack

- Flutter
- Dart
- Supabase (Auth, DB, Storage, Functions)
- Stacked Architecture (MVVM)
- Payment Gateway: Xendit/Midtrans (design-ready)

## 📦 Installation

```bash
# Clone repo
git clone https://github.com/username/papa.git
cd papa

# Install dependencies
flutter pub get

# Setup Supabase
# Import schema dari supabase_schema.sql

# Run app
flutter run
```

## 🧪 Testing

```bash
# Run tests
flutter test

# Update golden files
flutter test --update-goldens
```

## 📁 Project Structure

```
lib/
├── app/
├── models/
├── services/
├── ui/
│   ├── bottom_sheets/
│   ├── common/
│   ├── dialogs/
│   └── views/
└── utils/
```

## 📝 Recent Changes

### 2025-01-28 - v0.2.0

- **Files Modified**: `auth_service.dart`, `login_viewmodel.dart`, `login_view.dart`, `auth_service_test.dart`
- **Authentication Improvements**:
  - ✅ Enhanced error handling with reactive `lastError` field in AuthService
  - ✅ Improved loading states with modal overlay and disabled inputs during auth operations
  - ✅ Added error banner in Login UI for better user feedback
  - ✅ Fixed deprecated `withOpacity` usage in favor of `withValues(alpha:)`
- **Testing & Quality**:
  - ✅ Added comprehensive unit tests for error handling scenarios
  - ✅ Created `dart_test.yaml` to eliminate golden tag warnings
  - ✅ All 18 tests passing with improved error validation
- **Impact**: Users now get clear error messages and smooth loading experience during authentication

### [Previous] - v0.1.0

- **Initial Setup**: Project structure and documentation

## 🐛 Known Issues

- Project dalam tahap awal pengembangan

## 📄 License

MIT License
