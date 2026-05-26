import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Пользовательское соглашение",
  description: "Пользовательское соглашение FPV Last Run"
};

export default function TermsPage() {
  return (
    <main>
      <section className="page-header">
        <div className="page-header-inner">
          <p className="eyebrow">Пользовательское соглашение</p>
          <h1>Пользовательское соглашение</h1>
          <p className="lead">
            Основные правила использования мобильной игры FPV Last Run.
          </p>
        </div>
      </section>
      <section className="legal-content">
        <article className="legal-block">
          <h2>Описание сервиса</h2>
          <p>
            FPV Last Run — мобильная игра про управление FPV-дроном. Пользователь
            может играть в гостевом режиме или создать аккаунт для сохранения
            прогресса и участия в игровых сервисах.
          </p>
        </article>
        <article className="legal-block">
          <h2>Правила поведения</h2>
          <p>Пользователь обязуется не нарушать работу игры и backend-сервиса.</p>
          <ul>
            <li>запрещены попытки взлома и обхода ограничений;</li>
            <li>запрещена автоматизация игрового процесса;</li>
            <li>запрещена накрутка очков и результатов;</li>
            <li>запрещены действия, мешающие другим пользователям.</li>
          </ul>
        </article>
        <article className="legal-block">
          <h2>Баланс и доступность функций</h2>
          <p>
            Разработчик может изменять баланс, миссии, механику и доступность
            функций. Игра находится в развитии, поэтому отдельные возможности
            могут быть временно недоступны или изменены.
          </p>
        </article>
        <article className="legal-block">
          <h2>Таблица лидеров и поддержка</h2>
          <p>
            Таблица лидеров может модерироваться для защиты от нечестных
            результатов. Для связи с поддержкой используйте
            support@fpv-last-run.ru.
          </p>
        </article>
      </section>
    </main>
  );
}
