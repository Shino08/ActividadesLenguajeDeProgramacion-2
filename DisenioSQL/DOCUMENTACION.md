# Documentación del Diseño de Base de Datos - Blog Multimedia

## 📋 Índice

1. [Información General](#información-general)
2. [Análisis de Requerimientos](#análisis-de-requerimientos)
3. [Modelo de Negocio](#modelo-de-negocio)
4. [Diagrama Entidad-Relación](#diagrama-entidad-relación)
5. [Tipos de Relaciones](#tipos-de-relaciones)
6. [Estructura de Tablas](#estructura-de-tablas)
7. [Decisiones de Diseño](#decisiones-de-diseño)
8. [Consultas de Ejemplo](#consultas-de-ejemplo)

---

## 📌 Información General

- **Proyecto**: Sistema de Gestión de Blog Multimedia
- **Motor de BD**: MySQL 8.0+ / MariaDB 10.5+
- **Charset**: utf8mb4 (soporte completo Unicode + emojis)
- **Collation**: utf8mb4_unicode_ci
- **Motor de Almacenamiento**: InnoDB

---

## 🎯 Análisis de Requerimientos

### Entrevista Simulada con el Cliente

**Cliente**: Director de Marketing Digital de "ContentHub"

**Requerimientos Identificados**:

1. **Sistema Multi-Autor**
   - Múltiples usuarios pueden crear contenido
   - Cada autor puede publicar artículos, videos y podcasts

2. **Tipos de Contenido**
   - Artículos (texto/blog)
   - Videos (multimedia)
   - Podcasts (audio)

3. **Perfiles de Usuario**
   - Cada usuario debe tener un perfil único
   - Información: biografía, avatar, ubicación, sitio web
   - Relación 1:1 con la cuenta de usuario

4. **Sistema de Categorización**
   - Cada contenido tiene una categoría principal
   - Múltiples etiquetas por contenido (clasificación flexible)

5. **Interacción Social**
   - Sistema de comentarios para todos los tipos de contenido
   - Comentarios requieren moderación antes de publicarse
   - Sistema de reacciones emocionales (like, love, wow, sad, angry)

6. **Métricas**
   - Contador de vistas para artículos y videos
   - Contador de reproducciones para podcasts
   - Tracking de engagement (comentarios + reacciones)

7. **Imágenes Destacadas**
   - Cada contenido puede tener una imagen principal
   - Almacenar dimensiones para optimización

---

## 🏢 Modelo de Negocio

### Reglas de Negocio

1. **RN-01**: Un usuario = un perfil único (1:1)
2. **RN-02**: Un contenido = un autor + una categoría (N:1)
3. **RN-03**: Un contenido = múltiples etiquetas (N:N)
4. **RN-04**: Un contenido = múltiples comentarios (N:1 polimórfica)
5. **RN-05**: Un contenido = una imagen destacada (1:1 polimórfica)
6. **RN-06**: Un usuario = una reacción por contenido específico (N:N polimórfica con restricción)
7. **RN-07**: Eliminar usuario → eliminar su contenido y perfil (CASCADE)
8. **RN-08**: Eliminar categoría → NO permitido si tiene contenido (RESTRICT)
9. **RN-09**: Eliminar contenido → eliminar sus relaciones (CASCADE)
10. **RN-10**: Los comentarios requieren aprobación del moderador

### Entidades Principales

```
USUARIOS
├── PERFIL_USUARIO (1:1)
├── ARTÍCULOS (N:1)
├── VIDEOS (N:1)
├── PODCASTS (N:1)
├── COMENTARIOS (N:1)
└── REACCIONES (N:N)

CATEGORÍAS
├── ARTÍCULOS (N:1)
├── VIDEOS (N:1)
└── PODCASTS (N:1)

ETIQUETAS
├── ARTÍCULOS (N:N)
├── VIDEOS (N:N)
└── PODCASTS (N:N)

CONTENIDO POLIMÓRFICO
├── IMÁGENES_DESTACADAS (1:1 polimórfica)
├── COMENTARIOS (N:1 polimórfica)
└── REACCIONES (N:N polimórfica)
```

---

## 📊 Diagrama Entidad-Relación

### Relaciones Principales

```
┌─────────────┐           ┌──────────────────┐
│  usuarios   │───────────│ perfil_usuario   │
│             │   1:1     │                  │
└──────┬──────┘           └──────────────────┘
       │
       │ N:1
       │
       ├─────────┐
       │         │
       ▼         ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  articulos  │ │   videos    │ │  podcasts   │
└──────┬──────┘ └──────┬──────┘ └──────┬──────┘
       │               │               │
       │ N:1           │ N:1           │ N:1
       │               │               │
       ▼               ▼               ▼
    ┌──────────────────────────────────┐
    │        categorias                │
    └──────────────────────────────────┘

       │               │               │
       │ N:N           │ N:N           │ N:N
       │               │               │
       ▼               ▼               ▼
    ┌──────────────────────────────────┐
    │        etiquetas                 │
    │  (via tablas pivot)              │
    └──────────────────────────────────┘
```

### Relaciones Polimórficas

```
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│  articulos  │ │   videos    │ │  podcasts   │
└──────┬──────┘ └──────┬──────┘ └──────┬──────┘
       │               │               │
       │               │               │
       └───────────────┼───────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
┌─────────────┐ ┌──────────────┐ ┌──────────────┐
│  imagenes_  │ │  comentarios │ │  reacciones  │
│  destacadas │ │              │ │              │
│   (1:1)     │ │    (N:1)     │ │    (N:N)     │
└─────────────┘ └──────────────┘ └──────────────┘
```

---

## 🔗 Tipos de Relaciones

### 1. Relación 1:1 (Uno a Uno)

**Ejemplo**: `usuarios ↔ perfil_usuario`

```sql
-- Implementación
CREATE TABLE perfil_usuario (
    usuario_id INT UNIQUE NOT NULL,  -- UNIQUE garantiza 1:1
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);
```

**Características**:
- Un usuario tiene exactamente un perfil
- Un perfil pertenece a exactamente un usuario
- Se implementa con `FOREIGN KEY` + `UNIQUE constraint`

**Justificación**:
- Separación de datos de autenticación vs. datos de perfil
- Mejor rendimiento en consultas de login
- Flexibilidad para extender el perfil sin afectar tabla principal

---

### 2. Relación N:1 (Muchos a Uno)

**Ejemplo**: `articulos → usuarios` (autor)

```sql
-- Implementación
CREATE TABLE articulos (
    autor_id INT NOT NULL,  -- SIN UNIQUE = N:1
    FOREIGN KEY (autor_id) REFERENCES usuarios(id)
);
```

**Características**:
- Múltiples artículos pueden pertenecer a un mismo usuario
- Cada artículo tiene exactamente un autor
- Se implementa con `FOREIGN KEY` sin restricción UNIQUE

**Justificación**:
- Un autor puede escribir muchos artículos
- Modelo simple de autoría única por contenido
- Facilita consultas de "artículos por autor"

**Comportamiento de Eliminación**:
- `ON DELETE CASCADE`: Eliminar autor → elimina sus artículos
- `ON DELETE RESTRICT` (categorías): No permite eliminar categoría con contenido

---

### 3. Relación N:N (Muchos a Muchos)

**Ejemplo**: `articulos ↔ etiquetas`

```sql
-- Tabla pivot
CREATE TABLE articulo_etiqueta (
    articulo_id INT NOT NULL,
    etiqueta_id INT NOT NULL,
    PRIMARY KEY (articulo_id, etiqueta_id),  -- Clave compuesta
    FOREIGN KEY (articulo_id) REFERENCES articulos(id),
    FOREIGN KEY (etiqueta_id) REFERENCES etiquetas(id)
);
```

**Características**:
- Un artículo puede tener múltiples etiquetas
- Una etiqueta puede estar en múltiples artículos
- Requiere tabla pivot (intermedia)

**Justificación**:
- Clasificación flexible y multidimensional
- Reutilización de etiquetas entre contenidos
- Sin límite de etiquetas por artículo

**Campos Adicionales**:
- `fecha_asignacion`: Auditoría de cuándo se asignó la etiqueta

---

### 4. Relación 1:1 Polimórfica

**Ejemplo**: `imagenes_destacadas → (articulos|videos|podcasts)`

```sql
-- Implementación
CREATE TABLE imagenes_destacadas (
    contenido_type VARCHAR(50) NOT NULL,  -- 'articulo', 'video', 'podcast'
    contenido_id INT NOT NULL,
    UNIQUE KEY (contenido_type, contenido_id)  -- Garantiza 1:1 por tipo
);
```

**Características**:
- Una imagen puede pertenecer a un artículo, video o podcast
- Cada contenido solo puede tener una imagen destacada
- No usa `FOREIGN KEY` tradicional

**Ventajas**:
- Una sola tabla en lugar de tres (imagenes_articulos, imagenes_videos, etc.)
- Código más DRY y mantenible
- Fácil extensión a nuevos tipos de contenido

**Desventajas**:
- Integridad referencial manejada por aplicación
- No hay constraint de BD para validar `contenido_id`

---

### 5. Relación N:1 Polimórfica

**Ejemplo**: `comentarios → (articulos|videos|podcasts)`

```sql
-- Implementación
CREATE TABLE comentarios (
    contenido_type VARCHAR(50) NOT NULL,
    contenido_id INT NOT NULL,
    usuario_id INT NOT NULL,  -- FK real hacia usuarios
    INDEX (contenido_type, contenido_id)
);
```

**Características**:
- Múltiples comentarios pueden pertenecer a un mismo contenido
- Los comentarios funcionan igual para todos los tipos de contenido
- Sistema unificado de moderación

**Justificación**:
- UX consistente (misma interfaz de comentarios)
- Moderación centralizada
- Estadísticas unificadas

---

### 6. Relación N:N Polimórfica

**Ejemplo**: `reacciones → usuarios × (articulos|videos|podcasts)`

```sql
-- Implementación
CREATE TABLE reacciones (
    contenido_type VARCHAR(50) NOT NULL,
    contenido_id INT NOT NULL,
    usuario_id INT NOT NULL,
    tipo_reaccion_id INT NOT NULL,
    UNIQUE KEY (contenido_type, contenido_id, usuario_id),  -- Un usuario = una reacción
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    FOREIGN KEY (tipo_reaccion_id) REFERENCES tipos_reaccion(id)
);
```

**Características**:
- Múltiples usuarios pueden reaccionar a múltiples contenidos
- Contenidos pueden ser de múltiples tipos
- Cada usuario puede dar solo una reacción por contenido

**Regla de Negocio**:
- `UNIQUE KEY (contenido_type, contenido_id, usuario_id)`
- Permite cambiar la reacción (UPDATE)
- No permite reacciones duplicadas

**Ejemplo de Datos**:
```
usuario_id | contenido_type | contenido_id | tipo_reaccion_id
-----------|----------------|--------------|------------------
2          | 'articulo'     | 1            | 1 (like)
3          | 'articulo'     | 1            | 2 (love)
2          | 'video'        | 5            | 3 (wow)
```

---

## 📁 Estructura de Tablas

### Tabla: usuarios

| Campo | Tipo | Descripción | Justificación |
|-------|------|-------------|---------------|
| `id` | INT AUTO_INCREMENT | Identificador único | PK, suficiente para millones de usuarios |
| `nombre` | VARCHAR(100) | Nombre completo | Longitud estándar para nombres |
| `email` | VARCHAR(150) UNIQUE | Correo electrónico | Username único, 150 chars = RFC estándar |
| `password` | VARCHAR(255) | Hash de contraseña | bcrypt/argon2 (60-255 chars) |
| `fecha_registro` | TIMESTAMP | Fecha de creación | Auditoría automática |
| `activo` | BOOLEAN | Estado de cuenta | Soft-delete sin perder datos |

**Índices**:
- `PRIMARY KEY (id)`: Búsqueda O(log n)
- `UNIQUE INDEX (email)`: Login rápido, evita duplicados
- `INDEX (activo)`: Filtros eficientes

---

### Tabla: perfil_usuario (Relación 1:1)

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT AUTO_INCREMENT | ID del perfil |
| `usuario_id` | INT UNIQUE | FK a usuarios (UNIQUE = 1:1) |
| `biografia` | TEXT | Descripción personal |
| `avatar` | VARCHAR(255) | URL de imagen de perfil |
| `fecha_nacimiento` | DATE | Fecha de nacimiento |
| `ubicacion` | VARCHAR(100) | Ciudad/País |
| `sitio_web` | VARCHAR(255) | URL personal |

**Constraints**:
- `ON DELETE CASCADE`: Eliminar usuario → elimina perfil
- `ON UPDATE CASCADE`: Actualización automática

---

### Tabla: articulos (Relación N:1)

| Campo | Tipo | Descripción | Justificación |
|-------|------|-------------|---------------|
| `id` | INT AUTO_INCREMENT | ID del artículo | PK |
| `titulo` | VARCHAR(255) | Título | Longitud máxima SEO |
| `slug` | VARCHAR(255) UNIQUE | URL amigable | 'introduccion-a-php' |
| `contenido` | TEXT | Contenido completo | Hasta 65,535 chars |
| `autor_id` | INT | FK a usuarios (N:1) | Un artículo = un autor |
| `categoria_id` | INT | FK a categorías (N:1) | Una categoría principal |
| `fecha_publicacion` | TIMESTAMP | Fecha de publicación | Ordenamiento cronológico |
| `vistas` | INT DEFAULT 0 | Contador de vistas | Métrica de engagement |
| `publicado` | BOOLEAN | Estado publicación | Borrador vs publicado |

**Comportamiento de Eliminación**:
- `autor_id`: `ON DELETE CASCADE` (sin autor = sin artículo)
- `categoria_id`: `ON DELETE RESTRICT` (protección de datos)

---

### Tabla: articulo_etiqueta (Relación N:N)

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `articulo_id` | INT | FK a artículos |
| `etiqueta_id` | INT | FK a etiquetas |
| `fecha_asignacion` | TIMESTAMP | Auditoría |

**Primary Key**: `(articulo_id, etiqueta_id)` - Clave compuesta

**Ejemplo**:
```
Artículo "Intro PHP" puede tener:
- (articulo_id=1, etiqueta_id=5)  → "PHP"
- (articulo_id=1, etiqueta_id=12) → "Backend"
- (articulo_id=1, etiqueta_id=3)  → "Tutorial"
```

---

### Tabla: imagenes_destacadas (1:1 Polimórfica)

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT AUTO_INCREMENT | ID de la imagen |
| `contenido_type` | VARCHAR(50) | 'articulo', 'video', 'podcast' |
| `contenido_id` | INT | ID del contenido relacionado |
| `url_imagen` | VARCHAR(500) | URL de la imagen |
| `alt_text` | VARCHAR(255) | Texto alternativo (accesibilidad) |
| `ancho` | INT | Ancho en píxeles |
| `alto` | INT | Alto en píxeles |

**Constraint**: `UNIQUE KEY (contenido_type, contenido_id)` → Garantiza 1:1

---

### Tabla: comentarios (N:1 Polimórfica)

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT AUTO_INCREMENT | ID del comentario |
| `contenido_type` | VARCHAR(50) | Tipo de contenido |
| `contenido_id` | INT | ID del contenido |
| `usuario_id` | INT | FK a usuarios (quien comenta) |
| `comentario` | TEXT | Texto del comentario |
| `fecha_comentario` | TIMESTAMP | Fecha de creación |
| `aprobado` | BOOLEAN | Estado de moderación |

**Sin UNIQUE** = Múltiples comentarios por contenido (N:1)

---

### Tabla: reacciones (N:N Polimórfica)

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT AUTO_INCREMENT | ID de la reacción |
| `contenido_type` | VARCHAR(50) | Tipo de contenido |
| `contenido_id` | INT | ID del contenido |
| `usuario_id` | INT | FK a usuarios |
| `tipo_reaccion_id` | INT | FK a tipos_reaccion |
| `fecha_reaccion` | TIMESTAMP | Fecha de la reacción |

**Constraint**: `UNIQUE KEY (contenido_type, contenido_id, usuario_id)`
- Un usuario = una reacción por contenido
- Puede cambiarla con UPDATE

---

## 💡 Decisiones de Diseño

### ¿Por qué separar usuarios y perfil_usuario?

✅ **Ventajas**:
- Rendimiento: Login no carga datos pesados (TEXT, URLs)
- Seguridad: Datos sensibles separados de datos públicos
- Escalabilidad: Perfil puede crecer sin afectar autenticación

❌ **Alternativa rechazada**: Todo en una tabla
- Problema: Campos NULL, consultas pesadas, mezcla de concerns

---

### ¿Por qué usar relaciones polimórficas?

✅ **Ventajas**:
- Código DRY (una tabla vs. tres)
- Fácil extensión (nuevo tipo = sin cambios en BD)
- Consultas unificadas

❌ **Desventajas**:
- Sin integridad referencial a nivel BD
- Validación en capa de aplicación

**Decisión**: Usar polimórficas porque el beneficio en mantenibilidad supera la pérdida de constraints de BD.

---

### ¿Por qué CASCADE vs RESTRICT?

**CASCADE en autor_id**:
- Razón: Un artículo sin autor no tiene sentido
- Eliminar autor → eliminar su contenido

**RESTRICT en categoria_id**:
- Razón: Protección de datos masiva
- No permitir eliminar categoría con contenido
- Primero reasignar, luego eliminar

---

### ¿Por qué utf8mb4 y no utf8?

**utf8mb4**:
- Soporte completo Unicode (4 bytes)
- Emojis: 🔥 ❤️ 👍
- Caracteres raros: 𝕳𝖊𝖑𝖑𝖔

**utf8** (antiguo):
- Solo 3 bytes
- No soporta emojis
- Obsoleto en MySQL moderno

---

## 🔍 Consultas de Ejemplo

### Consulta 1:1 - Usuario con su perfil

```sql
SELECT 
    u.nombre, 
    u.email, 
    p.biografia, 
    p.ubicacion 
FROM usuarios u 
INNER JOIN perfil_usuario p ON u.id = p.usuario_id
WHERE u.activo = TRUE;
```

---

### Consulta N:1 - Artículos con autor y categoría

```sql
SELECT 
    a.titulo, 
    u.nombre AS autor, 
    c.nombre AS categoria,
    a.vistas
FROM articulos a 
INNER JOIN usuarios u ON a.autor_id = u.id 
INNER JOIN categorias c ON a.categoria_id = c.id
WHERE a.publicado = TRUE
ORDER BY a.fecha_publicacion DESC;
```

---

### Consulta N:N - Artículos con sus etiquetas

```sql
SELECT 
    a.titulo, 
    GROUP_CONCAT(e.nombre ORDER BY e.nombre SEPARATOR ', ') AS etiquetas 
FROM articulos a 
INNER JOIN articulo_etiqueta ae ON a.id = ae.articulo_id 
INNER JOIN etiquetas e ON ae.etiqueta_id = e.id 
GROUP BY a.id, a.titulo;
```

**Resultado**:
```
titulo                  | etiquetas
------------------------|------------------------
Introducción a PHP      | Backend, PHP, Tutorial
Diseño Responsivo       | CSS, Frontend, UX
```

---

### Consulta 1:1 Polimórfica - Contenido con imagen

```sql
SELECT 
    i.contenido_type AS tipo,
    CASE 
        WHEN i.contenido_type = 'articulo' THEN a.titulo
        WHEN i.contenido_type = 'video' THEN v.titulo
        WHEN i.contenido_type = 'podcast' THEN p.titulo
    END AS titulo,
    i.url_imagen,
    i.ancho,
    i.alto
FROM imagenes_destacadas i
LEFT JOIN articulos a ON i.contenido_type = 'articulo' AND i.contenido_id = a.id
LEFT JOIN videos v ON i.contenido_type = 'video' AND i.contenido_id = v.id
LEFT JOIN podcasts p ON i.contenido_type = 'podcast' AND i.contenido_id = p.id;
```

---

### Consulta N:1 Polimórfica - Comentarios por contenido

```sql
SELECT 
    c.comentario, 
    u.nombre AS usuario, 
    c.fecha_comentario 
FROM comentarios c 
INNER JOIN usuarios u ON c.usuario_id = u.id 
WHERE c.contenido_type = 'articulo' 
  AND c.contenido_id = 1
  AND c.aprobado = TRUE
ORDER BY c.fecha_comentario DESC;
```

---

### Consulta N:N Polimórfica - Reacciones por contenido

```sql
SELECT 
    r.contenido_type AS tipo,
    r.contenido_id AS id,
    tr.nombre AS reaccion,
    tr.icono,
    COUNT(*) AS total 
FROM reacciones r 
INNER JOIN tipos_reaccion tr ON r.tipo_reaccion_id = tr.id 
GROUP BY r.contenido_type, r.contenido_id, tr.id, tr.nombre, tr.icono
ORDER BY total DESC;
```

**Resultado**:
```
tipo      | id | reaccion | icono | total
----------|----|-----------|----- |------
articulo  | 1  | like      | 👍   | 45
articulo  | 1  | love      | ❤️   | 23
video     | 3  | wow       | 😮   | 12
```

---

### Consulta Compleja - Top autores por engagement

```sql
SELECT 
    u.nombre AS autor,
    COUNT(DISTINCT a.id) AS total_articulos,
    SUM(a.vistas) AS total_vistas,
    COUNT(DISTINCT c.id) AS total_comentarios,
    COUNT(DISTINCT r.id) AS total_reacciones,
    (COUNT(DISTINCT c.id) + COUNT(DISTINCT r.id)) AS engagement_total
FROM usuarios u
LEFT JOIN articulos a ON u.id = a.autor_id
LEFT JOIN comentarios c ON c.contenido_type = 'articulo' AND c.contenido_id = a.id
LEFT JOIN reacciones r ON r.contenido_type = 'articulo' AND r.contenido_id = a.id
WHERE a.publicado = TRUE
GROUP BY u.id, u.nombre
ORDER BY engagement_total DESC
LIMIT 10;
```

---

## 📝 Conclusión

Este diseño de base de datos implementa:

✅ **Todos los tipos de relaciones solicitados**:
- 1:1 (usuarios ↔ perfil_usuario)
- N:1 (articulos → usuarios/categorias)
- N:N (articulos ↔ etiquetas)
- 1:1 Polimórfica (imagenes_destacadas)
- N:1 Polimórfica (comentarios)
- N:N Polimórfica (reacciones)

✅ **Buenas prácticas**:
- Normalización adecuada
- Índices para rendimiento
- Integridad referencial
- Documentación completa
- Nombres consistentes

✅ **Escalabilidad**:
- Fácil agregar nuevos tipos de contenido
- Estructura modular
- Preparado para crecimiento

---

**Fecha de Creación**: 2025  
**Última Actualización**: 2025  
**Versión**: 1.0

