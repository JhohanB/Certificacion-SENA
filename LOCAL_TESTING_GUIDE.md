# Testing Local - Checklist Completo

## 🧪 Antes de Desplegar

Sigue estos pasos para verificar que todo funciona localmente.

## 1️⃣ Instalar Dependencias

```bash
# Backend
cd backend
python -m pip install -r requirements.txt

# Frontend (en otra terminal)
cd frontend
npm install
```

## 2️⃣ Configurar Variables de Entorno

### Backend `.backend/.env`

```
DATABASE_URL=postgresql://...  # Tu Supabase (ya tienes)
JWT_SECRET=test_local_secret_development_only

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
SUPABASE_STORAGE_BUCKET=uploads

# El resto como está
```

### Frontend `frontend/.env`

```
VITE_API_URL=http://localhost:8000
```

## 3️⃣ Iniciar Backend

```bash
cd backend
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Espera a ver:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Prueba en navegador:** http://localhost:8000/docs
- Debe abrir Swagger UI
- Si ve error de BD, revisa `DATABASE_URL`

## 4️⃣ Iniciar Frontend

**En otra terminal:**

```bash
cd frontend
npm run dev
```

**Espera a ver:**
```
> Local:        http://localhost:5173/
```

**Abre:** http://localhost:5173

## 5️⃣ Tests Funcionales

### Test 1: Login como Aprendiz
- [ ] Página de inicio se carga
- [ ] Puedo ver "Crear Nueva Solicitud"

### Test 2: Crear Solicitud
- [ ] Completo el formulario
- [ ] Selecciono un PDF válido
- [ ] Hago clic en "Enviar"
- [ ] Recibo confirmación
- [ ] Recibo email en la bandeja
- [ ] Verifico en Supabase Storage que el archivo esté en `documentos/123/`

### Test 3: Login como Funcionario
- [ ] Cambio de rol en SeleccionarRol
- [ ] Puedo ver el dashboard
- [ ] Aparece la solicitud que creé

### Test 4: Revisar Documentos
- [ ] Hago clic en la solicitud
- [ ] Puedo ver los documentos
- [ ] Puedo descargar PDFs
- [ ] Funcionan los permisos

### Test 5: Aprobar Todo
- [ ] Apruebo todos los documentos
- [ ] Confirmo revisión
- [ ] Sistema genera PDF consolidado
- [ ] PDF se sube a Supabase
- [ ] Puedo descargar el PDF

### Test 6: Firmar
- [ ] Cambio a rol Coordinador
- [ ] Veo solicitud en "Pendiente Firmas"
- [ ] Puedo firmar con mi contraseña
- [ ] Sistema incrusta firma en PDF
- [ ] PDF actualizado tiene firma

### Test 7: Certificación
- [ ] Cambio a rol Certificación
- [ ] Certifico la solicitud
- [ ] Aprendiz recibe email de certificación

## 6️⃣ Tests Técnicos

### Backend está conectado a Supabase
```bash
python -c "from core.config import settings; print(f'DB OK: {settings.DATABASE_URL[:30]}...')"
```

### Storage está configurado
```bash
python -c "from core.config import settings; print(f'Supabase URL: {settings.SUPABASE_URL}'); print(f'Bucket: {settings.SUPABASE_STORAGE_BUCKET}')"
```

### Frontend apunta al backend correcto
Abre DevTools (F12) en navegador:
```javascript
console.log('API:', import.meta.env.VITE_API_URL)
// Debe mostrar: http://localhost:8000
```

### Verificar Storage en Supabase
1. Ve a Supabase Dashboard
2. Storage → `uploads` bucket
3. Buscas carpeta `documentos/`
4. Dentro debe haber carpetas con los IDs de solicitudes
5. Dentro de cada carpeta: los PDFs subidos

## 7️⃣ Pruebas de Errores

### Test Error: PDF inválido
- [ ] Intento subir un archivo que no es PDF (ej: imagen)
- [ ] Sistema rechaza con mensaje claro

### Test Error: Archivo muy grande
- [ ] Intento subir archivo > 10MB
- [ ] Sistema rechaza

### Test Error: Sin conexión Supabase
- [ ] Apago temporalmente Supabase Storage vars
- [ ] Sistema debería usar fallback local
- [ ] Los archivos se guardan en `uploads/` del servidor

### Test Error: Base de datos desconectada
- [ ] Apago la BD
- [ ] Intento crear solicitud
- [ ] Error 500 con mensaje claro

## 8️⃣ Logs a Revisar

### Backend (Terminal donde corre uvicorn)
```
INFO:     POST /solicitudes/ 
INFO:     Database query executed
INFO:     File uploaded to Supabase
```

**Si ves errores:**
```
ERROR:root:... (búscalos, son importantes)
```

### Frontend (Console en DevTools - F12)
Debe estar limpia de errores rojos.

Si hay errores de CORS:
```
Access to XMLHttpRequest blocked by CORS
```
→ Necesitas actualizar CORS en backend

## 9️⃣ Checklist Pre-Deploy

- [ ] Todo lo anterior funciona sin errores
- [ ] Base de datos conectada y con datos
- [ ] Supabase Storage recibe y devuelve archivos
- [ ] PDFs se pueden descargar
- [ ] Firmas se incrustan correctamente
- [ ] Emails se envían
- [ ] No hay errores en logs
- [ ] Frontend se conecta correctamente al backend
- [ ] Los usuarios pueden completar flujo de certificación

## 🎯 Si Algo Falla

**Paso 1:** Revisa los logs
```bash
# Backend
# Mira el terminal donde corre uvicorn

# Frontend
# F12 en navegador, pestaña Console
```

**Paso 2:** Busca el error en los archivos correspondientes
- Error de BD → `core/database.py`
- Error de Storage → `app/utils/storage.py`
- Error de ruta → el endpoint específico

**Paso 3:** Verifica variables de entorno
```bash
python -c "from core.config import settings; print(vars(settings))" | grep -i supabase
```

**Paso 4:** Si persiste, revisa:
- [ ] Las credenciales de Supabase son correctas
- [ ] El bucket existe en Supabase
- [ ] Los permisos de CORS están configurados
- [ ] La BD está en línea

## ✅ Cuando Todo Esté Listo

Entonces puedes:
1. Hacer push a GitHub
2. Configurar variables en Render
3. Ver el deploy en producción

¡Buena suerte! 🚀
