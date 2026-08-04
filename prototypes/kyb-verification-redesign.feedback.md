# UX advisor feedback — kyb-verification-redesign.html

Reviewed against the UX Newsletter Knowledge Base (`Barion PO assistant/UX Newsletter KB/`), 2026-07-26.

> **Status 2026-07-30 — both "To fix" items resolved.** Section Approve buttons now disable in place
> (`setApproveButton(n, { visible: true, enabled: false })` in `approveSection`), so no layout shift and
> no hide-when-the-state-can-still-change. Reject and final Approve both run through confirmation
> modals, with Reject requiring a reason; the modals now also trap focus, close on Escape, and restore
> focus to their trigger.

## To fix

**Hiding vs. disabling the section Approve buttons**
`setApproveButton()` uses `display:none` to hide the button once a section is auto-approved or finalized, rather than disabling it in place. `[2024-05-07 — Hidden vs. Disabled In UX]` is explicit here: hide only when the user can *never* interact again; disable when the action is temporarily unavailable but the state could change. Since `rejectSection()` re-shows the same button, it's not permanently gone — that's a disable case, not a hide case. The same entry also warns to "avoid layout shift when toggling," and removing the button from the flex row visibly shifts the neighboring Reject button. Consider disabling (grayed, in place) instead of removing.

**No confirm/undo on Reject or final Approve**
`rejectOverall()` and `approveOverall()` are both explicitly commented as terminal/irreversible in the code, yet they fire on a single click with no confirmation step and no undo window. `[2025-03-21 — Free UI Decision Trees: Confirm vs Undo]` is built for exactly this call — run high-consequence actions like this through the confirm-vs-undo decision tree rather than defaulting to instant execution. `[2024-04-15 — Designing For Edge Cases and Exceptions]` reinforces this: irreversible actions should get an undo window.

## Already aligned — keep as-is

- Persistent inline banners (not toasts) for the expiry/revert states — matches `[2025-06-17 — Toast & Snackbars UX Guidelines]`, which warns toasts are wrong for anything error-severity or requiring sustained visibility.
- Status chips pair color with a text label ("Approved"/"Rejected"), and banners pair color with distinct icons (check/x/alert-circle) — matches the "never rely on color alone" rule from `[2025-02-26 — Designing Better Error Messages UX]`.
- Document row actions are persistent icon buttons, not hover-reveal — matches `[2024-11-19 — How To Design Complex Data Tables]`'s warning that hover-only actions cause rage-clicks.
- `requestNewDocument()` shows a real loading state rather than resolving instantly — matches "design all 5 UI states deliberately" in `[2024-04-15 — Designing For Edge Cases and Exceptions]`.

## Not covered by the KB

Keyboard/ARIA patterns for the collapsible section headers (role=button, aria-expanded, keydown handler) are solid but the newsletter KB has no guidance on this specifically — not attributed to it.
