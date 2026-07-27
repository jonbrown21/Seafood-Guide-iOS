# Seafood Guide for iOS

[![iOS CI](https://github.com/jonbrown21/Seafood-Guide-iOS/actions/workflows/ci.yml/badge.svg)](https://github.com/jonbrown21/Seafood-Guide-iOS/actions/workflows/ci.yml)
[![Security: policy](https://img.shields.io/badge/security-policy-blue.svg)](SECURITY.md)
[![App Store](https://img.shields.io/badge/App_Store-download-0D96F6?logo=apple)](https://apps.apple.com/us/app/seafood-guide/id915176295)

Seafood Guide is a UIKit app for iPhone and iPad that helps people learn seafood terminology, species information, sustainability considerations, and sourcing practices. The project began as a learning app and remains a practical example of a storyboard-based iOS application using Swift, Core Data, XML data sources, and Swift Package Manager.

## Features

- Browse and search seafood species.
- Read sustainability and sourcing guidance.
- Learn common seafood and fishing terminology.
- Explore curated educational content without an account.
- Use the app without analytics or user tracking declared by the project.

## Requirements

- macOS with a current supported version of Xcode
- iOS 15.1 or later for the app target
- Git

The shared `Seafood Guide` scheme resolves these Swift packages automatically:

- [ProgressHUD](https://github.com/relatedcode/ProgressHUD)
- [SWXMLHash](https://github.com/drmohundro/SWXMLHash)

## Getting started

1. Clone the repository.
2. Open `Seafood Guide.xcworkspace` in Xcode.
3. Select the `Seafood Guide` scheme and an iOS simulator.
4. Build and run with <kbd>Command</kbd>+<kbd>R</kbd>.

For a command-line, signing-free validation build:

```sh
xcodebuild build \
  -workspace "Seafood Guide.xcworkspace" \
  -scheme "Seafood Guide" \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO
```

## Project status

The current app version is `7.5.2`. Maintenance focuses on correctness, compatibility, security, and incremental modernization. A SwiftUI migration is a possible future direction, but proposals should begin in [GitHub Discussions](https://github.com/jonbrown21/Seafood-Guide-iOS/discussions) before becoming implementation issues.

See the [changelog](CHANGELOG.md) for notable changes and [release guide](docs/RELEASING.md) for versioning policy.

## Contributing and support

Bug reports and focused improvements are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Use:

- [Issues](https://github.com/jonbrown21/Seafood-Guide-iOS/issues) for reproducible bugs and actionable work;
- [Discussions](https://github.com/jonbrown21/Seafood-Guide-iOS/discussions) for questions, ideas, and broad design proposals;
- [SECURITY.md](SECURITY.md) for private vulnerability reporting;
- [SUPPORT.md](SUPPORT.md) for usage help.

All participation is governed by the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

Copyright is retained by the project owner. The source, bundled content, and artwork are publicly viewable for learning and collaboration but are not offered under an open-source license. See [LICENSE](LICENSE) for details. Contributions are accepted under the same repository terms.

The compiled app is distributed through the [Apple App Store](https://apps.apple.com/us/app/seafood-guide/id915176295).
