import Link from "next/link";

const aboutItems = [
  ["Управление FPV-дроном", "Держите высоту, реагируйте на препятствия и ловите ритм коротких напряженных миссий."],
  ["Препятствия", "Деревья, сети и разрушенная городская среда требуют точного маневра."],
  ["Миссии", "Каждый вылет ведет через опасный маршрут к цели в конце уровня."],
  ["Цель уровня", "Долетите до финальной зоны и поразите танк, чтобы завершить миссию."],
  ["Очки", "Результат складывается из прохождения, точности и успешного удара по цели."],
  ["Таблица лидеров", "Сравнивайте лучший прогресс и очки с другими игроками."]
];

const features = [
  "Гостевой режим",
  "Аккаунт и сохранение прогресса",
  "Миссии",
  "Достижения",
  "Таблица лидеров",
  "Русский и английский язык"
];

export default function HomePage() {
  return (
    <main>
      <section className="hero">
        <div className="hero-content">
          <p className="eyebrow">Официальный сайт игры</p>
          <h1>FPV Last Run</h1>
          <p className="lead">
            Аркадная 2D-игра про FPV-дрон в мире разрушенного города.
          </p>
          <p className="hero-copy">
            Управляйте дроном, проходите опасные маршруты, избегайте препятствий
            и завершайте миссии точным ударом по цели.
          </p>
          <div className="actions">
            <span className="button disabled" aria-disabled="true">
              Скачать в RuStore — скоро
            </span>
            <Link className="button secondary" href="/support">
              Поддержка
            </Link>
          </div>
        </div>
      </section>

      <div className="home-band home-band-middle">
        <section className="section" id="about">
          <div className="section-inner">
            <div className="section-title">
              <h2>Об игре</h2>
              <p>
                FPV Last Run делает ставку на быстрые вылеты, понятное управление
                и честный аркадный вызов.
              </p>
            </div>
            <div className="grid three">
              {aboutItems.map(([title, text]) => (
                <article className="feature" key={title}>
                  <h3>{title}</h3>
                  <p>{text}</p>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="section">
          <div className="section-inner">
            <div className="section-title">
              <h2>Возможности</h2>
              <p>
                В игре уже есть основа для альфа-тестирования и будущего развития
                кампании.
              </p>
            </div>
            <div className="grid">
              {features.map((feature) => (
                <article className="feature" key={feature}>
                  <h3>{feature}</h3>
                  <p>Доступно или готовится в рамках текущего альфа-этапа.</p>
                </article>
              ))}
            </div>
          </div>
        </section>

        <section className="section">
          <div className="section-inner">
            <div className="section-title">
              <h2>Скриншоты</h2>
              <p>
                Здесь появятся финальные скриншоты RuStore. Сейчас используются
                аккуратные места под материалы.
              </p>
            </div>
            <div className="grid">
              {["Главное меню", "Полет", "Финальная цель", "Результат миссии"].map(
                (label) => (
                  <div className="screenshot" key={label}>
                    <div className="screenshot-frame">{label}</div>
                  </div>
                )
              )}
            </div>
          </div>
        </section>
      </div>

      <div className="home-band home-band-lower">
        <section className="section">
          <div className="section-inner">
            <div className="status-box">
              <div>
                <h2>Статус</h2>
                <p>
                  Игра находится на этапе альфа-тестирования. Баланс, миссии и
                  отдельные функции могут изменяться по результатам проверки.
                </p>
              </div>
              <span className="status-badge">Alpha</span>
            </div>
          </div>
        </section>

        <section className="section section-cta">
          <div className="section-inner">
            <div className="status-box support-cta">
              <div>
                <h2>Нужна помощь?</h2>
                <p>
                  Для вопросов по альфа-версии, аккаунту или ошибкам напишите в
                  поддержку FPV Last Run.
                </p>
              </div>
              <Link className="button secondary" href="/support">
                Поддержка
              </Link>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}
