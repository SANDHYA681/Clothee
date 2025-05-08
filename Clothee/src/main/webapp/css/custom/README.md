# Custom CSS Framework

This directory contains a custom CSS framework that replaces any Bootstrap dependencies while maintaining the same look and feel of the application.

## Structure

- `main.css` - Main entry point that imports all other CSS files
- `grid-system.css` - Custom grid system similar to Bootstrap's grid
- `buttons.css` - Custom button styles
- `utilities.css` - Utility classes for spacing, typography, colors, etc.

## Usage

### Grid System

The grid system uses a 12-column layout with responsive breakpoints:

```html
<div class="container">
  <div class="row">
    <div class="col-6 col-md-4 col-sm-12">Column 1</div>
    <div class="col-6 col-md-8 col-sm-12">Column 2</div>
  </div>
</div>
```

### Buttons

Various button styles are available:

```html
<button class="btn btn-primary">Primary Button</button>
<button class="btn btn-secondary">Secondary Button</button>
<button class="btn btn-outline-primary">Outline Button</button>
<button class="btn btn-sm">Small Button</button>
<button class="btn btn-lg">Large Button</button>
```

### Utilities

Utility classes for common styling needs:

```html
<div class="d-flex justify-content-between align-items-center">
  <div class="text-primary font-weight-bold">Left content</div>
  <div class="bg-light p-3 m-2 rounded">Right content</div>
</div>
```

## CSS Variables

All styles use CSS variables defined in `../common/variables.css` for consistent theming across the application.

## Responsive Design

The framework includes responsive breakpoints:

- xs: < 576px
- sm: 576px - 768px
- md: 768px - 992px
- lg: 992px - 1200px
- xl: > 1200px

## Customization

To customize the appearance, modify the CSS variables in `../common/variables.css` rather than changing the component CSS files directly.
