# Plan de desarrollo de AlimentoRed

AlimentoRed será una aplicación multiplataforma desarrollada con Flutter para conectar donantes de alimentos con organizaciones sociales. El trabajo se realizará durante dos semanas y seguirá un orden verificable: cada fase debe producir una evidencia concreta antes de comenzar la siguiente.

## Decisiones principales

| Aspecto | Decisión |
|---|---|
| Problema social | Desperdicio de alimentos aprovechables y dificultad de organizaciones sociales para acceder a donaciones |
| Solución | Publicar, localizar, reservar y registrar la entrega de donaciones de alimentos |
| Beneficiarios | Comedores comunitarios, albergues y otras organizaciones sociales |
| Usuarios | Donantes y representantes de organizaciones sociales |
| Framework | Flutter con Dart |
| Plataformas principales | Android y web |
| Alcance | Producto mínimo viable demostrable en dos semanas |

## Regla de avance

No se iniciará una fase hasta completar y revisar los entregables de la fase anterior. Los cambios de alcance deberán registrarse en este documento.

## Orden de trabajo

### Fase 1. Planteamiento del problema

**Objetivo:** justificar que la aplicación responde a una necesidad social real.

**Entregables:**

- [x] Descripción y delimitación del problema.
- [x] Contexto en el que ocurre.
- [x] Población afectada y beneficiarios.
- [x] Causas y consecuencias.
- [x] Evidencias o fuentes que demuestren su existencia.
- [x] Pregunta central del proyecto.

**Criterio de finalización:** el problema puede explicarse sin mencionar todavía las pantallas o la tecnología.

### Fase 2. Árbol de problemas y objetivos

**Objetivo:** relacionar las causas del problema con las funcionalidades que tendrá la solución.

**Entregables:**

- [x] Árbol de problemas: problema central, causas y efectos.
- [x] Árbol de objetivos: objetivo central, medios y fines.
- [x] Objetivo general.
- [x] Objetivos específicos medibles.
- [x] Alcance y exclusiones del proyecto.

**Criterio de finalización:** cada funcionalidad propuesta responde a una causa o necesidad identificada.

### Fase 3. Requisitos del sistema

**Objetivo:** definir con precisión lo que la aplicación debe hacer y las condiciones que debe cumplir.

**Entregables:**

- [x] Actores y roles del sistema.
- [x] Requisitos funcionales identificados como RF-01, RF-02, etc.
- [x] Requisitos no funcionales identificados como RNF-01, RNF-02, etc.
- [x] Reglas de negocio.
- [x] Criterios de aceptación verificables.
- [x] Matriz que relacione problema, objetivo y requisito.

**Criterio de finalización:** todos los requisitos son claros, comprobables y posibles dentro de dos semanas.

### Fase 4. Historias de usuario y casos de uso

**Objetivo:** describir cómo interactuará cada usuario con la aplicación.

**Entregables:**

- [x] Historias de usuario priorizadas.
- [x] Criterios de aceptación por historia.
- [x] Diagrama general de casos de uso.
- [x] Descripción de flujos principales y alternativos.
- [x] Flujo de navegación entre pantallas.

**Criterio de finalización:** se puede recorrer el proceso completo desde el registro hasta la entrega de una donación.

### Fase 5. Arquitectura y modelo de datos

**Objetivo:** definir la estructura técnica antes de programar.

**Entregables:**

- [x] Arquitectura general de la aplicación Flutter.
- [x] Organización de carpetas y responsabilidades.
- [x] Entidades y relaciones del dominio.
- [x] Modelo de datos.
- [x] Estrategia de persistencia con Supabase.
- [x] Manejo de autenticación, imágenes y ubicación.

**Criterio de finalización:** cada requisito tiene un lugar definido dentro de la arquitectura y el modelo de datos.

### Fase 6. Wireframes y mockups

**Objetivo:** validar la experiencia de usuario antes de construir las interfaces.

**Pantallas mínimas:**

- [x] Bienvenida e inicio de sesión.
- [x] Registro y selección de rol.
- [x] Inicio del donante.
- [x] Formulario de publicación de una donación.
- [x] Inicio de la organización social.
- [x] Listado y detalle de donaciones.
- [x] Reserva y confirmación.
- [x] Historial de publicaciones y reservas.
- [x] Perfil e indicadores de impacto.

**Entregables:**

- [x] Wireframes de baja fidelidad.
- [x] Mockups de alta fidelidad.
- [x] Guía breve de colores, tipografía y componentes.
- [x] Prototipo navegable o flujo visual.
- [x] Matriz entre pantalla, requisito y acción disponible.

**Criterio de finalización:** todas las interfaces derivan de requisitos aprobados y permiten completar los flujos principales.

### Fase 7. Preparación del proyecto Flutter

