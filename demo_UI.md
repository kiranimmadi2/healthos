# HealthOS: Modern UI/UX Design Plan

## 1. Objective & Aesthetic Philosophy
**Theme:** "Zen & Natural" Minimalist.
We are moving away from traditional "clinical" designs (sterile whites, stark hospital blues/greens) to a modern, empathetic, and calming aesthetic. The UI should feel like a premium wellness or lifestyle app rather than a traditional medical utility. It must be highly intuitive, heavily rely on whitespace, and use smooth, fluid animations.

## 2. Design Language (Tokens)

### Color Palette
- **Backgrounds:** Warm Off-White (`#F9F9F7`) - Reduces eye strain compared to pure white.
- **Surface/Cards:** Pure White (`#FFFFFF`) with very soft, large-spread shadows to create a floating effect.
- **Primary Accent (Sage/Mint):** Soft Sage Green (`#88A992`) - Used for primary buttons, active states, and successful actions.
- **Secondary Accent (Sand):** Warm Sand/Terracotta (`#D9BFA9`) - Used for warnings, notifications, or secondary highlights.
- **Text & Icons:** 
  - Primary Text: Charcoal Black (`#2A2A2A`) - Softer than pure black.
  - Secondary Text: Muted Grey (`#8E8E93`).

### Typography
- **Font Family:** A modern, geometric sans-serif (e.g., `Plus Jakarta Sans`, `Inter`, or `SF Pro Rounded`).
- **Styling:** Large, bold headers for hierarchy. Minimal text overall. No dense paragraphs.

### Shapes & Components
- **Border Radii:** Highly rounded corners (`24px` to `32px` for cards, full pill-shapes for buttons) to feel approachable and smooth (squircle shapes).
- **Shadows:** Very diffuse, low-opacity shadows (e.g., `box-shadow: 0px 10px 40px rgba(0,0,0, 0.04)`) to create depth without clutter.
- **Glassmorphism:** Subtle use of blurred, translucent overlays (frosted glass) for bottom nav bars and sticky headers.

---

## 3. Core Screen Layouts

### A. Home Dashboard (The "Command Center")
- **Header:** Personalized greeting ("Good morning, Alex") with a high-quality circular avatar. No heavy app bars.
- **Quick Action Pills:** Horizontal scrolling row of pill-shaped buttons (e.g., "Consult AI", "Find Doctor", "My Records").
- **Upcoming Card:** A beautifully spaced card showing the next appointment or AI triage result, acting as the focal point.
- **Navigation:** Floating, glass-effect bottom navigation bar, detached from the very bottom of the screen.

### B. AI Triage (Gemini Integration)
- **Vibe:** Feels like texting a highly intelligent, calm friend.
- **Layout:** Chat bubble interface. User messages are soft Sage, AI messages are clean White with soft shadows.
- **Input:** A pill-shaped floating input field at the bottom with a simple send icon.
- **Micro-interactions:** A smooth typing indicator (pulsing dots) when Gemini is processing.

### C. Find a Doctor
- **Search:** A large, prominent, soft-edged search bar that blends into the background.
- **Categories:** Horizontal scrolling cards with minimal, abstract iconography for specialties (Cardiology, Dermatology, etc.).
- **Doctor Cards:** Vertical list. Each card shows the doctor's photo, name, rating (with a subtle star icon), and a "Next Available" tag. Clean, uncluttered layout.

### D. Appointment Booking (Bottom Sheet)
- **Interaction:** Instead of navigating to a new page, tapping a doctor pulls up a smooth bottom sheet (sliding up from the bottom).
- **Calendar:** A minimalist horizontal week view (dates as rounded squares) that the user can swipe through.
- **Time Slots:** Clean, distinct pill shapes for available times. Selected times highlight in Sage.
- **Action:** A sticky "Confirm Booking" button at the bottom of the sheet.

---

## 4. Motion & Smoothness (The "Feel")

- **Hero Animations:** When tapping a Doctor Card, the doctor's image smoothly transitions and expands into the detail view.
- **Bouncy Physics:** Lists and scrolls should have slight "overscroll" bounce (standard iOS feel, implemented via Flutter physics).
- **Fade & Slide:** Elements should not snap into view. Pages should fade in while sliding slightly upwards (`200ms-300ms` duration).
- **Haptic Feedback:** Subtle vibrations on critical interactions (e.g., sending an AI message, confirming an appointment).

---

## 5. Implementation Strategy
1. Add `google_fonts` package to apply the modern typography.
2. Build a central `AppTheme` class defining the colors, shapes, and text styles globally.
3. Refactor existing screens (`main.dart`, `ai_service.dart` views) to use the new layout widgets and `Hero` animations.
4. Implement the glassmorphism effects using Flutter's `BackdropFilter`.