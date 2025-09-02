"""
test fixture api
"""
from fastapi import FastAPI
from .routes import healthz
from .config import settings, route_prefix

tags_metadata = [
    {
        "name": "main"
    }
]

api = FastAPI(
    title=settings.title,
    description=settings.description,
    version=settings.releaseId,
    openapi_tags=tags_metadata,
    docs_url=f"{route_prefix}/apidocs",
    openapi_url=f"{route_prefix}/openapi.json",
    redoc_url=None,
    debug=settings.debug
)

api.include_router(healthz.route, prefix=route_prefix)


@api.get(route_prefix, summary="greeting", tags=["main"])
async def root():
    """
    root endpoint and hello response.
    """
    return { "message": "test" }
