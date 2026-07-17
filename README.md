# Medical Request Voice App

**A cross-platform Flutter application for creating medical supply request forms using voice or manual entry.**

Designed for offline healthcare environments with full Arabic and English speech recognition, RTL/LTR support, and a built-in offline licensing system.

---

## Author & Copyright

**© 2024 Abdullah Alshwerif (0917156449)**

All rights reserved. This software is proprietary. No part of this application may be copied, modified, distributed, or sold without the express written permission of the author. Each installation requires a unique registration code tied to the device. See the [LICENSE](LICENSE) file for full terms.

---

## Table of Contents

1. [Features](#features)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Database Schema](#database-schema)
5. [Prerequisites](#prerequisites)
6. [Installation & Build](#installation--build)
7. [Usage Guide](#usage-guide)
8. [Licensing System](#licensing-system)
9. [Arabic RTL Support](#arabic-rtl-support)
10. [Medication Database](#medication-database)
11. [Dependencies](#dependencies)
12. [Publishing to Stores](#publishing-to-stores)

---

## Features

### Core
- **Voice-driven request creation**: Tap the microphone, speak item names in Arabic or English, and the app matches them against a built-in database of 6,882 medical items.
- **Manual entry**: Search and add items by typing; fuzzy matching handles typos and partial names.
- **Quantity by voice**: Speak quantities as words ("twenty", "عشرون") — the app parses them into numbers automatically.
- **Offline operation**: The entire app works without internet. Speech recognition uses the device's built-in engine. Data is stored locally in SQLite.
- **Bilingual**: Full Arabic and English UI with instant language toggle. The app respects RTL/LTR direction throughout.

### Request Management
- **Header fields**: Title, date, department, requester name, and signature.
- **Line items**: Each item has a name, quantity (with +/− steppers), and optional notes.
- **Reordering**: Move items up or down within the request.
- **Scrollable list**: Items display in a scrollable area that never hides behind the bottom action bar.
- **Save & resume**: Requests persist in the local database. History view groups them by date.
- **Edit saved requests**: Open any past request, modify it, and re-save.

### Export
- **Word (.docx)**: Generates a properly formatted OOXML document with bordered tables. Arabic text uses Unicode BiDi control characters and `<w:bidi/>`/`<w:rtl/>` markup so it renders correctly (not reversed) in Microsoft Word.
- **PDF**: Generates a PDF with the Cairo font embedded for correct Arabic glyph shaping. Text direction is set to RTL for Arabic content.
- **Share**: Uses the platform share sheet to send the exported file via email, messaging, or any installed app.

### Import
- **Supported formats**: .docx, .txt, .csv, .xls
- **Merge or replace**: Add imported items to the existing database, or replace the entire database.
- **Smart parsing**: Extracts item names from Word tables, text lists, comma-separated values, and Excel BIFF records.

### Licensing
- **Per-device registration**: Each installation generates a unique device ID. A registration code must be entered to activate the app.
- **Offline verification**: Codes are verified locally using HMAC-SHA256 — no server connection required.
- **Master code**: A master activation code exists for the author to unlock any device.

---

## Architecture

The app follows **Clean Architecture** with the **Flutter BLoC** pattern for state management.

```
┌─────────────────────────────────────────────┐
│              Presentation                    │
│  (Screens, Widgets, BLoC Events/States)      │
├─────────────────────────────────────────────┤
│                 Domain                       │
│  (Entities, Business Logic, Models)          │
├─────────────────────────────────────────────┤
│                  Data                        │
│  (Repositories, Services, SQLite, Assets)    │
├─────────────────────────────────────────────┤
│                 Core                         │
│  (Constants, Theme, DB, Utils, Services)     │
└─────────────────────────────────────────────┘
```

### Layers

- **Core**: Cross-cutting concerns — constants, theme, database helper, speech service, locale service, license service, utility functions (number parsing, fuzzy matching, BiDi handling, DOCX/PDF exporters), and shared widgets.
- **Domain**: Pure Dart entities with no framework dependencies — `MedicalItem`, `RequestEntity`, `RequestItemEntity`.
- **Data**: Repositories that mediate between the SQLite database and the domain layer — `ItemsRepository`, `RequestsRepository`, `ImportService`, `ExportService`.
- **Presentation**: BLoC classes (events, states, blocs) and UI screens.

### State Management

Each feature has its own BLoC:

| Feature | BLoC | Responsibility |
|---------|------|----------------|
| Items | `ItemsBloc` | Search, fuzzy match, voice search, item selection |
| Request Builder | `RequestBuilderBloc` | Add/edit/reorder/delete items, save/load requests, header fields |
| History | `HistoryBloc` | Load all saved requests, delete, open for editing |

---

## Project Structure

```
medical_request_app/
├── lib/
│   ├── main.dart                          # Entry point, app bootstrap, license gate
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart         # DB names, table names, keys, author info
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Material 3 theme, Cairo font, colors
│   │   ├── database/
│   │   │   └── database_helper.dart       # SQLite open/create, 3 tables, indexes
│   │   ├── services/
│   │   │   ├── locale_service.dart        # Locale + RTL/LTR direction (ChangeNotifier)
│   │   │   ├── speech_service.dart        # speech_to_text wrapper, Ar/En switching
│   │   │   └── license_service.dart       # HMAC-SHA256 per-device license codes
│   │   ├── utils/
│   │   │   ├── number_parser.dart         # Arabic/English word → number parser
│   │   │   ├── fuzzy_matcher.dart         # Levenshtein distance + similarity
│   │   │   ├── bidi_helper.dart           # Unicode BiDi controls for RTL in exports
│   │   │   ├── docx_exporter.dart         # OOXML .docx generation
│   │   │   └── pdf_exporter.dart          # PDF generation with Cairo font
│   │   └── widgets/
│   │       ├── voice_button.dart          # Animated microphone button
│   │       ├── empty_state.dart           # Generic empty state widget
│   │       └── request_item_card.dart     # Request line item card
│   ├── features/
│   │   ├── items/
│   │   │   ├── domain/
│   │   │   │   └── medical_item.dart      # MedicalItem entity
│   │   │   ├── data/
│   │   │   │   ├── items_repository.dart  # CRUD, search, seeding
│   │   │   │   └── import_service.dart    # Parse .docx/.txt/.csv/.xls
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── items_event.dart
│   │   │       │   ├── items_state.dart
│   │   │       │   └── items_bloc.dart
│   │   │       ├── items_browser_screen.dart
│   │   │       └── import_screen.dart
│   │   ├── request/
│   │   │   ├── domain/
│   │   │   │   ├── request_entity.dart
│   │   │   │   └── request_item_entity.dart
│   │   │   ├── data/
│   │   │   │   ├── requests_repository.dart
│   │   │   │   └── export_service.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── request_builder_event.dart
│   │   │       │   ├── request_builder_state.dart
│   │   │       │   └── request_builder_bloc.dart
│   │   │       ├── widgets/
│   │   │       │   ├── edit_item_dialog.dart
│   │   │       │   └── export_dialog.dart
│   │   │       └── request_builder_screen.dart
│   │   ├── history/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── history_event.dart
│   │   │       │   ├── history_state.dart
│   │   │       │   └── history_bloc.dart
│   │   │       └── history_screen.dart
│   │   ├── home/
│   │   │   └── presentation/
│   │   │       └── home_shell.dart        # NavigationBar, 4 tabs, language toggle
│   │   └── license/
│   │       └── presentation/
│   │           └── license_activation_screen.dart
│   └── l10n/
│       ├── app_en.arb                     # English strings (~120 keys)
│       ├── app_ar.arb                     # Arabic strings (~120 keys)
│       ├── app_localizations.dart         # Generated
│       ├── app_localizations_en.dart      # Generated
│       └── app_localizations_ar.dart      # Generated
├── assets/
│   ├── seed/
│   │   ├── master_items.json              # 6,882 medical items
│   │   ├── speech_vocabulary.json         # 7,198 speech tokens
│   │   ├── arabic_speech_map.json         # 105 Arabic mappings
│   │   └── pharma_companies.json          # 89 pharma companies
│   ├── fonts/
│   │   ├── Cairo-Regular.ttf              # Static weight 400
│   │   └── Cairo-Bold.ttf                 # Static weight 700
│   └── images/
├── test/
├── l10n.yaml
├── pubspec.yaml
├── LICENSE
└── README.md
```

---

## Database Schema

SQLite database (`medical_request.db`) with three tables:

### `medical_items`
Master catalog of medical supply items.

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT PRIMARY KEY | UUID |
| item_name | TEXT NOT NULL | Name of the item (Arabic or English) |
| category | TEXT | Optional category |
| created_at | INTEGER | Creation timestamp (ms) |
| updated_at | INTEGER | Last update timestamp (ms) |

**Indexes**: `idx_items_name` on `item_name` for fast search.

### `requests`
Saved request headers.

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT PRIMARY KEY | UUID |
| title | TEXT | Request title |
| date | TEXT | Request date |
| department | TEXT | Department name |
| requester | TEXT | Requester name |
| signature | TEXT | Signature |
| status | TEXT | Status (draft, submitted, etc.) |
| created_at | INTEGER | Creation timestamp (ms) |
| updated_at | INTEGER | Last update timestamp (ms) |

### `request_items`
Line items belonging to a request.

| Column | Type | Description |
|--------|------|-------------|
| id | TEXT PRIMARY KEY | UUID |
| request_id | TEXT NOT NULL | FK → requests.id |
| item_id | TEXT | FK → medical_items.id (nullable) |
| item_name | TEXT NOT NULL | Item name (denormalized for export) |
| quantity | INTEGER NOT NULL DEFAULT 1 | Quantity |
| notes | TEXT | Optional notes |
| order_index | INTEGER NOT NULL DEFAULT 0 | Sort order within request |

**Indexes**: `idx_ri_request` on `request_id`, `idx_ri_item` on `item_id`.

**Foreign keys**: Enabled (`PRAGMA foreign_keys = ON`). `request_items.request_id` references `requests.id` with `ON DELETE CASCADE`.

---

## Prerequisites

- **Flutter** >= 3.24.5 (tested with 3.44.6)
- **Dart** >= 3.5.4 (tested with 3.12.2)
- **Android Studio** or **VS Code** with Flutter extension
- **Android SDK** (for Android builds)
- **Xcode** (for iOS builds, macOS only)
- A physical device or emulator with speech recognition support for voice features

### Install Flutter

```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PWD/flutter/bin:$PATH"

# Verify installation
flutter doctor
```

---

## Installation & Build

### 1. Clone or extract the project

```bash
cd medical_request_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Generate localization files

```bash
flutter gen-l10n
```

### 4. Run the app (debug mode)

```bash
flutter run
```

### 5. Build release APK (Android)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### 6. Build release IPA (iOS)

```bash
flutter build ipa --release
```

Output: `build/ios/ipa/medical_request_app.ipa`

### 7. Build for Windows

```bash
flutter build windows --release
```

### 8. Static analysis

```bash
flutter analyze
```

Expected output: **No issues found!**

---

## Usage Guide

### First Launch

1. **License activation**: On first launch, the app displays a license activation screen showing your device ID. Enter the registration code provided by the author to activate. Once activated, the app remembers the activation and does not ask again.

2. **Home screen**: The main interface has four tabs accessible via the bottom navigation bar:
   - **Dashboard**: Shows statistics (item count, request count) and quick action buttons.
   - **New Request**: Create a new medical supply request.
   - **History**: View, open, or delete previously saved requests.
   - **Import**: Import custom item lists from files.

### Creating a Request

1. Tap the **New Request** tab.
2. **Add items by voice**: Tap the microphone button. Speak an item name (e.g., "باراسيتامول" or "Paracetamol"). The app searches the database and adds the best match. Speak the quantity as a word (e.g., "عشرون" or "twenty") and the app converts it to a number.
3. **Add items by search**: Tap the **Add Item** button (＋ icon in the bottom bar). Type or speak to search the database. Tap an item to add it.
4. **Edit items**: Tap the edit (pencil) icon on any item card to change its name, quantity, or notes. Use the +/− steppers for quick quantity changes.
5. **Reorder items**: Use the up/down arrows on item cards to change the order.
6. **Delete items**: Tap the delete (trash) icon on an item card.
7. **Set header info**: Tap the **Header** button (document icon) to set the title, date, department, requester, and signature.
8. **Save**: Tap the **Save** button (disk icon) to persist the request.
9. **Export**: Tap the **Export** button (share icon) to generate a Word or PDF document and share it.

### Scrolling

The item list scrolls freely. Items added beyond the visible area appear as you scroll — they never hide behind the bottom action bar. When you add a new item, the list auto-scrolls to show it.

### Language Toggle

Tap the **translate icon** (🌐) in the top-right corner of the app bar to instantly switch between Arabic and English. The entire UI, including text direction (RTL/LTR), updates immediately. The choice is persisted for the next launch.

### History

The History tab lists all saved requests grouped by date. Tap a request to open it for editing. Tap the delete icon to remove a request (with confirmation).

### Import

1. Tap the **Import** tab.
2. Tap **Pick File** and select a .docx, .txt, .csv, or .xls file.
3. Choose **Merge** (add to existing items) or **Replace** (replace all items).
4. The app parses the file and updates the database. A message shows how many items were found and imported.

---

## Licensing System

### How It Works

The app uses an offline, per-device licensing system based on HMAC-SHA256.

1. **Device ID**: On first launch, the app generates a unique device identifier from hardware/platform properties.
2. **Registration code**: The author generates a registration code from the device ID using a secret key and HMAC-SHA256. The code is a short alphanumeric string.
3. **Activation**: The user enters the registration code on the license activation screen. The app verifies it locally by recomputing the HMAC and comparing.
4. **Persistence**: Once activated, the status is saved in SharedPreferences. The app does not require re-activation on subsequent launches.
5. **Master code**: A master activation code can unlock any device. This is known only to the author.

### Generating Registration Codes

The author can generate registration codes using the following Dart code:

```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String generateCode(String deviceId) {
  const secretKey = 'YOUR_SECRET_KEY_HERE'; // Same as in license_service.dart
  final hmac = Hmac(sha256, utf8.encode(secretKey));
  final digest = hmac.convert(utf8.encode(deviceId));
  final hex = digest.toString();
  // Take first 12 characters, format as XXXX-XXXX-XXXX
  final code = hex.substring(0, 12).toUpperCase();
  return '${code.substring(0, 4)}-${code.substring(4, 8)}-${code.substring(8, 12)}';
}
```

Or use the master code (defined in `app_constants.dart`) to activate any device.

---

## Arabic RTL Support

### In the UI

The app uses Flutter's built-in `Directionality` widget. When Arabic is selected, the entire app switches to RTL (right-to-left) layout: text alignment, icon positions, navigation flow, and padding all adapt automatically.

### In Exports (Word/PDF)

Arabic text in Word and PDF documents requires special handling to avoid reversed/garbled rendering:

- **DOCX**: The exporter inserts Unicode BiDi control characters (RLM \u200F, RLE \u202B, PDF \u202C) around Arabic text runs. Paragraphs use `<w:bidi/>` to signal right-to-left paragraph direction, and runs use `<w:rtl/>` for RTL text shaping. The Cairo font is embedded for proper Arabic glyph rendering.
- **PDF**: The exporter uses the `pdf` package with the Cairo TTF font embedded. Arabic text is wrapped with BiDi control characters and rendered with `textDirection: rtl` to ensure correct visual order.

### `BidiHelper` utility

The `BidiHelper` class provides:
- `hasArabic(String)` — detects Arabic characters
- `isRtl(String)` — determines if a string needs RTL rendering
- `wrapForBiDi(String)` — wraps text with appropriate Unicode control characters
- `secureArabic(String)` — ensures Arabic text has trailing RLM mark
- Constants for RLM, LRM, RLE, LRE, PDF control characters

---

## Medication Database

### Seed Data

The app ships with a pre-seeded database of **6,882 medical items** compiled from:

- Worldwide medication trade names and generic names
- Arabic pharmaceutical company products (89 companies catalogued)
- Items extracted from the user's provided documents (supply lists, surplus/deficit reports, inventory valuations)

### Speech Vocabulary

A **7,198-token speech vocabulary** enhances recognition accuracy for medical terms in both Arabic and English. The vocabulary includes:

- Generic drug names (paracetamol, amoxicillin, ibuprofen, etc.)
- Trade names from major pharma companies
- Arabic medical terms and transliterations
- Dosage forms (tablets, capsules, injections, syrups, etc.)
- Unit names and quantities

### Arabic Speech Map

105 Arabic-to-normalized mappings handle common speech recognition variants (e.g., different spellings of the same drug name).

### Adding Custom Items

Users can import their own item lists via the Import tab. Imported items are merged into or replace the seed database.

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | ^8.1.6 | State management (BLoC pattern) |
| equatable | ^2.0.5 | Value equality for entities/states |
| sqflite | ^2.3.3+1 | SQLite database |
| path | ^1.9.0 | Path manipulation |
| path_provider | ^2.1.4 | File system paths |
| speech_to_text | ^6.6.0 | Arabic/English speech recognition |
| permission_handler | ^11.3.1 | Runtime permissions |
| file_picker | ^8.1.2 | File selection for import |
| share_plus | ^10.0.0 | Share sheet for exports |
| archive | ^3.6.1 | ZIP/OOXML for DOCX |
| xml | ^6.5.0 | XML parsing for DOCX |
| intl | ^0.20.2 | Internationalization |
| uuid | ^4.5.1 | Unique IDs |
| collection | ^1.18.0 | List/collection utilities |
| shared_preferences | ^2.3.2 | Key-value persistence |
| pdf | ^3.11.1 | PDF generation |
| printing | ^5.13.3 | PDF rendering/sharing |
| crypto | ^3.0.5 | HMAC-SHA256 for license codes |
| flutter_localizations | sdk | Localization delegates |

---

## Publishing to Stores

### Google Play Store

1. **Create a keystore**:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure signing** in `android/app/build.gradle`:
   ```gradle
   signingConfigs {
       release {
           keyAlias 'upload'
           keyPassword 'YOUR_KEY_PASSWORD'
           storeFile file('upload-keystore.jks')
           storePassword 'YOUR_STORE_PASSWORD'
       }
   }
   buildTypes {
       release {
           signingConfig signingConfigs.release
       }
   }
   ```

3. **Build signed APK/AAB**:
   ```bash
   flutter build appbundle --release
   ```

4. **Upload** to the [Google Play Console](https://play.google.com/console).

5. **Set pricing**: In the Play Console, go to Monetize → Pricing to set the app as paid. Users purchase the app, and the licensing system provides per-device registration.

### Apple App Store

1. **Configure signing** in Xcode: Open `ios/Runner.xcworkspace`, set the team and signing certificate.

2. **Build IPA**:
   ```bash
   flutter build ipa --release
   ```

3. **Upload** via Xcode or Transporter to App Store Connect.

4. **Set pricing**: In App Store Connect, go to Pricing and Availability to set the app as paid.

### Alternative: Registration Code Distribution

Instead of (or in addition to) store pricing, the per-device licensing system allows direct distribution:

1. Distribute the APK/IPA directly to users.
2. Each user's device shows a unique device ID on first launch.
3. The user sends the device ID to the author.
4. The author generates a registration code and sends it back.
5. The user enters the code to activate the app.

This approach works fully offline and does not require store infrastructure.

---

## License

See the [LICENSE](LICENSE) file for the full proprietary license terms.

© 2024 Abdullah Alshwerif (0917156449). All rights reserved.
