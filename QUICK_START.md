# ⚡ QUICK START - Checklist Rápida

Sigue estos pasos EN ORDEN para desplegar a producción.

## ✅ PASO 1: Obtener Credenciales Supabase (15 minutos)

- [ ] Abre https://app.supabase.com
- [ ] Selecciona tu proyecto (el de la BD)
- [ ] **Copia URL** (Settings → General → Project URL)
  - Ej: `https://phihfzsgrggvxursvpmi.supabase.co`
- [ ] **Copia Service Key** (Settings → API → service_role)
  - Ej: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
- [ ] **Crea Bucket Storage**:
  - Storage → Create Bucket → Nombre: `uploads` → Public → Create
- [ ] **Configura CORS** en Storage:
  - Storage → uploads → Settings → CORS:
  ```json
  [{"origin": "http://localhost:5173", "methods": ["GET", "POST", "PUT", "DELETE"], "headers": ["*"], "credentials": true}]
  ```

## ✅ PASO 2: Actualizar .env Backend (5 minutos)

**Abre:** `backend/.env`

Reemplaza estas 3 líneas:
```
SUPABASE_URL=https://phihfzsgrggvxursvpmi.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_STORAGE_BUCKET=uploads
```

(Usa TUS valores copios en PASO 1)

## ✅ PASO 3: Testing Local (30 minutos)

Terminal 1 - Backend:
```bash
cd backend
python -m uvicorn main:app --reload
# Espera: INFO:     Uvicorn running on http://0.0.0.0:8000
```

Terminal 2 - Frontend:
```bash
cd frontend
npm run dev
# Espera: Local:        http://localhost:5173/
```

Abre http://localhost:5173 y:
- [ ] Crea solicitud con PDF
- [ ] Verifica archivo en Supabase Storage (Storage → uploads → documentos)
- [ ] Descarga el PDF
- [ ] Todo funciona sin errores

## ✅ PASO 4: Subir a GitHub (5 minutos)

```bash
git add .
git commit -m "feat: Supabase Storage + ready to deploy"
git push origin main
```

## ✅ PASO 5: Desplegar Backend en Render (10 minutos)

1. Abre https://dashboard.render.com
2. Selecciona tu servicio Backend (o crea uno nuevo)
3. Settings → Environment
4. Agrega/Actualiza:
   ```
   SUPABASE_URL=https://phihfzsgrggvxursvpmi.supabase.co
   SUPABASE_SERVICE_ROLE_KEY=eyJ...
   SUPABASE_STORAGE_BUCKET=uploads
   ```
   (Más las demás variables que ya tenías)
5. Save → Render redeploya
6. Espera hasta ver "Live" (5-10 min)
7. **Copia la URL** (ej: https://nombre-backend.render.com)

## ✅ PASO 6: Desplegar Frontend en Render (10 minutos)

1. Abre https://dashboard.render.com
2. Selecciona tu servicio Frontend
3. Settings → Environment
4. Actualiza:
   ```
   VITE_API_URL=https://nombre-backend.render.com
   ```
   (Usa la URL que copiaste en PASO 5)
5. Save → Rebuild
6. Espera hasta ver "Live" (5-10 min)
7. Copia tu URL frontend

## ✅ PASO 7: Verificación Final (5 minutos)

1. Abre tu frontend en producción
2. Crea solicitud de prueba
3. Descarga PDF - debe funcionar
4. Si no funciona, revisa [LOCAL_TESTING_GUIDE.md](./LOCAL_TESTING_GUIDE.md)

## 🎉 ¡LISTO!

Tu sistema está en producción con:
- ✅ Base de datos en Supabase PostgreSQL
- ✅ Storage de archivos en Supabase Storage
- ✅ Backend en Render
- ✅ Frontend en Render

---

**⏱️ Tiempo total: ~1.5 horas**

**Si algo falla:** Revisa los logs en Render y busca el error específico.

**Documentos de referencia:**
- Paso 1 problema → [SUPABASE_STORAGE_SETUP.md](./SUPABASE_STORAGE_SETUP.md)
- Paso 3 problema → [LOCAL_TESTING_GUIDE.md](./LOCAL_TESTING_GUIDE.md)
- Paso 5-6 problema → [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
