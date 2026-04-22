# Stylo AI - iOS Build Guide for TestFlight

## Requisitos

### Software
- **macOS** 14.0+ (Sonoma o superior)
- **Xcode** 15.0+ (descargar desde Mac App Store)
- **Flutter SDK** 3.11+ (`flutter --version` para verificar)
- **CocoaPods** (`sudo gem install cocoapods`)

### Cuentas
- **Apple Developer Account** ($99 USD/ano) - [developer.apple.com](https://developer.apple.com)
- **App Store Connect** - acceso configurado con el mismo Apple ID

## 1. Configuracion Inicial de Xcode

### 1.1 Abrir el proyecto
```bash
open mobile/ios/Runner.xcworkspace
```
> IMPORTANTE: Abrir `.xcworkspace`, NO `.xcodeproj`

### 1.2 Configurar Signing & Capabilities
1. Seleccionar el target **Runner** en el panel izquierdo
2. Ir a la pestana **Signing & Capabilities**
3. Marcar **Automatically manage signing**
4. Seleccionar tu **Team** (tu Apple Developer Account)
5. Verificar que el **Bundle Identifier** sea: `app.styloai.mobile`

### 1.3 Configurar el Team ID
Editar `ios/ExportOptions.plist` y reemplazar `TEAM_ID_HERE` con tu Team ID real.
Tu Team ID se encuentra en [developer.apple.com/account](https://developer.apple.com/account) > Membership Details.

## 2. Certificados y Provisioning Profiles

### Opcion A: Managed Signing (Recomendado)
Xcode gestiona automaticamente los certificados y profiles cuando seleccionas
"Automatically manage signing". Solo necesitas:
1. Estar logueado con tu Apple ID en Xcode > Settings > Accounts
2. Tener el rol de Admin o App Manager en tu equipo de desarrollo

### Opcion B: Signing Manual
1. Ir a [developer.apple.com/account/resources/certificates](https://developer.apple.com/account/resources/certificates)
2. Crear un **Apple Distribution Certificate**
3. Crear un **App ID** con bundle ID `app.styloai.mobile`
4. Crear un **Provisioning Profile** de tipo App Store
5. Descargar e instalar en Xcode

## 3. Build del IPA

### 3.1 Instalar dependencias
```bash
cd mobile/
flutter pub get
cd ios/
pod install
cd ..
```

### 3.2 Build sin code signing (verificacion)
```bash
flutter build ios --release --no-codesign
```
Esto verifica que el proyecto compila correctamente sin necesitar certificados.

### 3.3 Build del IPA para TestFlight
```bash
flutter build ipa --release \
  --export-options-plist=ios/ExportOptions.plist
```

El archivo IPA se genera en:
```
build/ios/ipa/stylo_ai.ipa
```

### 3.4 Build con version especifica
```bash
flutter build ipa --release \
  --build-name=1.0.0 \
  --build-number=1 \
  --export-options-plist=ios/ExportOptions.plist
```

## 4. Subir a TestFlight

### Opcion A: Desde Xcode (Transporter)
1. Abrir **Xcode > Window > Organizer**
2. Seleccionar el archive mas reciente
3. Click en **Distribute App**
4. Seleccionar **App Store Connect**
5. Seguir el wizard hasta completar la subida

### Opcion B: Desde Terminal (xcrun)
```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/stylo_ai.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

Para obtener API Key e Issuer ID:
1. Ir a [appstoreconnect.apple.com/access/integrations/api](https://appstoreconnect.apple.com/access/integrations/api)
2. Crear una nueva API Key con rol **App Manager**
3. Descargar el archivo `.p8` y guardarlo en `~/.appstoreconnect/private_keys/`

### Opcion C: Transporter App
1. Descargar **Transporter** desde la Mac App Store
2. Arrastrar el archivo `.ipa` a la ventana de Transporter
3. Click en **Deliver**

## 5. Configurar TestFlight

### 5.1 En App Store Connect
1. Ir a [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Seleccionar **My Apps** > **Stylo AI**
3. Ir a la pestana **TestFlight**
4. El build aparecera automaticamente despues de procesarse (~15-30 min)

### 5.2 Testing Interno (hasta 100 testers)
1. En TestFlight > **Internal Testing**
2. Crear un grupo de testers
3. Agregar testers por email (deben tener Apple ID)
4. Los testers reciben invitacion por email

### 5.3 Testing Externo (hasta 10,000 testers)
1. En TestFlight > **External Testing**
2. Crear un grupo
3. Enviar para **Beta App Review** (requerido la primera vez)
4. Una vez aprobado, agregar testers o compartir link publico

### 5.4 Link Publico de TestFlight
Despues de la aprobacion de Beta App Review, puedes generar un link publico:
- Formato: `https://testflight.apple.com/join/XXXXXXXX`
- Compartible con cualquier persona que tenga un iPhone

## 6. Testers: Como Instalar

Los testers deben:
1. Descargar **TestFlight** desde el App Store en su iPhone
2. Abrir el link de invitacion recibido por email o el link publico
3. Aceptar la invitacion en TestFlight
4. Instalar **Stylo AI** desde TestFlight

## 7. Troubleshooting

### Error: "No signing certificate"
```bash
# Limpiar y regenerar
flutter clean
cd ios && pod deintegrate && pod install && cd ..
```
Luego abrir Xcode y re-seleccionar el Team.

### Error: "Provisioning profile doesn't match"
Verificar que el Bundle ID en Xcode coincida exactamente con `app.styloai.mobile`.

### Error: "Module not found"
```bash
cd ios && pod install --repo-update && cd ..
```

### Build lento o falla
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

## 8. Checklist Pre-Release

- [ ] Bundle ID correcto: `app.styloai.mobile`
- [ ] Version y build number actualizados en `pubspec.yaml`
- [ ] App icons configurados en `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- [ ] Info.plist con permisos necesarios (camara, galeria, ubicacion)
- [ ] Firebase configurado con `GoogleService-Info.plist`
- [ ] `.env` con variables de produccion
- [ ] Probado en dispositivo fisico antes de subir
- [ ] Screenshots preparados para App Store Connect
