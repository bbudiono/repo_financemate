# UX/UI Style Guide

## Document Version: 1.2
## Last Updated: May 8, 2025

---

# 0. Defining Your Style Via Inspiration

This section is designed to help you translate the look, feel, and functionality of applications you admire into concrete design decisions for your own project. By ranking your key inspirations, you can create a more focused and consistent design system.

## 0.1 Rank Your Key Inspirations
Review the list of "Key Inspirations" in **Section 2.2**. From that list (or by adding your own that align with those categories), identify and rank your top 3-5 inspirations that most closely represent the desired qualities of your application. This ranking will serve as a primary filter for the stylistic choices outlined in subsequent sections.

**Example Ranking Table (Fill this out for your project):**

| Rank | Key Inspiration Application | Key Qualities to Emulate                                      | Why it's a Top Inspiration                                     |
| :--- | :-------------------------- | :------------------------------------------------------------ | :------------------------------------------------------------- |
| 1    | [e.g., Native Apple Apps]   | [e.g., Clarity, platform consistency, subtle animations]      | [e.g., Desire for a deeply integrated macOS/iOS feel]         |
| 2    | [e.g., Notion]              | [e.g., Flexibility, clean typography, minimalist card design] | [e.g., Need for a highly adaptable content structure]          |
| 3    | [e.g., Linear]              | [e.g., Speed, efficiency, keyboard-first, dense UI]           | [e.g., Targeting power users who value productivity]           |
| 4    | [e.g., Fantastical]         | [e.g., Delightful micro-interactions, clear information hierarchy] | [e.g., Aiming for an enjoyable and polished user experience] |
| 5    | [e.g., OmniFocus]           | [e.g., Power, depth of features, professional aesthetic]      | [e.g., Complex domain requiring robust task management feel] |

*(Add or remove rows as needed)*

## 0.2 How This Ranking Guides Your Style
Throughout this document, sections like "Colour Palette," "Typography," "Iconography," "Layout & Spacing," "Components," and "Motion & Animation" will include a subsection called "**Deriving from Inspirations**." This part will prompt you to consider how your top-ranked applications approach specific design elements. Use these prompts to make informed decisions and then document your choices in the provided placeholders.

---

# 1. Introduction

## 1.1 Purpose of this Guide (Goal)
This Style Guide serves as the single source of truth for the user interface (UI) and user experience (UX) design of [Project Name/App Name]. Its primary goal is to:
* Ensure consistency across all aspects of the application, regardless of the platform, guided by your primary inspirations.
* Improve usability and accessibility for all users.
* Streamline the design and development process by providing clear standards and reusable components.
* Maintain a high level of quality and polish in the final product.
* Reflect the product's brand identity and core values.

## 1.2 Target Audience
This guide is intended for:
* UX/UI Designers
* Product Managers
* Software Engineers (Frontend and Full-stack)
* Quality Assurance Teams
* Marketing and Communication Teams
* Any stakeholder involved in the product development lifecycle.

## 1.3 How to Use This Document
First, complete **Section 0: Defining Your Style Via Inspiration**. Then, use your ranked inspirations to guide your choices as you work through the detailed sections of this guide. This document is organized to help you build a cohesive design system. It is a living document and will be updated as the product evolves. Pay attention to platform-specific callouts where applicable.

---

# 2. Core Design Philosophy

## 2.1 Product Vision & Values
* **Product Vision:** [Clearly articulate the overarching vision for your product. What problem does it solve? Who is it for? What is its ultimate aspiration?]
* **Core Values:**
    * **Clarity:** The interface should be intuitive and easy to understand, minimizing cognitive load.
    * **Efficiency:** Users should be able to accomplish tasks quickly and with minimal friction.
    * **Power & Depth:** While maintaining simplicity, the application should offer robust functionality for users who need it.
    * **Craftsmanship:** Attention to detail and a high level of polish are paramount.
    * **User-Centricity:** Design decisions are driven by user needs and feedback.
    * **Platform Native Feel with Brand Consistency:** Strive for an experience that feels at home on each platform while maintaining a consistent brand identity, informed by your chosen inspirations.

## 2.2 Inspiration & Alignment
Our design approach draws inspiration from best-in-class applications known for their exceptional user experience, powerful features, and refined aesthetics. We aim to achieve a similar level of quality and user satisfaction.

**Key Inspirations (Reference for Section 0.1):**
* **Productivity & Organization:** OmniFocus, OmniPlan, Things, Craft, Notion, Todoist, Obsidian, Microsoft Office (particularly modern iterations).
* **Creative & Design Tools:** OmniGraffle, Sketch, Affinity Studio (Photo, Designer, Publisher), Adobe Creative Suite (Photoshop, Illustrator, InDesign, XD), Figma Desktop, DaVinci Resolve, Cinema 4D, Logic Pro, Final Cut Pro.
* **Utility & Ecosystem:** Fantastical, Setapp ecosystem apps, Native Apple Apps (Photos, Keynote, Mail, Calendar, Notes, Reminders, Freeform, Files), Mimestream.
* **Writing & Content:** Ulysses, Bear.
* **Communication & Collaboration:** Slack.
* **Developer & Power User Tools:** Descript, ChatGPT (Desktop/Web Interface), Linear.
* **Data & Finance (Information Density & Clarity):** Bloomberg Terminal, FactSet, TradingView, Numbers, Tableau, Power BI.

