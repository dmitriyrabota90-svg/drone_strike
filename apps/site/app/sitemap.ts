import type { MetadataRoute } from "next";

const routes = ["", "/privacy", "/terms", "/account-deletion", "/support"];

export default function sitemap(): MetadataRoute.Sitemap {
  return routes.map((route) => ({
    url: `https://fpv-last-run.ru${route}`,
    lastModified: new Date()
  }));
}
