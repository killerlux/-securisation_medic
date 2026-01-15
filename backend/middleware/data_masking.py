import re
from typing import Any, Dict, List, Union

# Regex patterns for sensitive data
PHI_PATTERNS = {
    "ssn": re.compile(r"\b\d{3}-\d{2}-\d{4}\b"),
    "email": re.compile(r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b"),
    "phone": re.compile(r"\b\+?1?[-.]?\(?\d{3}\)?[-.]?\d{3}[-.]?\d{4}\b"),
}

class DataMasker:
    """
    Utility to mask sensitive fields in JSON responses based on user role.
    HIPAA Requirement: Minimum Necessary (limit access to PHI).
    """

    def __init__(self, sensitive_fields: List[str] = None):
        self.sensitive_fields = sensitive_fields or [
            "ssn", "medical_record_number", "diagnosis_code", "email", "phone"
        ]

    def mask_data(self, data: Any, user_role: str) -> Any:
        """
        Recursively masks sensitive fields if the user is not privileged.
        """
        # Full access for admin and doctor roles
        if user_role in ["admin", "doctor"]:
            return data

        return self._recursive_mask(data)

    def _recursive_mask(self, data: Any) -> Any:
        """
        Helper to traverse and mask dictionaries and lists.
        """
        if isinstance(data, dict):
            new_data: Dict[str, Any] = {}
            for key, value in data.items():
                if key in self.sensitive_fields:
                    new_data[key] = "*****"  # Redacted
                else:
                    new_data[key] = self._recursive_mask(value)
            return new_data
        
        elif isinstance(data, list):
            return [self._recursive_mask(item) for item in data]
        
        elif isinstance(data, str):
            # Optional: Mask patterns in unstructured text if needed
            # return self._mask_patterns(data)
            return data
            
        return data

    def _mask_patterns(self, text: str) -> str:
        """
        Masks patterns like SSN/Email in free text strings.
        """
        for pattern_name, regex in PHI_PATTERNS.items():
            text = regex.sub(f"[{pattern_name.upper()}_REDACTED]", text)
        return text

# Example Usage Integration
# In a FastAPI response model or middleware:
# masker = DataMasker()
# response_body = masker.mask_data(original_body, user.role)

