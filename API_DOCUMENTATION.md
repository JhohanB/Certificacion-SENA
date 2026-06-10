# 📡 Documentación de API REST - Sistema de Gestión de Certificaciones SENA

**Base URL**: `http://localhost:8000` (desarrollo) | `https://api.tudominio.com` (producción)

---

## 📋 Tabla de Contenidos

1. [Sistema](#sistema)
2. [Autenticación](#autenticación)
3. [Usuarios](#usuarios)
4. [Solicitudes](#solicitudes)
5. [Documentos y Firmas](#documentos-y-firmas)
6. [Plantillas](#plantillas)
7. [Roles y Permisos](#roles-y-permisos)
8. [Tipos de Programa](#tipos-de-programa)
9. [Auditoría](#auditoría)
10. [Reportes](#reportes)
11. [Códigos de Error](#códigos-de-error)

---

## �️ Sistema

### Información del Sistema
**GET** `/`

**Response (200)**:
```json
{
  "sistema": "Sistema de Gestión de Certificaciones y Firmas Digitales – Centro de Atención del Sector Agropecuario",
  "version": "1.0.0",
  "estado": "activo"
}
```

---

### Health Check
**GET** `/health`

**Response (200)**:
```json
{
  "estado": "ok",
  "servidor": "ok",
  "base_de_datos": "ok",
  "version": "1.0.0"
}
```

---

## 🔐 Autenticación

Todos los endpoints (excepto login) requieren token JWT en el header:
```
Authorization: Bearer {token}
```

### Login
**POST** `/auth/login`

**Request**:
```json
{
  "correo": "usuario@sena.edu.co",
  "password": "SecurePassword123"
}
```

**Response (200)**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "debe_cambiar_password": false,
  "debe_registrar_firma": false,
  "usuario": {
    "id": 1,
    "correo": "usuario@sena.edu.co",
    "nombre_completo": "Juan Pérez",
    "roles": [
      {
        "id": 1,
        "nombre": "COORDINADOR",
        "requiere_firma": true
      }
    ]
  }
}
```

**Errores**:
- `401 Unauthorized` - Credenciales inválidas o usuario bloqueado
- `429 Too Many Requests` - Usuario bloqueado por intentos fallidos (15 minutos)
- `403 Forbidden` - Usuario inactivo

---

### Refresh Token
**POST** `/auth/refresh`

**Request**:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200)**:
```json
{
  "access_token": "nuevo_token_jwt",
  "refresh_token": "nuevo_refresh_token"
}
```

**Errores**:
- `401 Unauthorized` - Refresh token inválido o expirado

---

### Logout
**POST** `/auth/logout`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "mensaje": "Sesión cerrada exitosamente"
}
```

---

### Cambiar Contraseña
**PUT** `/auth/cambiar-password`

**Headers**: Authorization requerida

**Request**:
```json
{
  "current_password": "OldPassword123!",
  "new_password": "NewPassword456!"
}
```

**Response (200)**:
```json
{
  "mensaje": "Contraseña actualizada exitosamente"
}
```

**Errores**:
- `401 Unauthorized` - Contraseña actual incorrecta
- `400 Bad Request` - Contraseña nueva no válida

---

### Obtener Datos del Usuario Actual
**GET** `/auth/me`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "id": 1,
  "correo": "usuario@sena.edu.co",
  "nombre_completo": "Juan Pérez",
  "documento": "1234567890",
  "activo": true,
  "roles": [
    {
      "id": 1,
      "nombre": "COORDINADOR",
      "requiere_firma": true
    }
  ]
}
```

---

## 👥 Usuarios

### Listar Usuarios
**GET** `/usuarios`

**Query Parameters**:
- `page`: Página (default: 1)
- `limit`: Registros por página (default: 50)

**Headers**: Authorization requerida. Solo accesible por ADMIN

**Response (200)**:
```json
[
  {
    "id": 1,
    "correo": "user1@sena.edu.co",
    "nombre_completo": "Juan Pérez",
    "documento": "1234567890",
    "activo": true,
    "roles": [
      {
        "id": 1,
        "nombre": "COORDINADOR"
      }
    ]
  }
]
```

---

### Obtener Usuario por ID
**GET** `/usuarios/{usuario_id}`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "id": 1,
  "correo": "user1@sena.edu.co",
  "nombre_completo": "Juan Pérez",
  "documento": "1234567890",
  "activo": true,
  "roles": [
    {
      "id": 1,
      "nombre": "COORDINADOR",
      "requiere_firma": true
    }
  ],
  "firma_url": "/uploads/firmas/firma_1.png"
}
```

**Acceso**:
- ADMIN: puede ver cualquier usuario
- Usuario regular: solo puede verse a sí mismo

---

### Crear Usuario
**POST** `/usuarios`

**Headers**: Authorization requerida. Solo accesible por ADMIN

**Body**:
```json
{
  "correo": "newuser@sena.edu.co",
  "nombre_completo": "Carlos López",
  "documento": "9876543210",
  "roles": [2, 3]
}
```

**Response (201)**:
```json
{
  "message": "Funcionario creado correctamente, se enviaron las credenciales al correo",
  "usuario_id": 10
}
```

**Notas**:
- La contraseña se genera automáticamente y se envía por correo
- El usuario debe cambiarla en el primer login

**Errores**:
- `400 Bad Request` - Email o documento ya existen
- `403 Forbidden` - No es ADMIN

---

### Actualizar Usuario
**PUT** `/usuarios/{usuario_id}`

**Headers**: Authorization requerida

**Body**:
```json
{
  "nombre_completo": "Carlos López Mejorado",
  "documento": "9876543210",
  "correo": "newcorreo@sena.edu.co"
}
```

**Response (200)**:
```json
{
  "message": "Datos actualizados correctamente"
}
```

**Acceso**:
- ADMIN: puede editar cualquier usuario
- Usuario regular: solo puede editar sus propios datos

---

### Cambiar Estado de Usuario
**PUT** `/usuarios/{usuario_id}/estado`

**Headers**: Authorization requerida. Solo accesible por ADMIN

**Query Parameters**:
- `activo`: true o false

**Response (200)**:
```json
{
  "message": "Funcionario activado correctamente"
}
```

---

### Subir Firma
**POST** `/usuarios/{usuario_id}/firma`

**Headers**: Authorization requerida

**Content-Type**: multipart/form-data

**Body**:
- `archivo`: Imagen JPG o PNG de la firma

**Response (201)**:
```json
{
  "message": "Firma registrada correctamente",
  "firma_url": "/uploads/firmas/firma_1.png"
}
```

**Validaciones**:
- Solo JPG, JPEG o PNG
- El usuario debe tener al menos un rol que requiera firma
- Acceso: cada usuario su propia firma o ADMIN puede asignar cualquiera

---

### Listar Coordinadores
**GET** `/usuarios/coordinadores`

**Headers**: Authorization requerida

**Response (200)**:
```json
[
  {
    "id": 2,
    "nombre_completo": "Ana García",
    "correo": "ana@sena.edu.co"
  }
]
```

---

## 📋 Solicitudes

### Listar Tipos de Programa (público)
**GET** `/solicitudes/tipos-programa`

**Response (200)**:
```json
[
  {
    "id": 1,
    "nombre": "TÉCNICO EN AGRONOMÍA",
    "descripcion": "Programa técnico en agronomía"
  }
]
```

---

### Obtener Documentos Requeridos (público)
**GET** `/solicitudes/documentos-requeridos/{tipo_programa_id}`

**Response (200)**:
```json
[
  {
    "id": 1,
    "nombre": "Cedula de ciudadania",
    "obligatorio": true,
    "descripcion": "Documento de identidad"
  }
]
```

---

### Crear Solicitud (público)
**POST** `/solicitudes`

**Content-Type**: multipart/form-data

**Body**:
- `tipo_documento`: enum [CC, TI, CE, PA] - Tipo de documento del aprendiz
- `numero_documento`: string - Número de documento
- `numero_ficha`: string - Número de ficha SENA
- `nombre_aprendiz`: string - Nombre completo
- `correo_aprendiz`: string - Email
- `confirmar_correo`: string - Confirmación de email
- `telefono_aprendiz`: string (opcional)
- `tipo_programa_id`: integer
- `nombre_programa`: string - Nombre del programa
- `archivo_{documento_id}`: file (PDF) - Múltiples archivos según documentos requeridos

**Response (201)**:
```json
{
  "message": "Solicitud creada correctamente, recibirás un correo de confirmación",
  "solicitud_id": 15
}
```

**Errores**:
- `400 Bad Request` - Correos no coinciden o solicitud duplicada
- `413 Payload Too Large` - Archivo > 10MB
- `415 Unsupported Media Type` - Archivo no es PDF

---

### Consultar Solicitud (público)
**POST** `/solicitudes/consultar`

**Body**:
```json
{
  "numero_documento": "CC 1234567890",
  "numero_ficha": "9999"
}
```

**Response (200)**:
```json
{
  "id": 1,
  "numero_documento": "CC 1234567890",
  "numero_ficha": "9999",
  "nombre_aprendiz": "Juan Pérez",
  "nombre_programa": "TÉCNICO EN AGRONOMÍA",
  "estado_actual": "PENDIENTE_REVISION",
  "fecha_solicitud": "2026-04-01T09:00:00",
  "documentos": [
    {
      "id": 1,
      "nombre": "Cedula",
      "estado_documento": "PENDIENTE"
    }
  ]
}
```

---

### Listar Solicitudes
**GET** `/solicitudes`

**Query Parameters**:
- `page`: Página (default: 1)
- `limit`: Registros por página (default: 50)
- `estado`: Filtrar por estado
- `tipo_programa_id`: Filtrar por tipo de programa (opcional)

**Headers**: Authorization requerida

**Response (200)**:
```json
[
  {
    "id": 1,
    "numero_documento": "CC 1234567890",
    "numero_ficha": "9999",
    "nombre_aprendiz": "Juan Pérez",
    "nombre_programa": "TÉCNICO EN AGRONOMÍA",
    "estado_actual": "PENDIENTE_REVISION",
    "fecha_solicitud": "2026-04-01T09:00:00",
    "documentos_cantidad": 3
  }
]
```

---

### Obtener Detalles de Solicitud
**GET** `/solicitudes/{solicitud_id}`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "id": 1,
  "numero_documento": "CC 1234567890",
  "numero_ficha": "9999",
  "nombre_aprendiz": "Juan Pérez",
  "nombre_programa": "TÉCNICO EN AGRONOMÍA",
  "tipo_programa_id": 1,
  "correo_aprendiz": "juan@email.com",
  "telefono_aprendiz": "3101234567",
  "estado_actual": "PENDIENTE_REVISION",
  "observaciones_generales": null,
  "fecha_solicitud": "2026-04-01T09:00:00",
  "pdf_consolidado_url": "/uploads/1/consolidado.pdf",
  "documentos": [
    {
      "id": 1,
      "nombre": "Cedula",
      "estado_documento": "APROBADO",
      "url": "/uploads/1/doc_1_v1.pdf",
      "version": 1,
      "observaciones": null
    }
  ],
  "firmas": [
    {
      "id": 1,
      "rol": "COORDINADOR",
      "estado_firma": "PENDIENTE",
      "usuario": null
    }
  ]
}
```

---

### Obtener Estados Posibles
**GET** `/solicitudes/estados-posibles`

**Headers**: Authorization requerida

**Response (200)**:
```json
[
  {"valor": "PENDIENTE_REVISION", "etiqueta": "PENDIENTE REVISION"},
  {"valor": "CON_OBSERVACIONES", "etiqueta": "CON OBSERVACIONES"},
  {"valor": "CORREGIDO", "etiqueta": "CORREGIDO"},
  {"valor": "PENDIENTE_FIRMAS", "etiqueta": "PENDIENTE FIRMAS"},
  {"valor": "PENDIENTE_CERTIFICACION", "etiqueta": "PENDIENTE CERTIFICACION"},
  {"valor": "CERTIFICADO", "etiqueta": "CERTIFICADO"}
]
```

---

### Actualizar Datos de Programa
**PUT** `/solicitudes/{solicitud_id}/programa`

**Headers**: Authorization requerida. Requiere permiso "solicitudes:actualizar"

**Body**:
```json
{
  "nombre_programa": "TÉCNICO EN GANADERÍA",
  "tipo_programa_id": 2,
  "observaciones_generales": "Cambio de programa por error"
}
```

**Response (200)**:
```json
{
  "message": "Datos actualizados correctamente"
}
```

---

### Actualizar Datos del Aprendiz
**PUT** `/solicitudes/{solicitud_id}/datos-aprendiz`

**Headers**: Authorization requerida. Requiere permiso "solicitudes:actualizar"

**Body** (parcial):
```json
{
  "nombre_aprendiz": "Juan Pérez García",
  "correo_aprendiz": "juang@email.com",
  "numero_ficha": "9999B",
  "telefono_aprendiz": "3109999999"
}
```

**Response (200)**:
```json
{
  "message": "Datos del aprendiz actualizados correctamente"
}
```

---

### Enviar Observaciones al Aprendiz
**POST** `/solicitudes/{solicitud_id}/enviar-observaciones`

**Headers**: Authorization requerida. Requiere permiso "solicitudes:actualizar"

**Response (200)**:
```json
{
  "message": "Notificación enviada al aprendiz correctamente"
}
```

**Notas**:
- Solo disponible cuando hay documentos observados o observaciones generales
- Genera un token de edición y envía correo al aprendiz

---

### Reenviar Observaciones
**POST** `/solicitudes/{solicitud_id}/reenviar-observaciones`

**Headers**: Authorization requerida. Requiere permiso "solicitudes:actualizar"

**Response (200)**:
```json
{
  "message": "Observaciones reenviadas al aprendiz correctamente"
}
```

---

### Obtener Tokens de Edición
**GET** `/solicitudes/{solicitud_id}/tokens`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "solicitud_id": 1,
  "tiene_token_activo": true,
  "tokens": [
    {
      "id": 1,
      "token": "abc123...",
      "usado": false,
      "fecha_creacion": "2026-05-01T10:00:00",
      "fecha_uso": null
    }
  ]
}
```

---

### Obtener Notificaciones
**GET** `/solicitudes/{solicitud_id}/notificaciones`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "solicitud_id": 1,
  "nombre_aprendiz": "Juan Pérez",
  "notificaciones": [
    {
      "id": 1,
      "destinatario": "juan@email.com",
      "tipo_notificacion": "OBSERVACIONES",
      "asunto": "Observaciones en tu solicitud",
      "enviado": true,
      "fecha_envio": "2026-05-01T10:30:00",
      "error_mensaje": null
    }
  ]
}
```

---

### Obtener Historial de Estados
**GET** `/solicitudes/{solicitud_id}/historial`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "solicitud_id": 1,
  "nombre_aprendiz": "Juan Pérez",
  "estado_actual": "PENDIENTE_REVISION",
  "historial": [
    {
      "id": 1,
      "estado_anterior": null,
      "estado_nuevo": "PENDIENTE_REVISION",
      "fecha_cambio": "2026-04-01T09:00:00",
      "usuario_id": null,
      "motivo": "Solicitud inicial"
    }
  ]
}
```

---

### Corregir Datos por Token (público)
**POST** `/solicitudes/corregir-datos/{token}`

**Content-Type**: multipart/form-data

**Body** (opcional):
- `nombre_aprendiz`: string
- `numero_documento`: string
- `tipo_documento`: enum
- `correo_aprendiz`: string
- `telefono_aprendiz`: string
- `tipo_programa_id`: integer
- `nombre_programa`: string
- `numero_ficha`: string
- `archivo_{documento_id}`: file (PDF) - Solo para documentos NO aprobados

**Response (200)**:
```json
{
  "message": "Correcciones enviadas correctamente. El funcionario revisará nuevamente tu solicitud."
}
```

---

### Reenviar Notificación
**POST** `/solicitudes/{solicitud_id}/reenviar-notificacion`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "message": "Correo reenviado correctamente al aprendiz"
}
```

---

### Confirmar Revisión y Pasar a Firmas
**POST** `/solicitudes/{solicitud_id}/confirmar-revision`

**Headers**: Authorization requerida

**Body**:
```json
{
  "coordinador_id": 2
}
```

**Response (200)**:
```json
{
  "message": "Revisión aprobada. La solicitud pasa a proceso de firmas.",
  "estado": "PENDIENTE_FIRMAS"
}
```

**Notas**:
- Si hay documentos aprobados → genera PDF consolidado y pasa a PENDIENTE_FIRMAS
- Si hay observaciones → envía correo con token de edición y pasa a CON_OBSERVACIONES

---

### Eliminar Documentos de Solicitudes Certificadas
**POST** `/solicitudes/eliminar-documentos`

**Headers**: Authorization requerida. Solo ADMIN y FUNCIONARIO_CERTIFICACION

**Body**:
```json
{
  "solicitud_ids": [1, 2, 3],
  "password": "miContraseña123"
}
```

**Response (200)**:
```json
{
  "procesadas": 3,
  "exitosas": 3,
  "fallidas": 0,
  "detalles": [
    {
      "solicitud_id": 1,
      "numero_documento": "CC 1234567890",
      "numero_ficha": "9999",
      "nombre_aprendiz": "Juan Pérez",
      "documentos_cantidad": 3,
      "documentos_eliminados": 3,
      "estado": "éxito",
      "mensaje": "Se eliminaron 3 documento(s)"
    }
  ]
}
```

---

## 📄 Documentos y Firmas

### Revisar Documento
**PUT** `/documentos/{documento_id}/revisar`

**Headers**: Authorization requerida. Requiere permiso "documentos:aprobar"

**Body**:
```json
{
  "estado_documento": "APROBADO",
  "observaciones": null
}
```

O para observar:
```json
{
  "estado_documento": "OBSERVADO",
  "observaciones": "Falta firma adicional"
}
```

**Response (200)**:
```json
{
  "message": "Documento marcado como APROBADO"
}
```

---

### Obtener Documentos para Corregir (público)
**GET** `/documentos/corregir/{token}`

**Response (200)**:
```json
{
  "solicitud_id": 1,
  "nombre_aprendiz": "Juan Pérez",
  "nombre_programa": "TÉCNICO EN AGRONOMÍA",
  "documentos_observados": [
    {
      "id": 1,
      "nombre": "Cedula",
      "observaciones": "Falta firma"
    }
  ]
}
```

---

### Subir Documentos Corregidos (público)
**POST** `/documentos/corregir/{token}`

**Content-Type**: multipart/form-data

**Body**:
- `archivos`: File[] - PDFs en el mismo orden que documentos_observados

**Response (200)**:
```json
{
  "message": "Documentos corregidos correctamente. El funcionario revisará sus documentos nuevamente"
}
```

---

### Obtener Solicitud por Token (público)
**GET** `/documentos/corregir/{token}/solicitud`

**Response (200)**:
```json
{
  "id": 1,
  "numero_documento": "CC 1234567890",
  "numero_ficha": "9999",
  "nombre_aprendiz": "Juan Pérez",
  "nombre_programa": "TÉCNICO EN AGRONOMÍA",
  "estado_actual": "CON_OBSERVACIONES",
  "documentos": [...]
}
```

---

### Reubicar Documento
**PUT** `/documentos/{documento_id}/reubicar`

**Headers**: Authorization requerida. Requiere permiso "documentos:aprobar"

**Body**:
```json
{
  "nuevo_documento_id": 2
}
```

**Response (200)**:
```json
{
  "message": "Documento reubicado correctamente"
}
```

**Notas**:
- Reasigna el tipo de documento cuando se sube en el campo equivocado
- Solo aplica a documentos PENDIENTE u OBSERVADO (no APROBADO)

---

### Obtener Firmas de Solicitud
**GET** `/documentos/{solicitud_id}/firmas`

**Headers**: Authorization requerida

**Response (200)**:
```json
[
  {
    "id": 1,
    "solicitud_id": 1,
    "rol": "COORDINADOR",
    "usuario_id": 2,
    "usuario_nombre": "Ana García",
    "estado_firma": "PENDIENTE",
    "fecha_firma": null,
    "orden_firma": 0
  }
]
```

---

### Firmar Solicitud
**POST** `/documentos/{solicitud_id}/firmar`

**Headers**: Authorization requerida. Requiere permiso "firmas:firmar"

**Body**:
```json
{
  "password": "miContraseña123"
}
```

**Response (200)**:
```json
{
  "message": "Solicitud firmada correctamente",
  "estado_solicitud": "PENDIENTE_FIRMAS"
}
```

**Notas**:
- La solicitud debe estar en PENDIENTE_FIRMAS
- El usuario debe tener un rol firmante
- Se verifica contraseña y que tenga firma registrada si lo requiere
- Si todas las firmas están completas → estado PENDIENTE_CERTIFICACION

**Errores**:
- `401 Unauthorized` - Contraseña incorrecta
- `400 Bad Request` - No tiene firma pendiente o no cumple orden de firma

---

## 🎨 Plantillas

### Listar Plantillas
**GET** `/plantillas`

**Headers**: Authorization requerida

**Response (200)**:
```json
[
  {
    "id": 1,
    "version": "2.0",
    "activa": true,
    "url_archivo": "/uploads/plantillas/plantilla_v2.0.pdf",
    "fecha_creacion": "2026-02-27T09:00:00"
  }
]
```

---

### Obtener Plantilla Activa
**GET** `/plantillas/activa`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "id": 1,
  "version": "2.0",
  "activa": true,
  "url_archivo": "/uploads/plantillas/plantilla_v2.0.pdf",
  "coordenadas": [
    {
      "id": 1,
      "rol": "COORDINADOR",
      "posicion_x": 25.5,
      "posicion_y": 85.3,
      "ancho": 3.0,
      "alto": 1.5
    }
  ]
}
```

---

### Obtener Plantilla por ID
**GET** `/plantillas/{plantilla_id}`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "id": 1,
  "version": "2.0",
  "activa": true,
  "url_archivo": "/uploads/plantillas/plantilla_v2.0.pdf",
  "coordenadas": [...]
}
```

---

### Subir Nueva Plantilla
**POST** `/plantillas`

**Headers**: Authorization requerida. Requiere permiso "plantillas:crear"

**Content-Type**: multipart/form-data

**Body**:
- `version`: string - Versión de la plantilla (ej. "2.1")
- `archivo`: File - PDF

**Response (201)**:
```json
{
  "message": "Plantilla subida correctamente. Configure las coordenadas de firma antes de activarla",
  "plantilla_id": 5
}
```

---

### Guardar Coordenadas de Firma
**PUT** `/plantillas/{plantilla_id}/coordenadas`

**Headers**: Authorization requerida. Requiere permiso "plantillas:editar"

**Body**:
```json
[
  {
    "rol_id": 1,
    "posicion_x": 25.5,
    "posicion_y": 85.3,
    "ancho": 3.0,
    "alto": 1.5
  },
  {
    "rol_id": 2,
    "posicion_x": 55.0,
    "posicion_y": 85.3,
    "ancho": 3.0,
    "alto": 1.5
  }
]
```

**Response (200)**:
```json
{
  "message": "Coordenadas guardadas correctamente"
}
```

**Notas**:
- Las coordenadas se expresan en porcentaje (0-100) del tamaño de página
- Permite que funcionen independientemente del tamaño del PDF

---

### Activar Plantilla
**POST** `/plantillas/{plantilla_id}/activar`

**Headers**: Authorization requerida. Requiere permiso "plantillas:editar"

**Response (200)**:
```json
{
  "message": "Plantilla activada correctamente"
}
```

**Notas**:
- Desactiva la plantilla anterior
- Solo una plantilla puede estar activa

---

## 🔑 Roles y Permisos

### Listar Roles
**GET** `/roles`

**Query Parameters**:
- `incluir_inactivos`: boolean (default: true)

**Headers**: Authorization requerida

**Response (200)**:
```json
[
  {
    "id": 1,
    "nombre": "COORDINADOR",
    "descripcion": "Coordinador de certificaciones",
    "requiere_firma": true,
    "activo": true
  }
]
```

---

### Obtener Rol Completo
**GET** `/roles/{rol_id}`

**Headers**: Authorization requerida. Solo ADMIN

**Response (200)**:
```json
{
  "id": 1,
  "nombre": "COORDINADOR",
  "descripcion": "Coordinador de certificaciones",
  "requiere_firma": true,
  "permisos": [
    {
      "id": 1,
      "modulo": "solicitudes",
      "accion": "leer"
    }
  ]
}
```

---

### Crear Rol
**POST** `/roles`

**Headers**: Authorization requerida. Solo ADMIN

**Body**:
```json
{
  "nombre": "REVISOR",
  "descripcion": "Revisa solicitudes",
  "requiere_firma": false
}
```

**Response (201)**:
```json
{
  "message": "Rol creado correctamente",
  "rol_id": 5
}
```

---

### Actualizar Rol
**PUT** `/roles/{rol_id}`

**Headers**: Authorization requerida. Solo ADMIN

**Body**:
```json
{
  "descripcion": "Nuevo coordinador de firmas",
  "requiere_firma": true
}
```

**Response (200)**:
```json
{
  "message": "Rol actualizado correctamente"
}
```

---

### Cambiar Estado de Rol
**PUT** `/roles/{rol_id}/estado`

**Headers**: Authorization requerida. Solo ADMIN

**Query Parameters**:
- `activo`: boolean

**Response (200)**:
```json
{
  "message": "Rol activado correctamente"
}
```

---

### Asignar Permiso a Rol
**POST** `/roles/{rol_id}/permisos`

**Headers**: Authorization requerida. Solo ADMIN

**Body**:
```json
{
  "modulo_id": 1,
  "accion_id": 2
}
```

**Response (201)**:
```json
{
  "message": "Permiso asignado correctamente"
}
```

---

### Revocar Permiso de Rol
**DELETE** `/roles/{rol_id}/permisos/{permiso_id}`

**Headers**: Authorization requerida. Solo ADMIN

**Response (200)**:
```json
{
  "message": "Permiso revocado correctamente"
}
```

---

### Revocar Todos los Permisos
**DELETE** `/roles/{rol_id}/permisos`

**Headers**: Authorization requerida. Solo ADMIN

**Response (200)**:
```json
{
  "message": "Todos los permisos del rol fueron revocados"
}
```

---

### Listar Módulos
**GET** `/roles/modulos`

**Headers**: Authorization requerida. Solo ADMIN

**Response (200)**:
```json
[
  {
    "id": 1,
    "nombre": "solicitudes",
    "descripcion": "Gestión de solicitudes"
  }
]
```

---

### Listar Acciones
**GET** `/roles/acciones`

**Headers**: Authorization requerida. Solo ADMIN

**Response (200)**:
```json
[
  {
    "id": 1,
    "nombre": "leer",
    "descripcion": "Lectura"
  }
]
```

---

## 📚 Tipos de Programa

### Listar Tipos de Programa
**GET** `/tipo-programas`

**Headers**: Authorization requerida. Solo ADMIN

**Response (200)**:
```json
[
  {
    "id": 1,
    "nombre": "TÉCNICO EN AGRONOMÍA",
    "descripcion": "Programa técnico en agronomía"
  }
]
```

---

### Obtener Tipo de Programa Detallado
**GET** `/tipo-programas/{tipo_id}`

**Headers**: Authorization requerida. Solo ADMIN

**Response (200)**:
```json
{
  "id": 1,
  "nombre": "TÉCNICO EN AGRONOMÍA",
  "descripcion": "Programa técnico",
  "documentos": [
    {
      "id": 1,
      "nombre": "Cedula",
      "obligatorio": true,
      "orden": 1
    }
  ],
  "roles_firmantes": [
    {
      "id": 1,
      "rol": "COORDINADOR",
      "orden_firma": 0
    }
  ]
}
```

---

### Crear Tipo de Programa
**POST** `/tipo-programas`

**Headers**: Authorization requerida. Solo ADMIN

**Body**:
```json
{
  "nombre": "TÉCNICO EN GANADERÍA",
  "descripcion": "Programa técnico en ganadería"
}
```

**Response (201)**:
```json
{
  "message": "Tipo de programa creado correctamente",
  "tipo_id": 5
}
```

---

### Actualizar Tipo de Programa
**PUT** `/tipo-programas/{tipo_id}`

**Headers**: Authorization requerida. Solo ADMIN

**Body**:
```json
{
  "nombre": "TÉCNICO EN GANADERÍA SOSTENIBLE",
  "descripcion": "Programa mejorado"
}
```

**Response (200)**:
```json
{
  "message": "Tipo de programa actualizado correctamente"
}
```

---

### Eliminar Tipo de Programa
**DELETE** `/tipo-programas/{tipo_id}`

**Headers**: Authorization requerida. Solo ADMIN

**Response (200)**:
```json
{
  "message": "Tipo de programa eliminado correctamente"
}
```

---

### Asignar Documento a Tipo de Programa
**POST** `/tipo-programas/{tipo_id}/documentos`

**Headers**: Authorization requerida. Solo ADMIN

**Body**:
```json
{
  "documento_id": 2,
  "obligatorio": true
}
```

**Response (201)**:
```json
{
  "message": "Documento asignado correctamente"
}
```

---

### Quitar Documento de Tipo de Programa
**DELETE** `/tipo-programas/{tipo_id}/documentos/{relacion_id}`

**Headers**: Authorization requerida. Solo ADMIN

**Response (200)**:
```json
{
  "message": "Documento quitado correctamente"
}
```

---

### Mover Orden de Documento
**PUT** `/tipo-programas/{tipo_id}/documentos/{relacion_id}/orden`

**Headers**: Authorization requerida. Solo ADMIN

**Body**:
```json
{
  "direccion": "up"
}
```

**Response (200)**:
```json
{
  "message": "Orden de documento actualizado correctamente"
}
```

---

### Asignar Rol Firmante
**POST** `/tipo-programas/{tipo_id}/roles`

**Headers**: Authorization requerida. Solo ADMIN

**Body**:
```json
{
  "rol_id": 1,
  "orden_firma": 0
}
```

**Response (201)**:
```json
{
  "message": "Rol firmante asignado correctamente"
}
```

---

### Quitar Rol Firmante
**DELETE** `/tipo-programas/{tipo_id}/roles/{relacion_id}`

**Headers**: Authorization requerida. Solo ADMIN

**Response (200)**:
```json
{
  "message": "Rol firmante quitado correctamente"
}
```

---

## 📊 Auditoría

### Listar Registros de Auditoría
**GET** `/auditoria`

**Query Parameters**:
- `page`: Página (default: 1)
- `limit`: Registros por página (default: 50)
- `usuario_id`: Filtrar por usuario (opcional)
- `tabla`: Filtrar por tabla (usuarios, solicitudes, etc)
- `accion`: Filtrar por acción (optional)
- `fecha_desde`: YYYY-MM-DD (optional)
- `fecha_hasta`: YYYY-MM-DD (optional)

**Headers**: Authorization requerida

**Response (200)**:
```json
[
  {
    "id": 1,
    "usuario_id": 1,
    "tabla_afectada": "solicitudes",
    "accion": "UPDATE",
    "id_registro_afectado": 15,
    "descripcion": "Estado cambiado de BORRADOR a ENVIADA",
    "fecha_evento": "2026-05-04T15:30:00",
    "ip_origen": "192.168.1.100"
  }
]
```

---

### Obtener Acciones Disponibles
**GET** `/auditoria/acciones`

**Headers**: Authorization requerida

**Response (200)**:
```json
[
  {
    "accion": "LOGIN_EXITOSO",
    "descripcion": "Login exitoso"
  },
  {
    "accion": "DOCUMENTO_OBSERVADO",
    "descripcion": "Documento marcado como observado"
  }
]
```

---

## 📈 Reportes

### Resumen General del Sistema
**GET** `/reportes/resumen-general`

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "total_solicitudes": 150,
  "por_estado": [
    {"estado_actual": "CERTIFICADO", "total": 120},
    {"estado_actual": "PENDIENTE_REVISION", "total": 20}
  ],
  "por_tipo_programa": [
    {"tipo_programa": "TÉCNICO EN AGRONOMÍA", "total": 80, "certificadas": 75}
  ],
  "dias_promedio_certificacion": 8.5
}
```

---

### Solicitudes por Período
**GET** `/reportes/solicitudes-por-periodo`

**Query Parameters**:
- `fecha_desde`: YYYY-MM-DD (requerido)
- `fecha_hasta`: YYYY-MM-DD (requerido)
- `tipo_programa_id`: integer (opcional)
- `estado`: string (opcional)

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "periodo": {"desde": "2026-04-01", "hasta": "2026-05-04"},
  "resumen": {
    "total": 30,
    "certificadas": 25,
    "con_observaciones": 3,
    "pendientes_revision": 2
  },
  "solicitudes": [...]
}
```

---

### Actividad de Funcionarios
**GET** `/reportes/actividad-funcionarios`

**Query Parameters**:
- `fecha_desde`: YYYY-MM-DD (opcional)
- `fecha_hasta`: YYYY-MM-DD (opcional)

**Headers**: Authorization requerida

**Response (200)**:
```json
{
  "periodo": {"desde": null, "hasta": null},
  "revision_documentos": [
    {
      "usuario_id": 1,
      "nombre_completo": "Juan Pérez",
      "documentos_aprobados": 50,
      "documentos_observados": 5
    }
  ],
  "firmas": [
    {
      "usuario_id": 2,
      "nombre_completo": "Ana García",
      "rol": "COORDINADOR",
      "firmas_completadas": 40,
      "firmas_rechazadas": 2
    }
  ],
  "logins": [...]
}
```

---

## 🚨 Códigos de Error

| Código | Significado | Ejemplo |
|--------|-------------|---------|
| `200` | OK - Solicitud exitosa | GET /usuarios/1 |
| `201` | Created - Recurso creado | POST /usuarios |
| `204` | No Content - Éxito sin contenido | DELETE /usuarios/1 |
| `400` | Bad Request - Solicitud inválida | Datos malformados |
| `401` | Unauthorized - Token inválido/expirado | Token JWT inválido o contraseña incorrecta |
| `403` | Forbidden - Sin permisos | Usuario intenta acceder a recurso sin permisos |
| `404` | Not Found - Recurso no existe | GET /usuarios/999 |
| `409` | Conflict - Violación de integridad | Email duplicado |
| `413` | Payload Too Large - Archivo muy grande | Documento > 10 MB |
| `415` | Unsupported Media Type - Formato no soportado | Subir .doc en lugar de .pdf |
| `422` | Unprocessable Entity - Validación fallida | Email inválido |
| `429` | Too Many Requests - Demasiadas solicitudes | Usuario bloqueado por intentos fallidos |
| `500` | Internal Server Error - Error del servidor | Error no previsto |
| `503` | Service Unavailable - Servicio no disponible | BD fuera de servicio |

---

## 📌 Convenciones

### Métodos HTTP
- `GET` - Obtener recurso(s)
- `POST` - Crear recurso
- `PUT` - Actualizar completamente o parcialmente
- `PATCH` - Actualizar parcialmente
- `DELETE` - Eliminar recurso

### Campos de Autenticación
- `correo`: Email del usuario (no "email")
- `password`: Contraseña (no "contraseña")
- Token JWT en header: `Authorization: Bearer {token}`

### Nombres de Endpoint
- Sustantivos plural: `/usuarios`, `/solicitudes`
- Rutas anidadas para relaciones: `/solicitudes/{id}/firmas`
- Acciones especiales con slash-verbo: `/solicitudes/{id}/confirmar-revision`

### Formatos
- Request/Response: JSON (salvo archivos)
- Fechas: ISO 8601 (YYYY-MM-DDTHH:MM:SS)
- Paginación: `page`, `limit`
- Enums: Mayúsculas con guiones (PENDIENTE_REVISION)

---

## 🧪 Ejemplos cURL

### Login
```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "correo": "usuario@sena.edu.co",
    "password": "SecurePass123!"
  }'
```

### Crear Solicitud (multipart)
```bash
curl -X POST http://localhost:8000/solicitudes \
  -F "tipo_documento=CC" \
  -F "numero_documento=1234567890" \
  -F "numero_ficha=9999" \
  -F "nombre_aprendiz=Juan Pérez" \
  -F "correo_aprendiz=juan@email.com" \
  -F "confirmar_correo=juan@email.com" \
  -F "tipo_programa_id=1" \
  -F "nombre_programa=TÉCNICO EN AGRONOMÍA" \
  -F "archivo_1=@documento1.pdf" \
  -F "archivo_2=@documento2.pdf"
```

### Subir Plantilla
```bash
curl -X POST http://localhost:8000/plantillas \
  -H "Authorization: Bearer {token}" \
  -F "version=2.1" \
  -F "archivo=@plantilla.pdf"
```

### Revisar Documento
```bash
curl -X PUT http://localhost:8000/documentos/1/revisar \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "estado_documento": "APROBADO",
    "observaciones": null
  }'
```

### Firmar Solicitud
```bash
curl -X POST http://localhost:8000/documentos/1/firmar \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "password": "miContraseña123"
  }'
```

---

**Documento**: API_DOCUMENTATION.md
**Version**: 2.0.0 (Sincronizado con API real)
**Última actualización**: 2026-05-04
}
```

**Estados válidos**:
- `Borrador` - Inicial
- `Enviada` - Usuario envía
- `En Revisión` - Coordinador revisa
- `Aprobada` - Coordinador aprueba
- `Rechazada` - Coordinador rechaza

**Response (200)**: Solicitud con estado actualizado

---

### Enviar Solicitud
**POST** `/solicitudes/{solicitud_id}/enviar`

Cambia estado de Borrador a Enviada y envía email de notificación

**Response (200)**:
```json
{
  "mensaje": "Solicitud enviada correctamente",
  "solicitud_id": 15,
  "email_enviado": true
}
```

---

## 📄 Documentos

### Listar Documentos de Solicitud
**GET** `/solicitudes/{solicitud_id}/documentos`

**Response (200)**:
```json
[
  {
    "id": 1,
    "solicitud_id": 15,
    "tipo": "Certificado",
    "ruta_archivo": "uploads/documentos/15/certificado_001.pdf",
    "tamaño_bytes": 245000,
    "fecha_carga": "2026-04-01T10:30:00",
    "created_at": "2026-04-01T10:30:00"
  }
]
```

---

### Cargar Documento
**POST** `/solicitudes/{solicitud_id}/documentos/cargar`

**Content-Type**: multipart/form-data

**Body**:
```
file: [Binary PDF file]
tipo: "Certificado"
```

**Response (201)**:
```json
{
  "id": 2,
  "solicitud_id": 15,
  "tipo": "Certificado",
  "ruta_archivo": "uploads/documentos/15/certificado_002.pdf",
  "tamaño_bytes": 512000,
  "fecha_carga": "2026-05-04T15:00:00",
  "mensaje": "Documento cargado exitosamente"
}
```

**Validaciones**:
- Formato: Solo PDF
- Tamaño máximo: 10 MB
- Debe estar acoplado a una solicitud existente

**Errores**:
- `413 Payload Too Large` - Archivo excede límite
- `415 Unsupported Media Type` - Formato no soportado
- `404 Not Found` - Solicitud no existe

---

### Descargar Documento
**GET** `/documentos/{documento_id}/descargar`

**Response**: Binary PDF file

---

### Eliminar Documento
**DELETE** `/documentos/{documento_id}`

**Response (204)**: Documento eliminado

---

## 🎨 Plantillas

### Listar Plantillas
**GET** `/plantillas`

**Response (200)**:
```json
[
  {
    "id": 1,
    "nombre": "Plantilla Estándar 2026",
    "descripcion": "Plantilla oficial para certificados",
    "ruta_archivo": "uploads/documentos/plantillas/plantilla_001.pdf",
    "created_at": "2026-02-27T09:00:00"
  }
]
```

---

### Crear Plantilla
**POST** `/plantillas`

**Content-Type**: multipart/form-data

**Body**:
```
file: [Binary PDF file]
nombre: "Nueva Plantilla"
descripcion: "Descripción de la plantilla"
```

**Response (201)**: Plantilla creada

---

### Descargar Plantilla
**GET** `/plantillas/{plantilla_id}/descargar`

**Response**: Binary PDF file

---

## 🔑 Roles

### Listar Roles
**GET** `/roles`

**Response (200)**:
```json
[
  {
    "id": 1,
    "nombre": "Administrador",
    "descripcion": "Acceso total al sistema",
    "permisos": {
      "crear_usuario": true,
      "editar_usuario": true,
      "eliminar_usuario": true,
      "ver_auditoria": true
    }
  }
]
```

---

### Crear Rol
**POST** `/roles`

**Body**:
```json
{
  "nombre": "Revisor",
  "descripcion": "Revisa solicitudes",
  "permisos": {
    "revisar_solicitudes": true,
    "aprobar_solicitudes": true,
    "ver_documentos": true
  }
}
```

**Response (201)**: Rol creado

---

### Actualizar Rol
**PUT** `/roles/{rol_id}`

**Body**: Parcial o completo

**Response (200)**: Rol actualizado

---

## 📊 Auditoría

### Listar Logs de Auditoría
**GET** `/auditoria`

**Query Parameters**:
- `skip`: offset
- `limit`: límite
- `usuario_id`: Filtrar por usuario
- `tabla`: Filtrar por tabla (usuarios, solicitudes, documentos, etc)
- `accion`: Filtrar por acción (INSERT, UPDATE, DELETE)
- `fecha_desde`: YYYY-MM-DD
- `fecha_hasta`: YYYY-MM-DD

**Response (200)**:
```json
[
  {
    "id": 1,
    "usuario_id": 1,
    "tabla_afectada": "solicitudes",
    "accion": "UPDATE",
    "id_registro_afectado": 15,
    "valor_anterior": {
      "estado": "Borrador"
    },
    "valor_nuevo": {
      "estado": "Enviada"
    },
    "timestamp": "2026-05-04T15:30:00",
    "ip_origen": "192.168.1.100"
  }
]
```

---

### Exportar Auditoria
**GET** `/auditoria/exportar`

**Query Parameters**: Mismos que listar

**Response**: CSV file

---

## 📚 Tipos de Programa

### Listar Tipos de Programa
**GET** `/tipo-programas`

**Response (200)**:
```json
[
  {
    "id": 1,
    "nombre": "Técnico en Agronomía",
    "descripcion": "Programa técnico en agronomía",
    "horas_duracion": 1200
  }
]
```

---

### Crear Tipo de Programa
**POST** `/tipo-programas`

**Body**:
```json
{
  "nombre": "Técnico en Ganadería",
  "descripcion": "Programa técnico en ganadería",
  "horas_duracion": 1000
}
```

**Response (201)**: Tipo creado

---

## 🚨 Códigos de Error

| Código | Significado | Ejemplo |
|--------|-------------|---------|
| `200` | OK - Solicitud exitosa | GET /users/1 |
| `201` | Created - Recurso creado | POST /users |
| `204` | No Content - Éxito sin contenido | DELETE /users/1 |
| `400` | Bad Request - Solicitud inválida | Datos malformados |
| `401` | Unauthorized - Token inválido/expirado | Token JWT inválido |
| `403` | Forbidden - Sin permisos | Usuario intenta acceder a recurso de otro |
| `404` | Not Found - Recurso no existe | GET /users/999 |
| `409` | Conflict - Violación de integridad | Email duplicado |
| `413` | Payload Too Large - Archivo muy grande | Documento > 10 MB |
| `415` | Unsupported Media Type - Formato no soportado | Subir .doc en lugar de .pdf |
| `422` | Unprocessable Entity - Validación fallida | Email inválido |
| `500` | Internal Server Error - Error del servidor | Error no previsto |
| `503` | Service Unavailable - Servicio no disponible | BD fuera de servicio |

---

## 📌 Convenciones

### Métodos HTTP
- `GET` - Obtener recurso(s)
- `POST` - Crear recurso
- `PUT` - Actualizar completamente
- `PATCH` - Actualizar parcialmente
- `DELETE` - Eliminar recurso

### Nombres de Endpoint
- Sustantivos plural: `/users`, `/solicitudes`
- Acciones especiales: `/solicitudes/{id}/enviar`
- Relaciones: `/solicitudes/{id}/documentos`

### Formatos
- Request/Response: JSON (salvo archivos)
- Fechas: ISO 8601 (YYYY-MM-DDTHH:MM:SS)
- Paginación: `skip`, `limit`

---

## 🧪 Ejemplos cURL

### Login
```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@sena.edu.co",
    "contraseña": "SecurePass123!"
  }'
```

### Crear Solicitud
```bash
curl -X POST http://localhost:8000/solicitudes \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "usuario_id": 5,
    "tipo_programa_id": 1
  }'
```

### Cargar Documento
```bash
curl -X POST http://localhost:8000/solicitudes/15/documentos/cargar \
  -H "Authorization: Bearer {token}" \
  -F "file=@documento.pdf" \
  -F "tipo=Certificado"
```

---

**Documento**: API_DOCUMENTATION.md
**Version**: 1.0.0
**Última actualización**: 2026-05-04

