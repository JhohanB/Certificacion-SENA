-- ============================================
-- SCHEMA PARA POSTGRESQL
-- ============================================

-- Acciones
DROP TABLE IF EXISTS acciones CASCADE;
CREATE TABLE acciones (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE
);

-- Modulos
DROP TABLE IF EXISTS modulos CASCADE;
CREATE TABLE modulos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE
);

-- Roles
DROP TABLE IF EXISTS roles CASCADE;
CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion TEXT,
  requiere_firma BOOLEAN DEFAULT FALSE,
  activo BOOLEAN DEFAULT TRUE,
  es_coordinador BOOLEAN DEFAULT FALSE,
  es_funcionario_revision BOOLEAN DEFAULT FALSE,
  es_admin BOOLEAN DEFAULT FALSE
);

-- Usuarios
DROP TABLE IF EXISTS usuarios CASCADE;
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  documento VARCHAR(20) NOT NULL UNIQUE,
  nombre_completo VARCHAR(150) NOT NULL,
  correo VARCHAR(120) NOT NULL UNIQUE,
  telefono VARCHAR(20),
  password_hash TEXT NOT NULL,
  firma_url VARCHAR(255),
  firma_registrada BOOLEAN DEFAULT FALSE,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  debe_cambiar_password BOOLEAN DEFAULT FALSE,
  debe_registrar_firma BOOLEAN DEFAULT FALSE,
  intentos_fallidos INTEGER DEFAULT 0,
  bloqueado_hasta TIMESTAMP
);

CREATE INDEX idx_usuarios_activo ON usuarios(activo);

-- Documentos Requeridos
DROP TABLE IF EXISTS documentos_requeridos CASCADE;
CREATE TABLE documentos_requeridos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  descripcion TEXT
);

