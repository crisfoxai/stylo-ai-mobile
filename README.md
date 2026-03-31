# Stylo AI - Mobile App

Tu estilo, potenciado por IA. App Flutter para iOS y Android.

## Requisitos

- Flutter 3.41+ / Dart 3.11+
- Xcode 15+ (iOS)
- Android SDK 26+ (Android)

## Setup

```bash
# Clonar e instalar dependencias
flutter pub get

# Crear archivo de entorno
cp .env.example .env
# Editar .env con las URLs de API correspondientes

# (Opcional) Generar código si se modifican modelos
dart run build_runner build --delete-conflicting-outputs
```

## Ejecutar

```bash
# Debug en dispositivo/emulador
flutter run

# Elegir dispositivo específico
flutter run -d <device_id>
```

## Tests

```bash
# Unit + widget tests
flutter test

# Con cobertura
flutter test --coverage
dart run tool/coverage_calc.dart

# Integration tests (requiere emulador/dispositivo)
flutter test integration_test/

# Análisis estático
flutter analyze
```

## CI/CD

### iOS Build (GitHub Actions)

Push a `develop` o `main` dispara automáticamente:
- Flutter analyze (0 errors required)
- Unit tests (coverage >= 70%)
- iOS build para simulator
- Integration tests en simulator (iPhone 15)
- Artefacto descargable: `ios-app-debug`

**Status badge:**
[![iOS Build & Test](https://github.com/crisfoxai/stylo-ai-mobile/actions/workflows/ios-build.yml/badge.svg)](https://github.com/crisfoxai/stylo-ai-mobile/actions/workflows/ios-build.yml)

**Descargar build:** 
1. Ve a [Actions](https://github.com/crisfoxai/stylo-ai-mobile/actions)
2. Selecciona el workflow más reciente
3. Descarga el artifact `ios-app-debug`
4. Extraé `Runner.app` y abrí en Xcode Simulator

### Android Build

Android tests corren en CI vía emulador. Descarga los artefactos igual que iOS.

### Local Testing en Simulator

```bash
# Abrir Xcode workspace
open ios/Runner.xcworkspace

# Seleccionar Device > [device name]
# Click Run (Cmd+R)
```

### Cobertura actual: **72.4%** (1000/1382 líneas)

## Build

```bash
# APK (Android)
flutter build apk --release

# App Bundle (Android - para Play Store)
flutter build appbundle --release

# iOS (requiere Mac + Xcode + cuenta de developer)
flutter build ios --release
```

## Arquitectura

```
lib/
├── main.dart              # Entry point
├── app.dart               # MaterialApp + Router + Theme
├── core/                  # Constantes, tema, red, router, errores, utils
├── features/              # Módulos por feature (Clean Architecture)
│   ├── auth/              # Autenticación (email, Google, Apple)
│   ├── onboarding/        # Splash + onboarding slides
│   ├── style_profile/     # Quiz de estilo + perfil
│   ├── wardrobe/          # Guardarropa + escaneo IA
│   ├── outfits/           # Generador de outfits + historial + favoritos
│   ├── subscription/      # Planes free/premium
│   ├── settings/          # Configuración
│   └── try_on/            # Probador virtual
└── shared/                # Widgets y providers compartidos
```

Cada feature sigue **Clean Architecture**: `domain/` (entities, repositories) -> `data/` (models, datasources, impls) -> `presentation/` (providers, screens).

## Stack

| Capa | Tecnología |
|---|---|
| State Management | Riverpod |
| Navegación | GoRouter |
| HTTP | Dio + interceptors |
| Auth | Firebase Auth (Google, Apple, email) |
| Storage | FlutterSecureStorage + SharedPreferences |
| UI | Material 3, Plus Jakarta Sans, Inter |

## Colores principales

- Primary: `#1A1A1A`
- Accent (terracotta): `#C67A5C`
- Background: `#FAFAFA`

## Documentación adicional

- `ARCHITECTURE.md` - Arquitectura técnica completa
- `API_CONTRACT.md` - Contrato REST API
- `FLUTTER_SPEC.md` - Especificación detallada de la app
- `DESIGN.json` - Design system y specs de pantallas
