from uuid import UUID

from sqlalchemy.orm import Session

from app.repositories.legal_repository import create_legal_acceptance_if_missing
from app.schemas.legal import (
    LegalAcceptRequest,
    LegalAcceptResponse,
    LegalDocument,
    LegalDocumentsResponse,
)

APP_NAME = "FPV Last Run"
OPERATOR_NAME = "Анпилов Дмитрий Сергеевич"
OPERATOR_EMAIL = "anpilovdmitriy@yandex.ru"
EFFECTIVE_DATE = "2026-05-23"
MISSING_URL_NOTE = "URL to be added before publication."

TERMS_OF_USE_CONTENT = f"""
Дата вступления в силу: {EFFECTIVE_DATE}

Приложение: {APP_NAME}
Разработчик: {OPERATOR_NAME}
Контактный email: {OPERATOR_EMAIL}
Юрисдикция: Российская Федерация
Возраст пользователей: 13+

FPV Last Run предоставляется как мобильная игра с аккаунтом, профилем,
прогрессом, рейтингом и юридическими подтверждениями.

Пользователь отвечает за безопасность своего аккаунта и пароля. Запрещено
использовать чужие аккаунты, обходить авторизацию, вмешиваться в работу
backend-сервиса, использовать ошибки, модификации или автоматизацию для
нечестного получения прогресса, счета или места в рейтинге.

Игровой прогресс, лучшие результаты, общий счет, уровень и рейтинг могут
сохраняться на сервере. Рейтинг может показывать другим пользователям display
name, общий счет, уровень и позицию. Разработчик может исправлять или удалять
некорректные результаты, полученные из-за ошибки, злоупотребления или обхода
правил.

Гостевой прогресс может храниться локально на устройстве и может быть потерян
при удалении приложения или очистке данных приложения.

Покупки, premium account, реклама, аналитика и crash reporting планируются, но
не являются активными SDK/сервисами в текущей MVP/pre-release версии, если иное
явно не указано в приложении. Перед включением этих функций юридические
документы и интерфейс должны быть обновлены.

Удаление аккаунта доступно в приложении через настройки с подтверждением
пароля. Также можно обратиться по email: {OPERATOR_EMAIL}.

External account deletion URL: {MISSING_URL_NOTE}
Privacy Policy URL: {MISSING_URL_NOTE}
""".strip()

PERSONAL_DATA_CONSENT_CONTENT = f"""
Дата вступления в силу: {EFFECTIVE_DATE}

Оператор: {OPERATOR_NAME}
Контактный email: {OPERATOR_EMAIL}
Приложение: {APP_NAME}
Юрисдикция: Российская Федерация
Возраст пользователей: 13+

Регистрируясь в FPV Last Run, пользователь дает согласие на обработку
персональных данных для работы приложения, аккаунта, прогресса и рейтинга.

Обрабатываемые данные: email, display name, данные аккаунта и авторизации,
password hash, refresh token hash, подтверждение возраста 13+, игровой
прогресс, номера завершенных миссий, счет, лучшие результаты, бонусы за
точность полета и попадание в танк, общий счет, уровень игрока, данные
рейтинга, тип и версия принятых юридических документов, дата и время принятия.

На устройстве могут храниться локальные данные: жизни и таймер восстановления,
гостевой прогресс, локальные достижения, настройки языка и звука, access token
и refresh token в защищенном хранилище устройства.

Цели обработки: регистрация и вход, защита аккаунта, сохранение прогресса,
расчет счета и уровня, отображение профиля и рейтинга, подтверждение принятия
юридических документов, удаление аккаунта и техническая поддержка.

Пароли не хранятся в открытом виде. На сервере хранится password hash. Refresh
tokens на сервере хранятся только в виде hash.

Согласие можно отозвать через удаление аккаунта в приложении или запросом на
email: {OPERATOR_EMAIL}. После отзыва согласия функции, требующие аккаунта и
обработки данных, могут стать недоступны.

External account deletion URL: {MISSING_URL_NOTE}
Privacy Policy URL: {MISSING_URL_NOTE}
""".strip()

