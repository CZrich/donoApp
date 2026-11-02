# Fase 7: Preparación del proyecto Flutter

## Resultado actual

La base Flutter está creada y verificada para web. Incluye Android y web como plataformas objetivo, tema compartido, navegación, Riverpod, `go_router` y configuración opcional de Supabase. La compilación Android permanece bloqueada por componentes faltantes del SDK local y debe verificarse antes de cerrar formalmente esta fase.

## Componentes preparados

- Flutter 3.47.7 y Dart 3.13.5.
- Identificador Android `pe.alimentored.alimentored`.
- Plataforma Android generada.
- Plataforma web generada.
- `supabase_flutter` para backend.
- `flutter_riverpod` para estado e inyección.
- `go_router` para navegación.
- `intl` para formatos.
- Tema visual basado en los mockups.
- Estructura feature-first.
- Rutas iniciales para acceso, roles, publicación, donaciones, historial y perfil.
- Dos pruebas de widgets para bienvenida y navegación.

## Configuración de Supabase

La aplicación puede arrancar sin credenciales durante el desarrollo visual. Para habilitar Supabase se requieren:

```text
SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY
```

Se conserva compatibilidad temporal con `SUPABASE_ANON_KEY`. Nunca debe proporcionarse `service_role` a Flutter.

## Verificación realizada

| Comando | Resultado |
|---|---|
| `dart format lib test` | Correcto |
| `flutter analyze` | Correcto, sin incidencias |
| `flutter test` | Correcto, 2 pruebas superadas |
| `flutter build web` | Correcto, salida en `build/web` |
| `flutter build apk --debug` | Pendiente por configuración local del SDK Android |

## Bloqueo de Android

`flutter doctor -v` informa:

- Falta el componente Android `cmdline-tools`.
- Flutter no puede determinar el estado completo de las licencias Android.
- No hay un dispositivo Android conectado; solo Chrome y Linux aparecen disponibles.

La primera compilación intentó descargar componentes de Android SDK, pero Gradle no finalizó dentro del tiempo de verificación. No se considera una compilación Android exitosa.

## Acción necesaria

Instalar `Android SDK Command-line Tools` desde Android Studio o mediante el administrador oficial del SDK, aceptar las licencias y repetir:

```bash
flutter doctor -v
flutter build apk --debug
```

Si se desea ejecutar la aplicación, también deberá iniciarse un emulador o conectarse un dispositivo Android.

## Criterios de aceptación

- [x] Proyecto Flutter creado para Android y web.
- [x] Dependencias instaladas y documentadas.
- [x] Tema y componentes base preparados.
- [x] Navegación principal preparada.
- [x] Estructura feature-first creada.
- [x] Análisis estático y pruebas superados.
- [x] Compilación web superada.
- [ ] Compilación Android superada.
- [ ] Ejecución en dispositivo o emulador Android verificada.

## Siguiente paso

Resolver el toolchain Android y verificar la ejecución web. Después podrá comenzar la Unidad 1 de la Fase 8: autenticación, registro y selección de rol.
