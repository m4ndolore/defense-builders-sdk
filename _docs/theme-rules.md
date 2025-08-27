# Defense Builders SDK - Theme Rules & Design System

## Brand Identity

### Mission Statement Visual
"Professional defense technology aesthetic that conveys trust, capability, and innovation"

### Design Inspiration
- **Primary**: Modern defense contractors (Anduril, Shield AI, Palantir)
- **Secondary**: Developer tools (Vercel, GitHub, Linear)
- **Accent**: Tactical equipment and military aviation

## Color System

### Primary Palette

#### Brand Colors
```css
--brand-primary: #0EA5E9;     /* Sky-500 - Primary actions */
--brand-secondary: #6366F1;   /* Indigo-500 - Secondary elements */
--brand-accent: #10B981;      /* Emerald-500 - Success states */
--brand-danger: #EF4444;      /* Red-500 - Destructive actions */
--brand-warning: #F59E0B;     /* Amber-500 - Warnings */
```

#### Neutral Colors (Dark Mode Default)
```css
--gray-50: #F9FAFB;
--gray-100: #F3F4F6;
--gray-200: #E5E7EB;
--gray-300: #D1D5DB;
--gray-400: #9CA3AF;
--gray-500: #6B7280;
--gray-600: #4B5563;
--gray-700: #374151;
--gray-800: #1F2937;
--gray-900: #111827;
--gray-950: #030712;
```

#### Semantic Colors
```css
/* Backgrounds */
--bg-primary: var(--gray-950);      /* Main background */
--bg-secondary: var(--gray-900);    /* Cards, modals */
--bg-tertiary: var(--gray-800);     /* Hover states */
--bg-inverse: var(--gray-50);       /* Light mode background */

/* Text */
--text-primary: var(--gray-50);     /* Primary text */
--text-secondary: var(--gray-400);  /* Secondary text */
--text-tertiary: var(--gray-500);   /* Disabled text */
--text-inverse: var(--gray-900);    /* Light mode text */

/* Borders */
--border-subtle: var(--gray-800);   /* Subtle borders */
--border-default: var(--gray-700);  /* Default borders */
--border-strong: var(--gray-600);   /* Strong borders */
```

#### Status Colors
```css
/* Operational States */
--status-online: #10B981;      /* Emerald-500 */
--status-processing: #0EA5E9;  /* Sky-500 */
--status-idle: #6B7280;        /* Gray-500 */
--status-offline: #374151;     /* Gray-700 */
--status-error: #EF4444;       /* Red-500 */

/* Environment States */
--env-development: #6366F1;    /* Indigo-500 */
--env-staging: #F59E0B;        /* Amber-500 */
--env-production: #10B981;     /* Emerald-500 */
--env-classified: #DC2626;    /* Red-600 */
```

### Color Usage Guidelines

#### Hierarchy
1. **Primary Action**: Brand primary (blue)
2. **Secondary Action**: Gray outlines
3. **Tertiary Action**: Ghost/text buttons
4. **Destructive**: Red variants only
5. **Success**: Green confirmations

#### Accessibility
- **AA Compliance**: 4.5:1 contrast minimum
- **AAA Target**: 7:1 for body text
- **Focus States**: 3:1 against adjacent colors

## Typography

### Font Stack
```css
--font-sans: 'Inter', system-ui, -apple-system, sans-serif;
--font-mono: 'JetBrains Mono', 'SF Mono', monospace;
--font-display: 'Inter Display', var(--font-sans);
```

### Type Scale
```css
--text-xs: 0.75rem;    /* 12px - Labels, captions */
--text-sm: 0.875rem;   /* 14px - Secondary text */
--text-base: 1rem;     /* 16px - Body text */
--text-lg: 1.125rem;   /* 18px - Large body */
--text-xl: 1.25rem;    /* 20px - Small headings */
--text-2xl: 1.5rem;    /* 24px - Section headings */
--text-3xl: 1.875rem;  /* 30px - Page headings */
--text-4xl: 2.25rem;   /* 36px - Large headings */
--text-5xl: 3rem;      /* 48px - Hero text */
```

### Font Weights
```css
--font-normal: 400;    /* Body text */
--font-medium: 500;    /* Emphasis */
--font-semibold: 600;  /* Headings */
--font-bold: 700;      /* Strong emphasis */
```

### Line Heights
```css
--leading-tight: 1.25;   /* Headings */
--leading-snug: 1.375;   /* Subheadings */
--leading-normal: 1.5;   /* Body text */
--leading-relaxed: 1.625; /* Readable content */
--leading-loose: 2;      /* Spacious content */
```

