# Contributing

Thank you for helping improve Seafood Guide. Focused bug fixes, accessibility improvements, documentation, tests, and carefully scoped modernization work are welcome.

## Choose the right channel

- Search existing issues before reporting a bug or proposing actionable work.
- Use an issue form for reproducible bugs or well-defined features.
- Use GitHub Discussions for questions, early ideas, and architectural proposals.
- Report vulnerabilities privately as described in `SECURITY.md`.

## Development workflow

1. Create or claim an issue with clear acceptance criteria.
2. Branch from the current default branch using `<type>/<issue>-<short-description>`.
3. Make one logical change at a time.
4. Use Conventional Commit messages such as `fix: prevent empty detail selection`.
5. Update tests, documentation, and `CHANGELOG.md` when applicable.
6. Run the validation build documented in `README.md`.
7. Open a pull request using the repository template and link the issue with `Closes #123`.

Do not include unrelated formatting, generated build products, Xcode user data, `.DS_Store`, credentials, or AI-tool artifacts.

## Pull requests

Keep pull requests small enough to review comfortably. Explain user impact, risks, testing, and rollback considerations. Add before/after screenshots for UI changes. Draft pull requests are encouraged for early collaboration; mark them ready only after self-review and relevant checks pass.

At least one maintainer review is expected. Authors must not merge their own work without review unless the repository owner explicitly documents an exception. Squash or rebase only when requested; never force-push over another contributor's work.

## Code expectations

- Match existing Swift and UIKit conventions in the touched area.
- Prefer clear names and small functions over clever abstractions.
- Keep UI work accessible and test Dynamic Type, VoiceOver labels, color contrast, and common device sizes when relevant.
- Avoid raising the deployment target or adding dependencies without a documented reason.
- Treat warnings as defects when introduced by the change.

## Versioning and releases

The project follows semantic versioning. Add user-visible changes to the `Unreleased` section of `CHANGELOG.md`; maintainers follow `docs/RELEASING.md` when publishing.

By contributing, you agree that your contribution may be used under the terms in `LICENSE`. All community interactions must follow `CODE_OF_CONDUCT.md`.