-- Tipo Programas
DROP TABLE IF EXISTS tipo_programas CASCADE;
CREATE TABLE tipo_programas (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE,
  descripcion VARCHAR(255),
  activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- Plantillas Formato
DROP TABLE IF EXISTS plantillas_formato CASCADE;
CREATE TABLE plantillas_formato (
  id SERIAL PRIMARY KEY,
  version VARCHAR(20) NOT NULL UNIQUE,
  archivo_url VARCHAR(500) NOT NULL,
  activa BOOLEAN DEFAULT FALSE,
  creado_por INTEGER REFERENCES usuarios(id),
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rol Permisos
DROP TABLE IF EXISTS rol_permisos CASCADE;
CREATE TABLE rol_permisos (
  id SERIAL PRIMARY KEY,
  rol_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  modulo_id INTEGER NOT NULL REFERENCES modulos(id) ON DELETE CASCADE,
  accion_id INTEGER NOT NULL REFERENCES acciones(id) ON DELETE CASCADE,
  UNIQUE(rol_id, modulo_id, accion_id)
);

CREATE INDEX idx_rol_permisos_modulo ON rol_permisos(modulo_id);
CREATE INDEX idx_rol_permisos_accion ON rol_permisos(accion_id);

-- Usuario Roles
DROP TABLE IF EXISTS usuario_roles CASCADE;
CREATE TABLE usuario_roles (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  rol_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  activo BOOLEAN DEFAULT TRUE,
  asignado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(usuario_id, rol_id)
);

CREATE INDEX idx_usuario_roles_usuario_id ON usuario_roles(usuario_id);
CREATE INDEX idx_usuario_roles_rol_id ON usuario_roles(rol_id);

-- Tipo Programa Documentos
DROP TABLE IF EXISTS tipo_programa_documentos CASCADE;
CREATE TABLE tipo_programa_documentos (
  id SERIAL PRIMARY KEY,
  tipo_programa_id INTEGER NOT NULL REFERENCES tipo_programas(id) ON DELETE CASCADE,
  documento_id INTEGER NOT NULL REFERENCES documentos_requeridos(id),
  obligatorio BOOLEAN DEFAULT TRUE,
  orden_documento INTEGER,
  UNIQUE(tipo_programa_id, documento_id)
);

CREATE INDEX idx_tipo_programa_documentos_documento ON tipo_programa_documentos(documento_id);

-- Tipo Programa Roles
DROP TABLE IF EXISTS tipo_programa_roles CASCADE;
CREATE TABLE tipo_programa_roles (
  id SERIAL PRIMARY KEY,
  tipo_programa_id INTEGER NOT NULL REFERENCES tipo_programas(id) ON DELETE CASCADE,
  rol_id INTEGER NOT NULL REFERENCES roles(id),
  orden_firma INTEGER,
  obligatorio BOOLEAN DEFAULT TRUE,
  UNIQUE(tipo_programa_id, rol_id)
);

CREATE INDEX idx_tipo_programa_roles_rol_id ON tipo_programa_roles(rol_id);
CREATE INDEX idx_tipo_programa_roles_orden_firma ON tipo_programa_roles(orden_firma);
CREATE INDEX idx_tipo_programa_roles_tipo_programa ON tipo_programa_roles(tipo_programa_id);

-- Solicitudes
DROP TABLE IF EXISTS solicitudes CASCADE;
CREATE TABLE solicitudes (
  id SERIAL PRIMARY KEY,
  numero_documento VARCHAR(20) NOT NULL,
  numero_ficha VARCHAR(30) NOT NULL,
  nombre_aprendiz VARCHAR(150) NOT NULL,
  correo_aprendiz VARCHAR(120),
  telefono_aprendiz VARCHAR(20),
  tipo_programa_id INTEGER NOT NULL REFERENCES tipo_programas(id),
  nombre_programa VARCHAR(150) NOT NULL,
  estado_actual VARCHAR(50) NOT NULL DEFAULT 'PENDIENTE_REVISION'
    CHECK (estado_actual IN ('PENDIENTE_REVISION','CON_OBSERVACIONES','CORREGIDO','PENDIENTE_FIRMAS','PENDIENTE_CERTIFICACION','CERTIFICADO')),
  pdf_consolidado_url VARCHAR(255),
  pdf_hash VARCHAR(255),
  fecha_generacion_pdf TIMESTAMP,
  fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  observaciones_generales TEXT,
  plantilla_id INTEGER REFERENCES plantillas_formato(id),
  documentos_eliminados BOOLEAN DEFAULT FALSE,
  fecha_eliminacion_documentos TIMESTAMP,
  UNIQUE(numero_documento, numero_ficha)
);

CREATE INDEX idx_solicitudes_estado ON solicitudes(estado_actual);
CREATE INDEX idx_solicitudes_tipo_programa ON solicitudes(tipo_programa_id);
CREATE INDEX idx_solicitudes_fecha_solicitud ON solicitudes(fecha_solicitud);
CREATE INDEX idx_solicitudes_estado_fecha ON solicitudes(estado_actual, fecha_solicitud);

-- Solicitud Documentos
DROP TABLE IF EXISTS solicitud_documentos CASCADE;
CREATE TABLE solicitud_documentos (
  id SERIAL PRIMARY KEY,
  solicitud_id INTEGER NOT NULL REFERENCES solicitudes(id) ON DELETE CASCADE,
  documento_id INTEGER NOT NULL REFERENCES documentos_requeridos(id),
  archivo_url VARCHAR(255) NOT NULL,
  version INTEGER DEFAULT 1,
  es_version_activa BOOLEAN DEFAULT TRUE,
  estado_documento VARCHAR(50) DEFAULT 'PENDIENTE'
    CHECK (estado_documento IN ('PENDIENTE','OBSERVADO','APROBADO')),
  observaciones TEXT,
  aprobado_por INTEGER REFERENCES usuarios(id),
  fecha_revision TIMESTAMP,
  bloqueado BOOLEAN DEFAULT FALSE,
  fecha_subida TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_solicitud_documentos_solicitud_documento ON solicitud_documentos(solicitud_id, documento_id);
CREATE INDEX idx_solicitud_documentos_version_activa ON solicitud_documentos(solicitud_id, documento_id, es_version_activa);
CREATE INDEX idx_solicitud_documentos_solicitud_activa ON solicitud_documentos(solicitud_id, es_version_activa);
CREATE INDEX idx_solicitud_documentos_documento ON solicitud_documentos(documento_id);

-- Firmas
DROP TABLE IF EXISTS firmas CASCADE;
CREATE TABLE firmas (
  id SERIAL PRIMARY KEY,
  solicitud_id INTEGER NOT NULL REFERENCES solicitudes(id) ON DELETE CASCADE,
  rol_id INTEGER NOT NULL REFERENCES roles(id),
  usuario_id INTEGER REFERENCES usuarios(id),
  estado_firma VARCHAR(50) NOT NULL DEFAULT 'PENDIENTE'
    CHECK (estado_firma IN ('PENDIENTE','FIRMADO','RECHAZADO')),
  fecha_firma TIMESTAMP,
  ip_origen VARCHAR(45),
  motivo_rechazo TEXT,
  tipo_rechazo VARCHAR(50)
    CHECK (tipo_rechazo IS NULL OR tipo_rechazo IN ('POR_DOCUMENTOS','POR_OTRA_RAZON')),
  UNIQUE(solicitud_id, rol_id)
);

CREATE INDEX idx_firmas_estado_firma ON firmas(estado_firma);
CREATE INDEX idx_firmas_fecha_firma ON firmas(fecha_firma);
CREATE INDEX idx_firmas_solicitud_estado ON firmas(solicitud_id, estado_firma);
CREATE INDEX idx_firmas_usuario_fecha ON firmas(usuario_id, fecha_firma);
CREATE INDEX idx_firmas_solicitud ON firmas(solicitud_id);
CREATE INDEX idx_firmas_rol ON firmas(rol_id);
CREATE INDEX idx_firmas_usuario ON firmas(usuario_id);

-- Estados Historial
DROP TABLE IF EXISTS estados_historial CASCADE;
CREATE TABLE estados_historial (
  id SERIAL PRIMARY KEY,
  solicitud_id INTEGER NOT NULL REFERENCES solicitudes(id) ON DELETE CASCADE,
  estado_anterior VARCHAR(50)
    CHECK (estado_anterior IS NULL OR estado_anterior IN ('PENDIENTE_REVISION','CON_OBSERVACIONES','CORREGIDO','PENDIENTE_FIRMAS','PENDIENTE_CERTIFICACION','CERTIFICADO')),
  estado_nuevo VARCHAR(50) NOT NULL
    CHECK (estado_nuevo IN ('PENDIENTE_REVISION','CON_OBSERVACIONES','CORREGIDO','PENDIENTE_FIRMAS','PENDIENTE_CERTIFICACION','CERTIFICADO')),
  usuario_id INTEGER REFERENCES usuarios(id),
  motivo TEXT,
  fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_estados_historial_estado_nuevo ON estados_historial(estado_nuevo);
CREATE INDEX idx_estados_historial_fecha_cambio ON estados_historial(fecha_cambio);
CREATE INDEX idx_estados_historial_solicitud ON estados_historial(solicitud_id);

-- Tokens Edicion
DROP TABLE IF EXISTS tokens_edicion CASCADE;
CREATE TABLE tokens_edicion (
  id SERIAL PRIMARY KEY,
  solicitud_id INTEGER NOT NULL REFERENCES solicitudes(id) ON DELETE CASCADE,
  token VARCHAR(255) NOT NULL UNIQUE,
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  usado BOOLEAN DEFAULT FALSE,
  fecha_expiracion TIMESTAMP,
  fecha_uso TIMESTAMP
);

CREATE INDEX idx_tokens_edicion_solicitud ON tokens_edicion(solicitud_id);

-- Notificaciones Email
DROP TABLE IF EXISTS notificaciones_email CASCADE;
CREATE TABLE notificaciones_email (
  id SERIAL PRIMARY KEY,
  solicitud_id INTEGER NOT NULL REFERENCES solicitudes(id) ON DELETE CASCADE,
  destinatario VARCHAR(120) NOT NULL,
  tipo_notificacion VARCHAR(80) NOT NULL,
  asunto VARCHAR(255),
  enviado BOOLEAN DEFAULT FALSE,
  fecha_envio TIMESTAMP,
  error_mensaje TEXT
);

CREATE INDEX idx_notificaciones_email_solicitud ON notificaciones_email(solicitud_id);
CREATE INDEX idx_notificaciones_email_tipo ON notificaciones_email(tipo_notificacion);

-- Refresh Tokens
DROP TABLE IF EXISTS refresh_tokens CASCADE;
CREATE TABLE refresh_tokens (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
  token VARCHAR(500) NOT NULL,
  expira_en TIMESTAMP NOT NULL,
  revocado BOOLEAN DEFAULT FALSE,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_refresh_tokens_usuario ON refresh_tokens(usuario_id);

-- Auditoria
DROP TABLE IF EXISTS auditoria CASCADE;
CREATE TABLE auditoria (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios(id),
  accion VARCHAR(100) NOT NULL,
  tabla_afectada VARCHAR(100) NOT NULL,
  registro_id BIGINT,
  descripcion TEXT,
  ip_origen VARCHAR(45),
  fecha_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_auditoria_usuario ON auditoria(usuario_id);
CREATE INDEX idx_auditoria_fecha ON auditoria(fecha_evento);
CREATE INDEX idx_auditoria_tabla ON auditoria(tabla_afectada);

-- Coordenadas Firma
DROP TABLE IF EXISTS coordenadas_firma CASCADE;
CREATE TABLE coordenadas_firma (
  id SERIAL PRIMARY KEY,
  plantilla_id INTEGER NOT NULL REFERENCES plantillas_formato(id),
  rol_id INTEGER NOT NULL REFERENCES roles(id),
  pagina INTEGER NOT NULL DEFAULT 1,
  x_porcentaje FLOAT NOT NULL,
  y_porcentaje FLOAT NOT NULL,
  ancho_porcentaje FLOAT NOT NULL,
  alto_porcentaje FLOAT NOT NULL,
  nombre_x_porcentaje FLOAT DEFAULT 0,
  nombre_y_porcentaje FLOAT DEFAULT 0,
  nombre_ancho_porcentaje FLOAT DEFAULT 10,
  nombre_alto_porcentaje FLOAT DEFAULT 5,
  UNIQUE(plantilla_id, rol_id)
);

CREATE INDEX idx_coordenadas_firma_rol ON coordenadas_firma(rol_id);

-- ============================================
-- TRIGGERS (Funciones Automáticas)
-- ============================================

-- Función para asignar plantilla activa automáticamente
DROP FUNCTION IF EXISTS asignar_plantilla_activa() CASCADE;
CREATE OR REPLACE FUNCTION asignar_plantilla_activa()
RETURNS TRIGGER AS $$
BEGIN
    -- Si no se especifica plantilla, asignar la que esté activa
    IF NEW.plantilla_id IS NULL THEN
        NEW.plantilla_id := (
            SELECT id FROM plantillas_formato 
            WHERE activa = TRUE 
            LIMIT 1
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para ejecutar la función antes de insertar
DROP TRIGGER IF EXISTS tr_asignar_plantilla ON solicitudes CASCADE;
CREATE TRIGGER tr_asignar_plantilla
BEFORE INSERT ON solicitudes
FOR EACH ROW
EXECUTE FUNCTION asignar_plantilla_activa();