**Objetivo:** construir una base técnica ejecutable y verificable.

**Entregables:**

- [x] Proyecto configurado para Android y web.
- [x] Dependencias justificadas y documentadas.
- [x] Tema visual y componentes compartidos.
- [x] Navegación principal.
- [x] Estructura de carpetas acordada.
- [x] Configuración de análisis estático y pruebas.

**Criterio de finalización:** el proyecto compila y se ejecuta en Android o emulador y en navegador.

### Fase 8. Desarrollo incremental

**Objetivo:** implementar el producto mínimo viable en unidades funcionales pequeñas.

**Orden de implementación:**

- [ ] Unidad 1: acceso, registro y selección de rol.
- [ ] Unidad 2: publicación y edición de donaciones.
- [ ] Unidad 3: listado, filtros y detalle de donaciones.
- [ ] Unidad 4: reserva y cambio de estados.
- [ ] Unidad 5: historial, perfil e indicadores de impacto.
- [ ] Unidad 6: cámara, ubicación y validaciones finales.

Cada unidad incluirá su interfaz, lógica, persistencia, manejo de errores y pruebas correspondientes.

**Criterio de finalización:** los dos roles completan el flujo publicación → reserva → entrega sin datos simulados indispensables.

### Fase 9. Pruebas y validación

**Objetivo:** demostrar que el software satisface los requisitos.

**Entregables:**

- [ ] Pruebas unitarias de reglas y lógica relevante.
- [ ] Pruebas de widgets o componentes principales.
- [ ] Pruebas de integración de los flujos críticos.
- [ ] Pruebas manuales en Android y web.
- [ ] Matriz de trazabilidad entre requisitos y pruebas.
- [ ] Registro y corrección de defectos encontrados.

**Criterio de finalización:** cada requisito prioritario tiene una prueba o evidencia de validación.

### Fase 10. Evidencias, informe y presentación

**Objetivo:** preparar una entrega que permita evaluar tanto el proceso como el resultado.

**Entregables:**

- [ ] Informe con problema, objetivos, requisitos, diseño, arquitectura y pruebas.
- [ ] Capturas legibles de todas las funcionalidades principales.
- [ ] Evidencias de ejecución en Android y web.
- [ ] Guion de demostración.
- [ ] Presentación final.
- [ ] Manual breve de instalación y uso.
- [ ] Lista de limitaciones y mejoras futuras.

**Criterio de finalización:** otra persona puede instalar, ejecutar, comprender y evaluar la aplicación usando la documentación.

## Cronograma de dos semanas

| Día | Trabajo previsto | Resultado esperado |
|---|---|---|
| 1 | Fases 1 y 2 | Problema, árboles y objetivos aprobados |
| 2 | Fase 3 | Requisitos y reglas de negocio |
| 3 | Fase 4 | Historias, casos de uso y navegación |
| 4 | Fase 5 | Arquitectura y modelo de datos |
| 5 | Fase 6 | Wireframes y mockups terminados |
| 6 | Fase 7 | Proyecto Flutter ejecutable |
| 7–8 | Unidades 1 y 2 | Acceso y publicación de donaciones |
| 9–10 | Unidades 3 y 4 | Consulta, reserva y estados |
| 11 | Unidades 5 y 6 | Historial, impacto e integraciones |
| 12 | Fase 9 | Pruebas y correcciones |
| 13 | Fase 10 | Informe, capturas y presentación |
| 14 | Revisión final | Ensayo y versión entregable |

## Alcance excluido del MVP

Para proteger el plazo, la primera versión no incluirá pagos, chat en tiempo real, optimización automática de rutas, seguimiento GPS continuo ni verificación gubernamental de identidades. Estas funciones podrán presentarse como mejoras futuras.

## Lista maestra de validación del MVP

Esta sección define cuándo la aplicación puede considerarse funcional y entregable. Un requisito solo se marca como completado cuando su interfaz, API, persistencia, manejo de errores y pruebas funcionan sin depender de datos simulados.

### RF-01. Registro y autenticación

- [ ] Una persona puede registrarse con nombre, correo electrónico y contraseña.
- [ ] El correo se normaliza y no puede registrarse dos veces.
- [ ] La contraseña se almacena mediante un algoritmo de hash seguro; nunca en texto plano.
- [ ] Los campos muestran validaciones comprensibles antes de enviar el formulario.
- [ ] Una persona registrada puede iniciar sesión con correo y contraseña.
- [ ] Las credenciales incorrectas muestran un mensaje seguro que no revela datos privados.
- [ ] La sesión se conserva al recargar o reabrir la aplicación.
- [ ] El usuario puede cerrar sesión desde su perfil.
- [ ] Las rutas privadas rechazan solicitudes sin una sesión válida.
- [ ] El formulario de acceso permite mostrar u ocultar la contraseña.
- [ ] Existe un flujo documentado para recuperar o restablecer la contraseña.