### Typography Patterns

#### Headings
```css
.h1 {
  font-size: var(--text-3xl);
  font-weight: var(--font-semibold);
  line-height: var(--leading-tight);
  letter-spacing: -0.025em;
}

.h2 {
  font-size: var(--text-2xl);
  font-weight: var(--font-semibold);
  line-height: var(--leading-tight);
  letter-spacing: -0.02em;
}

.h3 {
  font-size: var(--text-xl);
  font-weight: var(--font-semibold);
  line-height: var(--leading-snug);
}
```

#### Body Text
```css
.body-large {
  font-size: var(--text-lg);
  line-height: var(--leading-relaxed);
}

.body-default {
  font-size: var(--text-base);
  line-height: var(--leading-normal);
}

.body-small {
  font-size: var(--text-sm);
  line-height: var(--leading-normal);
}
```

#### Code
```css
.code-inline {
  font-family: var(--font-mono);
  font-size: 0.875em;
  padding: 0.125rem 0.25rem;
  background: var(--gray-800);
  border-radius: 0.25rem;
}

.code-block {
  font-family: var(--font-mono);
  font-size: var(--text-sm);
  line-height: var(--leading-relaxed);
}
```

## Spacing System

### Base Unit
```css
--space-unit: 0.25rem; /* 4px */
```

### Scale
```css
--space-0: 0;
--space-1: 0.25rem;   /* 4px */
--space-2: 0.5rem;    /* 8px */
--space-3: 0.75rem;   /* 12px */
--space-4: 1rem;      /* 16px */
--space-5: 1.25rem;   /* 20px */
--space-6: 1.5rem;    /* 24px */
--space-8: 2rem;      /* 32px */
--space-10: 2.5rem;   /* 40px */
--space-12: 3rem;     /* 48px */
--space-16: 4rem;     /* 64px */
--space-20: 5rem;     /* 80px */
--space-24: 6rem;     /* 96px */
```

### Component Spacing
```css
/* Cards */
--card-padding: var(--space-6);
--card-gap: var(--space-4);

/* Forms */
--form-gap: var(--space-4);
--input-padding-x: var(--space-3);
--input-padding-y: var(--space-2);

/* Buttons */
--btn-padding-x: var(--space-4);
--btn-padding-y: var(--space-2);
--btn-gap: var(--space-2);
```

## Elevation System

### Shadow Scale
```css
--shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
--shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
--shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
--shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1);
--shadow-2xl: 0 25px 50px -12px rgb(0 0 0 / 0.25);
--shadow-inner: inset 0 2px 4px 0 rgb(0 0 0 / 0.05);
```

### Elevation Levels
```css
/* Level 0 - Base */
.elevation-0 {
  box-shadow: none;
}

/* Level 1 - Cards */
.elevation-1 {
  box-shadow: var(--shadow-sm);
  background: var(--bg-secondary);
}

/* Level 2 - Dropdowns */
.elevation-2 {
  box-shadow: var(--shadow-md);
  background: var(--bg-secondary);
}

/* Level 3 - Modals */
.elevation-3 {
  box-shadow: var(--shadow-lg);
  background: var(--bg-secondary);
}

/* Level 4 - Popovers */
.elevation-4 {
  box-shadow: var(--shadow-xl);
  background: var(--bg-secondary);
}
```

## Border System

### Border Widths
```css
--border-0: 0;
--border-1: 1px;
--border-2: 2px;
--border-4: 4px;
```

### Border Radius
```css
--radius-none: 0;
--radius-sm: 0.125rem;   /* 2px - Subtle rounding */
--radius-md: 0.375rem;   /* 6px - Default */
--radius-lg: 0.5rem;     /* 8px - Cards */
--radius-xl: 0.75rem;    /* 12px - Modals */
--radius-2xl: 1rem;      /* 16px - Large elements */
--radius-full: 9999px;   /* Pills, avatars */
```

### Border Styles
```css
/* Default */
.border-default {
  border: var(--border-1) solid var(--border-default);
}

/* Interactive */
.border-interactive {
  border: var(--border-1) solid var(--border-subtle);
  transition: border-color 0.15s;
}

.border-interactive:hover {
  border-color: var(--border-default);
}

.border-interactive:focus {
  border-color: var(--brand-primary);
  box-shadow: 0 0 0 3px rgb(14 165 233 / 0.1);
}
```

## Animation System

