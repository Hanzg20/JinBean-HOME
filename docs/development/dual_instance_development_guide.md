# Dual Instance Development Guide (Customer & Provider)

## Overview
This document provides a detailed guide for collaborative development using two Cursor instances, focusing on the customer and provider modules within the JinBean-01 project. It covers division of labor, directory usage, public code management, Git workflow, feature-level development, integration testing, and documentation standards.

---

## 1. Directory & Responsibility

- **Customer Instance**: Focus on `lib/features/customer/` and related customer-side features.
- **Provider Instance**: Focus on `lib/features/provider/` and related provider-side features.
- **Shared Code**: All common utilities, models, and widgets are placed in `lib/shared/` or `lib/core/`.

---

## 2. Feature-Level Task Breakdown

### Customer Side (lib/features/customer/)
- User registration, login, and authentication
- Profile management (avatar, nickname, contact, intro)
- Address book management (CRUD, default address)
- Service browsing, filtering, and booking
- Order management (view, cancel, review)
- Favorites, likes, and sharing
- Notifications/messages (future)
- UI/UX optimization and multi-device adaptation

#### Customer Side: Current Outstanding Tasks & Priorities

| Feature                                    | Status         | Priority | Notes |
|--------------------------------------------|----------------|----------|-------|
| Authentication (registration, login, reset)| In Progress    | High     | Core entry for all users |
| Profile management (edit avatar, etc.)     | Not Started    | High     | Needed for user personalization |
| Address book management (CRUD, default)    | Not Started    | High     | Required for booking and orders |
| Service browsing & filtering               | In Progress    | High     | Key for user engagement |
| Service booking flow (select, confirm, pay)| Not Started    | High     | Central business process |
| Order management (view, cancel, review)    | Not Started    | Medium   | Post-booking user experience |
| Favorites, likes, sharing                  | Not Started    | Medium   | Social/retention features |
| UI/UX optimization & multi-device adaptation| Not Started   | Medium   | Improves usability |
| Notifications/messages                     | Not Started    | Low      | Planned for future |

### Provider Side (lib/features/provider/)
- Provider registration (dynamic forms, efficient UI)
- Profile and qualification management
- Service publishing and management (CRUD)
- Order management (accept, process, history)
- Income and settlement management (future)
- Notifications/messages (future)
- Document/certificate upload and management
- UI/UX optimization

### Shared Code (lib/shared/, lib/core/)
- Utility functions (date formatting, validation, etc.)
- Data models (User, Order, Service, etc.)
- Common widgets (buttons, dialogs, address input, etc.)
- API service wrappers
- Localization/internationalization helpers

---

## 3. Public Code Collaboration

- All shared logic/components must be placed in `lib/shared/` or `lib/core/`.
- When adding or modifying shared code:
  1. Communicate with the other side before making changes.
  2. After changes, test both customer and provider modules for compatibility.
  3. Use a separate commit for shared code changes, with clear commit messages (e.g., "feat(shared): add date formatting util").
  4. Merge shared code changes to the main branch first, then both sides pull and adapt as needed.

---

## 4. Git Workflow & Branching

- Use feature branches for major features (e.g., `customer-feature-x`, `provider-feature-y`).
- Only stage and commit changes relevant to your module and shared code.
- Avoid using `git add .`; instead, use `git add lib/features/customer/` or `git add lib/features/provider/` or `git add lib/shared/` as appropriate.
- Before merging, run tests for both modules if shared code is involved.
- Regularly pull from the main branch to keep up-to-date with shared changes.

---

## 5. Feature Development & Integration

- Develop features in your respective module directory.
- For new shared utilities or widgets, add them to `lib/shared/` and document their usage.
- When APIs or data models change, update both sides and the shared code as needed.
- Use mock data or stubs for integration before the other side's feature is ready.

---

## 6. Integration Testing

- After shared code or API changes, both sides must test their modules for regressions.
- For cross-module features (e.g., order flow from customer to provider), coordinate integration testing sessions.
- Log and track integration issues in a shared document or issue tracker.

---

## 7. Documentation & Communication

- Document all new shared utilities, models, and widgets in `docu/` or as inline code comments.
- Update API/interface documentation in `docu/` when changes occur.
- Use clear, English commit messages and documentation for team-wide understanding.
- Hold regular sync meetings or async updates to discuss progress and blockers.

---

## 8. Best Practices & Error Prevention

- Always communicate before making shared code changes.
- Test both modules after shared code updates.
- Use descriptive commit messages and keep commits focused.
- Avoid large, mixed commits spanning both modules and shared code.
- Keep documentation up-to-date with code changes.

---

## 9. Example Workflow

1. **Customer developer** implements a new booking feature in `lib/features/customer/`.
2. Needs a new date utility → adds it to `lib/shared/utils/date_util.dart`.
3. Notifies provider developer, who tests provider-side compatibility.
4. Both test, then customer developer commits with message: `feat(shared): add date utility for booking`.
5. Merge to main, both sides pull, continue feature work.

---

## 10. Appendix: Useful Commands

```bash
# Stage only customer module changes
git add lib/features/customer/
# Stage only provider module changes
git add lib/features/provider/
# Stage only shared code changes
git add lib/shared/
# Commit with a clear message
git commit -m "feat(customer): implement booking UI"
# Pull latest shared code
git pull origin main
```

---

**This guide should be updated as the project evolves.** 