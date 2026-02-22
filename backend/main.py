import logging
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from core.config import settings
from api import auth, subjects, content, tasks, schedule, community, notifications, quizzes, announcements, attendance, gradebook, admin

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="LMS API",
    description="Mobile-first Educational Platform API",
    version="1.0.0",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
)

# Set all CORS enabled origins
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

@app.middleware("http")
async def log_requests(request: Request, call_next):
    logger.info(f"Request: {request.method} {request.url}")
    response = await call_next(request)
    logger.info(f"Response: {response.status_code}")
    return response

@app.get("/")
def root():
    return {"message": "Welcome to LMS API", "docs": "/docs"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

app.include_router(auth.router, prefix=settings.API_V1_STR, tags=["login"])
app.include_router(subjects.router, prefix=f"{settings.API_V1_STR}/subjects", tags=["subjects"])
app.include_router(content.router, prefix=settings.API_V1_STR, tags=["content"])
app.include_router(tasks.router, prefix=settings.API_V1_STR, tags=["tasks"])
app.include_router(quizzes.router, prefix=f"{settings.API_V1_STR}/quizzes", tags=["quizzes"])
app.include_router(schedule.router, prefix=f"{settings.API_V1_STR}/schedule", tags=["schedule"])
app.include_router(community.router, prefix=settings.API_V1_STR, tags=["community"])
app.include_router(notifications.router, prefix=f"{settings.API_V1_STR}/notifications", tags=["notifications"])
app.include_router(announcements.router, prefix=settings.API_V1_STR, tags=["announcements"])
app.include_router(attendance.router, prefix=settings.API_V1_STR, tags=["attendance"])
app.include_router(gradebook.router, prefix=settings.API_V1_STR, tags=["gradebook"])
app.include_router(admin.router, prefix=f"{settings.API_V1_STR}/admin", tags=["admin"])
