# Integración Supabase Storage para Backend

## Resumen de Cambios

Ya hemos integrado Supabase Storage en el backend para reemplazar el almacenamiento de archivos local. Los cambios implementados incluyen:

### 1. **Nueva Utilidad de Almacenamiento** (`app/utils/storage.py`)
- `upload_bytes_to_supabase()`: Sube archivos a Supabase Storage usando la API REST
- `download_to_temp()`: Descarga archivos remotos a temporales para procesamiento local
- `ensure_local_file()`: Maneja tanto rutas locales como URLs remotas
- `is_remote_url()`: Detecta si una URL es remota
- Fallback a almacenamiento local si Supabase no está configurado

### 2. **Configuración en `core/config.py`**
Se añadieron variables de entorno:
```python
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
SUPABASE_STORAGE_BUCKET = os.getenv("SUPABASE_STORAGE_BUCKET", "uploads")
```

### 3. **Endpoints Actualizados**

#### `POST /solicitudes/` (Crear solicitud)
- Documentos subidos se guardan directamente en Supabase Storage
- Ruta: `documentos/{solicitud_id}/{nombre_archivo}.pdf`

#### `POST /documentos/corregir/{token}` (Aprendiz corrige documentos)
- Documentos corregidos se suben a Supabase Storage
- Mantiene versionado (v1, v2, v3, etc.)

#### `POST /solicitudes/corregir-datos/{token}` (Aprendiz corrige datos)
- Procesa documentos corregidos desde Supabase
- Usa `ensure_local_file()` para descargar si es necesario

#### `POST /solicitudes/{id}/confirmar-revision` (Confirma revisión de documentos)
- Genera PDF consolidado localmente
- Sube el PDF consolidado a Supabase Storage
- Almacena la URL pública en BD

#### `POST /documentos/{id}/firmar` (Funcionario firma)
- Obtiene el PDF consolidado de Supabase (si es remoto)
- Incrusta firmas localmente
- Sube el PDF firmado a Supabase Storage

#### `GET /documentos/{id}/pdf` (Descarga PDF)
- Si es URL remota: descarga a temporal, sirve, luego limpia
- Si es local: sirve directamente
- Utiliza `BackgroundTasks` para limpiar temporales

#### `POST /documentos/certificados/zip` (Descarga ZIP de certificados)
- Maneja URLs remotas y locales
- Descarga temporales, crea ZIP, limpia

#### `POST /usuarios/{id}/firma` (Sube firma de funcionario)
- Procesa imagen de firma (transparencia, etc.)
- Sube PNG procesado a Supabase Storage
- Ruta: `firmas/firma_{usuario_id}.png`

#### `POST /plantillas/` (Sube plantilla)
- Sube archivos de plantilla a Supabase Storage
- Ruta: `plantillas/plantilla_v{version}.pdf`

### 4. **Utilidades PDF Actualizadas** (`app/utils/pdf.py`)
- `generar_pdf_consolidado()`: Maneja archivos desde Supabase o local
- `incrustar_firmas_en_pdf()`: Procesa firmas desde URL remota
- Utiliza `ensure_local_file()` para descargas temporales

### 5. **Flujo de Archivos**

```
Usuario sube documento
        ↓
Validación (PDF, tamaño)
        ↓
Sube a Supabase Storage
        ↓
URL pública almacenada en BD
        ↓
Durante descarga: si es remoto → descarga → temporal → sirve → limpia
```

## Configuración Requerida

Agregar al archivo `.env`:

```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5...
SUPABASE_STORAGE_BUCKET=uploads
```

## Ventajas

1. **Almacenamiento Persistente**: Archivos en Supabase, no en servidor
2. **Escalabilidad**: Sin límite de espacio en servidor
3. **CDN Global**: Descargas rápidas desde cualquier ubicación
4. **Seguridad**: Control de acceso en Supabase
5. **Backup Automático**: Supabase maneja respaldos
6. **Fallback Local**: Continúa funcionando si Supabase no está configurado

## Notas

- Los archivos se siguen procesando localmente (PDFs, firmas)
- Temporales se limpian automáticamente
- URLs públicas se usan para descargas HTTP
- Service Role Key debe tener acceso de escritura en Storage

## Próximos Pasos

1. Configurar credenciales de Supabase en `.env`
2. Crear bucket "uploads" en Supabase Storage
3. Configurar políticas de acceso público en Storage
4. Probar flujo de uploads desde frontend
5. Validar descargas de PDFs remotos
