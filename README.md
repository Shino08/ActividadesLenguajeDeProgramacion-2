# Actividades Lenguaje de Programación 2

Repositorio de ejercicios de PHP y desarrollo web.

## Descripción del Proyecto

Esta es una colección de ejercicios de PHP y desarrollo web enfocados en conceptos de lenguaje de programación.

**Entorno**: XAMPP (PHP 8.2.12) en Windows

## Estructura del Proyecto

El repositorio consiste en módulos de ejercicios independientes, cada uno en su propio directorio:

- **SanitizarEmails/**: Validación y sanitización de correos electrónicos usando filtros de PHP
  - `index.html`: Formulario para recopilar 3 direcciones de correo
  - `process.php`: Validación backend usando `FILTER_SANITIZE_EMAIL` y `FILTER_VALIDATE_EMAIL`

- **SumaDeTresNum/**: Demostración simple de cálculo en PHP
  - `index.php`: Genera tres números aleatorios (1-100) y muestra su suma

- **LandingPage/**: Página de aterrizaje HTML estática con múltiples secciones
  - `index.html`: Página con navegación, artículos y formulario de contacto

- **DisenioSQL/**: Diseño completo de base de datos para un sistema de blog multimedia
  - `BlogSQL.sql`: Esquema SQL documentado con todos los tipos de relaciones
  - `DOCUMENTACION.md`: Documentación técnica completa del diseño de base de datos

## Comandos Comunes

### Ejecutar Archivos PHP

Dado que PHP no está en el PATH del sistema, usa la ruta completa de XAMPP:

```pwsh
# Ejecutar un archivo PHP directamente
C:\xampp\php\php.exe <archivo>.php

# Ejemplo: Ejecutar la calculadora de suma
C:\xampp\php\php.exe SumaDeTresNum\index.php
```

### Acceder vía Servidor Web

Inicia Apache de XAMPP y accede a través del navegador:

```
http://localhost/Lenguaje_2/SanitizarEmails/
http://localhost/Lenguaje_2/SumaDeTresNum/
http://localhost/Lenguaje_2/LandingPage/
```

### Pruebas

No hay framework de pruebas automatizadas configurado. Las pruebas son manuales mediante:
1. Iniciar el servidor Apache de XAMPP
2. Navegar a la URL localhost apropiada
3. Interactuar con los formularios/páginas

## Notas de Arquitectura

### Patrón de Procesamiento de Formularios PHP

El código sigue un patrón tradicional de procesamiento de formularios PHP:

1. **Formulario Front-end** (`index.html`): Recopila entrada del usuario vía formulario HTML
2. **Envío POST**: El formulario envía datos a un procesador PHP separado
3. **Backend PHP** (`process.php` o `index.php`): 
   - Recibe datos POST vía superglobal `$_POST`
   - Realiza validación/procesamiento
   - Genera resultados directamente como HTML
4. **Sin Framework**: PHP puro sin MVC o motores de plantillas

### Consideraciones de Seguridad

- El módulo `SanitizarEmails` demuestra el uso correcto de funciones de filtro de PHP:
  - `filter_var()` con `FILTER_SANITIZE_EMAIL` para limpiar entrada
  - `filter_var()` con `FILTER_VALIDATE_EMAIL` para verificar formato
  - `htmlspecialchars()` para prevenir XSS al mostrar datos del usuario

### Organización de Archivos

Cada ejercicio es autocontenido con dependencias mínimas. No hay configuración compartida, utilidades o autoloading. Al agregar nuevos ejercicios, sigue el patrón de crear un nuevo directorio de nivel superior.

---

## 🗄️ Proyecto de Base de Datos - DisenioSQL

### Descripción General

Sistema completo de base de datos para una plataforma de blog multimedia que implementa **todos los tipos de relaciones** en bases de datos relacionales.

### Características del Diseño

#### Tipos de Relaciones Implementadas

1. **Relación 1:1** (Uno a Uno)
   - `usuarios ↔ perfil_usuario`
   - Cada usuario tiene exactamente un perfil único

2. **Relación N:1** (Muchos a Uno)
   - `articulos → usuarios` (autor)
   - `videos → usuarios` (autor)
   - `podcasts → usuarios` (autor)
   - `articulos/videos/podcasts → categorias`
   - Múltiples contenidos pueden pertenecer a un mismo usuario o categoría

3. **Relación N:N** (Muchos a Muchos)
   - `articulos ↔ etiquetas`
   - `videos ↔ etiquetas`
   - `podcasts ↔ etiquetas`
   - Implementadas con tablas pivot (articulo_etiqueta, video_etiqueta, podcast_etiqueta)

4. **Relación 1:1 Polimórfica**
   - `imagenes_destacadas` → (articulos | videos | podcasts)
   - Cada contenido puede tener una imagen destacada

5. **Relación N:1 Polimórfica**
   - `comentarios` → (articulos | videos | podcasts)
   - Múltiples comentarios pueden pertenecer a cualquier tipo de contenido

6. **Relación N:N Polimórfica**
   - `reacciones` ↔ usuarios × (articulos | videos | podcasts)
   - Sistema de reacciones emocionales (like, love, wow, sad, angry)

### Estructura de la Base de Datos

#### Entidades Principales
- `usuarios` - Cuentas de acceso al sistema
- `perfil_usuario` - Información extendida de cada usuario (1:1)
- `categorias` - Clasificación principal del contenido
- `etiquetas` - Tags para clasificación flexible

#### Tipos de Contenido
- `articulos` - Contenido en formato texto/blog
- `videos` - Contenido multimedia de video
- `podcasts` - Contenido de audio/podcast

#### Entidades Polimórficas
- `imagenes_destacadas` - Imagen principal para cualquier contenido (1:1)
- `comentarios` - Sistema de comentarios con moderación (N:1)
- `tipos_reaccion` - Catálogo de tipos de reacciones
- `reacciones` - Reacciones de usuarios a contenido (N:N)

### Análisis y Diseño

#### Análisis de Requerimientos

Basado en una **entrevista simulada con el cliente** que requiere:
- Sistema multi-autor para diferentes tipos de contenido
- Perfiles de usuario personalizados
- Sistema de categorización (categorías + etiquetas)
- Interacción social (comentarios moderados + reacciones)
- Métricas de engagement (vistas, reproducciones)
- Imágenes destacadas para todo el contenido

#### Reglas de Negocio

- **RN-01**: Un usuario = un perfil único
- **RN-02**: Un contenido = un autor + una categoría
- **RN-03**: Un contenido = múltiples etiquetas
- **RN-04**: Un contenido = múltiples comentarios (con moderación)
- **RN-05**: Un contenido = una imagen destacada
- **RN-06**: Un usuario = una reacción por contenido (puede cambiarla)
- **RN-07**: Eliminar usuario → eliminar su contenido (CASCADE)
- **RN-08**: Eliminar categoría → NO permitido si tiene contenido (RESTRICT)

### Características Técnicas

- **Motor**: MySQL 8.0+ / MariaDB 10.5+
- **Charset**: utf8mb4 (soporte completo Unicode + emojis)
- **Collation**: utf8mb4_unicode_ci
- **Engine**: InnoDB (transaccional, integridad referencial)
- **Documentación**: Comentarios en SQL + archivo DOCUMENTACION.md

### Decisiones de Diseño Importantes

#### ¿Por qué Relaciones Polimórficas?

✅ **Ventajas**:
- Una tabla en lugar de tres (ej: comentarios vs comentarios_articulos, comentarios_videos, comentarios_podcasts)
- Código más DRY (Don't Repeat Yourself)
- Fácil extensión a nuevos tipos de contenido
- Consultas unificadas

❌ **Desventajas**:
- No se puede usar FOREIGN KEY tradicional
- Integridad referencial manejada por aplicación

**Decisión**: El beneficio en mantenibilidad supera la pérdida de constraints de BD.

#### ¿Por qué Separar usuarios y perfil_usuario?

✅ **Ventajas**:
- Rendimiento: Login no carga datos pesados (TEXT, URLs)
- Seguridad: Datos sensibles (password) separados de datos públicos
- Escalabilidad: Perfil puede crecer sin afectar tabla de autenticación

### Instalación y Uso

#### Importar la Base de Datos

```bash
# Opción 1: Desde phpMyAdmin
1. Abrir phpMyAdmin (http://localhost/phpmyadmin)
2. Crear nueva base de datos "blog_multimedia"
3. Importar archivo DisenioSQL/BlogSQL.sql

# Opción 2: Desde línea de comandos
mysql -u root -p < DisenioSQL/BlogSQL.sql
```

#### Consultas de Ejemplo

```sql
-- Ver usuarios con sus perfiles (1:1)
SELECT u.nombre, u.email, p.biografia, p.ubicacion 
FROM usuarios u 
INNER JOIN perfil_usuario p ON u.id = p.usuario_id;

-- Ver artículos con autor y categoría (N:1)
SELECT a.titulo, u.nombre AS autor, c.nombre AS categoria
FROM articulos a 
INNER JOIN usuarios u ON a.autor_id = u.id 
INNER JOIN categorias c ON a.categoria_id = c.id;

-- Ver artículos con sus etiquetas (N:N)
SELECT a.titulo, GROUP_CONCAT(e.nombre) AS etiquetas 
FROM articulos a 
INNER JOIN articulo_etiqueta ae ON a.id = ae.articulo_id 
INNER JOIN etiquetas e ON ae.etiqueta_id = e.id 
GROUP BY a.id;

-- Ver comentarios de un artículo (N:1 Polimórfica)
SELECT c.comentario, u.nombre AS usuario
FROM comentarios c 
INNER JOIN usuarios u ON c.usuario_id = u.id 
WHERE c.contenido_type = 'articulo' AND c.contenido_id = 1;

-- Ver reacciones por contenido (N:N Polimórfica)
SELECT r.contenido_type, tr.nombre AS reaccion, COUNT(*) AS total 
FROM reacciones r 
INNER JOIN tipos_reaccion tr ON r.tipo_reaccion_id = tr.id 
GROUP BY r.contenido_type, r.contenido_id, tr.id;
```

### Documentación Completa

Para más detalles sobre:
- Diagramas Entidad-Relación
- Explicación detallada de cada tipo de relación
- Justificación de decisiones de diseño
- Estructura completa de tablas
- Más consultas de ejemplo

**Ver**: [`DisenioSQL/DOCUMENTACION.md`](DisenioSQL/DOCUMENTACION.md)

### Datos de Ejemplo Incluidos

El archivo SQL incluye datos de ejemplo para todas las tablas:
- 3 usuarios con perfiles
- 3 categorías
- 2 artículos, 1 video, 1 podcast
- 4 etiquetas con relaciones N:N
- Imágenes destacadas (1:1 polimórfica)
- Comentarios (N:1 polimórfica)
- 5 tipos de reacciones con ejemplos (N:N polimórfica)

