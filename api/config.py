"""
test fixture api

api base configuration
"""
import os
from pydantic_settings import BaseSettings
from pydantic import Field

DESCRIPTION = """
test fixture
"""

# pylint: disable=too-few-public-methods
class Settings(BaseSettings):
    """base settings"""
    title: str = "test-fixture"
    description: str = DESCRIPTION
    prefix: str = "/test"
    debug: bool = False
    releaseId: str = Field(default_factory=lambda: os.environ.get("API_VERSION", "snapshot"))
    version: str = "v1"
    server_info_url: str = "http://localhost:15000/server_info"

settings = Settings()
route_prefix = f"/{settings.version}{settings.prefix}"
