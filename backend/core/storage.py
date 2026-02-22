import os
import shutil
import uuid
from abc import ABC, abstractmethod
from fastapi import UploadFile, HTTPException
from .config import settings

ALLOWED_EXTENSIONS = {".pdf", ".docx", ".pptx", ".jpg", ".png", ".zip"}
MAX_FILE_SIZE = 20 * 1024 * 1024 # 20MB

def validate_file(file: UploadFile):
    file_ext = os.path.splitext(file.filename)[1].lower()
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail=f"File extension {file_ext} not allowed")

    # Check size (requires seeking to end)
    file.file.seek(0, os.SEEK_END)
    file_size = file.file.tell()
    file.file.seek(0)

    if file_size > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File too large (max 20MB)")

class StorageProvider(ABC):
    @abstractmethod
    async def save(self, file: UploadFile, sub_dir: str = "") -> str:
        pass

    @abstractmethod
    async def delete(self, file_path: str):
        pass

class LocalStorageProvider(StorageProvider):
    def __init__(self, upload_dir: str):
        self.upload_dir = upload_dir
        if not os.path.exists(upload_dir):
            os.makedirs(upload_dir)

    async def save(self, file: UploadFile, sub_dir: str = "") -> str:
        target_dir = os.path.join(self.upload_dir, sub_dir)
        if not os.path.exists(target_dir):
            os.makedirs(target_dir)

        file_extension = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        file_path = os.path.join(target_dir, unique_filename)

        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        # Return a path relative to the static route
        return os.path.join("/static/uploads", sub_dir, unique_filename).replace("\\", "/")

    async def delete(self, file_path: str):
        # Implementation for deleting local files
        pass

def get_storage_provider() -> StorageProvider:
    if settings.STORAGE_PROVIDER == "local":
        return LocalStorageProvider(settings.UPLOAD_DIR)
    # Future: S3StorageProvider
    raise ValueError(f"Unknown storage provider: {settings.STORAGE_PROVIDER}")

# Helper for backward compatibility
def save_upload_file(file: UploadFile, sub_dir: str = "") -> str:
    import asyncio
    provider = get_storage_provider()
    # This is a sync wrapper for an async method, might be risky in some contexts
    # but for FastAPI endpoints it should be fine if not called from an async loop
    # or if we use run_until_complete.
    # Actually most endpoints are def not async def so they run in threadpool.
    return asyncio.run(provider.save(file, sub_dir))
