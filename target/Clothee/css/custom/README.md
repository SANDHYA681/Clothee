# Custom CSS Framework

This directory contains a custom CSS framework that provides styling for the application.

## Structure

- `main.css` - Main entry point that imports all other CSS files
- `grid-system.css` - Custom grid system for layout
- `buttons.css` - Custom button styles
- `utilities.css` - Utility classes for spacing, typography, colors, etc.

## Usage

### Grid System

The grid system uses a 12-column layout with responsive breakpoints:

```html
<div class="layout-container">
  <div class="flex-row">
    <div class="column-6 column-medium-4 column-small-12">Column 1</div>
    <div class="column-6 column-medium-8 column-small-12">Column 2</div>
  </div>
</div>
```

### Buttons

Various button styles are available:

```html
<button class="button button-primary">Primary Button</button>
<button class="button button-secondary">Secondary Button</button>
<button class="button button-outline-primary">Outline Button</button>
<button class="button button-small">Small Button</button>
<button class="button button-large">Large Button</button>
```

### Utilities

Utility classes for common styling needs:

```html
<div class="show-flex justify-between align-center">
  <div class="text-primary font-weight-bold">Left content</div>
  <div class="bg-light p-3 m-2 rounded">Right content</div>
</div>
```

## CSS Variables

All styles use CSS variables defined in `../common/variables.css` for consistent theming across the application.

## Responsive Design

The framework includes responsive breakpoints:

- tiny: < 576px
- small: 576px - 768px
- medium: 768px - 992px
- large: 992px - 1200px
- extra-large: > 1200px

## Customization

To customize the appearance, modify the CSS variables in `../common/variables.css` rather than changing the component CSS files directly.
