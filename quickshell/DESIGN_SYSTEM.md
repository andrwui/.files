# Monochrome Soft UI
## Design System Specification

**Version:** 1.0  
**Status:** Specification  
**Platforms:** Web, Mobile  
**Theme:** Dark  
**Design language:** Minimal, monochromatic, soft surfaces, subtle glass-like borders, restrained depth.

---

# 1. Design Philosophy

Monochrome Soft UI is a dark design system built around subtle surface differentiation, restrained contrast, soft geometry, and controlled motion.

It combines elements of:
- Minimalist interface design.
- Soft UI / neumorphism, without excessive shadows or exaggerated depth.
- Glass-inspired surface treatments, primarily through gradient borders rather than transparency.
- Modern native application interfaces.
- Restrained spring-based interaction design.

The system should feel substantial and tactile without becoming decorative.

## 1.1 Core principles

1. **Monochromatic first:** Grayscale is the primary visual language. Semantic colors are reserved for meaningful status communication.
2. **Subtle depth:** Hierarchy is established through surface gradients, borders, spacing, and restrained shadows.
3. **Consistent geometry:** Components share a predictable radius and spacing scale.
4. **Compact interfaces:** Avoid unnecessary padding. Content density should remain relatively high without compromising readability.
5. **Typography-driven hierarchy:** Use font size, weight, contrast, and spacing instead of decorative labels or visual ornaments.
6. **Purposeful motion:** Animations communicate presence, state changes, and interaction feedback.
7. **Platform independence:** The visual language must work across desktop, tablet, and mobile without imitating a phone home screen.

## 1.2 Visual restrictions

The following are prohibited:

- Eyebrow decorations, accent lines, or decorative top-edge elements.
- Side lips, protruding edge accents, or decorative side highlights.
- Excessive gradients.
- Strong neumorphic shadows.
- Bright glowing borders.
- Unnecessary decorative icons.
- Excessive padding.
- Bouncy, elastic, or exaggerated animations.
- Decorative colors without semantic purpose.

Components must derive their visual identity from their surface, typography, and interaction states.

---

# 2. Color System

## 2.1 Background

The global application background is pure black.

| Token | Value | Usage |
|---|---|---|
| `color.background` | `#000000` | Application background |
| `color.surface.1` | `#121212` | Primary surface |
| `color.surface.2` | `#171717` | Secondary surface |
| `color.surface.3` | `#1E1E1E` | Elevated surface |
| `color.surface.4` | `#252525` | Hover and stronger surface |
| `color.surface.5` | `#303030` | Active and selected surface |

## 2.2 Surface gradients

Surfaces use a vertical gradient from lighter at the top to darker at the bottom.

**Primary surface gradient:**

```css
background: linear-gradient(
  180deg,
  #1E1E1E 0%,
  #121212 100%
);
```

This is the default surface treatment for cards, buttons, panels, dialogs, and elevated containers.

The gradient must remain subtle. It should provide dimensionality rather than look like a prominent color transition.

Different components may use different starting and ending values, but must preserve the same top-to-bottom lighting direction.

## 2.3 Glass-like borders

Borders use a vertical gradient to simulate a subtle reflective edge.

**Primary border gradient:**

```css
background: linear-gradient(
  180deg,
  #616161 0%,
  #232323 100%
);
```

The border starts brighter at the top and progressively darkens toward the bottom.

The visual transition should follow the rounded perimeter of the component. Ideally, the highlight should become less prominent as the upper border curves into the vertical sides.

The border must never appear as a uniformly bright outline.

Implementation should use a gradient border layer clipped to the component's border radius, with the interior masked out.

```css
.surface {
  position: relative;
  isolation: isolate;
  border-radius: 12px;
  background: linear-gradient(180deg, #1E1E1E, #121212);
}

.surface::before {
  content: "";
  position: absolute;
  inset: 0;
  padding: 1px;
  border-radius: inherit;
  background: radial-gradient(
    125% 95% at 50% 0%,
    #616161 0%,
    #444444 27%,
    #303030 53%,
    #232323 100%
  );
  -webkit-mask:
    linear-gradient(#fff 0 0) content-box,
    linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask-composite: exclude;
  pointer-events: none;
  z-index: -1;
}
```

This is the preferred implementation approach. The exact gradient can be adjusted to match the curvature and size of individual components.

