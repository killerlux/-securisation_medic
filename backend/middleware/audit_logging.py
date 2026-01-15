import json
import logging
import time
import uuid
from typing import Any, Callable, Dict, Optional
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

# Configure logging to write to stdout (captured by CloudWatch/container logs)
logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",  # JSON logging
)
logger = logging.getLogger("audit_logger")


class AuditMiddleware(BaseHTTPMiddleware):
    """
    HIPAA-compliant audit logging middleware.
    Logs who did what, when, and from where.
    """

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        """
        Intercepts the request, logs audit data, and proceeds.
        """
        request_id = str(uuid.uuid4())
        start_time = time.time()
        
        # Extract user context (assumes an upstream auth middleware sets state.user)
        user_id = getattr(request.state, "user_id", "anonymous")
        user_role = getattr(request.state, "user_role", "unknown")
        
        # Request details
        audit_entry: Dict[str, Any] = {
            "audit_id": request_id,
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(start_time)),
            "event_type": "access_audit",
            "actor": {
                "user_id": user_id,
                "role": user_role,
                "ip_address": request.client.host if request.client else "unknown",
                "user_agent": request.headers.get("user-agent", "unknown"),
            },
            "action": {
                "method": request.method,
                "path": request.url.path,
                "query_params": str(request.query_params),
            },
            "resource": {
                "target": "patient_data", # Context dependent in real app
            },
            "status": "pending",
        }

        try:
            response = await call_next(request)
            
            # Post-request updates
            duration = time.time() - start_time
            audit_entry["status"] = "success" if response.status_code < 400 else "failure"
            audit_entry["response"] = {
                "status_code": response.status_code,
                "duration_ms": round(duration * 1000, 2),
            }
            
            # Log the structured audit entry
            # HIPAA Requirement: Audit controls (record and examine activity)
            logger.info(json.dumps(audit_entry))
            
            return response

        except Exception as e:
            # Log failure with exception details
            duration = time.time() - start_time
            audit_entry["status"] = "error"
            audit_entry["error"] = str(e)
            audit_entry["response"] = {
                "status_code": 500,
                "duration_ms": round(duration * 1000, 2),
            }
            logger.error(json.dumps(audit_entry))
            raise e

