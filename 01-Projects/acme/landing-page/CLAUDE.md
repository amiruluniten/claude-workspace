# Acme Landing Page — Project Conventions

## Code Style
- Use TypeScript for all components
- Tailwind CSS only — no custom CSS files
- Component files: PascalCase (e.g., `HeroSection.tsx`)
- Utility files: camelCase (e.g., `formatPrice.ts`)

## Project Structure
```
src/
├── components/    # Reusable UI components
├── sections/      # Page sections (Hero, Features, Pricing)
├── lib/           # Utilities and helpers
└── styles/        # Tailwind config overrides
```

## Deployment
- Push to `main` triggers production deploy on Vercel
- All PRs get preview deploys automatically
