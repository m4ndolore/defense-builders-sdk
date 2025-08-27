# Defense Builders SDK - UI Rules & Guidelines

## Design Philosophy

### Core Principles
1. **Clarity Over Cleverness**: Function before form, always
2. **Dense Information Display**: Maximize data visibility for power users
3. **Keyboard-First**: Full keyboard navigation for efficiency
4. **Dark Mode Default**: Reduce eye strain, defense tech aesthetic
5. **Performance Obsessed**: Sub-100ms interactions

## Layout System

### Grid Structure
```
12-column grid system with 16px base unit
- Desktop: 1440px (12 columns)
- Laptop: 1024px (12 columns)
- Tablet: 768px (8 columns)
- Mobile: 375px (4 columns)
```

### Spacing Scale
```
Base unit: 4px
Scale: 0, 1, 2, 3, 4, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64
Usage: p-4 = 16px, m-8 = 32px
```

### Container Widths
- **Full**: 100% width
- **Constrained**: max-w-7xl (1280px)
- **Narrow**: max-w-3xl (768px)
- **Reading**: max-w-prose (65ch)

## Component Architecture

### Component Hierarchy

#### Page-Level Components
```tsx
<AppShell>
  <TopNav />
  <SideNav />
  <MainContent>
    <PageHeader />
    <PageBody />
  </MainContent>
</AppShell>
```

#### Card Components
```tsx
<Card>
  <CardHeader>
    <CardTitle />
    <CardDescription />
    <CardActions />
  </CardHeader>
  <CardContent />
  <CardFooter />
</Card>
```

### Button Hierarchy

#### Primary Actions
- **Solid Fill**: Main CTAs (Create Environment, Deploy, Submit)
- **Size**: Default 40px height, 16px horizontal padding
- **Icon**: Optional leading icon, always 20px

#### Secondary Actions
- **Outline**: Secondary CTAs (Cancel, Back, Export)
- **Ghost**: Tertiary actions (More options, Settings)
- **Text Only**: Inline actions (links, subtle actions)

#### Destructive Actions
- **Red Variants**: Delete, Remove, Terminate
- **Confirmation Required**: Modal or double-click
- **Undo Option**: When possible

### Form Patterns

#### Input Fields
```tsx
<FormField>
  <Label>Environment Name *</Label>
  <Input placeholder="my-dev-environment" />
  <HelperText>Lowercase letters, numbers, and hyphens only</HelperText>
  <ErrorMessage>This field is required</ErrorMessage>
</FormField>
```

#### Field States
- **Default**: Gray border, white background
- **Focus**: Blue border, slight glow
- **Error**: Red border, red error text
- **Disabled**: Gray background, reduced opacity
- **Success**: Green check icon

### Table Design

#### Data Tables
```tsx
<Table>
  <TableHeader>
    <TableRow>
      <TableHead sortable>Name</TableHead>
      <TableHead>Status</TableHead>
      <TableHead align="right">Actions</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    <TableRow hoverable clickable>
      <TableCell primary>Content</TableCell>
      <TableCell><StatusBadge /></TableCell>
      <TableCell><ActionMenu /></TableCell>
    </TableRow>
  </TableBody>
</Table>
```

#### Table Features
- **Sorting**: Click headers to sort
- **Selection**: Checkbox for multi-select
- **Pagination**: 25/50/100 items per page
- **Sticky Header**: Scroll with fixed headers
- **Row Actions**: Hover to reveal actions

## Navigation Patterns

### Top Navigation
```
[Logo] [Primary Nav Items] [Spacer] [Search] [Notifications] [User Menu]
```
- **Height**: 64px
- **Background**: Dark with subtle border
- **Items**: Max 5 primary nav items
- **Mobile**: Hamburger menu

### Side Navigation
```
[Section Header]
  [Nav Item]
  [Nav Item with Badge]
  [Active Nav Item]
[Section Header]
  [Nav Item]
```
- **Width**: 240px collapsed, 64px mini
- **Behavior**: Persistent on desktop, overlay on mobile
- **Sections**: Grouped by function
- **Icons**: Always present, 20px

### Breadcrumbs
```
Home / Projects / TAK Integration / Settings
```
- **Location**: Below top nav, above page header
- **Behavior**: Clickable except current page
- **Truncation**: Middle truncation for long paths

## Data Visualization

### Status Indicators
```
● Online (green-500)
● Processing (blue-500 animated)
● Warning (yellow-500)
● Offline (gray-400)
● Error (red-500)
```

### Progress Indicators
- **Linear**: For known duration/percentage
- **Circular**: For unknown duration
- **Stepped**: For multi-step processes
- **Skeleton**: For loading content

### Charts & Graphs
- **Library**: Recharts or Tremor
- **Colors**: Use theme palette
- **Responsiveness**: Resize gracefully
- **Accessibility**: Keyboard navigation, screen reader support

## Interactive States

