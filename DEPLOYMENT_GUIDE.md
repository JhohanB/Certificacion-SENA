# Guía Completa de Despliegue a Render

## 📋 Pre-requisitos

- [ ] Proyecto en GitHub (repo actualizado)
- [ ] Credenciales de Supabase obtenidas
- [ ] Cuenta en Render (render.com)
- [ ] Variables de entorno listadas

## 🚀 Paso 1: Preparar Cambios Locales

Antes de desplegar, asegúrate que todo funcione localmente:

```bash
# Backend
cd backend
python -m pip install -r requirements.txt
python -m uvicorn main:app --reload

# Frontend (en otra terminal)
cd frontend
npm install
npm run dev
```

Prueba:
- [ ] Crear una solicitud en el frontend
- [ ] Verificar que se guarde en la BD
- [ ] Descargar PDF

## 📤 Paso 2: Subir Cambios a GitHub

```bash
# Desde la raíz del proyecto
git add .
git commit -m "feat: Integración Supabase Storage + preparación deploy"
git push origin main
```

**Archivos a verificar que están committed:**
- ✅ `backend/app/utils/storage.py` (nuevo)
- ✅ `backend/core/config.py` (actualizado)
- ✅ `backend/requirements.txt` (si hay cambios)
- ✅ `backend/app/router/*.py` (todos actualizados)
- ✅ `frontend/src/api/axios.js`
- ✅ `frontend/.env` (NO debe estar)

**Verificar `.gitignore`:**
```
backend/.env
backend/.env.local
frontend/.env
frontend/.env.local
```

## 🔗 Paso 3: Obtener Credenciales de Supabase

Sigue [SUPABASE_STORAGE_SETUP.md](./SUPABASE_STORAGE_SETUP.md) para:
- [ ] Obtener `SUPABASE_URL`
- [ ] Obtener `SUPABASE_SERVICE_ROLE_KEY`
- [ ] Crear bucket `uploads` en Storage
- [ ] Configurar CORS

## 🎯 Paso 4: Desplegar Backend a Render

### Opción A: Si ya tienes servicio de Backend en Render

1. Abre Render Dashboard
2. Selecciona tu servicio Backend
3. Ve a **Settings** → **Environment**
4. Actualiza/Agrega variables (ver [RENDER_ENV_SETUP.md](./RENDER_ENV_SETUP.md))
5. Guarda → Render hace rebuild automático
6. Espera 5-10 minutos hasta que esté listo

### Opción B: Si es primera vez desplegando

1. Ve a render.com
2. Haz clic en **New +**
3. Selecciona **Web Service**
4. Conecta tu repo de GitHub
5. Configura:
   - **Name**: `nombre-backend`
   - **Root Directory**: `backend/`
   - **Start Command**: `gunicorn main:app --bind 0.0.0.0:$PORT`
   - **Python Version**: `3.13`
6. Agrega variables de entorno
7. Crea servicio (tardará 5-10 min)
8. Copia la URL (ej: `https://nombre-backend.render.com`)

## 🎨 Paso 5: Desplegar Frontend a Render

### Opción A: Si ya tienes servicio de Frontend

1. Abre Render Dashboard
2. Selecciona tu servicio Frontend
3. Ve a **Settings** → **Environment**
4. Actualiza `VITE_API_URL`:
   ```
   VITE_API_URL=https://nombre-backend.render.com
   ```
5. Guarda → Render hace rebuild

### Opción B: Primera vez desplegando

1. Ve a render.com → **New +** → **Static Site**
2. Conecta tu repo
3. Configura:
   - **Name**: `nombre-frontend`
   - **Root Directory**: `frontend/`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `dist/`
4. Agrega variable:
   ```
   VITE_API_URL=https://nombre-backend.render.com
   ```
5. Crea (tardará 5-10 min)
6. Copia la URL (ej: `https://nombre-frontend.render.com`)

## ✅ Paso 6: Actualizar URLs

Una vez que tengas ambas URLs:

1. **En Backend (.env de Render):**
   ```
   FRONTEND_URL=https://nombre-frontend.render.com
   BASE_URL=https://nombre-backend.render.com
   ```

2. **En Frontend (.env de Render):**
   ```
   VITE_API_URL=https://nombre-backend.render.com
   ```

## 🧪 Paso 7: Verificación Final

1. Abre el frontend: `https://nombre-frontend.render.com`
2. Intenta crear una solicitud
3. Verifica en Supabase Dashboard:
   - [ ] Datos en la tabla `solicitudes`
   - [ ] Archivos en Storage → `uploads/documentos/`
4. Descarga el PDF
5. Verifica logs en Render (no debe haber errores)

## 🔧 Troubleshooting

### El frontend no conecta al backend
- [ ] Verifica `VITE_API_URL` en Render
- [ ] Revisa CORS en FastAPI (debe permitir dominio frontend)
- [ ] Mira logs en Render Backend

### Los archivos no se suben a Supabase
- [ ] Verifica `SUPABASE_SERVICE_ROLE_KEY` (correcta y sin espacios)
- [ ] Verifica `SUPABASE_URL`
- [ ] Crea el bucket `uploads` si no existe
- [ ] Revisa Supabase Dashboard → Storage

### Error 401/403 en descarga
- [ ] Verifica `DATABASE_URL`
- [ ] Verifica `JWT_SECRET`
- [ ] Revisa logs en Render Backend

### PDFs con URL remota fallan
- [ ] Verifica que Supabase Storage tenga política de lectura pública
- [ ] Prueba descargar la URL directamente en navegador

## 📊 Monitoreo

Después del deploy, visita regularmente:

1. **Render Dashboard**: Verifica que los servicios estén "Live"
2. **Supabase**: Verifica que la BD esté recibiendo datos
3. **Logs de Render**: En Backend y Frontend, busca errores

## 🔄 Para Futuros Cambios

```bash
# Solo necesitas hacer push a GitHub
git add .
git commit -m "descripción del cambio"
git push origin main

# Render redeploya automáticamente
```

¡Listo! 🎉
