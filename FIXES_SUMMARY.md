# QA Fixes Summary — Stylo AI Mobile

**Developer**: Lucía (Flutter Dev)
**Branch**: `fix/qa-bugs-mobile`
**Date**: 2026-04-01
**QA Report**: Camila — TEST_RESULTS_MOBILE.md

---

## Bugs Resueltos

### BUG-001 (HIGH) — Toggle link se mueve en register mode

**Root cause**: Al mostrar campos de Nombre/Apellido, el Column crece y el toggle link baja ~150px, quedando fuera del viewport en pantallas chicas.

**Fix aplicado** (`auth_screen.dart`):
- `AnimatedSize` wrapping los campos de registro para transición suave
- `ScrollController` con auto-scroll al `maxScrollExtent` post-toggle, asegurando que el link siempre esté visible

**Estado**: FIXED

---

### BUG-002 (MEDIUM) — Form state inconsistency tras toggle auth mode

**Root cause**: Al cambiar entre login/register, los TextEditingControllers retenían texto y el form mantenía errores de validación del modo anterior. El focus del teclado no se dismisseaba, causando que input fuera al field equivocado.

**Fix aplicado** (`auth_screen.dart`):
- `FocusScope.of(context).unfocus()` al inicio de `_toggleMode()` — dismissea el teclado
- `_formKey.currentState?.reset()` — limpia errores de validación
- `.clear()` en los 4 TextEditingControllers — limpia texto
- Reset de `_obscurePassword = true`

**Estado**: FIXED

---

### BUG-004 (LOW) — Accessibility labels insuficientes

**Root cause**: Solo 6 elementos tenían `content-desc`. Elementos interactivos sin labels para screen readers.

**Fix aplicado** (`auth_screen.dart`):
- `Semantics` widgets agregados a todos los elementos interactivos:
  - Logo/header (`header: true`, label descriptivo)
  - Botón Google (`button: true`, "Iniciar sesión con Google")
  - Botón Apple (`button: true`, "Iniciar sesión con Apple")
  - Divider ("o", `excludeSemantics: true`)
  - Campo Nombre (`textField: true`)
  - Campo Apellido (`textField: true`)
  - Campo Email (`textField: true`)
  - Campo Contraseña (`textField: true`)
  - Toggle visibilidad contraseña (label dinámico "Mostrar/Ocultar")
  - Botón submit (label dinámico según modo)
  - Toggle login/register (label dinámico según modo)
  - Texto legal

**Estado**: FIXED — 12 elementos con accessibility labels (antes: 6)

---

### BUG-003 (MEDIUM) — Janky frames en debug

**Root cause**: 100% janky frames es comportamiento esperado en Flutter debug mode (no AOT, assertions activas, DevTools overhead).

**Validación**:
- Release APK construido exitosamente: `flutter build apk --release`
- APK size: 56.0MB
- Build confirma compilación AOT sin errores
- Janky frames en release requieren verificación en dispositivo real con `adb shell dumpsys gfxinfo`

**Estado**: VALIDATED — No requiere fix de código. Pendiente verificación de performance en release build en dispositivo real.

---

## Archivos Modificados

| Archivo | Cambios |
|---------|---------|
| `lib/features/auth/presentation/screens/auth_screen.dart` | AnimatedSize, form reset, FocusScope.unfocus(), Semantics widgets |

## Commits

| Hash | Mensaje |
|------|---------|
| `375448e` | fix: QA bugs encontrados por Camila |
| `f522acc` | fix: QA bugs - form state focus management, accessibility labels |

## Release APK

- Path: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 56.0MB
- Status: BUILD SUCCESS

## Push Status

Push bloqueado por GitHub OAuth scope — el initial commit incluye `.github/workflows/ci.yml` y el token no tiene scope `workflow`. Requiere actualización del token de autenticación.

---

## Pendientes para QA

- [ ] Verificar janky frames en release build en dispositivo real
- [ ] Re-test toggle login/register en dispositivos con pantalla <5.5"
- [ ] Verificar accessibility con TalkBack activado
- [ ] Run integration tests con single device: `flutter test integration_test/ -d emulator-5554`