**Alignment with Platform Human Interface Guidelines (HIG):**
Adherence to platform-specific HIGs is fundamental. This guide complements them by providing project-specific interpretations and extensions.
* **Apple Platforms (iOS, macOS, iPadOS):** Apple Human Interface Guidelines (Clarity, Deference, Depth).
* **Android:** Material Design Guidelines (Material You principles: adaptable, personal, expressive).
* **Windows:** Fluent Design System Principles (Light, Depth, Motion, Material, Scale).

## 2.3 Design Principles
* **Consistency:** Similar elements should look and behave in similar ways across the app and adapt predictably across platforms.
* **Feedback:** The system should always keep users informed about what is happening.
* **Affordance:** The design of elements should suggest their function, respecting platform conventions.
* **Hierarchy:** Visual hierarchy should guide the user's attention.
* **Accessibility:** Design for everyone (see Section 7).
* **Aesthetics (Delight):** Strive for an interface that is functional, visually pleasing, and enjoyable to use on any device.

---

# 3. Brand & Visual Identity

## 3.1 Logo Usage and Clear‑Space Rules
* **Primary Logo:** [Insert Primary Logo Image/Vector]
    * Usage guidelines (e.g., preferred backgrounds, minimum size).
* **Secondary/Monochrome Logo:** [Insert Secondary Logo Image/Vector]
    * Usage guidelines.
* **Clear Space:** A minimum clear space of [X units or % of logo height] must be maintained around the logo.
* **Misuse:** Examples of incorrect logo usage (e.g., stretching, color alteration, busy backgrounds).

## 3.2 Colour Palette

