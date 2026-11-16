# TrabahoTap project rules

## About the app
- Flutter/Dart app for UN SDG 1 (No Poverty): a two-sided job platform.
- Roles: Job Seeker and Business Owner. Users pick a role at sign up and login.
- Job Seekers upload skills and a resume, browse jobs, and apply. Business Owners post jobs, browse talent, view applicants, and mark workers as Hired.
- Ratings (1-5 stars with a short review) are allowed only after a worker is marked Hired.

## Technical rules
- No backend. Use Provider (ChangeNotifier) and shared_preferences. Seed realistic Davao-based sample users, jobs, and reviews.
- Folders: lib/models, lib/providers, lib/screens, lib/widgets, lib/theme.
- Keep the code simple and beginner-friendly, with short comments.
- Run `flutter analyze` after changes and fix errors.
- Do not add packages unless asked. Allowed: provider, shared_preferences, file_picker.
- Before each big task, explain your plan in 5 bullets, then implement.

## Design system (copied from the Taxio reference UI)
- Primary color: amber yellow #FCB81C. Use it for buttons, active tab, icon circles, star ratings, and the Open-to-Work toggle.
- Text: near-black #1F1F1F for headings, gray #8A8A8A for hints and secondary text.
- Backgrounds: white screens; soft cream #FFF7E0 for highlights; input fields light gray #F5F5F5 with 12px rounded corners and no border.
- Buttons: full-width, fully rounded (pill) shape, 54px high, yellow fill with bold dark text. Secondary buttons are outlined in yellow.
- Headings: large, bold, left-aligned (e.g. "Create your Account"). Back arrow top-left on inner screens.
- Icons sit inside yellow filled circles (list items, notifications, success dialogs).
- Success and confirmation dialogs: white rounded card over a dark 50% overlay, a big yellow circle icon, bold title, short message.
- Bottom navigation with 5 items, active item in yellow.
- Cards: white, 16px radius, soft shadow. 8pt spacing grid. Minimum touch target 48x48.
- Onboarding: centered illustration (use icons or simple shapes), title, subtitle, dot indicators, a yellow "Next" pill button.