### Duration
```css
--duration-instant: 0ms;
--duration-fast: 150ms;
--duration-base: 200ms;
--duration-slow: 300ms;
--duration-slower: 500ms;
```

### Easing
```css
--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
--ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);
```

### Common Animations
```css
/* Fade */
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* Scale */
@keyframes scale-in {
  from { transform: scale(0.95); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}

/* Slide */
@keyframes slide-up {
  from { transform: translateY(4px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}

/* Pulse */
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
```

## Icon System

### Icon Sizes
```css
--icon-xs: 12px;
--icon-sm: 16px;
--icon-md: 20px;
--icon-lg: 24px;
--icon-xl: 32px;
```

### Icon Library
- **Primary**: Lucide Icons (consistent, open source)
- **Secondary**: Custom defense icons (military symbols)
- **Fallback**: System emoji for status

### Icon Guidelines
1. Always use currentColor for fill/stroke
2. Maintain 2px minimum stroke width
3. Include aria-label for standalone icons
4. Use consistent metaphors across platform

## Component Theming

### Button Variants
```css
/* Primary */
.btn-primary {
  background: var(--brand-primary);
  color: white;
  border: none;
}

/* Secondary */
.btn-secondary {
  background: transparent;
  color: var(--text-primary);
  border: 1px solid var(--border-default);
}

/* Ghost */
.btn-ghost {
  background: transparent;
  color: var(--text-primary);
  border: none;
}

/* Destructive */
.btn-destructive {
  background: var(--brand-danger);
  color: white;
  border: none;
}
```

### Status Badges
```css
.badge-success {
  background: rgb(16 185 129 / 0.1);
  color: var(--status-online);
  border: 1px solid rgb(16 185 129 / 0.2);
}

.badge-warning {
  background: rgb(245 158 11 / 0.1);
  color: var(--brand-warning);
  border: 1px solid rgb(245 158 11 / 0.2);
}

.badge-error {
  background: rgb(239 68 68 / 0.1);
  color: var(--brand-danger);
  border: 1px solid rgb(239 68 68 / 0.2);
}
```

## Dark/Light Mode

### Implementation
```css
/* Dark mode (default) */
:root {
  color-scheme: dark;
  /* All dark theme variables */
}

/* Light mode (user preference) */
[data-theme="light"] {
  color-scheme: light;
  /* Override with light theme variables */
}

/* System preference */
@media (prefers-color-scheme: light) {
  :root:not([data-theme="dark"]) {
    /* Light theme variables */
  }
}
```

### Mode Switching
- Store preference in localStorage
- Respect system preference by default
- Smooth transition between modes
- Update meta theme-color

## Special Effects

### Glassmorphism
```css
.glass {
  background: rgb(17 24 39 / 0.7);
  backdrop-filter: blur(10px);
  border: 1px solid rgb(31 41 55 / 0.5);
}
```

### Gradient Borders
```css
.gradient-border {
  background: linear-gradient(var(--bg-secondary), var(--bg-secondary)) padding-box,
              linear-gradient(135deg, var(--brand-primary), var(--brand-secondary)) border-box;
  border: 2px solid transparent;
}
```

### Glow Effects
```css
.glow-primary {
  box-shadow: 0 0 20px rgb(14 165 233 / 0.15);
}

.glow-success {
  box-shadow: 0 0 20px rgb(16 185 129 / 0.15);
}
```

## Responsive Considerations

### Breakpoint-Specific Themes
```css
/* Mobile adjustments */
@media (max-width: 640px) {
  :root {
    --text-base: 0.875rem;  /* Smaller base text */
    --space-unit: 0.25rem;  /* Maintain spacing */
  }
}

/* Touch device adjustments */
@media (hover: none) {
  :root {
    --min-touch-target: 44px;  /* Larger touch targets */
  }
}
```

## Brand Applications

### Logo Treatment
- Primary: White on dark backgrounds
- Inverse: Dark on light backgrounds
- Minimum size: 32px height
- Clear space: 0.5x logo height

### Marketing vs Application
- Marketing pages: More gradients and effects
- Application: Subtle, functional design
- Documentation: High contrast, readable

## Don'ts

1. **Don't** use pure black (#000000)
2. **Don't** use pure white (#FFFFFF) on dark backgrounds
3. **Don't** create new colors without adding to system
4. **Don't** use more than 3 font weights per page
5. **Don't** mix border radius styles
6. **Don't** animate color changes without transition
7. **Don't** use shadows on dark backgrounds without testing