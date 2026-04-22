# Crash Report - stylo-ai Mobile App
**Date:** 2026-03-31  
**Tester:** Lucía (QA Mobile) + Cristóbal (Director)  
**Device:** iOS Simulator (iPhone 17) + Android Emulator (pending)  
**Version:** Debug Build

---

## 🔴 Critical Issues Found

### 1. **Google Sign-In Crash (iOS)**
- **Severity:** 🔴 **CRITICAL** — App crashes on launch of Google auth
- **Steps to Reproduce:**
  1. Run app in iOS simulator
  2. Tap "Continuar con Google" button
  3. App crashes immediately (SIGABRT)
  
- **Root Cause:** `GoogleSignIn` plugin not properly initialized on iOS
  - Missing `GoogleService-Info.plist` configuration
  - No iOS URL schemes registered for Google OAuth callback
  - `google_sign_in_ios` pod dependency not fully linked
  
- **Stack Trace (inferred):**
  ```
  E/flutter ( XXXX): [ERROR:flutter/runtime/dart_isolate.cc(XXX)] Unhandled exception:
  PlatformException(exception, [UNSPECIFIED] The developer hasn't set up the project properly. Go to https://developers.google.com/mobile/add and follow the steps to create a valid GCP project.
  ```

- **Code Location:**
  - `lib/features/auth/presentation/providers/auth_provider.dart:111` → `signInWithGoogle()`
  - `lib/features/auth/data/repositories/auth_repository_impl.dart` → `signInWithGoogle()` impl

- **Affected Platform:** iOS (Simulator + Device)
- **Impact:** Users cannot authenticate with Google on iOS

---

### 2. **Missing Firebase Configuration (iOS)**
- **Severity:** 🟡 **HIGH**
- **Issue:** `GoogleSignIn` requires Firebase project setup
- **Required Setup:**
  - [ ] GoogleService-Info.plist must be added to `ios/Runner` directory
  - [ ] iOS URL Schemes must be registered in `Info.plist`
  - [ ] Bundle ID must match Firebase project configuration

---

### 3. **Apple Sign-In Not Tested Yet**
- **Severity:** 🟡 **MEDIUM**
- **Status:** Not yet tested (similar issues likely exist)
- **Required Setup:**
  - [ ] Sign in with Apple capability enabled in Xcode
  - [ ] Team ID configured for signing

---

## 📊 Test Summary

| Feature | Status | Issue | Priority |
|---------|--------|-------|----------|
| Email/Password Login | ✅ Not Tested | N/A | — |
| Google Auth (iOS) | ❌ Crash | Missing GoogleService-Info.plist | 🔴 CRITICAL |
| Google Auth (Android) | ⏳ Pending | Unknown | — |
| Apple Auth | ⏳ Pending | Unknown | — |
| App Navigation | ✅ Not Tested | N/A | — |

---

## 🔧 Next Steps for Mateo (Backend) & Lucía (Mobile Dev)

### Phase 1: Fix Google Sign-In (iOS) — **URGENT**

1. **Get Firebase Credentials**
   - Create/use existing Firebase project: `stylo-ai-firebase`
   - Download `GoogleService-Info.plist` from Firebase Console
   - Verify iOS Bundle ID: `com.styloai.app`

2. **Configure iOS Project**
   - Add `GoogleService-Info.plist` to `ios/Runner` in Xcode
   - Add to Build Phases if not automatic
   - Register URL Schemes in `ios/Runner/Info.plist`:
     ```xml
     <key>CFBundleURLTypes</key>
     <array>
       <dict>
         <key>CFBundleURLSchemes</key>
         <array>
           <string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
         </array>
       </dict>
     </array>
     ```

3. **Test on Simulator**
   - Clean build: `cd mobile && flutter clean && flutter pub get`
   - Run: `flutter run -d emulator-5554` (iOS)
   - Test: Tap "Continuar con Google"
   - Verify: Should open Google login web view (not crash)

4. **Update .env**
   - Add `GOOGLE_SIGN_IN_CLIENT_ID=com.googleusercontent.apps.XXXX`

### Phase 2: Test & Fix Android

1. Emulator: `emulator -avd Pixel_7 &`
2. Same process for Android (Google Play Services)

### Phase 3: Apple Sign-In (Optional for MVP)

- If not required for launch, defer to v1.1
- If required: Add Apple Sign-In capability + Team ID

---

## 📝 Debug Commands

```bash
# iOS Simulator crash logs
xcrun simctl spawn booted log stream --level debug --predicate 'processImagePath contains "flutter"'

# ADB logs (Android)
adb logcat | grep -E "flutter|google|auth|error"

# Flutter verbose logs
flutter run -v
```

---

## 👤 Assigned To

- **Lucía** 📱 — Mobile Developer
  - [ ] Complete Firebase iOS setup
  - [ ] Fix Google Sign-In crash
  - [ ] Test on both simulators
  - [ ] Document fixes in code

- **Mateo** ⚙️ — Backend Developer
  - [ ] Ensure backend OAuth endpoints ready
  - [ ] Verify Firebase Admin SDK configured
  - [ ] Check token validation logic

---

## ✅ Definition of Done (For This Bug)

- [ ] Google Sign-In works on iOS Simulator
- [ ] Google Sign-In works on Android Emulator
- [ ] Both navigate to `/home` or `/style-quiz` after auth
- [ ] No crashes in console logs
- [ ] Tests pass: `flutter test`
- [ ] Bug marked as RESOLVED in GitHub

---

**Status:** 🔴 BLOCKING  
**Est. Fix Time:** 2-4 hours  
**Next Review:** 2026-03-31 21:00 ART