**Validación:** pruebas de registro exitoso, correo duplicado, datos inválidos, acceso correcto, acceso rechazado, persistencia de sesión, cierre de sesión y acceso no autorizado.

### RF-02. Perfil de usuario

- [ ] El usuario autenticado puede consultar su perfil real.
- [ ] Puede modificar nombre, teléfono, ubicación y fotografía.
- [ ] El correo y el rol no pueden cambiarse accidentalmente desde el formulario general.
- [ ] La imagen anterior se conserva si no se selecciona una nueva.
- [ ] Los cambios persisten en PostgreSQL y se reflejan al volver a ingresar.
- [ ] La pantalla presenta estados de carga, éxito, vacío y error.

**Validación:** consultar, editar, recargar y verificar el perfil; rechazar campos inválidos y acceso de otro usuario.

### RF-03. Organizaciones

- [ ] Un usuario autorizado puede registrar una organización.
- [ ] El formulario solicita nombre, descripción, tipo, teléfono, correo, dirección, ubicación, horario y fotografía o logotipo.
- [ ] Los campos obligatorios y formatos se validan en frontend y backend.
- [ ] La organización queda asociada a su creador o responsable.
- [ ] El responsable puede consultar y editar su organización.
- [ ] Un usuario no puede editar ni eliminar organizaciones ajenas.
- [ ] Cualquier usuario puede consultar el listado y detalle de organizaciones activas.
- [ ] El listado ofrece búsqueda y estados de carga, vacío y error.
- [ ] Las acciones sensibles quedan protegidas por autorización del backend.

**Validación:** crear, listar, buscar, consultar detalle, editar como responsable y rechazar edición ajena.

### RF-04. Publicación de donaciones

- [ ] Un donante autenticado puede crear una donación.
- [ ] El formulario solicita título, descripción, categoría, cantidad, unidad, fecha de vencimiento, fecha y horario de retiro, ubicación e imágenes.
- [ ] La cantidad debe ser positiva y las fechas deben ser coherentes.
- [ ] La donación se crea inicialmente en estado `available`.
- [ ] El propietario puede editar o cancelar una donación disponible.
- [ ] Un usuario no puede modificar donaciones ajenas.
- [ ] El propietario puede consultar su historial de publicaciones.
- [ ] El listado público admite búsqueda y filtros por categoría, ubicación y estado.
- [ ] El detalle muestra la información necesaria para coordinar el retiro.

**Validación:** crear, consultar, filtrar, editar y cancelar; rechazar datos inválidos y modificaciones ajenas.

### RF-05. Reserva y entrega

- [ ] El responsable de una organización puede reservar una donación disponible.
- [ ] Una donación no puede tener dos reservas activas.
- [ ] La reserva registra organización, responsable, fecha y estado.
- [ ] El donante puede aceptar o rechazar la solicitud cuando corresponda.
- [ ] Las partes pueden cancelar según las reglas de negocio documentadas.
- [ ] El flujo controla las transiciones `available`, `reserved`, `delivered`, `cancelled` y `expired`.
- [ ] La entrega requiere confirmación y queda registrada.
- [ ] Donante y organización pueden consultar su historial.
- [ ] Las operaciones concurrentes no producen reservas duplicadas.

**Validación:** recorrido completo publicación → reserva → confirmación → entrega, más cancelación, expiración y reserva concurrente.

### RF-06. Imágenes con Cloudinary

- [ ] Las imágenes de perfil, organizaciones y donaciones se almacenan en Cloudinary.
- [ ] Ningún secreto de Cloudinary se incorpora al código Flutter ni al repositorio.
- [ ] El backend controla la firma o el mecanismo seguro de carga.
- [ ] Se validan tipo MIME, extensión, tamaño máximo y cantidad de archivos.
- [ ] La aplicación presenta progreso, reintento y error de carga.
- [ ] PostgreSQL conserva únicamente identificadores y URLs necesarias.
- [ ] La sustitución o eliminación de imágenes limpia los recursos anteriores cuando corresponda.
- [ ] Existe una imagen predeterminada cuando no se ha cargado contenido.

**Variables pendientes de configurar en `.env`:**

```dotenv
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
CLOUDINARY_UPLOAD_FOLDER=alimentored
```

El archivo `.env.example` deberá contener estas claves sin valores secretos. La aplicación debe fallar con un mensaje claro si falta una variable obligatoria.

### RF-07. Experiencia y accesibilidad

- [ ] La navegación cambia según el estado de autenticación y el rol.
- [ ] Todas las acciones presentan confirmación visual y evitan envíos duplicados.
- [ ] Los formularios preservan la información cuando una solicitud recuperable falla.
- [ ] La interfaz es adaptable a Android y web.
- [ ] Los controles tienen etiquetas accesibles, contraste legible y áreas táctiles adecuadas.
- [ ] Fechas, cantidades y mensajes usan un formato consistente.
- [ ] Los errores técnicos no se muestran directamente al usuario.
- [ ] Las pantallas críticas incluyen carga, vacío, error, éxito y reintento.

