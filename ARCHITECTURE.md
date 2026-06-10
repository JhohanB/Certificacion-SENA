# 🏗️ Arquitectura Técnica - Sistema de Gestión de Certificaciones y Firmas Digitales – Centro de Atención del Sector Agropecuario

---

## 📊 Diagrama de Arquitectura General

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENTE (Browser)                         │
│                      React 19 + Vite App                         │
└────────────────┬────────────────────────────────────┬────────────┘
                 │                                    │
                 ▼                                    ▼
        ┌──────────────┐                    ┌──────────────┐
        │   Frontend   │                    │ Local Storage│
        │ (Port 5173)  │                    │ (Auth Token) │
        └──────┬───────┘                    └──────────────┘
               │
               │ HTTP/REST
               ▼
        ┌──────────────────────────────────────────────────────┐
        │          BACKEND - API REST (FastAPI)                │
        │                 Port 8000                            │
        │  ┌─────────────────────────────────────────────────┐ │
        │  │           Authentication Layer                   │ │
        │  │    JWT + Password Hashing (Bcrypt)              │ │
        │  └─────────────────────────────────────────────────┘ │
        │  ┌─────────────────────────────────────────────────┐ │
        │  │         Router Layer (REST Endpoints)           │ │
        │  │ /users, /auth, /solicitudes, /documentos, etc.  │ │
        │  └─────────────────────────────────────────────────┘ │
        │  ┌─────────────────────────────────────────────────┐ │
        │  │  Business Logic Layer (CRUD Operations)         │ │
        │  │     Validaciones, Reglas de Negocio             │ │
        │  └─────────────────────────────────────────────────┘ │
        │  ┌─────────────────────────────────────────────────┐ │
        │  │        Utilities Layer                          │ │
        │  │  Email, PDF, File Validation, Auditoría         │ │
        │  └─────────────────────────────────────────────────┘ │
        └──────┬──────────────────────────────────────────────┘
               │
               │ SQL
               ▼
        ┌──────────────────────────────────────────────────────┐
        │          DATABASE LAYER                              │
        │  MySQL 5.7+ (SQLAlchemy ORM)                         │
        │  ┌────────────────────────────────────────────────┐ │
        │  │  ├─ usuarios                                   │ │
        │  │  ├─ roles                                      │ │
        │  │  ├─ solicitudes                                │ │
        │  │  ├─ documentos                                 │ │
        │  │  ├─ solicitudes_eliminar_documentos            │ │
        │  │  ├─ plantillas                                 │ │
        │  │  ├─ tipo_programas                             │ │
        │  │  ├─ auditoria_logs                             │ │
        │  │  └─ firmas_digitales                           │ │
        │  └────────────────────────────────────────────────┘ │
        └──────┬──────────────────────────────────────────────┘
               │
               ▼
        ┌──────────────────────────────────────────────────────┐
        │        FILE STORAGE                                  │
        │   uploads/documentos/[ID]/                           │
        │   - PDFs de solicitudes                              │
        │   - PDFs de plantillas                               │
        │   - Firmas digitales                                 │
        └──────────────────────────────────────────────────────┘
```

---

## 🔐 Capas de Arquitectura

### 1. **Capa de Presentación (Frontend)**

**Stack**: React 19, Vite, Ant Design, Axios

**Componentes principales**:
- `App.jsx` - Enrutador principal
- `components/Layout.jsx` - Layout general
- `components/Skeletons.jsx` - Loading states
- `pages/` - Vistas principales (Dashboard, Solicitudes, Usuarios, etc.)
- `context/AuthContext.jsx` - Gestión de autenticación
- `api/axios.js` - Cliente HTTP configurado
- `hooks/useInactividad.js` - Manejo de sesión inactiva

**Características**:
- ✅ Autenticación JWT
- ✅ Context API para estado global
- ✅ Custom hooks para lógica reutilizable
- ✅ Validación de formularios
- ✅ Error handling

---

### 2. **Capa de API (Backend - FastAPI)**

**Stack**: Python 3.9+, FastAPI, SQLAlchemy, Pydantic

#### 2.1 **Router Layer** (`app/router/`)

Define endpoints REST:
```
├── auth.py                 # Login, logout, refresh token
├── users.py                # CRUD usuarios
├── solicitudes.py          # CRUD solicitudes de certificación
├── documentos.py           # Carga y gestión de documentos
├── plantillas.py           # Gestión de plantillas
├── roles.py                # Gestión de roles
├── tipo_programas.py       # Tipos de programas
├── auditoria.py            # Logs de auditoría
└── solicitudes_eliminar_documentos.py  # Solicitudes especiales
```

#### 2.2 **CRUD Layer** (`app/crud/`)

Operaciones base de datos:
```
├── auth.py                 # Validación de credenciales
├── usuarios.py             # Operaciones usuarios
├── solicitudes.py          # Operaciones solicitudes
├── documentos.py           # Operaciones documentos
├── plantillas.py           # Operaciones plantillas
├── roles.py                # Operaciones roles
├── tipo_programas.py       # Operaciones tipos programa
└── solicitudes_eliminar_documentos.py  # Operaciones especiales
```

#### 2.3 **Schemas Layer** (`app/schemas/`)

Validación Pydantic (Request/Response):
```
├── usuarios.py             # UsuarioCreate, UsuarioResponse
├── solicitudes.py          # SolicitudCreate, SolicitudResponse
├── documentos.py           # DocumentoCreate, DocumentoResponse
├── plantillas.py           # PlantillaCreate, PlantillaResponse
├── roles.py                # RolCreate, RolResponse
└── tipo_programas.py       # TipoProgramaCreate, TipoProgramaResponse
```

#### 2.4 **Utils Layer** (`app/utils/`)

Funcionalidades transversales:
```
├── email_service.py        # Envío de correos SMTP
├── email_templates.py      # Templates HTML de emails
├── pdf.py                  # Generación/validación PDF
├── file_validation.py      # Validación de archivos
└── auditoria.py            # Registro de cambios
```

#### 2.5 **Core Layer** (`core/`)

Configuración y seguridad:
```
├── config.py               # Variables de entorno
├── database.py             # Conexión SQLAlchemy
└── security.py             # JWT, Hashing, Permisiones
```

---

### 3. **Capa de Datos (Base de Datos)**

**BD**: MySQL 5.7+
**ORM**: SQLAlchemy

**Tablas principales**:

```sql
usuarios
├── id (PK)
├── email (UNIQUE)
├── nombre_completo
├── contraseña (Hashed)
├── activo
├── rol_id (FK)
└── created_at, updated_at