## 2.4 Border colors

| Token | Value | Usage |
|---|---|---|
| `color.border.subtle` | `#292929` | Dividers and low-emphasis borders |
| `color.border.default` | `#363636` | Standard borders |
| `color.border.strong` | `#484848` | Inputs and interactive components |
| `color.border.highlight` | `#616161` | Upper reflective border |
| `color.border.dark` | `#232323` | Lower reflective border |

## 2.5 Text colors

| Token | Value | Usage |
|---|---|---|
| `color.text.primary` | `#F5F5F5` | Primary text |
| `color.text.secondary` | `#A3A3A3` | Secondary text |
| `color.text.muted` | `#858585` | Supporting text |
| `color.text.disabled` | `#606060` | Disabled text |
| `color.text.inverse` | `#111111` | Text on light surfaces |

Avoid using pure white for all text. The primary text color should remain slightly off-white.

## 2.6 Semantic colors

Semantic colors should be muted and controlled.

| Token | Value | Usage |
|---|---|---|
| `color.success` | `#75C99A` | Success |
| `color.warning` | `#E7B96A` | Warning |
| `color.error` | `#E47777` | Error |
| `color.info` | `#82AEE8` | Informational |

Semantic colors should not replace the monochromatic palette.

They should appear primarily in:
- Status indicators.
- Validation messages.
- Notifications.
- Destructive actions.
- Charts when categorical distinction is necessary.

---

# 3. Typography

## 3.1 Typeface

**Primary typeface: Inter**

Use a modern sans-serif typeface with neutral proportions and excellent readability.

Fallback:

```css
font-family:
  Inter,
  ui-sans-serif,
  system-ui,
  sans-serif;
```

The typography should be clean, compact, and contemporary.

Avoid excessively rounded fonts, decorative typefaces, or overly condensed typography.

## 3.2 Font weights

| Weight | Value | Usage |
|---|---|---|
| Regular | 400 | Body text |
| Medium | 500 | Labels and controls |
| Semibold | 600 | Headings and emphasis |
| Bold | 700 | Strong emphasis, used sparingly |

## 3.3 Type scale

| Token | Size | Weight | Usage |
|---|---:|---:|---|
| `type.display` | 48px | 600 | Large presentation headings |
| `type.h1` | 36px | 600 | Page headings |
| `type.h2` | 28px | 600 | Major sections |
| `type.h3` | 22px | 600 | Subsections |
| `type.h4` | 18px | 600 | Component headings |
| `type.body.large` | 16px | 400 | Prominent body text |
| `type.body` | 14px | 400 | Default body text |
| `type.caption` | 12px | 400 | Supporting information |
| `type.label` | 13px | 500 | Form labels and controls |
| `type.micro` | 10px | 500 | Dense metadata |

These are desktop reference sizes. Mobile implementations should scale display and heading sizes appropriately.

## 3.4 Typography rules

- Prefer negative letter spacing on large headings.
- Use normal or slightly relaxed letter spacing for body text.
- Avoid uppercase text for ordinary content.
- Use uppercase only for compact metadata where appropriate.
- Use tabular numerals for financial values, statistics, and aligned numerical data.
- Maintain sufficient line height for longer text.
- Do not use font weight as the only way to communicate hierarchy.

---

# 4. Geometry and Spacing

## 4.1 Border radius

| Token | Value | Usage |
|---|---:|---|
| `radius.sm` | 6px | Small controls and badges |
| `radius.md` | 8px | Inputs and buttons |
| `radius.lg` | 12px | Cards and standard surfaces |
| `radius.xl` | 16px | Dialogs and large containers |
| `radius.2xl` | 24px | Large visual containers |
| `radius.full` | 9999px | Pills and circular elements |

The default component radius is 8px for controls and 12px for containers.

## 4.2 Spacing scale

Use a consistent 4px-based spacing system.

| Token | Value |
|---|---:|
| `space.1` | 4px |
| `space.2` | 8px |
| `space.3` | 12px |
| `space.4` | 16px |
| `space.5` | 20px |
| `space.6` | 24px |
| `space.8` | 32px |
| `space.10` | 40px |
| `space.12` | 48px |
| `space.16` | 64px |

## 4.3 Density

The default density is compact.

Guidelines:

