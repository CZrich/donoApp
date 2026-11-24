# AlimentoRed

Aplicación Flutter para coordinar donaciones de alimentos entre donantes y organizaciones sociales en Perú. El MVP apunta a Android y web y utiliza una API REST en Dart con PostgreSQL.

## Requisitos

- Flutter 3.47.7 o compatible.
- Dart 3.13.5 o compatible.
- Chrome para ejecutar la versión web.
- Docker Engine con Docker Compose para ejecutar la API y PostgreSQL.

## Preparar el proyecto

```bash
flutter pub get
flutter analyze
flutter test
```

## Levantar la persistencia

Crear opcionalmente un archivo `.env` desde `.env.example` y cambiar la contraseña. Después ejecutar:

```bash
docker compose up --build -d
curl http://localhost:8080/health
```

La respuesta saludable es:

```json
{"status":"ok","database":"connected"}
```

PostgreSQL queda disponible en `localhost:5432` y la API en `localhost:8080`. El esquema de `database/init/001_schema.sql` se aplica al crear el volumen por primera vez.

## Ejecutar Flutter

```bash
flutter run -d web-server \
  --web-hostname=127.0.0.1 \
  --web-port=8081 \
  --dart-define=API_BASE_URL=http://localhost:8080
```

En un emulador Android se debe usar `http://10.0.2.2:8080` como `API_BASE_URL`. En un dispositivo físico se usa la IP local de la computadora.

Para detener los servicios sin borrar los datos:

```bash
docker compose down
```

## Estructura

- `lib/app/` — arranque, rutas y tema.
- `lib/core/` — configuración y componentes compartidos.
- `lib/features/` — funcionalidades organizadas por dominio.
- `backend/` — API REST Dart que protege el acceso a PostgreSQL.
- `database/init/` — esquema inicial de PostgreSQL.
- `Dockerfile` y `docker-compose.yml` — contenedores de API y base de datos.
- `docs/` — especificación del proyecto.
- `mocks/` — wireframes y prototipo navegable.

## Estado

La arquitectura vigente es Flutter → API REST en Dart → PostgreSQL en Docker. Hay código de autenticación (registro, acceso, sesión y cierre) y consulta/actualización de perfil; su presencia no demuestra por sí sola el flujo integrado. Inicio por rol, publicación, listado e historial todavía contienen pantallas provisionales. El MVP no está completo y quedan validaciones de permisos, integración y ejecución multiplataforma. Las referencias a Supabase en documentos previos son históricas.

## Artículo y diseño

- Repositorio: https://github.com/CZrich/donoApp.git
- [Artículo académico en PDF](docs/article/alimentored-articulo.pdf) — borrador pendiente de datos de autoría.
- [Fuente editable HTML](docs/article/article.html) y [reconstrucción y limitaciones](docs/article/README.md).
- [Galería complementaria](docs/article/gallery.html) — prototipos con datos ilustrativos, no capturas de la aplicación ni evidencia de impacto.
- [Prototipo original](mocks/mockups/index.html) y [comentarios de cambios](docs/article/CHANGELOG.md).
