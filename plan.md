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
- [ ] Fase actual: completar verificación de plataformas.

## Siguiente paso

Instalar Android SDK Command-line Tools, verificar la compilación Android y cerrar la **Fase 7** antes de comenzar la **Fase 8, Unidad 1**.