- Buttons should not have excessive horizontal padding.
- Inputs should remain relatively short.
- Cards should use enough padding to separate content without wasting space.
- Form fields should have compact vertical spacing.
- Navigation items should be concise.
- Dense data interfaces should remain readable without excessive whitespace.

Default padding recommendations:

| Component | Padding |
|---|---|
| Small button | 0 9px |
| Standard button | 0 11px |
| Large button | 0 16px |
| Input | 0 9px |
| Standard card | 12px |
| Large card | 16px |
| Dialog | 18–20px |

---

# 5. Surface and Depth System

## 5.1 Surface hierarchy

The system uses surface contrast rather than strong shadows to establish depth.

1. Application background: `#000000`.
2. Standard containers: gradient from `#1E1E1E` to `#121212`.
3. Interactive surfaces: slightly brighter gradient.
4. Elevated surfaces: brighter surface and subtle shadow.
5. Overlays: darker backdrop with blur and elevated content.

## 5.2 Shadows

Shadows should be soft, diffuse, and subtle.

| Token | Value | Usage |
|---|---|---|
| `shadow.none` | `none` | Standard surfaces |
| `shadow.sm` | `0 2px 8px #0005` | Small elevation |
| `shadow.md` | `0 5px 15px #0007` | Cards |
| `shadow.lg` | `0 8px 25px #0008` | Elevated surfaces |
| `shadow.xl` | `0 15px 40px #0009` | Dialogs and overlays |

Shadows must never become the primary source of component definition.

## 5.3 Surface rules

- Use the standard vertical gradient for primary containers.
- Apply the reflective border to elevated or clearly defined surfaces.
- Use flat backgrounds for the application canvas.
- Avoid stacking multiple competing gradients.
- Avoid excessive transparency.
- Maintain consistent border thickness.

---

# 6. Motion System

Motion is a fundamental part of the design language.

The system uses spring-inspired easing, restrained scaling, opacity, blur, and small positional changes.

The intended result is smooth, responsive, and substantial, without bouncy or elastic behavior.

## 6.1 Motion principles

1. Motion must communicate a state change.
2. Animations should feel connected to the component's interaction.
3. Movement should be subtle.
4. Avoid overshooting and elastic behavior.
5. Avoid large translations.
6. Keep interaction feedback immediate.
7. Respect reduced-motion preferences.

## 6.2 Easing

Primary easing:

```css
cubic-bezier(0.2, 0.85, 0.25, 1)
```

This provides a spring-like deceleration without noticeable overshoot.

Additional easing tokens:

```css
--ease-standard: cubic-bezier(0.2, 0.85, 0.25, 1);
--ease-enter: cubic-bezier(0.16, 1, 0.3, 1);
--ease-exit: cubic-bezier(0.4, 0, 1, 1);
```

The primary easing should be used for most interactions.

On platforms supporting physical spring animations, use critically damped or heavily damped springs rather than elastic springs.

## 6.3 Duration tokens

| Token | Duration | Usage |
|---|---:|---|
| `motion.instant` | 100ms | Immediate visual feedback |
| `motion.fast` | 180ms | Small interactions |
| `motion.normal` | 300–480ms | Component transitions |
| `motion.slow` | 500–700ms | Presence and overlays |
| `motion.extended` | 800ms | Larger transitions, used sparingly |

## 6.4 Presence animations

Presence animations are used when elements enter or leave the interface.

The standard entrance combines:

- Opacity: 0 → 1.
- Blur: 10px → 0.
- Translation Y: 12px → 0.
- Scale: 0.975 → 1.

```css
@keyframes presence-enter {
  from {
    opacity: 0;
    filter: blur(10px);
    transform: translateY(12px) scale(0.975);
  }

  to {
    opacity: 1;
    filter: blur(0);
    transform: translateY(0) scale(1);
  }
}
```

Default duration: 560ms.

Use for:
- Page content.
- Cards entering a list.
- Menus.
- Panels.
- Notifications.
- Dialog content.

## 6.5 Scale animations

Scale transitions should be subtle.

Recommended values:

| State | Scale |
|---|---:|
| Initial entrance | 0.96–0.98 |
| Normal | 1 |
| Hover | 1.015–1.025 |
| Press | 0.965 |
| Exit | 0.97 |

Never use large scale changes for ordinary interactions.

## 6.6 Blur animations

Blur should communicate depth and presence.

Recommended transitions:

