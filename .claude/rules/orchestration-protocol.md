# Orchestration Protocol

When decomposing complex tasks or delegating work:

1. **State Ownership:** Clearly partition responsibility between modules (UI Layer, Service Layer, Database Layer).
2. **Atomic Steps:** Deliver functional, test-verified increments rather than broad unverified rewrites.
3. **Skill Activation:** Check `.agents/skills/` and activate domain-specific skills (e.g., `viet-expense-ocr`, `frontend-design`).
4. **Resolution Check:** Verify all edge cases (e.g. invalid OCR formats, empty database queries, missing permissions).
