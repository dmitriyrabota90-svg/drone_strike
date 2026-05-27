from __future__ import annotations

import logging
import smtplib
from email.message import EmailMessage

from app.core.config import settings


logger = logging.getLogger(__name__)


class EmailDeliveryError(RuntimeError):
    pass


def send_email_verification_email(email: str, link: str) -> None:
    subject = "Подтверждение email — FPV Last Run"
    body = (
        "Здравствуйте!\n\n"
        "Вы запросили подтверждение email для FPV Last Run.\n"
        "Откройте ссылку, чтобы подтвердить адрес:\n\n"
        f"{link}\n\n"
        "Если вы не запрашивали подтверждение, просто проигнорируйте это письмо.\n"
    )
    _send_plain_text_email(email, subject, body)


def send_password_reset_email(email: str, link: str) -> None:
    subject = "Восстановление пароля — FPV Last Run"
    body = (
        "Здравствуйте!\n\n"
        "Вы запросили восстановление пароля для FPV Last Run.\n"
        "Ссылка действует 1 час:\n\n"
        f"{link}\n\n"
        "Если вы не запрашивали восстановление пароля, просто проигнорируйте это письмо.\n"
    )
    _send_plain_text_email(email, subject, body)


def _send_plain_text_email(email: str, subject: str, body: str) -> None:
    if not settings.smtp_configured:
        if settings.is_production:
            logger.error("SMTP is not configured; email was not sent")
            raise EmailDeliveryError("SMTP is not configured")

        logger.info("SMTP is not configured; skipping email send in non-production")
        return

    message = EmailMessage()
    message["Subject"] = subject
    message["From"] = f"{settings.smtp_from_name} <{settings.smtp_from_email}>"
    message["To"] = email
    message.set_content(body)

    try:
        with smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=15) as smtp:
            if settings.smtp_use_tls:
                smtp.starttls()
            smtp.login(settings.smtp_username, settings.smtp_password)
            smtp.send_message(message)
        logger.info("Email sent successfully: subject=%s recipient=%s", subject, email)
    except (OSError, smtplib.SMTPException) as exc:
        logger.warning("SMTP delivery failed: subject=%s recipient=%s", subject, email)
        raise EmailDeliveryError("SMTP delivery failed") from exc