| Context | Initial blur | Final blur |
|---|---:|---:|
| Content entrance | 10px | 0 |
| Dialog entrance | 9px | 0 |
| Notification entrance | 5px | 0 |
| Overlay backdrop | 0px | 8–10px |

Blur should be used selectively because it can be computationally expensive.

## 6.7 Hover and press

Hover:
- Small scale increase.
- Slight brightness increase.
- Optional subtle elevation.

Press:
- Scale down to approximately 0.965.
- Slight brightness reduction.
- No exaggerated bounce.

## 6.8 Navigation transitions

When switching between pages or major views:

- Fade out the previous content.
- Fade in the next content.
- Apply a small translation or scale adjustment.
- Avoid unnecessary full-screen animations.

The transition should not delay interaction.

## 6.9 Dialog transitions

Dialog entrance:

- Backdrop opacity increases.
- Backdrop blur increases.
- Dialog opacity increases.
- Dialog blur decreases.
- Dialog moves slightly upward.
- Dialog scales from approximately 0.965 to 1.

Dialog exit should be shorter than entrance.

## 6.10 Reduced motion

Respect:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

On mobile, also respect the platform's reduced-motion accessibility setting.

---

# 7. Component Specification

## 7.1 Buttons

Buttons must be compact and visually consistent.

### Variants

**Primary**
- Light surface.
- Dark text.
- Highest visual priority.
- Used for primary actions.

**Secondary**
- Dark vertical gradient.
- Subtle border.
- Light text.
- Used for secondary actions.

**Outline**
- Transparent background.
- Visible border.
- Light text.
- Used for lower-priority actions.

**Ghost**
- Transparent background.
- No prominent border.
- Muted text.
- Used for tertiary actions.

**Destructive**
- Muted red surface.
- Subtle red border.
- Light red text.
- Used for destructive operations.

### Dimensions

| Property | Default |
|---|---|
| Height | 32px |
| Horizontal padding | 11px |
| Radius | 8px |
| Font size | 11–13px |
| Weight | 500–600 |

### States

- Default.
- Hover.
- Pressed.
- Focused.
- Disabled.
- Loading.

All variants must have consistent interaction behavior.

Buttons should not grow significantly on hover.

## 7.2 Inputs

Inputs should follow the same surface language as buttons.

### Default appearance

- Dark gradient background.
- Subtle visible border.
- Compact padding.
- Rounded corners.
- Muted placeholder text.

### Dimensions

| Property | Default |
|---|---|
| Height | 34px |
| Horizontal padding | 9px |
| Radius | 8px |
| Font size | 12–14px |

### States

**Default**
- Standard dark surface.
- Subtle border.

**Hover**
- Slight border brightness increase.

**Focus**
- Brighter border.
- Subtle focus ring.
- No exaggerated glow.

**Disabled**
- Reduced contrast.
- No interactive hover feedback.

**Invalid**
- Muted red border.
- Supporting error message.

**Valid**
- Optional subtle semantic border or supporting text.

## 7.3 Selection controls

Includes:
- Checkbox.
- Radio button.
- Switch.
- Select.

Selection controls must use the same neutral visual language.

### Checkbox

- Compact square shape.
- Muted border.
- Light checked state.
- Clear checkmark.

### Radio

- Circular shape.
- Subtle border.
- Light selected indicator.

### Switch

- Compact horizontal control.
- Dark inactive track.
- Light active track.
- Smooth thumb movement.
- No exaggerated bounce.

### Select

- Dark gradient surface.
- Consistent input dimensions.
- Clear dropdown indicator.
- Focus and open states consistent with inputs.

## 7.4 Cards

Cards are the primary content containers.

Appearance:
- Vertical dark gradient.
- Reflective gradient border.
- 12px default radius.
- Compact padding.
- Optional subtle shadow.

Interaction:
- Slight upward movement on hover.
- Very subtle scale increase.
- Smooth brightness transition.

Cards should not automatically behave as clickable surfaces unless their content or purpose indicates interaction.

## 7.5 Dialogs

Dialogs should appear elevated over the application.

Appearance:
- Dark gradient surface.
- Reflective border.
- 16px radius.
- Soft shadow.
- Compact internal spacing.

Behavior:
- Blurred dark backdrop.
- Presence entrance.
- Clear primary and secondary actions.
- Escape key dismissal when appropriate.
- Focus management.
- Focus restoration when closed.

