# Actividades Lenguaje de Programación 2

Repositorio de ejercicios de PHP y desarrollo web.

## Descripción del Proyecto

Esta es una colección de ejercicios de PHP y desarrollo web enfocados en conceptos de lenguaje de programación. El repositorio está alojado en: https://github.com/Shino08/ActividadesLenguajeDeProgramacion-2.git

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

- **DisenioSQL/**: Ejercicios de diseño de base de datos SQL
  - `BlogSQL.sql`: Archivo de esquema SQL (actualmente vacío)

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

