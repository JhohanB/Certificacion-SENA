from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum


# -------------------------------------------------------
# Enums
# -------------------------------------------------------

class EstadoDocumento(str, Enum):
    PENDIENTE = "PENDIENTE"
    OBSERVADO = "OBSERVADO"
    APROBADO = "APROBADO"


class EstadoFirma(str, Enum):
    PENDIENTE = "PENDIENTE"
    FIRMADO = "FIRMADO"
    RECHAZADO = "RECHAZADO"

class TipoRechazo(str, Enum):
    POR_DOCUMENTOS = "POR_DOCUMENTOS"
    POR_OTRA_RAZON = "POR_OTRA_RAZON"


# -------------------------------------------------------
# Revisar un documento individual
# El funcionario puede aprobar u observar
# -------------------------------------------------------

class RevisarDocumento(BaseModel):
    estado_documento: EstadoDocumento
    observaciones: Optional[str] = Field(
        default=None,
        description="Obligatorio si estado_documento es OBSERVADO"
    )

    def model_post_init(self, __context):
        if self.estado_documento == EstadoDocumento.OBSERVADO and not self.observaciones:
            raise ValueError("Las observaciones son obligatorias al observar un documento")


# -------------------------------------------------------
# Firmar una solicitud
# La sesión activa es la autenticación (cierre automático por inactividad)
# -------------------------------------------------------

class FirmarSolicitud(BaseModel):
    pass


# -------------------------------------------------------
# Rechazar firma
# El firmante puede rechazar indicando el motivo
# -------------------------------------------------------

class RechazarFirma(BaseModel):
    tipo_rechazo: TipoRechazo
    motivo_rechazo: str = Field(min_length=10, max_length=500)


# -------------------------------------------------------
# Respuesta de firma
# -------------------------------------------------------

class FirmaOut(BaseModel):
    id: int
    solicitud_id: int
    rol_id: int
    nombre_rol: str
    usuario_id: Optional[int] = None
    nombre_usuario: Optional[str] = None
    estado_firma: EstadoFirma
    tipo_rechazo: Optional[TipoRechazo] = None
    motivo_rechazo: Optional[str] = None
    fecha_firma: Optional[datetime] = None


# -------------------------------------------------------
# Respuesta de historial de estados
# -------------------------------------------------------

class HistorialEstadoOut(BaseModel):
    id: int
    estado_anterior: Optional[str] = None
    estado_nuevo: str
    nombre_usuario: Optional[str] = None
    motivo: Optional[str] = None
    fecha_cambio: datetime


# -------------------------------------------------------
# Reubicar documento
# -------------------------------------------------------

class ReubicarDocumento(BaseModel):
    nuevo_documento_id: int = Field(description="ID del documento requerido al que se reasignará el archivo")