PRIVACY_POLICY_CONTENT = f"""
Дата вступления в силу: {EFFECTIVE_DATE}

Приложение: {APP_NAME}
Оператор и разработчик: {OPERATOR_NAME}
Контактный email: {OPERATOR_EMAIL}
Юрисдикция: Российская Федерация
Возраст пользователей: 13+

В текущей MVP/pre-release версии FPV Last Run обрабатывает данные аккаунта,
профиля, игрового прогресса, рейтинга и юридических подтверждений.

Данные аккаунта и авторизации: email, password hash, access token, refresh
token, refresh token hash на сервере, флаг подтверждения возраста 13+, факт
принятия условий использования и согласия на обработку персональных данных.

Данные профиля и игры: display name, признак смены имени, общий счет, уровень
игрока, статус premium, номера завершенных миссий, лучший счет по миссии,
бонус за точность полета, бонус за попадание в танк, дата завершения миссии,
количество завершенных миссий и открытая миссия.

Данные рейтинга: display name, общий счет, уровень и рассчитанная позиция в
рейтинге. Эти данные могут быть видны другим пользователям в рейтинге.

Юридические подтверждения: тип документа, версия документа, дата и время
принятия.

Локальные данные на устройстве: жизни и время восстановления, гостевой
прогресс по миссиям 1-2, локальные достижения и дата открытия, настройки звука
и языка, токены авторизации в защищенном хранилище устройства.

Данные используются для создания и защиты аккаунта, входа, сохранения прогресса,
расчета счета и уровня, отображения профиля и рейтинга, проверки принятия
юридических документов и работы локальных игровых систем.

Пароли не хранятся в открытом виде. На сервере хранится только password hash.
Refresh tokens на сервере хранятся только в виде hash.

Реклама, аналитика, crash reporting, in-app purchases и premium account
планируются, но не подключены как активные SDK/сервисы в текущей версии. Перед
их включением Политика конфиденциальности будет обновлена.

Удаление аккаунта доступно в приложении через настройки с подтверждением
пароля. При удалении аккаунта удаляются аккаунт, refresh token hashes,
юридические подтверждения, профиль и игровой прогресс, если хранение отдельных
данных не требуется законом.

Privacy Policy URL: {MISSING_URL_NOTE}
External account deletion URL: {MISSING_URL_NOTE}
""".strip()

LEGAL_DOCUMENTS = [
    LegalDocument(
        type="terms_of_use",
        version="1.0",
        title="Условия использования",
        content=TERMS_OF_USE_CONTENT,
        operator_name=OPERATOR_NAME,
        operator_email=OPERATOR_EMAIL,
    ),
    LegalDocument(
        type="personal_data_consent",
        version="1.0",
        title="Согласие на обработку персональных данных",
        content=PERSONAL_DATA_CONSENT_CONTENT,
        operator_name=OPERATOR_NAME,
        operator_email=OPERATOR_EMAIL,
    ),
    LegalDocument(
        type="privacy_policy",
        version="1.0",
        title="Политика конфиденциальности",
        content=PRIVACY_POLICY_CONTENT,
        operator_name=OPERATOR_NAME,
        operator_email=OPERATOR_EMAIL,
    ),
]


def get_legal_documents() -> LegalDocumentsResponse:
    return LegalDocumentsResponse(documents=LEGAL_DOCUMENTS)


def accept_legal_document(
    db: Session,
    user_id: UUID,
    request: LegalAcceptRequest,
) -> LegalAcceptResponse:
    create_legal_acceptance_if_missing(
        db,
        user_id=user_id,
        document_type=request.document_type,
        document_version=request.document_version,
    )
    db.commit()
    return LegalAcceptResponse(
        status="accepted",
        document_type=request.document_type,
        document_version=request.document_version,
    )
