# QA Report — Stylo AI Mobile

**Fecha:** 2026-03-31
**QA:** Camila (QA Mobile Senior)
**Plataforma:** macOS 26.2 / Flutter 3.41.6 / Dart 3.11.4

---

## 1. Flutter Analyze

| Metric | Value |
|--------|-------|
| **Status** | **PASS** |
| Errors | 0 |
| Warnings | 4 (unused imports, unused field) |
| Infos | 81 (deprecated APIs, unnecessary underscores, etc.) |

**Nota:** No hay errores de compilación. Los warnings son menores (imports no usados). Los infos son mayormente `withOpacity` deprecado y `unnecessary_underscores`.

---

## 2. Unit Tests

| Metric | Value |
|--------|-------|
| **Status** | **PASS** |
| Total tests | 714 |
| Passed | 714 |
| Failed | 0 |
| Coverage | **72.4%** (>= 70% threshold) |
| Covered lines | 1000 / 1382 |

---

## 3. Android Integration Tests

| Metric | Value |
|--------|-------|
| **Status** | **FAIL** |
| Device | emulator-5554 (Pixel 9a, API 37) |
| Tests passed | 1 |
| Tests failed | 1 |
| Retries | 2 (mismo error reproducible) |

**Error:** `NotInitializedError` en Riverpod durante `_SplashScreenState._navigateAfterDelay`. El `ProviderContainer` no está inicializado cuando el splash screen intenta leer el `authNotifierProvider` después de que el test dispone el widget tree. Este es un bug real en el integration test, no un flake.

**Root cause probable:** `splash_screen.dart:46` — `_navigateAfterDelay` hace `ref.read()` después de un delay, pero el `ProviderContainer` ya fue disposed cuando el segundo test inicia. Falta un guard `if (!mounted) return` antes del `ref.read()`.

---

## 4. iOS Integration Tests

| Metric | Value |
|--------|-------|
| **Status** | **BLOCKED** |
| Reason | No se pudo acceder a `xcrun simctl` (permisos denegados en sandbox) |

---

## Resultado Final

| Check | Result |
|-------|--------|
| Analyze (0 errors) | PASS |
| Unit tests (>= 70% coverage) | PASS |
| Android integration | **FAIL** |
| iOS integration | **BLOCKED** |

### **Veredicto: FAIL**

El proyecto pasa analyze y unit tests con buena cobertura (72.4%), pero los integration tests en Android fallan por un bug de lifecycle en el splash screen (Riverpod NotInitializedError). iOS no pudo ser evaluado.

### Acción requerida
- **Fix:** Agregar guard `if (!mounted) return;` en `lib/features/onboarding/presentation/screens/splash_screen.dart:43` antes de `ref.read()` en `_navigateAfterDelay`.
- **iOS:** Re-ejecutar manualmente cuando haya acceso a simuladores.
