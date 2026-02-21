import logging
import sys
from typing import Any, Dict
from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel

# Structured Logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)]
)

logger = logging.getLogger("lms")

class ErrorResponse(BaseModel):
    detail: str
    code: str
    params: Dict[str, Any] = {}

async def custom_http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "detail": exc.detail,
            "code": getattr(exc, "code", "UNKNOWN_ERROR"),
            "params": getattr(exc, "params", {})
        },
    )
