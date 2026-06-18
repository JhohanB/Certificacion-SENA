# 💾 Esquema de Base de Datos - Sistema de Gestión de Certificaciones SENA

**DBMS**: MySQL 5.7+
**Charset**: utf8mb4
**Collation**: utf8mb4_unicode_ci

---

## 📊 Diagrama ER (Entidad-Relación)

```
┌─────────────────┐       ┌─────────────┐       ┌──────────────┐
│   acciones      │       │   modulos   │       │   roles      │
├─────────────────┤       ├─────────────┤       ├──────────────┤
│ id (PK)         │       │ id (PK)     │       │ id (PK)      │
│ nombre (UNIQUE) │       │ nombre(UNI) │       │ nombre(UNIQUE)
└─────────────────┘       └─────────────┘       │ descripcion  │
         ▲                       ▲               │ requiere_firma
         │                       │               │ es_coordinador
         │                       │               │ es_admin     │
         └───┬───────────────────┘               └──────┬───────┘
             │ N:M (rol_permisos)                      │
             │                                         │ 1:N
      ┌──────▼──────────┐                     ┌────────▼─────────┐
      │  rol_permisos   │                     │ usuario_roles    │
      ├─────────────────┤                     ├──────────────────┤
      │ rol_id (FK)     │                     │ usuario_id (FK)  │
      │ modulo_id (FK)  │                     │ rol_id (FK)      │
      │ accion_id (FK)  │                     │ activo           │
      └─────────────────┘                     └────────┬─────────┘
                                                       │
                                            ┌──────────▼──────────┐
                                            │    usuarios         │
                                            ├─────────────────────┤
                                            │ id (PK)             │
                                            │ documento (UNIQUE)  │
                                            │ nombre_completo     │
                                            │ correo (UNIQUE)     │
                                            │ password_hash       │
                                            │ firma_registrada    │
                                            │ activo              │
                                            └──────────┬──────────┘
                                                       │ 1:N
                                            ┌──────────▼──────────┐
                                            │  solicitudes        │
                                            ├─────────────────────┤
                                            │ id (PK)             │
                                            │ numero_documento    │
                                            │ numero_ficha        │
                                            │ nombre_aprendiz     │
                                            │ tipo_programa_id(FK)│
                                            │ estado_actual       │
                                            │ plantilla_id (FK)   │
                                            └──────────┬──────────┘
                                                       │
                              ┌────────────────────────┼────────────────────┐
                              │                        │                    │
                    ┌─────────▼────────┐   ┌──────────▼───┐    ┌──────────▼─────┐
                    │ solicitud_doc    │   │  firmas      │    │ estados_hist   │
                    ├──────────────────┤   ├──────────────┤    ├────────────────┤
                    │ documento_id(FK) │   │ rol_id (FK)  │    │ estado_nuevo   │
                    │ archivo_url      │   │ usuario_id   │    │ usuario_id(FK) │
                    │ version          │   │ estado_firma │    │ fecha_cambio   │
                    │ estado_documento │   │ fecha_firma  │    └────────────────┘
                    └──────────────────┘   └──────────────┘
```

**Tablas maestras**:
- `acciones` - Acciones disponibles (crear, leer, actualizar, eliminar)
- `modulos` - Módulos del sistema (usuarios, solicitudes, reportes, etc)
- `roles` - Roles con permisos configurables
- `usuarios` - Usuarios del sistema
- `tipo_programas` - Tipos de programas de certificación
- `documentos_requeridos` - Documentos que requiere cada programa
- `plantillas_formato` - Plantillas PDF para certificados

---

## 📋 Definición Detallada de Tablas

### 1. **Tabla: `acciones`**

Define las acciones disponibles en el sistema (crear, leer, actualizar, eliminar, etc).