### Hover States
- **Buttons**: Darken 10%
- **Cards**: Elevate shadow
- **Table Rows**: Light background
- **Links**: Underline

### Focus States
- **Outline**: 2px blue ring
- **Offset**: 2px from element
- **High Contrast**: Visible on all backgrounds

### Loading States
- **Inline**: Spinner replaces content
- **Full Page**: Overlay with spinner
- **Skeleton**: Shape placeholders
- **Progressive**: Load critical first

### Empty States
```tsx
<EmptyState>
  <EmptyStateIcon />
  <EmptyStateTitle>No environments yet</EmptyStateTitle>
  <EmptyStateDescription>
    Create your first development environment
  </EmptyStateDescription>
  <EmptyStateAction>Create Environment</EmptyStateAction>
</EmptyState>
```

## Modal & Dialog Patterns

### Modal Sizes
- **Small**: 400px (confirmations)
- **Medium**: 600px (forms)
- **Large**: 800px (complex forms)
- **Full**: 95vw (data tables)

### Modal Structure
```tsx
<Modal>
  <ModalHeader>
    <ModalTitle />
    <ModalClose />
  </ModalHeader>
  <ModalBody />
  <ModalFooter>
    <Button variant="ghost">Cancel</Button>
    <Button variant="primary">Confirm</Button>
  </ModalFooter>
</Modal>
```

## Notification System

### Toast Notifications
- **Position**: Top-right corner
- **Duration**: 5 seconds (auto-dismiss)
- **Variants**: Success, Error, Warning, Info
- **Actions**: Optional action button

### Banner Notifications
- **Position**: Top of page
- **Persistence**: Until dismissed
- **Use Cases**: System maintenance, critical updates

### Inline Alerts
```tsx
<Alert variant="warning">
  <AlertIcon />
  <AlertTitle>Limited Resources</AlertTitle>
  <AlertDescription>
    You've used 80% of your compute quota
  </AlertDescription>
  <AlertAction>Upgrade Plan</AlertAction>
</Alert>
```

## Mobile Responsiveness

### Breakpoints
```scss
$mobile: 0-639px
$tablet: 640px-1023px
$desktop: 1024px-1439px
$wide: 1440px+
```

### Mobile-First Rules
1. **Stack Vertically**: Columns become rows
2. **Simplify Navigation**: Hamburger menu
3. **Touch Targets**: Minimum 44px
4. **Gesture Support**: Swipe for actions
5. **Optimize Forms**: Full-width inputs

### Desktop-Only Features
- Keyboard shortcuts
- Hover states
- Right-click menus
- Drag and drop
- Complex data tables

## Accessibility Standards

### WCAG 2.1 AA Compliance
- **Color Contrast**: 4.5:1 minimum
- **Focus Indicators**: Always visible
- **Keyboard Navigation**: Full support
- **Screen Readers**: Proper ARIA labels
- **Skip Links**: Navigation bypass

### Keyboard Shortcuts
```
Cmd/Ctrl + K: Command palette
Cmd/Ctrl + N: New environment
Cmd/Ctrl + /: Search
Escape: Close modal/dropdown
Tab: Navigate forward
Shift + Tab: Navigate backward
```

## Performance Guidelines

### Loading Performance
- **Initial Load**: < 3 seconds
- **Route Change**: < 100ms
- **API Response**: < 500ms
- **Interaction**: < 100ms

### Optimization Techniques
- **Code Splitting**: Route-based
- **Lazy Loading**: Below-fold content
- **Image Optimization**: WebP with fallbacks
- **Caching**: Aggressive cache headers
- **Virtualization**: Long lists

## Design Tokens

### Semantic Naming
```typescript
// Good
--color-background-primary
--color-text-primary
--color-border-subtle

// Bad
--gray-900
--blue-500
```

### Token Categories
1. **Colors**: Background, text, border, status
2. **Typography**: Font family, size, weight, line height
3. **Spacing**: Padding, margin, gap
4. **Elevation**: Shadow levels
5. **Animation**: Duration, easing

## Implementation Notes

### Component Library
- Use **Shadcn/ui** as base
- Extend with custom defense components
- Document all customizations
- Maintain Storybook for all components

### CSS Architecture
```scss
// Base layer (Tailwind)
@tailwind base;
@tailwind components;
@tailwind utilities;

// Custom utilities
@layer utilities {
  .text-balance { 
    text-wrap: balance;
  }
}

// Component overrides
@layer components {
  .card-defense {
    @apply bg-gray-900 border-gray-800;
  }
}
```

### Testing Requirements
- Visual regression tests
- Accessibility audits
- Performance budgets
- Cross-browser testing (Chrome, Firefox, Safari, Edge)

## Don'ts

1. **Don't** use animations longer than 200ms
2. **Don't** hide critical information behind hover
3. **Don't** use more than 2 fonts
4. **Don't** create custom form controls without accessibility
5. **Don't** use color as the only indicator
6. **Don't** break platform conventions without good reason
7. **Don't** sacrifice function for aesthetics