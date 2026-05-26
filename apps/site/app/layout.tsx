import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL("https://fpv-last-run.ru"),
  title: {
    default: "FPV Last Run",
    template: "%s | FPV Last Run"
  },
  description: "Аркадная 2D-игра про FPV-дрон",
  openGraph: {
    title: "FPV Last Run",
    description: "Аркадная 2D-игра про FPV-дрон в мире разрушенного города",
    url: "https://fpv-last-run.ru",
    siteName: "FPV Last Run",
    locale: "ru_RU",
    type: "website",
    images: [
      {
        url: "/images/hero-destroyed-city.png",
        width: 1200,
        height: 630,
        alt: "FPV Last Run"
      }
    ]
  },
  icons: {
    icon: "/images/icon.png",
    apple: "/images/icon.png"
  }
};

const navLinks = [
  ["Об игре", "/#about"],
  ["Поддержка", "/support"],
  ["Политика конфиденциальности", "/privacy"],
  ["Пользовательское соглашение", "/terms"]
] as const;

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ru">
      <body>
        <div className="site-shell">
          <header className="topbar">
            <Link className="brand" href="/" aria-label="FPV Last Run">
              <Image src="/images/icon.png" alt="" width={36} height={36} />
              <span>FPV Last Run</span>
            </Link>
            <nav className="nav" aria-label="Основная навигация">
              {navLinks.map(([label, href]) => (
                <Link key={href} href={href}>
                  {label}
                </Link>
              ))}
            </nav>
          </header>
          {children}
          <footer className="footer">
            <div className="footer-inner">
              <span>support@fpv-last-run.ru</span>
              <div className="footer-links">
                <Link href="/privacy">Политика конфиденциальности</Link>
                <Link href="/terms">Пользовательское соглашение</Link>
                <Link href="/account-deletion">Удаление аккаунта</Link>
                <Link href="/support">Поддержка</Link>
              </div>
            </div>
          </footer>
        </div>
      </body>
    </html>
  );
}
