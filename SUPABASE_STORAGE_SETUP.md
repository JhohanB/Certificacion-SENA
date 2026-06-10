# Cómo Obtener Credenciales de Supabase Storage

## Paso 1: Accede a tu Proyecto de Supabase

1. Ve a https://app.supabase.com
2. Selecciona tu proyecto (el que tiene la BD de certificaciones)
3. En el panel izquierdo, haz clic en **Settings**

## Paso 2: Obtén la URL de Supabase

1. En **Settings** → **General**, busca **Project URL**
2. Copia la URL completa (ej: `https://phihfzsgrggvxursvpmi.supabase.co`)

```
SUPABASE_URL=https://phihfzsgrggvxursvpmi.supabase.co
```

## Paso 3: Obtén la Service Role Key

1. En **Settings** → **API**, busca la sección **Project API keys**
2. Encuentra la key llamada **service_role** (NOT anon, es la privada)
3. Copia la clave completa

```
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

⚠️ **Importante**: Esta es la clave privada. Nunca la compartas ni la commits a Git.

## Paso 4: Crea el Bucket

1. En el panel izquierdo, ve a **Storage**
2. Haz clic en **Create a new bucket**
3. Nombre: `uploads`
4. Private or Public: selecciona **Public** (para descargas HTTP)
5. Clic en **Create bucket**

```
SUPABASE_STORAGE_BUCKET=uploads
```

## Paso 5: Configura Permisos (CORS)

1. En **Storage** → **Buckets** → **uploads**
2. Haz clic en el bucket **uploads**
3. Ve a **Settings**
4. En **CORS Configuration**, agrega:

```json
[
  {
    "origin": "http://localhost:5173",
    "methods": ["GET", "POST", "PUT", "DELETE"],
    "headers": ["*"],
    "credentials": true
  },
  {
    "origin": "https://tu-dominio-frontend.render.com",
    "methods": ["GET", "POST", "PUT", "DELETE"],
    "headers": ["*"],
    "credentials": true
  }
]
```

(Actualiza la URL del frontend según tu dominio en Render)

## Paso 6: Actualiza tu .env

Reemplaza en `backend/.env`:

```
SUPABASE_URL=https://phihfzsgrggvxursvpmi.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_STORAGE_BUCKET=uploads
```

## Verificación

Ejecuta en el terminal del backend:

```bash
python -c "from core.config import settings; print(f'URL: {settings.SUPABASE_URL}'); print(f'Key: {settings.SUPABASE_SERVICE_ROLE_KEY[:20]}...'); print(f'Bucket: {settings.SUPABASE_STORAGE_BUCKET}')"
```

Debería mostrar las variables cargadas correctamente.

## Políticas Públicas del Bucket (Opcional)

Si quieres que los archivos sean descargables públicamente sin autenticación:

1. Ve a **Storage** → **Buckets** → **uploads** → **Policies**
2. Agrega una policy pública para lecturas:
   - **Allow public access** para `SELECT` en objetos
   - Esto permite URLs públicas directas

Esto es lo que usamos para las descargas de PDFs.
