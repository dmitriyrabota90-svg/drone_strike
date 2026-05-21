from fastapi import FastAPI

from app.api.routes.auth import router as auth_router
from app.api.routes.health import router as health_router
from app.api.routes.profile import router as profile_router
from app.api.routes.progress import router as progress_router
from app.core.config import settings


app = FastAPI(title=settings.app_name)

app.include_router(health_router)
app.include_router(health_router, prefix=settings.api_v1_prefix)
app.include_router(auth_router, prefix=settings.api_v1_prefix)
app.include_router(profile_router, prefix=settings.api_v1_prefix)
app.include_router(progress_router, prefix=settings.api_v1_prefix)


@app.get("/")
def read_root() -> dict[str, str]:
    return {
        "name": settings.app_name,
        "status": "running",
    }