### RNF-01. Seguridad

- [ ] Contraseñas protegidas con Argon2id o bcrypt y parámetros documentados.
- [ ] Sesiones mediante tokens de corta duración y renovación segura, o una estrategia equivalente documentada.
- [ ] Validación y autorización obligatorias en el backend.
- [ ] Consultas SQL parametrizadas y restricciones de integridad en la base de datos.
- [ ] Secretos fuera del repositorio y archivos `.env` ignorados por Git.
- [ ] CORS, límites de carga y rate limiting configurados para el entorno de despliegue.
- [ ] Logs sin contraseñas, tokens ni información privada innecesaria.

### RNF-02. Calidad y operación

- [ ] `flutter analyze` finaliza sin errores.
- [ ] Las pruebas unitarias y de widgets finalizan correctamente.
- [ ] Las pruebas del backend finalizan correctamente.
- [ ] Existe una prueba de integración para cada flujo crítico.
- [ ] La API expone un endpoint de salud que verifica su conexión con PostgreSQL.
- [ ] Las migraciones o scripts de base de datos pueden ejecutarse desde cero.
- [ ] Docker Compose levanta API y base de datos con una sola instrucción documentada.
- [ ] README explica configuración, variables, ejecución, pruebas y problemas frecuentes.
- [ ] La aplicación se verifica en navegador y en un dispositivo o emulador Android.
- [ ] No quedan datos simulados en los flujos obligatorios.

## Configuración prevista

El repositorio deberá mantener una plantilla `.env.example` con nombres de variables y valores locales no sensibles. Como mínimo:

```dotenv
POSTGRES_DB=alimentored
POSTGRES_USER=alimentored
POSTGRES_PASSWORD=
DB_HOST=database
DB_PORT=5432
DB_NAME=alimentored
DB_USER=alimentored
DB_PASSWORD=
PORT=8080
AUTH_TOKEN_SECRET=
AUTH_ACCESS_TOKEN_MINUTES=15
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
CLOUDINARY_UPLOAD_FOLDER=alimentored
```

Los valores reales se configuran únicamente en `.env` local o en el gestor de secretos del despliegue.

## Decisiones pendientes antes de implementar

- [x] Cualquier usuario autenticado puede crear una organización; su creador queda registrado como responsable y solo las personas autorizadas pueden administrarla.
- [ ] Confirmar si una donación se reserva inmediatamente o si el donante debe aprobar la solicitud.
- [ ] Definir si el correo debe verificarse en el MVP.
- [ ] Definir el proveedor de correo para recuperación de contraseña.
- [ ] Definir límites de tamaño y cantidad de imágenes.
- [ ] Definir si ubicación será dirección escrita, coordenadas del dispositivo o ambas.
- [ ] Confirmar política de eliminación de cuentas, organizaciones y donaciones.

## Definición de aplicación validada

La aplicación se considera validada únicamente cuando:

1. Todos los requisitos obligatorios anteriores están marcados y respaldados por evidencia.
2. Un usuario nuevo completa registro → acceso → perfil sin intervención técnica.
3. Un responsable crea y administra una organización.
4. Un donante publica una donación con imágenes reales.
5. Una organización completa reserva → coordinación → entrega.
6. Los dos roles consultan historiales persistidos.
7. Los controles de autorización impiden modificar recursos ajenos.
8. Las pruebas automatizadas, análisis estático y compilaciones Android/web finalizan correctamente.
9. La instalación desde cero funciona siguiendo únicamente el README.

## Estado actual

- [x] Tema social seleccionado.
- [x] Framework y plataformas seleccionados.
- [x] Plan de trabajo establecido.
- [x] Fase 1: planteamiento del problema.
- [x] Fase 2: árbol de problemas y objetivos.
- [x] Fase 3: requisitos del sistema.
- [x] Fase 4: historias de usuario y casos de uso.
- [x] Fase 5: arquitectura y modelo de datos.
- [x] Fase 6: wireframes y mockups.
- [ ] Fase 7: preparación del proyecto Flutter — web verificada; Android bloqueado por `cmdline-tools`.
- [ ] Fase actual: completar verificación de plataformas y auditar la implementación real contra la lista maestra del MVP.

## Siguiente paso

1. Resolver las decisiones pendientes de producto.
2. Auditar frontend, backend y base de datos contra la lista maestra.
3. Instalar Android SDK Command-line Tools y verificar la compilación Android.
4. Implementar la **Fase 8** en unidades verticales, comenzando por registro y autenticación.
