import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Политика конфиденциальности",
  description: "Политика конфиденциальности FPV Last Run"
};

export default function PrivacyPage() {
  return (
    <main>
      <section className="page-header">
        <div className="page-header-inner">
          <p className="eyebrow">Политика конфиденциальности</p>
          <h1>Политика конфиденциальности</h1>
          <p className="lead">
            Как FPV Last Run обрабатывает данные, необходимые для работы игры и
            поддержки пользователей.
          </p>
        </div>
      </section>
      <section className="legal-content">
        <article className="legal-block">
          <h2>Какие данные могут обрабатываться</h2>
          <p>На текущем этапе приложение может обрабатывать:</p>
          <ul>
            <li>email пользователя;</li>
            <li>никнейм или имя профиля;</li>
            <li>ID пользователя;</li>
            <li>игровой прогресс;</li>
            <li>очки и уровень;</li>
            <li>данные таблицы лидеров;</li>
            <li>
              технические данные, необходимые для работы приложения и backend.
            </li>
          </ul>
        </article>
        <article className="legal-block">
          <h2>Для чего используются данные</h2>
          <p>
            Данные используются для регистрации, входа в аккаунт, сохранения
            прогресса, работы таблицы лидеров, поддержки пользователей и
            обеспечения стабильной работы сервиса.
          </p>
        </article>
        <article className="legal-block">
          <h2>Что приложение не запрашивает</h2>
          <ul>
            <li>геолокацию;</li>
            <li>контакты;</li>
            <li>файлы пользователя;</li>
            <li>SMS и сообщения;</li>
            <li>платежные данные на текущем этапе.</li>
          </ul>
        </article>
        <article className="legal-block">
          <h2>Удаление аккаунта и контакт</h2>
          <p>
            Пользователь может запросить удаление аккаунта. По вопросам
            конфиденциальности и поддержки напишите на
            support@fpv-last-run.ru.
          </p>
        </article>
      </section>
    </main>
  );
}
