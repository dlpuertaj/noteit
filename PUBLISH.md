# noteIt — Google Play Publication Checklist

**App name:** noteIt
**Application ID:** `com.dlpj.noteit`
**Initial version:** `1.0.0` (versionCode 1)

Mark each item `[x]` as it is completed. **You** = action only you can take (Play Console, device, password). **Code** = changes in this repo (Claude can do).

---

## 1. App identity & code

- [x] App display name set to `noteIt` in `AndroidManifest.xml` (`android:label`)
- [x] App title set to `noteIt` in `lib/main.dart` (`MaterialApp.title`)
- [x] `pubspec.yaml` description updated
- [x] `applicationId` = `com.dlpj.noteit` in `android/app/build.gradle.kts`
- [x] `namespace` = `com.dlpj.noteit` in `android/app/build.gradle.kts`
- [x] `MainActivity.kt` moved to `kotlin/com/dlpj/noteit/` with matching `package` declaration
- [x] Debug build verified (`flutter build apk --debug`)

## 2. Visual assets

Source SVGs live in `assets/branding/`. Convert them to PNG at the listed sizes (Inkscape, ImageMagick, or any online SVG→PNG converter — flatten transparency for the Play Store icon).

- [x] 512×512 Play Store icon (PNG, no alpha) — `assets/branding/icon.png`
- [x] **You** — 1024×500 feature graphic (PNG/JPG, no alpha) — from `assets/branding/feature_graphic.svg`
- [x] 1024×1024 adaptive icon foreground (PNG, transparent) — `assets/branding/icon_foreground.png`
- [x] Adaptive icon background — solid hex `#FAFAFA` (configured in `flutter_launcher_icons.yaml`)
- [x] Legacy fallback icon — generated from `assets/branding/icon.png`
- [x] **Code** — `flutter_launcher_icons` 0.14.4 added and configured
- [x] **Code** — `dart run flutter_launcher_icons` — all mipmap densities generated
- [ ] **You** — Screenshot #1 at 1080×1920 (suggested: empty editor)
- [ ] **You** — Screenshot #2 at 1080×1920 (suggested: side panel with folder tree)
- [ ] **You** — Screenshot #3 at 1080×1920 (optional: search results)

## 3. Store listing copy

- [x] Short description drafted (`A simple, offline notes app with folders, search, and auto-save.` — 63 chars)
- [x] Full description drafted (1,720 chars; see chat history)
- [ ] **You** — Paste short description into Play Console
- [ ] **You** — Paste full description into Play Console
- [ ] **You** — Decide whether to keep the "WHAT IT IS NOT" section in the full description

## 4. Signing & release build

- [x] `signingConfigs.release` block added to `build.gradle.kts` (loads `key.properties` if present, falls back to debug)
- [x] `key.properties` and `*.jks` confirmed gitignored
- [ ] **You** — Generate `noteit-upload.jks` with `keytool` (see `PUBLISH.md` step in chat)
- [ ] **You** — Back up `noteit-upload.jks` and its passwords off-machine
- [ ] **You** — Create `android/key.properties` with `storePassword`, `keyPassword`, `keyAlias=upload`, `storeFile=noteit-upload.jks`
- [ ] **You** — Run `flutter build appbundle --release` and confirm `app-release.aab` is produced
- [ ] **You** — Verify signing certificate via `keytool -printcert -jarfile <path>` (must NOT be debug cert)

## 5. Privacy & compliance

- [x] Privacy policy URL ready
- [ ] **You** — Paste privacy policy URL into Play Console store listing
- [ ] **You** — Complete Play Console **Data safety** form (declare: no data collected, no data shared, all storage on-device)
- [ ] **You** — Complete Play Console **Content rating** questionnaire
- [ ] **You** — Complete Play Console **Target audience and content** declaration
- [ ] **You** — Complete Play Console **App category** selection (suggest: Productivity)
- [ ] **You** — Complete Play Console **Contact details** (email at minimum)
- [ ] **You** — Complete Play Console **Ads** declaration (none)
- [ ] **You** — Complete Play Console **News app** declaration (no)
- [ ] **You** — Complete Play Console **Government app** declaration (no)
- [ ] **You** — Complete Play Console **COVID-19 contact tracing** declaration (no)

## 6. Play Console setup

- [ ] **You** — Create the app in Play Console (one-time)
- [ ] **You** — Opt in to **Play App Signing** (recommended; uses your `noteit-upload.jks` as the upload key)
- [ ] **You** — Set countries/regions for distribution
- [ ] **You** — Set pricing (Free)
- [ ] **You** — Upload the `.aab` to a release track (suggest: **Internal testing** first, then promote to Production after smoke-testing)

## 7. Submit for review

- [ ] **You** — Resolve any "issues" warnings shown on the release dashboard
- [ ] **You** — Submit for review
- [ ] **You** — Wait for Google review (typically a few hours to a few days for first release)
- [ ] **You** — Address any review feedback if rejected

## 8. Post-launch (out of scope for now)

- [ ] Bump `version: 1.0.1+2` in `pubspec.yaml` for first update
- [ ] Decide on update cadence
- [ ] Set up crash reporting if desired (would require code changes)

---

## Quick-resume commands

```powershell
# Generate keystore (run once, see step 4)
keytool -genkey -v -keystore android/app/noteit-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Build release App Bundle
flutter build appbundle --release

# Verify signing
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```
