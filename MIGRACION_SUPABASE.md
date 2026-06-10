# 🗄️ Guía: Migración MySQL → PostgreSQL (Supabase)

## ✅ Archivos Creados

- **`schema_postgresql.sql`** - Estructura de tablas para PostgreSQL
- **`seed_postgresql.sql`** - Datos iniciales (roles, módulos, acciones)

## 📋 Pasos para Ejecutar en Supabase

### **Paso 1: Conectar a Supabase**

1. Ve a [supabase.com](https://supabase.com) y accede a tu proyecto
2. En el menú lateral, ve a **"SQL Editor"**
3. Haz clic en **"New Query"**

### **Paso 2: Ejecutar Schema (Estructura)**

1. Copia TODO el contenido de `schema_postgresql.sql`
2. Pégalo en el editor SQL de Supabase
3. Haz clic en **"Run"** (Ctrl + Enter)

✅ **Resultado esperado**: Se crearán todas las tablas sin errores

### **Paso 3: Ejecutar Seed (Datos Iniciales)**

1. Copia TODO el contenido de `seed_postgresql.sql`
2. Crea una **Nueva Query** en Supabase
3. Pégalo en el editor SQL
4. Haz clic en **"Run"** (Ctrl + Enter)

✅ **Resultado esperado**: Se insertarán todos los roles, módulos y acciones

---

## 🔄 Cambios a Hacer en el Backend

### **1. Cambiar driver de MySQL a PostgreSQL**

**En `backend/requirements.txt`**, reemplaza:

```
PyMySQL==1.1.2
```

Con:

```
psycopg2-binary==2.9.9
```

### **2. Actualizar DATABASE_URL en `backend/core/config.py`**

```python
# Cambiar de:
DATABASE_URL: str = (
    f"mysql+pymysql://{os.getenv('DB_USER', 'root')}:"
    f"{os.getenv('DB_PASSWORD', '')}@"
    f"{os.getenv('DB_HOST', 'localhost')}:"
    f"{os.getenv('DB_PORT', '3306')}/"
    f"{os.getenv('DB_NAME', 'default_db')}"
)

# A:
DATABASE_URL: str = (
    f"postgresql://{os.getenv('DB_USER', 'postgres')}:"
    f"{os.getenv('DB_PASSWORD', '')}@"
    f"{os.getenv('DB_HOST', 'localhost')}:"
    f"{os.getenv('DB_PORT', '5432')}/"
    f"{os.getenv('DB_NAME', 'postgres')}"
)
```

### **3. Variables de Entorno para Supabase**

```env
# En tu .env local y en Supabase
DB_HOST=tu-proyecto.supabase.co
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=tu_password_supabase
DB_NAME=postgres
```

---

## 📦 Almacenamiento de Archivos (Supabase Storage)

### **Paso 1: Crear Bucket en Supabase**

1. En Supabase, ve a **"Storage"** en el menú lateral
2. Haz clic en **"Create a new bucket"**
3. Nombre: `certificacion-documentos`
4. Configura como **Public** (para descargar PDFs)

### **Paso 2: Crear carpetas en el Bucket**

Dentro del bucket, crea:
- `documentos/` - Para PDFs e imágenes de aprendices
- `firmas/` - Para imágenes de firmas digitales
- `plantillas/` - Para plantillas de certificación

### **Paso 3: Actualizar código del backend**

En `backend/app/utils/pdf.py` y rutas de upload, cambiar rutas locales por URLs de Supabase Storage.

---

## 🔑 Generar Credenciales de Supabase

1. Ve a **Settings** → **API** en tu proyecto
2. Copia:
   - **Project URL** (API URL)
   - **anon key** (Token público)
   - **service_role key** (Token privado - proteger)

Usa `service_role key` en el backend para autorizar uploads a Storage.

---

## ✅ Verificación

Después de ejecutar los scripts, verifica en Supabase:

```sql
-- Ver todas las tablas
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';

-- Ver roles creados
SELECT id, nombre FROM roles;

-- Ver acciones
SELECT id, nombre FROM acciones;
```

---

## ❌ Si Algo Falla

**Error: "constraint violation"**
- Ejecuta primero `schema_postgresql.sql` antes que `seed_postgresql.sql`

**Error: "sequence not found"**
- Los setval() al final de seed.sql arreglará esto

**Error: "column does not exist"**
- Verifica que hayas ejecutado completo el `schema_postgresql.sql`

---

Próximos pasos: Actualizaré tu backend para usar Supabase PostgreSQL + Storage.
