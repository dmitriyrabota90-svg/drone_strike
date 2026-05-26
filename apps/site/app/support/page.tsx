import type { Metadata } from "next";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Поддержка",
  description: "Поддержка пользователей FPV Last Run"
};

const requestDetails = [
  "модель устройства",
  "версия Android",
  "версия приложения",
  "описание ошибки",
  "скриншот или видео при наличии",
  "email аккаунта, если проблема связана с профилем"
];

const faq = [
  [
    "Можно ли играть без аккаунта?",
    "Да, доступен гостевой режим, но аккаунт нужен для сохранения прогресса."
  ],
  [
    "Почему email не подтвержден?",
    "Подтверждение email находится в разработке."
  ],
  [
    "Что делать, если не входит в аккаунт?",
    "Проверьте интернет и напишите в поддержку, если проблема повторяется."
  ],
  [
    "Как удалить аккаунт?",
    "Через настройки приложения или обращение в поддержку."
  ]
];

export default function SupportPage() {
  return (
    <main>
      <section className="page-header">
        <div className="page-header-inner">
          <p className="eyebrow">Поддержка</p>
          <h1>Поддержка</h1>
          <p className="lead">
            Напишите нам на support@fpv-last-run.ru, если столкнулись с ошибкой
            или вопросом по аккаунту.
          </p>
          <div className="actions">
            <Link className="button" href="mailto:support@fpv-last-run.ru">
              Написать в поддержку
            </Link>
          </div>
        </div>
      </section>
      <section className="legal-content">
        <article className="legal-block">
          <h2>Что указать в обращении</h2>
          <ul>
            {requestDetails.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ul>
        </article>
        <article className="legal-block">
          <h2>FAQ</h2>
          {faq.map(([question, answer]) => (
            <div key={question}>
              <h3>{question}</h3>
              <p>{answer}</p>
            </div>
          ))}
        </article>
      </section>
    </main>
  );
}