roles
├── id (PK)
├── nombre (UNIQUE)
├── descripcion
├── permisos (JSON)
└── created_at

solicitudes
├── id (PK)
├── usuario_id (FK)
├── estado (ENUM: Borrador, Enviada, En Revisión, Aprobada, Rechazada)
├── fecha_creacion
├── fecha_envio
├── observaciones (TEXT)
└── created_at, updated_at

documentos
├── id (PK)
├── solicitud_id (FK)
├── tipo (ENUM: Certificado, Diploma, Otros)
├── ruta_archivo
├── fecha_carga
└── created_at

auditoria_logs
├── id (PK)
├── usuario_id (FK)
├── tabla_afectada
├── accion (INSERT, UPDATE, DELETE)
├── valor_anterior (JSON)
├── valor_nuevo (JSON)
├── timestamp
└── ip_origen
```

---

## 🔄 Flujos Principales

### Flujo 1: Autenticación
```
1. Usuario ingresa email/contraseña en Login
2. Frontend envía POST /auth/login
3. Backend valida credenciales
4. Backend genera JWT token
5. Frontend guarda token en localStorage
6. Redirecciona a Dashboard
7. Requests posteriores incluyen Authorization header con token
```

### Flujo 2: Creación de Solicitud
```
1. Usuario crea nueva solicitud (vacía - Borrador)
2. Carga documentos PDF
3. Sistema valida formato y tamaño
4. Almacena en uploads/documentos/[ID]/
5. Registra en BD
6. Auditoría registra acción
7. Email de confirmación al usuario
```

### Flujo 3: Flujo de Revisión
```
1. Coordinador revisa solicitud
2. Puede aprobar, rechazar o solicitar correcciones
3. Sistema registra observaciones
4. Email notifica al usuario
5. Auditoría registra cambio de estado
6. Si aprueba → genera firma digital
7. Genera certificado/diploma PDF
```

---

## 🛡️ Seguridad

### Autenticación
- ✅ JWT (JSON Web Tokens)
- ✅ Password hashing con Bcrypt
- ✅ Tokens con expiración (60 min default)
- ✅ Refresh token mechanism

### Autorización
- ✅ Control de roles (RBAC)
- ✅ Middlewares de permisos
- ✅ Validación de acceso a recursos

### Validación
- ✅ Validación Pydantic en request body
- ✅ Validación de archivos (tipo MIME, tamaño)
- ✅ Sanitización de entrada
- ✅ CORS configurado

### Auditoría
- ✅ Log de todas las acciones
- ✅ Registro de usuario, timestamp, acción
- ✅ Valores antes y después de cambios
- ✅ IP de origen

---

## 📦 Dependencias Clave

### Backend
```
fastapi==0.104.0
sqlalchemy==2.0.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
pydantic-settings==2.0.0
python-multipart==0.0.6
aiofiles==23.2.0
python-dotenv==1.0.0
```

### Frontend
```
react==19.0.0
vite==5.0.0
ant-design==5.0.0
axios==1.6.0
react-router-dom==6.x
```

---

## 🚀 Patrones de Diseño

### 1. **MVC Adaptado**
- Model: SQLAlchemy ORM
- View: React Components
- Controller: FastAPI Routers + CRUD

### 2. **Separation of Concerns**
- Router ≠ Business Logic ≠ Data Access
- Utilities separadas por funcionalidad

### 3. **Middleware**
- Autenticación JWT
- CORS
- Error handling

### 4. **Context Pattern** (Frontend)
- AuthContext para estado global de autenticación

---

## 🔧 Extensibilidad

### Agregar nueva funcionalidad:

1. **Crear schema** en `app/schemas/nueva_funcionalidad.py`
2. **Crear modelo** en `core/database.py` (si nueva tabla)
3. **Crear CRUD** en `app/crud/nueva_funcionalidad.py`
4. **Crear router** en `app/router/nueva_funcionalidad.py`
5. **Crear página React** en `frontend/src/pages/`
6. **Registrar ruta** en `main.py`

---

## 📈 Escalabilidad

**Consideraciones para crecimiento**:
- Caché con Redis (para sesiones, tokens)
- Message Queue (Celery) para emails asincronos
- CDN para archivos estáticos
- Load Balancing para múltiples instancias backend
- Read replicas en BD para queries pesadas
- Versionamiento de API (v1, v2...)

---

## 🔍 Monitoreo Recomendado

- Logs centralizados (ELK, Datadog)
- APM (Application Performance Monitoring)
- Error tracking (Sentry)
- Uptime monitoring
- Database performance monitoring
- API response time tracking

---

**Documento Técnico**: ARCHITECTURE.md
**Última actualización**: 2026-05-04

