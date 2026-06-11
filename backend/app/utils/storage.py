import io
import logging
import os
import tempfile
import urllib.parse
import urllib.request
from typing import Optional

from core.config import settings

logger = logging.getLogger(__name__)


def is_remote_url(path: str) -> bool:
    return isinstance(path, str) and path.startswith(("http://", "https://"))


def get_supabase_bucket() -> str:
    if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY or not settings.SUPABASE_STORAGE_BUCKET:
        raise ValueError(
            "Supabase storage is not configured. Set SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY and SUPABASE_STORAGE_BUCKET."
        )
    return settings.SUPABASE_STORAGE_BUCKET


def build_storage_public_url(object_path: str) -> str:
    bucket = get_supabase_bucket()
    object_path = object_path.lstrip("/")
    base = settings.SUPABASE_URL.rstrip("/")
    quoted_path = urllib.parse.quote(object_path, safe="/")
    return f"{base}/storage/v1/object/public/{bucket}/{quoted_path}"


def upload_bytes_to_supabase(object_path: str, content: bytes, content_type: str = "application/pdf") -> str:
    if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY or not settings.SUPABASE_STORAGE_BUCKET:
        # Fallback local storage for development
        destination = os.path.join(settings.UPLOAD_DIR, object_path)
        os.makedirs(os.path.dirname(destination), exist_ok=True)
        with open(destination, "wb") as f:
            f.write(content)
        return destination.replace("\\", "/")

    object_path = object_path.lstrip("/")
    base = settings.SUPABASE_URL.rstrip("/")
    params = urllib.parse.urlencode({
        "cacheControl": "public, max-age=86400",
        "upsert": "true",
        "name": object_path,
    })
    url = f"{base}/storage/v1/object/{get_supabase_bucket()}?{params}"
    headers = {
        "Authorization": f"Bearer {settings.SUPABASE_SERVICE_ROLE_KEY}",
        "apikey": settings.SUPABASE_SERVICE_ROLE_KEY,
        "Content-Type": content_type,
        "x-upsert": "true",
    }
    request = urllib.request.Request(url, data=content, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(request) as response:
            if response.status not in (200, 201):
                raise RuntimeError(f"Supabase storage upload failed: {response.status} {response.reason}")
    except urllib.error.HTTPError as err:
        body = err.read().decode(errors="ignore")
        if err.code == 404:
            # Some Supabase setups require object path upload as part of the URL path.
            fallback_url = f"{base}/storage/v1/object/{get_supabase_bucket()}/{urllib.parse.quote(object_path, safe='/')}"
            logger.info("Supabase upload 404, retrying with fallback URL: %s", fallback_url)
            fallback_request = urllib.request.Request(fallback_url, data=content, headers=headers, method="POST")
            try:
                with urllib.request.urlopen(fallback_request) as response:
                    if response.status not in (200, 201):
                        raise RuntimeError(f"Supabase storage upload failed: {response.status} {response.reason}")
            except urllib.error.HTTPError as err2:
                body2 = err2.read().decode(errors="ignore")
                raise RuntimeError(
                    f"Supabase storage upload failed: {err2.code} {err2.reason} {body2}"
                ) from err2
        else:
            raise RuntimeError(f"Supabase storage upload failed: {err.code} {err.reason} {body}") from err

    return build_storage_public_url(object_path)


def download_to_temp(path_or_url: str) -> str:
    if not path_or_url:
        raise ValueError("No path or URL provided for download_to_temp")

    if not is_remote_url(path_or_url):
        return path_or_url

    headers = {}
    if settings.SUPABASE_SERVICE_ROLE_KEY:
        headers["Authorization"] = f"Bearer {settings.SUPABASE_SERVICE_ROLE_KEY}"
        headers["apikey"] = settings.SUPABASE_SERVICE_ROLE_KEY

    request = urllib.request.Request(path_or_url, headers=headers, method="GET")
    with urllib.request.urlopen(request) as response:
        suffix = os.path.splitext(urllib.parse.urlparse(path_or_url).path)[1] or ""
        tmp_file = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
        tmp_file.write(response.read())
        tmp_file.close()
        return tmp_file.name


def ensure_local_file(path_or_url: str) -> tuple[str, bool]:
    if is_remote_url(path_or_url):
        return download_to_temp(path_or_url), True
    return path_or_url, False
