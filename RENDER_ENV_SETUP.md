# Variables de Entorno para Render - Guía de Configuración

## Backend en Render

Las siguientes variables deben configurarse en Render Dashboard → Tu Servicio Backend → Settings → Environment:

### 1. Base de Datos (Supabase)
```
DATABASE_URL=postgresql://postgres.phihfzsgrggvxursvpmi:PASSWORD@aws-1-us-east-1.pooler.supabase.com:5432/postgres
DB_DRIVER=postgresql
DB_HOST=postgres.phihfzsgrggvxursvpmi
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=YOUR_SUPABASE_PASSWORD
DB_NAME=postgres
```

### 2. JWT (Autenticación)
```
JWT_SECRET=una_clave_secreta_muy_larga_y_segura_min_32_caracteres
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=60
```

### 3. Supabase Storage
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_STORAGE_BUCKET=uploads
```

### 4. Email
```
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=tu-correo@gmail.com
MAIL_PASSWORD=tu-contraseña-app
MAIL_FROM=tu-correo@gmail.com
MAIL_FROM_NAME=Certificaciones SENA Centro Atención Sector Agropecuario
```

### 5. URLs Base
```
BASE_URL=https://tu-backend.render.com
FRONTEND_URL=https://tu-frontend.render.com
```

### 6. Almacenamiento (para fallback local si Supabase falla)
```
UPLOAD_DIR=uploads
MAX_FILE_SIZE_MB=10
```

## Frontend en Render

Variable de entorno a configurar en Render Dashboard → Tu Servicio Frontend:

### VITE_API_URL
```
VITE_API_URL=https://tu-backend.render.com
```

## Cómo Configurar en Render

### Para el Backend (Python/FastAPI):

1. Ve a tu servicio Backend en Render
2. Haz clic en **Settings**
3. Baja a **Environment**
4. Agrega cada variable
5. Haz clic en **Save Changes**
6. Render redesplegará automáticamente

### Para el Frontend (Node/Vite):

1. Ve a tu servicio Frontend
2. Haz clic en **Settings**
3. Busca **Environment Variables**
4. Agrega `VITE_API_URL` con tu URL del backend
5. Guarda y déjalo que haga rebuild

## Orden Recomendado

1. ✅ Subir cambios a Git
2. ✅ Backend: Configurar variables en Render
3. ✅ Frontend: Configurar VITE_API_URL en Render
4. ✅ Prueba: Crear solicitud de prueba