```sql
CREATE TABLE acciones (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  INDEX idx_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Campos**:
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT | Identificador único |
| `nombre` | VARCHAR(50) | Nombre de la acción (CREAR, LEER, ACTUALIZAR, ELIMINAR, etc) |

**Ejemplo de datos**:
- CREAR
- LEER
- ACTUALIZAR
- ELIMINAR
- REVISAR
- APROBAR
- RECHAZAR
- FIRMAR

---

### 2. **Tabla: `modulos`**

Define los módulos o secciones del sistema.

```sql
CREATE TABLE modulos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  INDEX idx_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Ejemplo de datos**:
- Usuarios
- Solicitudes
- Documentos
- Reportes
- Configuración
- Auditoría

---

### 3. **Tabla: `roles`**

Define los roles del sistema con atributos específicos para funcionalidades.

```sql
CREATE TABLE roles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion TEXT,
  requiere_firma TINYINT(1) DEFAULT 0,
  activo TINYINT(1) DEFAULT 1,
  es_coordinador TINYINT(1) NOT NULL DEFAULT 0,
  es_funcionario_revision TINYINT(1) NOT NULL DEFAULT 0,
  es_admin TINYINT(1) NOT NULL DEFAULT 0,
  INDEX idx_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Campos**:
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | INT | ID único |
| `nombre` | VARCHAR(50) | Nombre del rol |
| `descripcion` | TEXT | Descripción |
| `requiere_firma` | TINYINT(1) | Si este rol debe firmar documentos |
| `activo` | TINYINT(1) | Está activo o no |
| `es_coordinador` | TINYINT(1) | Es rol de coordinador |
| `es_funcionario_revision` | TINYINT(1) | Es funcionario de revisión |
| `es_admin` | TINYINT(1) | Es administrador |

**Roles estándar**:
- Administrador (es_admin=1)
- Coordinador (es_coordinador=1, requiere_firma=1)
- Funcionario de Revisión (es_funcionario_revision=1, requiere_firma=1)
- Instructor
- Aprendiz
- Jefe de Centro

---

### 4. **Tabla: `usuarios`**

Almacena información de usuarios del sistema.

```sql
CREATE TABLE usuarios (
  id INT PRIMARY KEY AUTO_INCREMENT,
  documento VARCHAR(20) NOT NULL UNIQUE,
  nombre_completo VARCHAR(150) NOT NULL,
  correo VARCHAR(120) NOT NULL UNIQUE,
  telefono VARCHAR(20),
  password_hash TEXT NOT NULL,
  firma_url VARCHAR(255),
  firma_registrada TINYINT(1) DEFAULT 0,
  activo TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  debe_cambiar_password TINYINT(1) DEFAULT 0,
  debe_registrar_firma TINYINT(1) DEFAULT 0,
  intentos_fallidos INT DEFAULT 0,
  bloqueado_hasta DATETIME,
  INDEX idx_documento (documento),
  INDEX idx_correo (correo),
  INDEX idx_activo (activo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Campos**:
| Campo | Tipo | Descripción |
|-------|------|-------------|
| `documento` | VARCHAR(20) | Cédula/Documento (UNIQUE) |
| `nombre_completo` | VARCHAR(150) | Nombre completo |
| `correo` | VARCHAR(120) | Email (UNIQUE) |
| `telefono` | VARCHAR(20) | Teléfono (opcional) |
| `password_hash` | TEXT | Contraseña hasheada (Bcrypt) |
| `firma_url` | VARCHAR(255) | URL de firma digital registrada |
| `firma_registrada` | TINYINT(1) | ¿Tiene firma registrada? |
| `activo` | TINYINT(1) | ¿Usuario activo? |
| `debe_cambiar_password` | TINYINT(1) | Fuerza cambio en próximo login |
| `debe_registrar_firma` | TINYINT(1) | Debe registrar firma antes de firmar |
| `intentos_fallidos` | INT | Intentos de login fallidos |
| `bloqueado_hasta` | DATETIME | Hasta cuándo está bloqueado |

---

### 5. **Tabla: `rol_permisos`**

Relación muchos-a-muchos entre roles, módulos y acciones.

```sql
CREATE TABLE rol_permisos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rol_id INT NOT NULL,
  modulo_id INT NOT NULL,
  accion_id INT NOT NULL,
  UNIQUE KEY unique_permiso (rol_id, modulo_id, accion_id),
  FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE,
  FOREIGN KEY (modulo_id) REFERENCES modulos(id) ON DELETE CASCADE,
  FOREIGN KEY (accion_id) REFERENCES acciones(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Ejemplo**: Coordinador puede REVISAR solicitudes
- rol_id = 2 (Coordinador)
- modulo_id = 2 (Solicitudes)
- accion_id = 5 (REVISAR)

---

### 6. **Tabla: `usuario_roles`**

Relación muchos-a-muchos entre usuarios y roles. Un usuario puede tener múltiples roles.

```sql
CREATE TABLE usuario_roles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  rol_id INT NOT NULL,
  activo TINYINT(1) DEFAULT 1,
  asignado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_usuario_rol (usuario_id, rol_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (rol_id) REFERENCES roles(id) ON DELETE CASCADE,
  INDEX idx_usuario_id (usuario_id),
  INDEX idx_rol_id (rol_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 7. **Tabla: `tipo_programas`**

Programas de capacitación disponibles.

```sql
CREATE TABLE tipo_programas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion VARCHAR(255),
  activo TINYINT(1) NOT NULL DEFAULT 1,
  INDEX idx_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Ejemplo de datos**:
- Técnico en Agronomía
- Técnico en Ganadería
- Diplomado en Gestión Agropecuaria

---

### 8. **Tabla: `documentos_requeridos`**

Documentos que pueden ser requeridos para solicitudes.

```sql
CREATE TABLE documentos_requeridos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(150) NOT NULL,
  descripcion TEXT,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Ejemplo de datos**:
- Certificado de asistencia
- Diploma
- Carta de finalización
- Evaluación final

---

### 9. **Tabla: `tipo_programa_documentos`**

Relación entre tipo de programas y documentos requeridos.

```sql
CREATE TABLE tipo_programa_documentos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  tipo_programa_id INT NOT NULL,
  documento_id INT NOT NULL,
  obligatorio TINYINT(1) DEFAULT 1,
  orden_documento INT,
  UNIQUE KEY unique_tipo_doc (tipo_programa_id, documento_id),
  FOREIGN KEY (tipo_programa_id) REFERENCES tipo_programas(id) ON DELETE CASCADE,
  FOREIGN KEY (documento_id) REFERENCES documentos_requeridos(id),
  INDEX idx_tipo_programa (tipo_programa_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 10. **Tabla: `tipo_programa_roles`**

Define qué roles deben firmar en qué orden para cada tipo de programa.

```sql
CREATE TABLE tipo_programa_roles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  tipo_programa_id INT NOT NULL,
  rol_id INT NOT NULL,
  orden_firma INT,
  obligatorio TINYINT(1) DEFAULT 1,
  UNIQUE KEY unique_tipo_rol (tipo_programa_id, rol_id),
  FOREIGN KEY (tipo_programa_id) REFERENCES tipo_programas(id) ON DELETE CASCADE,
  FOREIGN KEY (rol_id) REFERENCES roles(id),
  INDEX idx_tipo_programa (tipo_programa_id),
  INDEX idx_rol_id (rol_id),
  INDEX idx_orden_firma (orden_firma)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Uso**: Especifica el flujo de firmas. Ej:
- orden_firma=1: Instructor
- orden_firma=2: Coordinador
- orden_firma=3: Jefe de Centro

---

### 11. **Tabla: `plantillas_formato`**

Plantillas PDF para certificados/diplomas.

```sql
CREATE TABLE plantillas_formato (
  id INT PRIMARY KEY AUTO_INCREMENT,
  version VARCHAR(20) NOT NULL UNIQUE,
  archivo_url VARCHAR(500) NOT NULL,
  activa TINYINT(1) DEFAULT 0,
  creado_por INT,
  creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (creado_por) REFERENCES usuarios(id),
  INDEX idx_version (version),
  INDEX idx_activa (activa)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 12. **Tabla: `solicitudes`**

Solicitudes de certificación de aprendices.

```sql
CREATE TABLE solicitudes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  numero_documento VARCHAR(20) NOT NULL,
  numero_ficha VARCHAR(30) NOT NULL,
  nombre_aprendiz VARCHAR(150) NOT NULL,
  correo_aprendiz VARCHAR(120),
  telefono_aprendiz VARCHAR(20),
  tipo_programa_id INT NOT NULL,
  nombre_programa VARCHAR(150) NOT NULL,
  estado_actual ENUM('PENDIENTE_REVISION','CON_OBSERVACIONES','CORREGIDO','PENDIENTE_FIRMAS','PENDIENTE_CERTIFICACION','RECHAZADO','CERTIFICADO') DEFAULT 'PENDIENTE_REVISION',
  pdf_consolidado_url VARCHAR(255),
  pdf_hash VARCHAR(255),
  fecha_generacion_pdf TIMESTAMP,
  fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  observaciones_generales TEXT,
  plantilla_id INT,
  documentos_eliminados TINYINT(1) DEFAULT 0,
  fecha_eliminacion_documentos TIMESTAMP,
  UNIQUE KEY unique_doc_ficha (numero_documento, numero_ficha),
  FOREIGN KEY (tipo_programa_id) REFERENCES tipo_programas(id),
  FOREIGN KEY (plantilla_id) REFERENCES plantillas_formato(id),
  INDEX idx_estado (estado_actual),
  INDEX idx_tipo_programa (tipo_programa_id),
  INDEX idx_fecha_solicitud (fecha_solicitud),
  INDEX idx_estado_fecha (estado_actual, fecha_solicitud)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Estados del flujo**:
1. `PENDIENTE_REVISION` - Inicial
2. `CON_OBSERVACIONES` - Coordinador solicita correcciones
3. `CORREGIDO` - Aprendiz corrigió
4. `PENDIENTE_FIRMAS` - Esperando firmas
5. `PENDIENTE_CERTIFICACION` - Listo para generar certificado
6. `RECHAZADO` - Rechazado por funcionario de certificación; solicitud finalizada
7. `CERTIFICADO` - Completado

---

### 13. **Tabla: `solicitud_documentos`**

Documentos asociados a una solicitud con versioning.

```sql
CREATE TABLE solicitud_documentos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  solicitud_id INT NOT NULL,
  documento_id INT NOT NULL,
  archivo_url VARCHAR(255) NOT NULL,
  version INT DEFAULT 1,
  es_version_activa TINYINT(1) DEFAULT 1,
  estado_documento ENUM('PENDIENTE','OBSERVADO','APROBADO') DEFAULT 'PENDIENTE',
  observaciones TEXT,
  aprobado_por INT,
  fecha_revision TIMESTAMP,
  bloqueado TINYINT(1) DEFAULT 0,
  fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id) ON DELETE CASCADE,
  FOREIGN KEY (documento_id) REFERENCES documentos_requeridos(id),
  FOREIGN KEY (aprobado_por) REFERENCES usuarios(id),
  INDEX idx_solicitud_documento (solicitud_id, documento_id),
  INDEX idx_version_activa (solicitud_id, documento_id, es_version_activa),
  INDEX idx_estado (estado_documento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 14. **Tabla: `firmas`**

Registro de firmas digitales requeridas y completadas.

```sql
CREATE TABLE firmas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  solicitud_id INT NOT NULL,
  rol_id INT NOT NULL,
  usuario_id INT,
  estado_firma ENUM('PENDIENTE','FIRMADO','RECHAZADO') NOT NULL DEFAULT 'PENDIENTE',
  fecha_firma TIMESTAMP,
  ip_origen VARCHAR(45),
  motivo_rechazo TEXT,
  tipo_rechazo ENUM('POR_DOCUMENTOS','POR_OTRA_RAZON'),
  UNIQUE KEY unique_firma (solicitud_id, rol_id),
  FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id) ON DELETE CASCADE,
  FOREIGN KEY (rol_id) REFERENCES roles(id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  INDEX idx_estado_firma (estado_firma),
  INDEX idx_solicitud_estado (solicitud_id, estado_firma),
  INDEX idx_usuario_fecha (usuario_id, fecha_firma)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 15. **Tabla: `estados_historial`**

Auditoría de cambios de estado.

```sql
CREATE TABLE estados_historial (
  id INT PRIMARY KEY AUTO_INCREMENT,
  solicitud_id INT NOT NULL,
  estado_anterior ENUM('PENDIENTE_REVISION','CON_OBSERVACIONES','CORREGIDO','PENDIENTE_FIRMAS','PENDIENTE_CERTIFICACION','RECHAZADO','CERTIFICADO'),
  estado_nuevo ENUM('PENDIENTE_REVISION','CON_OBSERVACIONES','CORREGIDO','PENDIENTE_FIRMAS','PENDIENTE_CERTIFICACION','RECHAZADO','CERTIFICADO') NOT NULL,
  usuario_id INT,
  motivo TEXT,
  fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id) ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  INDEX idx_solicitud (solicitud_id),
  INDEX idx_fecha_cambio (fecha_cambio),
  INDEX idx_estado_nuevo (estado_nuevo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 16. **Tabla: `coordenadas_firma`**

Define dónde colocar las firmas en las plantillas PDF.

```sql
CREATE TABLE coordenadas_firma (
  id INT PRIMARY KEY AUTO_INCREMENT,
  plantilla_id INT NOT NULL,
  rol_id INT NOT NULL,
  pagina INT NOT NULL DEFAULT 1,
  x_porcentaje FLOAT NOT NULL,
  y_porcentaje FLOAT NOT NULL,
  ancho_porcentaje FLOAT NOT NULL,
  alto_porcentaje FLOAT NOT NULL,
  nombre_x_porcentaje FLOAT NOT NULL DEFAULT 0,
  nombre_y_porcentaje FLOAT NOT NULL DEFAULT 0,
  nombre_ancho_porcentaje FLOAT NOT NULL DEFAULT 10,
  nombre_alto_porcentaje FLOAT NOT NULL DEFAULT 5,
  UNIQUE KEY uq_plantilla_rol (plantilla_id, rol_id),
  FOREIGN KEY (plantilla_id) REFERENCES plantillas_formato(id),
  FOREIGN KEY (rol_id) REFERENCES roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Uso**: Especifica coordenadas en porcentaje para colocar firmas en PDF.

---

### 17. **Tabla: `tokens_edicion`**

Tokens para permitir edición temporal de solicitudes.

```sql
CREATE TABLE tokens_edicion (
  id INT PRIMARY KEY AUTO_INCREMENT,
  solicitud_id INT NOT NULL,
  token VARCHAR(255) NOT NULL UNIQUE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  usado TINYINT(1) DEFAULT 0,
  fecha_expiracion TIMESTAMP,
  fecha_uso TIMESTAMP,
  FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id) ON DELETE CASCADE,
  INDEX idx_solicitud_id (solicitud_id),
  INDEX idx_token (token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 18. **Tabla: `notificaciones_email`**

Registro de emails enviados.

```sql
CREATE TABLE notificaciones_email (
  id INT PRIMARY KEY AUTO_INCREMENT,
  solicitud_id INT NOT NULL,
  destinatario VARCHAR(120) NOT NULL,
  tipo_notificacion VARCHAR(80) NOT NULL,
  asunto VARCHAR(255),
  enviado TINYINT(1) DEFAULT 0,
  fecha_envio TIMESTAMP,
  error_mensaje TEXT,
  FOREIGN KEY (solicitud_id) REFERENCES solicitudes(id) ON DELETE CASCADE,
  INDEX idx_solicitud_notif (solicitud_id),
  INDEX idx_tipo_notif (tipo_notificacion),
  INDEX idx_enviado (enviado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 19. **Tabla: `refresh_tokens`**

Almacena refresh tokens para autenticación.

```sql
CREATE TABLE refresh_tokens (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT NOT NULL,
  token VARCHAR(500) NOT NULL,
  expira_en DATETIME NOT NULL,
  revocado TINYINT(1) DEFAULT 0,
  creado_en DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  INDEX idx_usuario_id (usuario_id),
  INDEX idx_token (token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

### 20. **Tabla: `auditoria`**

Registro completo de auditoría de todas las acciones.

```sql
CREATE TABLE auditoria (
  id INT PRIMARY KEY AUTO_INCREMENT,
  usuario_id INT,
  accion VARCHAR(100) NOT NULL,
  tabla_afectada VARCHAR(100) NOT NULL,
  registro_id BIGINT,
  descripcion TEXT,
  ip_origen VARCHAR(45),
  fecha_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
  INDEX idx_usuario_auditoria (usuario_id),
  INDEX idx_fecha_auditoria (fecha_evento),
  INDEX idx_tabla_auditoria (tabla_afectada),
  INDEX idx_accion (accion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Ejemplo de acciones auditadas**:
- login_exitoso
- login_fallido
- usuario_creado
- solicitud_enviada
- documento_cargado
- firma_realizada
- estado_cambiado

## � Triggers

### Trigger: Asignar Plantilla Activa

Automáticamente asigna la plantilla activa a nuevas solicitudes.

```sql
CREATE TRIGGER tr_asignar_plantilla 
BEFORE INSERT ON solicitudes 
FOR EACH ROW 
BEGIN
    SET NEW.plantilla_id = (
        SELECT id FROM plantillas_formato 
        WHERE activa = TRUE LIMIT 1
    );
END;
```

---

## 🔧 Vistas (Views) Útiles

### Vista: `vista_solicitudes_pendientes`

Solicitudes que requieren revisión inmediata.

```sql
CREATE VIEW vista_solicitudes_pendientes AS
SELECT 
    s.id,
    s.numero_documento,
    s.numero_ficha,
    s.nombre_aprendiz,
    s.correo_aprendiz,
    s.nombre_programa,
    s.estado_actual,
    s.fecha_solicitud,
    DATEDIFF(NOW(), s.fecha_solicitud) as dias_espera,
    COUNT(d.id) as documentos_totales,
    SUM(CASE WHEN d.estado_documento = 'APROBADO' THEN 1 ELSE 0 END) as documentos_aprobados
FROM solicitudes s
LEFT JOIN solicitud_documentos d ON s.id = d.solicitud_id
WHERE s.estado_actual IN ('PENDIENTE_REVISION', 'CON_OBSERVACIONES')
GROUP BY s.id, s.numero_documento, s.numero_ficha, s.nombre_aprendiz, s.correo_aprendiz, 
         s.nombre_programa, s.estado_actual, s.fecha_solicitud;
```

---

### Vista: `vista_firmas_pendientes`

Firmas pendientes por usuario.

```sql
CREATE VIEW vista_firmas_pendientes AS
SELECT 
    f.id,
    f.solicitud_id,
    s.numero_documento,
    s.numero_ficha,
    s.nombre_aprendiz,
    r.nombre as rol_requerido,
    f.estado_firma,
    f.fecha_firma,
    COUNT(*) OVER (PARTITION BY f.usuario_id) as total_pendientes_usuario
FROM firmas f
JOIN solicitudes s ON f.solicitud_id = s.id
JOIN roles r ON f.rol_id = r.id
WHERE f.estado_firma = 'PENDIENTE'
ORDER BY f.solicitud_id, r.id;
```

---

### Vista: `vista_estadisticas_certificaciones`

Estadísticas por tipo de programa.

```sql
CREATE VIEW vista_estadisticas_certificaciones AS
SELECT 
    tp.id,
    tp.nombre as tipo_programa,
    COUNT(DISTINCT s.id) as total_solicitudes,
    SUM(CASE WHEN s.estado_actual = 'CERTIFICADO' THEN 1 ELSE 0 END) as certificadas,
    SUM(CASE WHEN s.estado_actual = 'CON_OBSERVACIONES' THEN 1 ELSE 0 END) as con_observaciones,
    SUM(CASE WHEN s.estado_actual = 'PENDIENTE_FIRMAS' THEN 1 ELSE 0 END) as pendiente_firmas,
    ROUND(
        SUM(CASE WHEN s.estado_actual = 'CERTIFICADO' THEN 1 ELSE 0 END) / 
        NULLIF(COUNT(DISTINCT s.id), 0) * 100, 
        2
    ) as porcentaje_completadas,
    AVG(DATEDIFF(
        CASE WHEN s.estado_actual = 'CERTIFICADO' THEN s.fecha_generacion_pdf ELSE NOW() END,
        s.fecha_solicitud
    )) as promedio_dias_procesamiento
FROM tipo_programas tp
LEFT JOIN solicitudes s ON tp.id = s.tipo_programa_id
GROUP BY tp.id, tp.nombre;
```

---

### Vista: `vista_usuarios_con_roles`

Usuarios con sus roles asignados.

```sql
CREATE VIEW vista_usuarios_con_roles AS
SELECT 
    u.id,
    u.documento,
    u.nombre_completo,
    u.correo,
    u.activo,
    u.firma_registrada,
    GROUP_CONCAT(r.nombre SEPARATOR ', ') as roles_asignados,
    GROUP_CONCAT(r.id SEPARATOR ', ') as rol_ids
FROM usuarios u
LEFT JOIN usuario_roles ur ON u.id = ur.usuario_id AND ur.activo = 1
LEFT JOIN roles r ON ur.rol_id = r.id
GROUP BY u.id, u.documento, u.nombre_completo, u.correo, u.activo, u.firma_registrada;
```

---

## 📊 Índices de Performance

**Índices críticos ya creados en el schema**:

```sql
-- Búsquedas frecuentes
KEY idx_usuarios_activo (activo)
KEY idx_usuario_roles_usuario_id (usuario_id)
KEY idx_usuario_roles_rol_id (rol_id)
KEY idx_estado (estado_actual)
KEY idx_tipo_programa (tipo_programa_id)
KEY idx_fecha_solicitud (fecha_solicitud)
KEY idx_estado_fecha (estado_actual, fecha_solicitud)
KEY idx_solicitud_documento (solicitud_id, documento_id)
KEY idx_version_activa (solicitud_id, documento_id, es_version_activa)
KEY idx_estado_firma (estado_firma)
KEY idx_solicitud_estado (solicitud_id, estado_firma)
KEY idx_usuario_fecha (usuario_id, fecha_firma)
KEY idx_usuario_auditoria (usuario_id)
KEY idx_tabla_auditoria (tabla_afectada)
```

---

## 🔄 Procedimientos Almacenados Recomendados

### Procedimiento: Cambiar estado de solicitud

```sql
DELIMITER $$

CREATE PROCEDURE sp_cambiar_estado_solicitud(
    IN p_solicitud_id INT,
    IN p_nuevo_estado VARCHAR(50),
    IN p_usuario_id INT,
    IN p_motivo TEXT
)
BEGIN
    DECLARE v_estado_anterior VARCHAR(50);
    
    START TRANSACTION;
    
    -- Obtener estado anterior
    SELECT estado_actual INTO v_estado_anterior 
    FROM solicitudes 
    WHERE id = p_solicitud_id;
    
    -- Actualizar estado
    UPDATE solicitudes 
    SET 
        estado_actual = p_nuevo_estado,
        updated_at = NOW()
    WHERE id = p_solicitud_id;
    
    -- Registrar en historial
    INSERT INTO estados_historial 
    (solicitud_id, estado_anterior, estado_nuevo, usuario_id, motivo, fecha_cambio)
    VALUES 
    (p_solicitud_id, v_estado_anterior, p_nuevo_estado, p_usuario_id, p_motivo, NOW());
    
    -- Registrar en auditoría
    INSERT INTO auditoria 
    (usuario_id, accion, tabla_afectada, registro_id, descripcion, fecha_evento)
    VALUES 
    (p_usuario_id, 'cambio_estado', 'solicitudes', p_solicitud_id, 
     CONCAT('Estado: ', v_estado_anterior, ' -> ', p_nuevo_estado), NOW());
    
    COMMIT;
END$$

DELIMITER ;
```

---

### Procedimiento: Registrar firma

```sql
DELIMITER $$

CREATE PROCEDURE sp_registrar_firma(
    IN p_solicitud_id INT,
    IN p_rol_id INT,
    IN p_usuario_id INT,
    IN p_ip_origen VARCHAR(45)
)
BEGIN
    START TRANSACTION;
    
    -- Actualizar firma
    UPDATE firmas 
    SET 
        usuario_id = p_usuario_id,
        estado_firma = 'FIRMADO',
        fecha_firma = NOW(),
        ip_origen = p_ip_origen
    WHERE 
        solicitud_id = p_solicitud_id 
        AND rol_id = p_rol_id;
    
    -- Verificar si todas las firmas están completas
    IF NOT EXISTS (
        SELECT 1 FROM firmas 
        WHERE solicitud_id = p_solicitud_id 
        AND estado_firma != 'FIRMADO'
    ) THEN
        -- Cambiar estado a PENDIENTE_CERTIFICACION
        UPDATE solicitudes 
        SET estado_actual = 'PENDIENTE_CERTIFICACION'
        WHERE id = p_solicitud_id;
    END IF;
    
    -- Registrar auditoría
    INSERT INTO auditoria 
    (usuario_id, accion, tabla_afectada, registro_id, descripcion)
    VALUES 
    (p_usuario_id, 'firma_registrada', 'firmas', p_solicitud_id, 
     CONCAT('Firma registrada por rol: ', p_rol_id));
    
    COMMIT;
END$$

DELIMITER ;
```

---

### Procedimiento: Generar PDF consolidado

```sql
DELIMITER $$

CREATE PROCEDURE sp_generar_pdf_consolidado(
    IN p_solicitud_id INT,
    IN p_pdf_url VARCHAR(255),
    IN p_pdf_hash VARCHAR(255)
)
BEGIN
    START TRANSACTION;
    
    UPDATE solicitudes 
    SET 
        pdf_consolidado_url = p_pdf_url,
        pdf_hash = p_pdf_hash,
        fecha_generacion_pdf = NOW(),
        estado_actual = 'CERTIFICADO'
    WHERE id = p_solicitud_id;
    
    INSERT INTO auditoria 
    (accion, tabla_afectada, registro_id, descripcion)
    VALUES 
    ('pdf_generado', 'solicitudes', p_solicitud_id, 
     CONCAT('PDF generado: ', p_pdf_url));
    
    COMMIT;
END$$

DELIMITER ;
```

---

## 📈 Recomendaciones de Mantenimiento

### Backup
- **Frecuencia**: Diaria a medianoche
- **Retención**: 30 días en línea, 1 año fuera de línea
- **Método**: mysqldump con compresión

### Limpieza de Datos
```sql
-- Archivar logs de auditoría > 1 año
DELETE FROM auditoria 
WHERE fecha_evento < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Limpiar tokens expirados
DELETE FROM tokens_edicion 
WHERE fecha_expiracion < NOW();

-- Limpiar refresh tokens revocados
DELETE FROM refresh_tokens 
WHERE revocado = 1 AND creado_en < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

### Optimización
```sql
-- Mensual
OPTIMIZE TABLE solicitudes;
OPTIMIZE TABLE firmas;
OPTIMIZE TABLE auditoria;
OPTIMIZE TABLE estados_historial;

-- Analizar tablas para mejor plan de query
ANALYZE TABLE solicitudes;
ANALYZE TABLE firmas;
```

### Monitoreo
- Size de la BD
- Queries lentas (slow query log)
- Replicación (si existe)
- Conexiones activas
- Uso de memoria

---

## 🗂️ Estructura de Almacenamiento de Archivos

```
uploads/
├── documentos/
│   ├── solicitud_1/
│   │   ├── documento_certificado_v1.pdf
│   │   ├── documento_certificado_v2.pdf
│   │   └── documento_diploma.pdf
│   ├── solicitud_2/
│   └── ...
└── plantillas/
    ├── plantilla_v1.0.pdf
    ├── plantilla_v1.1.pdf
    └── plantilla_v2.0_activa.pdf
```

---

**Documento**: DATABASE_SCHEMA.md
**Versión**: 2.0 (Actualizado con estructura real)
**Última actualización**: 2026-05-04
