from pydantic_settings import BaseSettings
import os
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    PROJECT_NAME: str = "Sistema de Gestión de Certificaciones y Firmas Digitales – Centro Atención Sector Agropecuario"
    PROJECT_VERSION: str = "1.0.0"
    PROJECT_DESCRIPTION: str = "Sistema para gestionar y digitalizar el proceso de certificación de aprendices"

    # -------------------------------------------------------
    # Base de datos
    # -------------------------------------------------------
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_PORT: int = int(os.getenv("DB_PORT", "5432"))
    DB_USER: str = os.getenv("DB_USER", "postgres")
    DB_PASSWORD: str = os.getenv("DB_PASSWORD", "")
    DB_NAME: str = os.getenv("DB_NAME", "postgres")
    DB_DRIVER: str = os.getenv("DB_DRIVER", "postgresql")

    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        (
            f"{DB_DRIVER}://{DB_USER}:"
            f"{DB_PASSWORD}@"
            f"{DB_HOST}:"
            f"{DB_PORT}/"
            f"{DB_NAME}"
        ),
    )

    # -------------------------------------------------------
    # JWT para funcionarios
    # -------------------------------------------------------
    JWT_SECRET: str = os.getenv("JWT_SECRET", "clave_temporal_desarrollo")
    JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("JWT_ACCESS_TOKEN_EXPIRE_MINUTES", "60"))

    # -------------------------------------------------------
    # Archivos subidos por aprendices
    # -------------------------------------------------------
    UPLOAD_DIR: str = os.getenv("UPLOAD_DIR", "uploads/documentos")
    MAX_FILE_SIZE_MB: int = int(os.getenv("MAX_FILE_SIZE_MB", "10"))
    ALLOWED_EXTENSIONS: list = ["pdf", "jpg", "jpeg", "png"]

    # -------------------------------------------------------
    # Supabase Storage
    # -------------------------------------------------------
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_SERVICE_ROLE_KEY: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
    SUPABASE_STORAGE_BUCKET: str = os.getenv("SUPABASE_STORAGE_BUCKET", "uploads")

    # -------------------------------------------------------
    # Correo electrónico
    # -------------------------------------------------------

    RESEND_API_KEY: str = os.getenv("RESEND_API_KEY", "")

    # -------------------------------------------------------
    # URL base del sistema
    # -------------------------------------------------------
    BASE_URL: str = os.getenv("BASE_URL", "http://localhost:8000")
    FRONTEND_URL: str = os.getenv("FRONTEND_URL", "http://localhost:5173")

    class Config:
        env_file = ".env"

settings = Settings()