## 7.6 Badges

Badges communicate short status information.

Default:
- Dark surface.
- Subtle border.
- Small typography.
- Compact padding.

Semantic variants:
- Success.
- Warning.
- Error.
- Information.

Badges should not become decorative labels.

## 7.7 Notifications and toasts

Notifications communicate operation results and temporary feedback.

Appearance:
- Compact surface.
- Clear text.
- Optional semantic indicator.
- Subtle border.

Entrance:
- Fade in.
- Small upward movement.
- Blur reduction.
- Slight scale increase.

Exit:
- Fade out.
- Slight downward movement.

Notifications must remain readable and accessible.

## 7.8 Tables

Tables should be visually minimal.

- No heavy grid lines.
- Subtle horizontal separators.
- Muted column headers.
- Compact row height.
- Clear hover state.
- Tabular numerals for numerical columns.

Avoid unnecessary container decoration.

## 7.9 Navigation

Navigation should be minimal and functional.

Desktop:
- Sidebar or top navigation.
- Compact items.
- Clear active state.
- Subtle hover transitions.

Mobile:
- Navigation adapted to available screen space.
- Prefer native navigation patterns appropriate to the application.
- Do not force desktop sidebars into narrow layouts.

---

# 8. Responsive Design

The design system must support desktop, tablet, and mobile application layouts.

Responsive behavior is determined by available space, not by simply shrinking desktop components.

## 8.1 Breakpoints

| Token | Width | Target |
|---|---:|---|
| `breakpoint.sm` | 640px | Small devices |
| `breakpoint.md` | 768px | Tablets |
| `breakpoint.lg` | 1024px | Desktop |
| `breakpoint.xl` | 1280px | Large desktop |
| `breakpoint.2xl` | 1536px | Wide desktop |

## 8.2 Desktop

Desktop layouts should prioritize:
- Information density.
- Multi-column composition.
- Persistent navigation.
- Side panels where appropriate.
- Efficient use of horizontal space.

Cards and panels should align consistently.

## 8.3 Tablet

Tablet layouts should:
- Reduce unnecessary columns.
- Allow navigation to become more compact.
- Preserve comfortable interaction targets.
- Avoid excessive horizontal scrolling.

## 8.4 Mobile

Mobile layouts should:
- Prefer single-column composition.
- Use full-width inputs where appropriate.
- Adapt navigation to the application's information architecture.
- Preserve consistent surface treatments.
- Use appropriate touch targets.
- Avoid excessively small text.
- Respect safe areas and system insets.

The mobile design system is an application interface, not a phone home screen.

## 8.5 Mobile interaction

Hover states must never be required to discover or use functionality.

Use:
- Press feedback.
- Focus states where applicable.
- Clear selected states.
- Native scrolling behavior.
- Appropriate touch target sizes.

Recommended minimum touch target: 44 × 44px, even when the visible control is smaller.

---

# 9. Accessibility

The visual language must not compromise usability.

Requirements:

1. All interactive elements must be keyboard accessible.
2. Focus states must be clearly visible.
3. Text contrast must meet WCAG AA requirements.
4. Semantic color must not be the only way to communicate state.
5. Forms must have associated labels.
6. Dialogs must manage focus correctly.
7. Animations must respect reduced-motion preferences.
8. Controls must expose appropriate accessible names and states.
9. Touch targets must be sufficiently large.
10. Disabled and read-only states must be distinguishable.

The subtle border treatment must not replace visible focus indicators.

---

# 10. Design Tokens

The following is the recommended canonical token structure.

