import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Удаление аккаунта",
  description: "Как удалить аккаунт FPV Last Run"
};

export default function AccountDeletionPage() {
  return (
    <main>
      <section className="page-header">
        <div className="page-header-inner">
          <p className="eyebrow">Удаление аккаунта</p>
          <h1>Удаление аккаунта</h1>
          <p className="lead">
            Инструкция для пользователей, которые хотят удалить аккаунт FPV Last
            Run и связанные игровые данные.
          </p>
        </div>
      </section>
      <section className="legal-content">
        <article className="legal-block">
          <h2>Удаление в приложении</h2>
          <p>
            Если функция доступна в вашей версии приложения, аккаунт можно
            удалить внутри игры: Настройки → Удалить аккаунт.
          </p>
        </article>
        <article className="legal-block">
          <h2>Запрос через поддержку</h2>
          <p>
            Если доступ к приложению невозможен, напишите на
            support@fpv-last-run.ru и укажите email аккаунта, который нужно
            удалить.
          </p>
        </article>
        <article className="legal-block">
          <h2>Какие данные могут быть удалены</h2>
          <ul>
            <li>профиль;</li>
            <li>игровой прогресс;</li>
            <li>очки;</li>
            <li>запись в таблице лидеров.</li>
          </ul>
          <p>Удаление аккаунта и связанных данных может быть необратимым.</p>
        </article>
      </section>
    </main>
  );
}
