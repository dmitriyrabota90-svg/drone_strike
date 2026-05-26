# FPV Last Run Site

Official website for FPV Last Run. The site is intended for RuStore publication materials, support, legal pages, and future deployment at `https://fpv-last-run.ru`.

## Commands

```bash
npm install
npm run dev
npm run lint
npm run build
npm run start
```

## Pages

- `/` - game landing page.
- `/privacy` - privacy policy.
- `/terms` - terms of use.
- `/account-deletion` - account deletion instructions.
- `/support` - support contact and FAQ.

## Deployment Notes

The site is a regular Next.js app and can be deployed as a static/standard production build depending on the hosting setup chosen later.

This app does not contain secrets. Do not add tokens, private keys, production `.env` files, or service credentials to this directory.