```css
:root {
  color-scheme: dark;

  --color-background: #000000;

  --color-surface-1: #121212;
  --color-surface-2: #171717;
  --color-surface-3: #1E1E1E;
  --color-surface-4: #252525;
  --color-surface-5: #303030;

  --color-border-subtle: #292929;
  --color-border-default: #363636;
  --color-border-strong: #484848;
  --color-border-highlight: #616161;
  --color-border-dark: #232323;

  --color-text-primary: #F5F5F5;
  --color-text-secondary: #A3A3A3;
  --color-text-muted: #858585;
  --color-text-disabled: #606060;
  --color-text-inverse: #111111;

  --color-success: #75C99A;
  --color-warning: #E7B96A;
  --color-error: #E47777;
  --color-info: #82AEE8;

  --gradient-surface:
    linear-gradient(180deg, #1E1E1E 0%, #121212 100%);

  --gradient-border:
    linear-gradient(180deg, #616161 0%, #232323 100%);

  --font-family:
    Inter, ui-sans-serif, system-ui, sans-serif;

  --radius-sm: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;
  --radius-xl: 16px;
  --radius-2xl: 24px;
  --radius-full: 9999px;

  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-5: 20px;
  --space-6: 24px;
  --space-8: 32px;
  --space-10: 40px;
  --space-12: 48px;
  --space-16: 64px;

  --motion-fast: 180ms;
  --motion-normal: 480ms;
  --motion-slow: 700ms;

  --ease-standard:
    cubic-bezier(0.2, 0.85, 0.25, 1);

  --ease-enter:
    cubic-bezier(0.16, 1, 0.3, 1);

  --ease-exit:
    cubic-bezier(0.4, 0, 1, 1);

  --shadow-sm: 0 2px 8px #0005;
  --shadow-md: 0 5px 15px #0007;
  --shadow-lg: 0 8px 25px #0008;
  --shadow-xl: 0 15px 40px #0009;
}
```

---

# 11. Implementation Guidelines

## 11.1 Architecture

The design system should be implemented in layers.

**Foundations**
- Colors.
- Typography.
- Spacing.
- Geometry.
- Shadows.
- Motion.
- Responsive breakpoints.

**Primitives**
- Surface.
- Text.
- Icon.
- Separator.
- Stack.
- Grid.
- Container.

**Components**
- Button.
- Input.
- Select.
- Checkbox.
- Radio.
- Switch.
- Card.
- Badge.
- Dialog.
- Tooltip.
- Toast.
- Table.

**Patterns**
- Forms.
- Navigation.
- Dashboards.
- Data views.
- Settings pages.
- Application layouts.

## 11.2 Platform implementations

Web and mobile should share the same design tokens and component semantics.

However, they should not be forced to share identical implementations.

Web can use:
- CSS gradients.
- CSS masks.
- Backdrop filters.
- CSS transitions.
- Spring-based animation libraries.

Mobile should use equivalent native capabilities for:
- Gradients.
- Borders.
- Blur.
- Shadows.
- Spring animations.
- Touch interactions.

Visual consistency is more important than implementation consistency.

## 11.3 Component API

Components should expose semantic variants and sizes rather than arbitrary styling options.

For example:

```ts
type ButtonVariant =
  | 'primary'
  | 'secondary'
  | 'outline'
  | 'ghost'
  | 'destructive'

type ButtonSize =
  | 'sm'
  | 'md'
  | 'lg'
```

Components should:
- Have predictable defaults.
- Support disabled states.
- Support accessible interaction.
- Preserve native semantics.
- Avoid duplicating token definitions.
- Allow composition without breaking the visual language.

## 11.4 Animation implementation

Prefer reusable animation presets.

Examples:

- `presence`
- `scale`
- `blur`
- `slide`
- `press`
- `hover`
- `dialog-enter`
- `dialog-exit`

Do not implement individual, unrelated animation curves for every component.

All motion should derive from the centralized motion system.

---

# 12. Quality Criteria

A component is considered compliant when:

- It uses the correct monochromatic palette.
- Its gradient follows the top-to-bottom lighting direction.
- Its border treatment matches the system.
- It uses the established radius scale.
- It follows compact spacing conventions.
- Its typography follows the established hierarchy.
- Its interaction states are consistent.
- Its animations use the centralized motion system.
- It supports reduced motion.
- It is accessible.
- It adapts correctly to web and mobile layouts.
- It contains no decorative eyebrow or side-lip elements.

## Final design direction

The overall interface should feel like a cohesive, carefully engineered application rather than a collection of individually styled components.

The defining characteristics are:

- Pure black application background.
- Dark vertical gradient surfaces (`#1E1E1E → #121212`).
- Subtle reflective gradient borders (`#616161 → #232323`).
- Inter typography.
- Compact controls and spacing.
- Consistent rounded geometry.
- Restrained shadows.
- Smooth spring-inspired motion.
- Presence animations combining opacity, blur, and scale.
- No unnecessary decoration.

**The goal is depth without visual noise, density without clutter, and motion without distraction.**
