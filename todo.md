# Medical Request Voice App – Build & Delivery Checklist

## Phase 1 — Project skeleton & deps
- [x] pubspec.yaml with all dependencies
- [x] l10n.yaml config
- [x] Cairo fonts (Regular + Bold) generated from variable font

## Phase 2 — Core layer
- [x] app_constants.dart (DB, tables, pref keys, author info, speech locales)
- [x] app_theme.dart (Material 3, Cairo font, status colors)
- [x] database_helper.dart (SQLite 3 tables + indexes + FKs)
- [x] locale_service.dart (ChangeNotifier, RTL/LTR, persist)
- [x] speech_service.dart (Ar/En locale switching, listen, number parse)
- [x] license_service.dart (HMAC-SHA256 per-device codes, master code)
- [x] number_parser.dart (Ar + En word→number)
- [x] fuzzy_matcher.dart (Levenshtein + similarity + token matching)
- [x] bidi_helper.dart (Unicode BiDi controls for Ar RTL in Word/PDF)
- [x] docx_exporter.dart (OOXML .docx with bidi/rtl, Cairo font, tables)
- [x] pdf_exporter.dart (PDF with embedded Cairo TTF, rtl for Arabic)
- [x] voice_button.dart (animated mic with pulse)
- [x] empty_state.dart (generic empty state)
- [x] request_item_card.dart (item card with qty stepper, RTL-aware)

## Phase 3 — Feature modules
- [x] items: MedicalItem model, ItemsRepository, ImportService
- [x] request: RequestEntity, RequestItemEntity, RequestsRepository, ExportService
- [x] items BLoC + request_builder BLoC + history BLoC
- [x] All screens (items_browser, request_builder, history, import, home_shell, license_activation)
- [x] edit_item_dialog + export_dialog widgets

## Phase 4 — Additional features
- [x] Arabic RTL fix in exports
- [x] Worldwide + Arabic pharma medication names (6,882 items, 7,198 vocab)
- [x] Scrollable main interface
- [x] Language toggle (Ar ↔ En)
- [x] Copyright/License for Abdullah Alshwerif (0917156449)
- [x] Use provided 7 documents

## Phase 5 — Localization
- [x] app_en.arb + app_ar.arb
- [x] Generated app_localizations.dart
- [x] Wired into main.dart

## Phase 6 — Fix & verify
- [x] Fix ~200 flutter analyze errors
- [x] flutter analyze: No issues found!

## Phase 7 — Documentation & packaging
- [ ] README.md
- [ ] LICENSE
- [ ] Final delivery package (zip) + summary
