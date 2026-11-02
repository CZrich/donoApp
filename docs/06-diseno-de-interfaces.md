# Fase 6: Diseño de interfaces

## Resultado de la fase

Se diseñaron wireframes de baja fidelidad y un prototipo navegable de alta fidelidad para el flujo principal de AlimentoRed. Los artefactos se encuentran en `mocks/` y cubren Android y una adaptación web responsive.

## 1. Ruta de revisión

1. Abrir `mocks/wireframes/flujo-principal.svg` para validar estructura.
2. Abrir `mocks/mockups/index.html` en un navegador.
3. Recorrer las nueve pantallas desde la navegación superior.
4. Probar publicación, reserva, historial y cierre de sesión.
5. Contrastar cada pantalla con la matriz de trazabilidad de este documento.

## 2. Principios de diseño

- **Acción principal visible:** cada pantalla destaca una acción prioritaria.
- **Reconocimiento antes que memoria:** estados, filtros y datos importantes permanecen visibles.
- **Confianza:** las responsabilidades sanitarias y logísticas se explican antes de reservar.
- **Accesibilidad:** estados combinan texto, forma y color; no dependen únicamente del color.
- **Prevención de errores:** acciones críticas requieren confirmación y los formularios anticipan validaciones.
- **Diseño adaptable:** la arquitectura de información permanece estable entre móvil y escritorio.

## 3. Sistema visual

### Personalidad

La identidad busca transmitir cercanía, confianza y aprovechamiento responsable. Evita representar la problemática desde la lástima; presenta a donantes y organizaciones como participantes activos de una red comunitaria.

### Colores

| Uso | Color | Hexadecimal |
|---|---|---|
| Primario | Verde comunidad | `#176B52` |
| Primario oscuro | Verde bosque | `#0D4F3B` |
| Fondo suave | Verde menta | `#E8F5EF` |
| Acento | Amarillo cálido | `#F5C95D` |
| Acento secundario | Lima clara | `#D9F4A7` |
| Fondo general | Crema | `#F8F5ED` |
| Texto principal | Verde tinta | `#17332D` |
| Texto secundario | Gris verde | `#66756F` |
| Error | Rojo tierra | `#B3443E` |

### Tipografía

- Familia principal: **Manrope**.
- Títulos: peso 700–800.
- Texto y formularios: peso 400–600.
- Etiquetas: mayúsculas breves con espaciado moderado.

En Flutter se utilizará una fuente empaquetada o una alternativa compatible sin depender obligatoriamente de una conexión externa.

### Componentes

- Botón primario verde con etiqueta explícita.
- Botón secundario textual para acciones reversibles.
- Tarjetas de donación con imagen, estado, cantidad, ubicación y fecha límite.
- Chips para filtros y estados.
- Campos con etiqueta persistente y error cercano.
- Tarjetas de impacto que separan kilogramos, unidades, litros y porciones.
- Diálogos inferiores para confirmar reserva, cancelación y entrega.
- Navegación inferior en móvil y navegación lateral o superior en escritorio.

## 4. Pantallas y propósito

| Pantalla | Propósito | Acción principal |
|---|---|---|
| Acceso | Comunicar valor e iniciar sesión | Iniciar sesión |
| Registro | Elegir rol y crear cuenta | Continuar registro |
| Inicio del donante | Resumir actividad y publicaciones | Publicar donación |
| Publicar | Registrar datos completos del alimento | Publicar |
| Inicio de organización | Descubrir oferta vigente | Explorar donaciones |
| Donaciones | Buscar y filtrar resultados | Abrir detalle |
| Detalle | Evaluar condiciones y responsabilidad | Reservar |
| Historial e impacto | Seguir estados y resultados | Abrir actividad |
| Perfil | Mantener datos de coordinación | Guardar cambios |

## 5. Estados de interfaz requeridos

Cada pantalla con datos remotos deberá contemplar:

- **Carga:** indicador y acciones bloqueadas cuando exista riesgo de duplicación.
- **Datos:** contenido actualizado y acciones según rol y estado.
- **Vacío:** explicación y acción útil, como limpiar filtros o publicar.
- **Error recuperable:** mensaje comprensible y acción para reintentar.
- **Sin permisos:** explicación sin mostrar información protegida.
- **Sin conexión:** conservar estabilidad y permitir reintento.
- **Éxito:** confirmación breve sin interrumpir innecesariamente el flujo.

## 6. Comportamiento adaptable

### Móvil

- Una columna.
- Navegación inferior por rol.
- Formularios verticales.
- Confirmaciones mediante panel inferior.
- Botones principales de ancho completo.

### Web de escritorio

- Contenido centrado con ancho máximo legible.
- Navegación lateral o superior persistente.
- Formularios con dos columnas solo para campos relacionados.
- Listados en cuadrícula cuando exista espacio.
- Diálogos centrados con foco controlado.

La adaptación web no debe estirar una pantalla móvil hasta ocupar todo el monitor.

## 7. Accesibilidad

- Contraste mínimo verificable antes de implementación.
- Objetivos táctiles cercanos o superiores a 44 × 44 px.
- Etiquetas semánticas para botones, imágenes y estados.
- Orden de foco lógico en web.
- Mensajes que no dependan únicamente de iconos.
- Posibilidad de aumentar texto sin perder acciones.
- Fotografías con descripción alternativa basada en el título de la donación.

## 8. Matriz pantalla–requisito–historia

| Pantalla | Requisitos | Historias |
|---|---|---|
| Acceso | RF-02 | HU-02 |
| Registro | RF-01 | HU-01 |
| Inicio del donante | RF-05, RF-15 | HU-05, HU-11 |
| Publicar donación | RF-04, RF-16, RF-17 | HU-04, HU-12, HU-13 |
| Inicio de organización | RF-08, RF-09 | HU-06 |
| Donaciones disponibles | RF-08, RF-09 | HU-06 |
| Detalle y reserva | RF-10, RF-11 | HU-07, HU-08 |
| Historial e impacto | RF-12 a RF-15 | HU-09 a HU-11 |
| Perfil | RF-03 | HU-03 |

## 9. Decisiones fuera del prototipo

- No se diseñó chat porque está excluido del MVP.
- No se muestra una certificación sanitaria inexistente.
- La ubicación se representa mediante dirección y distrito; el mapa sigue condicionado.
- Las notificaciones remotas no forman parte del prototipo.
- La verificación documental de organizaciones queda para una versión futura.

## 10. Criterios de aceptación de la fase

- [x] Existen wireframes de baja fidelidad.
- [x] Existen mockups de alta fidelidad navegables.
- [x] Se cubren las nueve pantallas mínimas del plan.
- [x] La guía visual define colores, tipografía y componentes.
- [x] Se documentan estados de carga, error, vacío y éxito.
- [x] El diseño considera Android y web adaptable.
- [x] Cada pantalla se relaciona con requisitos e historias aprobadas.
- [x] Los diseños no agregan funcionalidades fuera del alcance.

## Siguiente fase

Crear el proyecto Flutter, configurar Android y web, integrar dependencias, preparar Supabase y construir la navegación y el sistema visual compartido.
