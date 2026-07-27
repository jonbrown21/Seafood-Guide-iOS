# Release process

Seafood Guide uses semantic versions in the form `MAJOR.MINOR.PATCH` and annotated Git tags prefixed with `v`.

- **MAJOR**: incompatible behavior, data, or platform changes.
- **MINOR**: backward-compatible features.
- **PATCH**: backward-compatible fixes, security updates, and documentation corrections shipped with the app.

Before a release:

1. Ensure the release milestone has no unresolved blockers.
2. Update `MARKETING_VERSION` to the semantic version and increment `CURRENT_PROJECT_VERSION` to a monotonically increasing integer.
3. Move `CHANGELOG.md` entries from `Unreleased` to a dated version section and refresh comparison links.
4. Run CI and a clean Archive build; smoke-test supported devices and data migration paths.
5. Verify privacy disclosures, screenshots, App Store metadata, and dependency licenses.
6. Merge the reviewed release pull request.
7. Create an annotated `vX.Y.Z` tag from the release commit and push it.
8. Create a GitHub Release from the changelog, clearly noting upgrade risks and known issues.
9. Submit the matching archive through App Store Connect.

Do not tag, publish a GitHub Release, or submit to App Store Connect from an unreviewed feature branch. GitHub Releases are the canonical release notes; the changelog remains the source-controlled record.