### Deriving from Inspirations: Colours
Consider your top-ranked inspirations from Section 0.1.
* **Overall Feel:** Do your top inspirations have a light, dark, or vibrant theme? Are they professional and subdued (e.g., OmniFocus, Microsoft Office), clean and minimalist (e.g., Things, Craft, Bear), or data-dense with functional color coding (e.g., Bloomberg, TradingView)?
* **Primary/Brand Color:** How do your inspirations use their main brand color? Is it for all interactive elements (like Linear's purple), or more selectively for key calls to action and branding accents (like many Apple apps)?
* **Accent Colors:** Observe how accents are used. For subtle highlights (Fantastical), for categorization (Notion), or for user customization (some Setapp apps)?
* **Functional Colors:** Note the clarity and consistency of success, warning, and error states in your inspirations. Are they bold or subtle?
* **Backgrounds & Surfaces:** Do they use flat colors, subtle gradients, or rich materials (like Apple's vibrancy or Windows' Mica/Acrylic)? How do they create depth between layers?

### Defining Your Colour Palette:

* **General Principles:**
    * Use colour purposefully to create hierarchy, convey meaning, and provide visual consistency.
    * Ensure sufficient contrast for accessibility across all platforms (WCAG AA minimum).
    * Test colours in both light and dark modes.

* **Primary Brand Colours:**
    * `Primary Brand Color`: `#[YOUR_HEXCODE]` (Rationale: [Inspired by e.g., Linear's bold interactive color, or OmniFocus's professional blue])
        * `Darker Shade (for hover/pressed states or depth)`: `#[YOUR_HEXCODE]`
        * `Lighter Shade (for subtle backgrounds or highlights)`: `#[YOUR_HEXCODE]`
    * `Secondary Brand Color`: `#[YOUR_HEXCODE]` (Rationale: [e.g., A complementary color seen in Notion's secondary elements])
        * `Darker Shade`: `#[YOUR_HEXCODE]`
        * `Lighter Shade`: `#[YOUR_HEXCODE]`
    * **Usage:** [Define how and where these will be used, based on your inspirations]
    * **Platform Note:** [Consider platform influences as per original document]

* **Accent Colours:**
    * `Accent 1 (Brand Aligned)`: `#[YOUR_HEXCODE]` (Rationale: [e.g., Inspired by Fantastical's event type colors])
    * `Accent 2 (Data Viz/Categorization)`: `#[YOUR_HEXCODE]`
    * `Accent 3 (Data Viz/Categorization)`: `#[YOUR_HEXCODE]`
    * `Accent 4 (User-selectable/Dynamic)`: `#[YOUR_HEXCODE]`
    * **Usage:** [Define based on inspirations]
    * **Platform Adaptation:** [As per original document]

* **Functional (Semantic) Colours:**
    * `Success/Confirmation`: `#[YOUR_HEXCODE]` (Rationale: [e.g., Clear green like in most native apps])
        * `Container/Subtle Background`: `#[YOUR_HEXCODE]`
    * `Warning/Caution`: `#[YOUR_HEXCODE]`
        * `Container/Subtle Background`: `#[YOUR_HEXCODE]`
    * `Error/Destructive`: `#[YOUR_HEXCODE]`
        * `Container/Subtle Background`: `#[YOUR_HEXCODE]`
    * `Informational`: `#[YOUR_HEXCODE]`
        * `Container/Subtle Background`: `#[YOUR_HEXCODE]`
    * **Usage:** [As per original document]
    * **Platform Cues:** [As per original document]

* **Neutral & Background Colours (UI Chrome, Text, Surfaces):**
    * **Base Backgrounds (Window/Page):**
        * `Background Page/Window (Light Mode)`: `#[YOUR_HEXCODE]` (Rationale: [e.g., Clean off-white like Craft or Notion])
        * `Background Page/Window (Dark Mode)`: `#[YOUR_HEXCODE]` (Rationale: [e.g., Deep gray like OmniFocus or Linear])
    * **Surface Backgrounds (Cards, Sheets, Menus, Sidebars):**
        * `Surface Primary (Light Mode)`: `#[YOUR_HEXCODE]`
        * `Surface Primary (Dark Mode)`: `#[YOUR_HEXCODE]`
        * `Surface Secondary/Elevated (Light Mode)`: `#[YOUR_HEXCODE]`
        * `Surface Secondary/Elevated (Dark Mode)`: `#[YOUR_HEXCODE]`
    * **Text Colours:**
        * `Text Primary (On Light/Dark)`: `#[YOUR_HEXCODE]`
        * `Text Secondary (On Light/Dark)`: `#[YOUR_HEXCODE]`
        * `Text Tertiary/Disabled (On Light/Dark)`: `#[YOUR_HEXCODE]`
        * `Text Interactive/Link (On Light/Dark)`: `Primary Brand Color` or `#[YOUR_HEXCODE]`
    * **Borders & Separators:**
        * `Border Subtle (Light Mode)`: `#[YOUR_HEXCODE]`
        * `Border Subtle (Dark Mode)`: `#[YOUR_HEXCODE]`
        * `Border Emphasized (Light Mode)`: `#[YOUR_HEXCODE]`
        * `Border Emphasized (Dark Mode)`: `#[YOUR_HEXCODE]`
        * `Border Focus (Interactive Elements)`: `Primary Brand Color` or `#[YOUR_HEXCODE]`

* **Transparency, Vibrancy & Materials:**
    * **Guidance:** If your inspirations include Native Apple Apps, Setapp ecosystem apps, or Mimestream, you'll lean heavily into system materials. If inspired by Windows apps, Fluent materials like Mica/Acrylic are key. Web-centric inspirations like Notion or Figma might use flatter, more opaque surfaces.
    * [Define your approach based on inspirations and platform guidelines as per original document]

* **Platform-Specific Color Considerations:** [As per original document]

## 3.3 Typography

### Deriving from Inspirations: Typography
Consider your top-ranked inspirations from Section 0.1.
* **Font Families:** Do your inspirations use system fonts (SF Pro for Apple, Segoe UI for Windows, Roboto for Android – common in native apps, OmniFocus, Things, Fantastical)? Or do they use custom/web fonts for a more branded or unique feel (Notion, Craft, Slack, Linear often use fonts like Inter or custom sans-serifs)? Are there serif fonts used for body content or branding (Ulysses, Bear, some aspects of Craft)?
* **Font Weights & Styles:** How is typographic hierarchy achieved? Through significant weight changes (common in modern UIs like Linear or Figma), size differences, or color/opacity? Observe the use of italics or other styles.
* **Type Scale:** Is the type scale compact and dense (Bloomberg, FactSet, potentially Linear for some elements) or more open and spacious (Craft, Bear, Apple native apps)? How large are body text and headings relative to each other?

### Defining Your Typography:

* **Font Families:**
    * **Primary UI Font Family:** `[Your Chosen Font Family]` (Rationale: [e.g., "SF Pro" for Apple native feel, "Inter" for cross-platform modern look inspired by Notion/Linear])
        * `Platform Specifics (if UI Default varies):`
            * `Apple Platforms`: `[SF Pro or Your Brand Font]`
            * `Windows`: `[Segoe UI Variable or Your Brand Font]`
            * `Android`: `[Roboto or Your Brand Font]`
    * **Body Text Font Family (if different from UI, e.g., for long-form content):** `[Your Chosen Font Family]` (Rationale: [e.g., "New York" for readability inspired by Ulysses, or same as UI font])
    * **Monospace Font Family:** `[Your Chosen Font Family]` (e.g., SF Mono, Cascadia Code, Roboto Mono, or a brand-aligned mono)
    * **Cross-Platform Brand Font (If used):** `[Your Brand Font Name]`
        * **Usage Notes:** [As per original document]
        * **Licensing:** [As per original document]
        * **Fallback Strategy:** [As per original document]

* **Font Weights:**
    (Define the specific weights from your chosen font family that map to these conceptual roles, informed by your inspirations)
    * `Thin/Ultralight`: `[Font Weight Name/Number]`
    * `Light`: `[Font Weight Name/Number]`
    * `Regular/Normal`: `[Font Weight Name/Number]`
    * `Medium`: `[Font Weight Name/Number]`
    * `Semibold`: `[Font Weight Name/Number]`
    * `Bold`: `[Font Weight Name/Number]`
    * `Heavy/Black`: `[Font Weight Name/Number]`
    * **Note:** [As per original document regarding variable fonts]

* **Font Styles:**
    * `Regular/Roman`: Available
    * `Italic`: Available (True Italic preferred)
    * `Oblique`: [Note if only oblique is available for any chosen family]

* **Type Scale & Hierarchy:**
    (Define your specific pt/sp/px sizes, weights, and line heights for each role, referencing your inspirations for relative scale and density)
    * `Display Large (XL)`: [Font Size, Weight, Line Height]
    * `Display Medium (L)`: [Font Size, Weight, Line Height]
    * `Headline 1 (H1)`: [Font Size, Weight, Line Height]
    * `Headline 2 (H2)`: [Font Size, Weight, Line Height]
    * `Headline 3 (H3)`: [Font Size, Weight, Line Height]
    * `Subtitle/Lead`: [Font Size, Weight, Line Height]
    * `Body Regular`: [Font Size, Weight, Line Height]
    * `Body Small/Caption`: [Font Size, Weight, Line Height]
    * `Button Text`: [Font Size, Weight, Line Height, All Caps: Yes/No]
    * `Micro/Overline`: [Font Size, Weight, Line Height, All Caps: Yes/No]
    * `Monospace/Code`: [Font Size, Weight, Line Height]
    * **Line Height (Leading):** [General approach, e.g., 1.4-1.5x for body]
    * **Letter Spacing (Tracking):** [General approach]
    * **Paragraph Spacing:** [General approach]

* **Usage Guidelines:** [As per original document, adapt based on chosen fonts and scale]
    * **Platform Adaptation:** [As per original document]
    * **Dynamic Type/Text Scaling:** [As per original document]

## 3.4 Iconography

### Deriving from Inspirations: Icons
Consider your top-ranked inspirations from Section 0.1.
* **Style:** Do they use filled icons, outlined icons, or a mix? Are they sharp and geometric (Linear, Figma, Sketch), or softer and more rounded (some Apple native apps)? What is the typical line weight?
* **Source:** Do they heavily rely on system icon libraries (SF Symbols for Apple apps, Material Symbols for Android apps), or do they use a fully custom set (common in highly branded apps or specialized tools like Adobe CC, Affinity)?
* **Density & Complexity:** Are icons simple and abstract, or more detailed and illustrative?

### Defining Your Iconography:

* **App Icon:** [As per original document]
* **General Icon Style Principles:**
    * **Chosen Style:** [e.g., Outline, Line Weight: 1.5pt, Corner Radius: 2px, inspired by Linear's clarity] OR [e.g., Filled with subtle internal details, inspired by OmniFocus's professional feel]
    * [Other principles as per original document: Simplicity, Consistency, Scalability, Pixel Perfection, Metaphor]
* **Platform-Specific Icon Libraries (Preferred Source):**
    * **Apple Platforms (iOS, macOS, iPadOS):** `SF Symbols` (Preferred Weight: `[.medium]`, Preferred Scale: `[.default]`)
    * **Android:** `Material Symbols` (Preferred Style: `[Outlined/Filled]`)
    * **Windows:** `Segoe Fluent Icons` (Preferred Style: `[Regular/Filled]`)
* **Custom Icons:**
    * **When to Use:** [As per original document]
    * **Style Matching:** [As per original document - MUST match chosen style and harmonize with platform libraries]
    * **Grid & Keylines:** [Define your grid, e.g., 24x24dp/pt canvas]
    * **Export:** [As per original document]
* **Toolbar & Navigation Icons:**
    * Size: [e.g., Visual size 22dp/pt, Touch Target 44dp/pt]
    * Color: [As per original document]
* **File Icons / Document Icons:** [As per original document]
* **Status & Semantic Icons:** [As per original document]
* **Cross-Platform Icon Set Strategy:**
    * `Your Chosen Strategy:` [e.g., Option 1: Platform Native, mapping concepts] (Rationale: [e.g., Prioritizing native feel and accessibility features of system libraries])
    * [Details for chosen strategy as per original document]

## 3.5 Illustration & Imagery Style
* **Illustrations:**
    * Style: `[Your Chosen Style]` (Rationale: [e.g., Inspired by Craft's clean line art or Slack's friendly characters])
    * [Other details as per original document]
* **Photography/Imagery:**
    * Style: `[Your Chosen Style]`
    * [Other details as per original document]

---

# 4. Layout & Spacing (App Spacing)

### Deriving from Inspirations: Layout & Spacing
Consider your top-ranked inspirations from Section 0.1.
* **Information Density:** Are your inspirations dense with information (Bloomberg, FactSet, some pro tools like Cinema 4D or Logic Pro), or do they prioritize white space and focus (Things, Bear, Craft, Apple native apps)?
* **Grid Usage:** Do they appear to use a strict grid, or is the layout more organic? How are elements aligned?
* **Padding & Margins:** Observe the spacing around key elements, within containers, and screen edges. Is it generous or tight?
* **Visual Hierarchy through Spacing:** How is spacing used to group related items and separate distinct sections?

### Defining Your Layout & Spacing:

* **Base Grid Unit:** `[e.g., 8dp/pt]` (Rationale: [e.g., Common practice, balances flexibility and consistency, seen in many inspirations])
* **Layout Grids:**
    * **Mobile (iOS, Android):**
        * Margins: `[e.g., 16dp/pt]`
        * Gutters: `[e.g., 16dp/pt]`
        * [Other details as per original document]
    * **Tablet/Desktop (iPadOS, macOS, Windows):**
        * Margins: `[e.g., 24dp/pt]`
        * Columns: `[e.g., 12-column]`
        * Gutters: `[e.g., 24dp/pt]`
        * [Other details as per original document]
* **Alignment:** [As per original document]

* **Window Sizes, Breakpoints, and Resizing Behaviour:**
    * **Responsive Design Approach:** [Describe your general strategy, informed by how inspirations handle different screen sizes]
    * **Breakpoints (Conceptual):**
        * `Compact (Mobile)`: `[e.g., < 600dp/pt width]`
        * `Medium (Tablet Portrait/Large Phones)`: `[e.g., 600-840dp/pt width]`
        * `Expanded (Tablet Landscape/Small Desktop)`: `[e.g., 841-1280dp/pt width]`
        * `Large Expanded (Desktop)`: `[e.g., > 1280dp/pt width]`
    * **Platform Specifics:** [As per original document]

* **Safe Areas, Insets & Padding Rules (App Spacing):**
    * **Safe Areas:** [As per original document]
    * **Screen/Window Margins:**
        * `Compact`: `[Your Value]`
        * `Medium/Expanded`: `[Your Value]`
    * **Content Padding within Containers (Cards, List Items, Dialogs, etc.):**
        * `Standard Padding`: `[Your Value, e.g., 16dp/pt]` (Rationale: [Common in inspirations like Notion, Apple HIG])
        * `Compact Padding`: `[Your Value, e.g., 8dp/pt]`
    * **Spacing Between Elements (Vertical and Horizontal):**
        (Define your scale based on the base unit and observations from inspirations)
        * `XSmall (XS)`: `[e.g., 4dp/pt]`
        * `Small (S)`: `[e.g., 8dp/pt]`
        * `Medium (M)`: `[e.g., 16dp/pt]`
        * `Large (L)`: `[e.g., 24dp/pt]`
        * `XLarge (XL)`: `[e.g., 32dp/pt or 40dp/pt]`
        * `XXLarge (XXL)`: `[e.g., 48dp/pt or 64dp/pt]`
    * **Vertical Rhythm:** [Your approach]
    * **Touch/Click Targets:** [As per original document]

* **Dark Mode & High‑Contrast Considerations:** [As per original document]

---

# 5. Components & Controls

### Deriving from Inspirations: Components
For each component type (Buttons, Cards, Inputs), examine your top-ranked inspirations:
* **Visual Style:** What are the common shapes (corner radii), elevation/shadows, borders, and background treatments? (e.g., Apple's flat but layered look, Material Design's clear elevation, Linear's sharp and efficient components).
* **States:** How clearly are states like hover, focus, pressed, and disabled communicated?
* **Interactivity & Affordance:** How obvious is it that a component is interactive?

### Defining Your Component Styles:

## 5.1 Buttons & Segmented Controls (Button Styling)
* **General Button Principles:**
    * **Clear Affordance:** [Your approach]
    * **States:** [Ensure all defined]
    * **Padding:** `Top/Bottom: [Value]`, `Left/Right: [Value]`
    * **Minimum Size:** [Adhere to platform standards]
    * **Corner Radius:** `[Your Value, e.g., 6dp/pt]` (Rationale: [e.g., Matches subtle rounding in OmniFocus])
* **Button Types & Styling:**
    * **`Primary Action Button (Filled/Contained)`:**
        * **Style:** Background: `Primary Brand Color`, Text: `[High Contrast Text Color]`
        * **Elevation/Shadow:** [Your approach, e.g., Subtle shadow inspired by Material Design]
        * **Typography:** `[Button Text style]`
    * **`Secondary Action Button (Outlined/Tonal)`:**
        * **Style (Outlined):** Background: `Transparent`, Border: `Primary Brand Color`, Text: `Primary Brand Color`
        * **Style (Tonal):** Background: `[Lighter shade of Primary Brand Color]`, Text: `[Darker shade of Primary Brand Color]`
        * **Typography:** `[Button Text style]`
    * **`Tertiary/Text Button (Borderless)`:**
        * **Style:** Text Color: `Primary Brand Color` or `Text Interactive`
        * **Typography:** `[Button Text style]`
    * **`Destructive Action Button`:** [As per original document, using your defined Error color]
    * **`Toggle/Stateful Button`:** [Define active/inactive styles, inspired by e.g., Things filter buttons]
    * **`Icon Button`:** [As per original document]
* **Segmented Controls:**
    * **Style:** [Your approach, e.g., "Native Apple style" or "Material SegmentedButton style with brand color for selection"]
    * [Other details as per original document]

## 5.2 Toolbars, Sidebars & Split Views
* **Toolbars (macOS Window Toolbar, Navigation Bars on iOS, App Bars on Android/Windows):**
    * Content: Common actions, navigation controls (back button), screen titles, search fields.
    * Iconography: Use platform-native icon libraries primarily (see 3.4). Consistent size and color.
    * Layout: Spacing and grouping of items. Respect platform conventions for title alignment and action placement.
    * Background: Often uses a `Surface Primary` or a slightly elevated/material background. May incorporate vibrancy/blur on Apple platforms, Mica on Windows.
* **Sidebars (macOS, iPadOS, responsive Desktop UIs on Windows/Web):**
    * Usage: Primary navigation (source lists), secondary content, inspector panels.
    * Style: Collapsible, fixed-width, resizable.
    * Background: `Surface Primary` or a distinct sidebar material (e.g., Apple's `.sidebar` material).
    * Item styling: Text (`Body Regular` or `Subtitle`), icons, clear selection state (e.g., background highlight with `Primary Brand Color` or system accent, bold text).
* **Split Views:**
    * Usage: For master-detail interfaces or displaying multiple content panes.
    * Divider style: Subtle, often a thin line (`Border Subtle`). May be draggable.
    * Minimum pane sizes to prevent content from becoming unusable.

## 5.3 Menus, Context Menus & Menu Bar Extras
* **Main Menu (macOS Menu Bar):**
    * Structure: Adhere to standard macOS menu categories (File, Edit, View, etc.).
    * Keyboard shortcuts: Define and display standard shortcuts.
* **Context Menus:**
    * Content: Relevant actions for the selected item or context.
    * Trigger: Right-click / Control-click / Long press.
* **Menu Bar Extras (macOS Status Bar Items):**
    * Iconography: Simple, clear, monochrome.
    * Menu content: Concise and focused on the app's background functionality.

## 5.4 Lists, Tables & Collection Views
* **Lists (e.g., `List` in SwiftUI, `UITableView`):**
    * Row height: Standard and variable.
    * Cell layout: Content (text, icons, images), accessory views.
    * Selection style.
    * Separators.
* **Tables (e.g., `Table` in SwiftUI, `NSTableView`):**
    * Column headers: Sorting indicators.
    * Cell content alignment.
    * Row selection (single, multiple).
    * Alternating row colors (optional, subtle).
* **Collection Views:**
    * Layouts: Grid, flow, custom.
    * Item sizing and spacing.
    * Selection and highlight states.

## 5.5 Forms, Text Inputs & Validation States (Input Styling)
* **Text Fields & Text Areas (Input Styling):**
    * **General Appearance:**
        * **Background:** `[e.g., Surface Primary or a dedicated input background]`
        * **Border:** Normal: `Border Subtle`, Focus: `Primary Brand Color`, Error: `Error/Destructive`
        * **Corner Radius:** `[Subtle Rounding value, e.g., 4dp/pt]`
        * **Internal Padding:** `[e.g., Top/Bottom: 10dp/pt, Left/Right: 12dp/pt]`
    * **Platform Variations:** [Note how your style might adapt, e.g., "Aim for Material outlined style on Android, simpler rounded rect on Apple"]
    * **Placeholder Text:** Color: `Text Secondary`
    * [Other details as per original document]
* **States:** [As per original document]
* **Labels:** [As per original document]
* **Pickers, Date Pickers, Sliders, Steppers:** [As per original document]
* **Checkboxes & Radio Buttons:** [As per original document]
* **Validation States (Visual Cues):** [As per original document]

## 5.6 Dialogs, Sheets & Popovers
* **Dialogs/Alerts:**
    * Usage: For critical information, warnings, or confirmations requiring immediate user attention.
    * Title, message, button layout (e.g., confirming action on the right).
    * Use sparingly.
* **Sheets (Modal Presentations):**
    * Usage: For focused tasks or presenting contextual information without losing the underlying context.
    * Dismissal methods (e.g., Done button, swipe).
* **Popovers:**
    * Usage: For displaying transient UI related to a specific control or selection.
    * Arrow direction and attachment point.
    * Content should be concise.

## 5.7 Status Bars, Progress Indicators & Badges
* **Status Bars (iOS):** System-managed, ensure content doesn't obscure it.
* **Progress Indicators:**
    * `Determinate`: For tasks with a known duration (e.g., progress bar, circular progress).
    * `Indeterminate`: For tasks with an unknown duration (e.g., spinner, activity indicator).
    * Placement and visibility.
* **Badges:**
    * Usage: To indicate counts, status, or new items (e.g., on app icons, sidebar items).
    * Style: Color, shape, typography.

## 5.8 Touch Bar & Menu Bar Widgets (if applicable)
* **Touch Bar (MacBook Pro):**
    * Provide relevant contextual controls.
    * Follow Apple's Touch Bar HIG.
* **Menu Bar Widgets (macOS Big Sur+):**
    * If providing widgets, ensure they are useful and well-integrated.

---

# 6. Interaction & Behaviour

## 6.1 Mouse, Trackpad & Keyboard Shortcuts
* **Hover States:** Provide clear visual feedback on hover for interactive elements.
* **Cursor Styles:** Use appropriate system cursors (e.g., pointer, text, grab).
* **Trackpad Gestures:** Support standard gestures (e.g., pinch to zoom, swipe to navigate).
* **Keyboard Navigation:** Ensure full keyboard navigability (see Section 7.4).
* **Keyboard Shortcuts:**
    * Define standard shortcuts for common actions (e.g., Cmd+S for Save, Cmd+N for New).
    * Display shortcuts in menus.
    * Avoid conflicts with system shortcuts.

## 6.2 Drag‑and‑Drop Patterns
* **Visual Feedback:** Clear indication of draggable items and valid drop targets.
* **Data Types:** Support relevant data types for dragging in and out of the app.
* **Spring Loading:** For folders or containers.

## 6.3 Selection, Focus & Activation States
* **Selection:**
    * Clear visual distinction for selected items (e.g., background color, border).
    * Single vs. multiple selection behavior.
* **Focus:**
    * Visible focus ring for keyboard navigation, especially for text inputs and controls.
    * Adhere to system focus ring appearance.
* **Activation States:** Visual feedback when an element is pressed or activated.

## 6.4 Animation & Motion Guidelines (Aesthetics & Motion/Animation)

### Deriving from Inspirations: Motion & Animation
Consider your top-ranked inspirations from Section 0.1.
* **Overall Feel:** Is the motion snappy and immediate (Linear)? Fluid and physics-based (Native Apple Apps, Fantastical)? Subtle and utilitarian (OmniFocus)? Or more expressive and branded (some creative tools or Setapp apps)?
* **Purpose:** How is animation used? Primarily for feedback, for delightful transitions, to guide focus, or to explain spatial relationships?
* **Complexity:** Are animations simple fades and slides, or do they involve more complex choreography or 3D effects?

### Defining Your Motion & Animation Guidelines:

* **Purpose of Animation:** [As per original document]
* **Core Principles:**
    * **Desired Feel:** `[e.g., "Responsive and fluid, with physics-based interactions inspired by Apple HIG and Fantastical"]`
    * [Other principles as per original document: Performance, Subtlety, Meaningful, Consistency]
* **Standard Durations & Easing Curves:**
    (Define your timings and easing, referencing inspirations)
    * `Micro-interactions (Feedback)`: `[e.g., 120ms, ease-out]`
    * `Short Transitions (UI Elements)`: `[e.g., 220ms, ease-in-out]`
    * `Medium Transitions (View/Screen Changes)`: `[e.g., 300ms, custom spring (stiffness: X, damping: Y) or platform default]`
    * `Long Transitions (Use Sparingly)`: `[e.g., 450ms]`
    * **Easing Curves:** [Specify preferred curves or spring parameters]
* **Platform-Specific Animation Systems:** [As per original document]
* **Specific Animation Examples:**
    * **View Transitions:** `[e.g., "Default platform push/modal, with potential for shared element transitions inspired by Material Design if applicable"]`
    * **List Item Animations:** `[e.g., "Subtle fade-in and slide-up for new items, similar to Things"]`
    * [Other examples as per original document]
* **Reduced Motion:** [As per original document - MANDATORY]

## 6.5 System Feedback (Haptic, Sound, Alerts)
* **Haptic Feedback (iOS/iPadOS):**
    * Use standard haptics (e.g., `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator`) to confirm actions or provide warnings.
    * Use appropriately and sparingly.
* **Sound Feedback:**
    * Generally avoid custom sounds unless core to the app's function.
    * If used, sounds should be subtle and provide meaningful feedback.
    * Provide an option to disable sounds.
* **Alerts & Notifications:** See Section 5.6 and Section 12.

---

# 7. Accessibility (A11Y)
Designing for accessibility ensures that people of all abilities can use the product. This is a legal and ethical requirement.

## 7.1 VoiceOver & Spoken Content
* All interactive elements must have clear, concise, and descriptive accessibility labels.
* Provide accessibility hints for non-obvious interactions.
* Group related elements logically for easier navigation.
* Ensure correct reading order.
* Support custom actions for complex elements.

## 7.2 Dynamic Type & Resize Text
* Support Dynamic Type to allow users to choose their preferred text size.
* UI should reflow gracefully as text size changes.
* Use text styles (Headline, Body, Caption) that adapt to Dynamic Type.
* Avoid fixed heights for text containers where possible.

## 7.3 Colour‑blind Friendly Palettes & Contrast
* Ensure sufficient color contrast between text and background (WCAG AA minimum: 4.5:1 for normal text, 3:1 for large text).
* Do not rely on color alone to convey information. Use icons, text labels, or other visual cues.
* Test color palettes with color blindness simulators.

## 7.4 Keyboard Navigation & Full‑Keyboard Access
* All interactive elements must be reachable and operable via keyboard.
* Provide a clear visual focus indicator (see Section 6.3).
* Ensure a logical tab order.
* Support standard keyboard shortcuts for navigation and interaction.

## 7.5 Reduced‑Motion Mode
* Respect the user's preference for reduced motion.
* Replace or disable non-essential animations and effects when this setting is enabled.
* Use cross-fades or other simple transitions instead of complex motion.

---

# 8. Content & Tone

## 8.1 Microcopy Standards (Buttons, Helpers, Empty States)
* **Clarity & Conciseness:** Use simple, direct language. Avoid jargon.
* **Action-Oriented:** Button labels should clearly indicate the action they perform (e.g., "Save Changes," "Create New Document").
* **Helpful Helper Text:** Provide brief, contextual assistance where needed.
* **Engaging Empty States:** Use empty states to guide users, offer tips, or provide a call to action.
* **Tone of Voice:** [Define the brand's tone: e.g., Friendly, Professional, Playful, Encouraging]. Maintain consistency.

## 8.2 Error Messages & Recovery Guidance
* **Be Specific:** Clearly explain what went wrong.
* **Be Constructive:** Provide actionable advice on how to fix the problem.
* **Be Polite:** Avoid blaming the user.
* **Placement:** Display error messages close to the point of error.
* **Example:** Instead of "Invalid input," use "Please enter a valid email address (e.g., name@example.com)."

## 8.3 Inclusive Language Checklist
* Use gender-neutral language.
* Avoid ableist, racist, or otherwise biased terms.
* Be mindful of cultural sensitivities.
* Refer to users respectfully.

## 8.4 Localisation & Internationalisation Rules
* Design UI that can accommodate text expansion in different languages.
* Avoid embedding text in images.
* Use locale-aware formatting for dates, times, numbers, and currencies.
* Ensure assets are localizable.

---

# 9. Performance & Resource Management

## 9.1 Launch‑Time Budget & Lazy Loading
* **Target Launch Time:** [e.g., < 2 seconds for cold launch].
* **Lazy Loading:** Load resources and data only when needed to improve initial launch time and responsiveness.
* Profile launch time regularly.

## 9.2 Memory Footprint Targets
* **Target Memory Usage:** [Define acceptable memory limits for typical usage scenarios].
* Monitor for memory leaks using tools like Instruments.
* Optimize data structures and image handling.

## 9.3 Power Efficiency (Energy Diagnostics)
* Minimize CPU usage, especially for background tasks.
* Optimize animations and graphics rendering.
* Use Energy Diagnostics in Xcode to identify and address power consumption issues.

## 9.4 Offline / Low‑Network Behaviour
* Provide clear feedback when the network is unavailable.
* Cache data for offline access where appropriate.
* Implement graceful degradation of features that require connectivity.
* Allow users to queue actions to be performed when connectivity is restored.

---

# 10. File Handling & Document Architecture (If Applicable)

## 10.1 Standard Save/Autosave Flow
* **Autosave:** Prefer autosave for document-based apps to prevent data loss.
* **Explicit Save:** If explicit save is used, follow platform conventions (Cmd+S).
* Provide clear indication of save status (e.g., "Edited" in window title).

## 10.2 File Format & Extension Guidelines
* Define custom file formats and extensions if necessary.
* Consider using package formats for complex documents.
* Ensure backward and forward compatibility where possible.

## 10.3 App Sandbox & Security Entitlements
* Adhere to App Sandbox rules for macOS apps.
* Request only necessary security entitlements.
* Handle sandbox restrictions gracefully (e.g., using `NSOpenPanel` for file access).

## 10.4 iCloud Drive & External Storage Support
* Support iCloud Drive for document syncing if appropriate.
* Handle access to external storage locations correctly.

---

# 11. Preferences & Settings

## 11.1 System‑wide vs. App‑specific Settings
* Distinguish between settings that affect the entire system (via System Settings) and app-specific preferences.
* Store app-specific preferences using `UserDefaults` or other appropriate mechanisms.

## 11.2 Preferences Window Layout (macOS) / Settings Screen (iOS)
* Organize preferences logically into sections or tabs.
* Use standard controls for settings.
* Provide clear labels and explanations for each setting.

## 11.3 Advanced/Developer Options Handling
* If providing advanced or developer options, consider hiding them by default or placing them in a separate section to avoid cluttering the main preferences for typical users.

---

# 12. Notifications & App Lifecycle

## 12.1 In‑App Banners vs. System Notifications
* **In-App Banners/Toasts:** For non-critical information or feedback related to an in-app action. Should be dismissible.
* **System Notifications:** For timely, relevant information when the app is in the background or not active.
    * Request permission appropriately.
    * Provide clear and actionable notification content.
    * Allow users to configure notification preferences.

## 12.2 App Nap & Background Tasks
* Support App Nap on macOS to conserve energy when the app is not in use.
* Use background task APIs correctly for tasks that need to continue when the app is not active.

## 12.3 State Restoration & Scene Management (macOS 13+, iOS)
* Implement state restoration to return users to where they left off.
* Support multi-windowing and scene management where appropriate (e.g., on iPadOS and macOS).

---

# 13. Quality Assurance

## 13.1 UI Regression Test Matrix
* Maintain a checklist or automated test suite covering key UI components and user flows to catch regressions.

## 13.2 Visual Snapshot Tests
* Consider using visual snapshot testing tools to detect unintended UI changes.

## 13.3 Accessibility Audits
* Regularly perform accessibility audits using tools (e.g., Accessibility Inspector) and manual testing with VoiceOver.

## 13.4 Beta Feedback & Crash Reporting Workflow
* Establish a clear process for collecting and addressing feedback from beta testers.
* Integrate a crash reporting tool to monitor and fix crashes promptly.

---

# 14. Release & Versioning

## 14.1 Semantic Versioning Policy
* Follow Semantic Versioning (MAJOR.MINOR.PATCH).
    * MAJOR version when you make incompatible API changes,
    * MINOR version when you add functionality in a backward-compatible manner, and
    * PATCH version when you make backward-compatible bug fixes.

## 14.2 Release Note Style
* Clearly communicate new features, improvements, and bug fixes in release notes.
* Use a consistent and user-friendly style.

## 14.3 App Store Asset Checklist
* Maintain a checklist of required App Store assets (screenshots, app previews, descriptions) for each release.

---

# 15. Resources & Appendices

## 15.1 Reference Links
* Apple Human Interface Guidelines: [Link to HIG]
* SF Symbols App: [Link to SF Symbols]
* Material Design Guidelines: [Link to Material Design]
* Material Symbols: [Link to Material Symbols]
* Fluent Design System: [Link to Fluent Design]
* WCAG Guidelines: [Link to WCAG]
* [Project-specific design tool links, e.g., Figma, Sketch Cloud]

## 15.2 Reusable Figma/Sketch/SwiftUI Libraries
* Link to shared design libraries or component libraries used by the team.
* Guidelines for contributing to and using these libraries.

## 15.3 Glossary of Terms
* Define any project-specific or technical terms used within this guide or by the team.

---
