from typing import Literal

from pydantic import BaseModel


DocumentType = Literal["terms_of_use", "personal_data_consent", "privacy_policy"]
DocumentVersion = Literal["1.0"]


class LegalDocument(BaseModel):
    type: DocumentType
    version: str
    title: str
    content: str
    operator_name: str
    operator_email: str


class LegalDocumentsResponse(BaseModel):
    documents: list[LegalDocument]


class LegalAcceptRequest(BaseModel):
    document_type: DocumentType
    document_version: DocumentVersion


class LegalAcceptResponse(BaseModel):
    status: str
    document_type: DocumentType
    document_version: str
