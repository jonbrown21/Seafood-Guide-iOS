# Seafood Guide

This branch is the SwiftUI rewrite of Seafood Guide. It preserves the existing bundle identifier and curated content while replacing the UIKit, Core Data, storyboard, XIB, and third-party XML dependencies with a code-only SwiftUI app.

## Current scope

- Eight seafood categories with searchable species lists and detail views.
- Glossary, Top 10 educational content, and the three-section guide information area.
- Share and email actions from seafood details.
- Native SwiftUI loading experience with SF Symbols instead of launch-image screens or image-based UI icons.
- Editorial photos and educational XML content reused only as content resources.
- iOS 16.0 or later, with iPhone and iPad support.

Open `Seafood Guide.xcodeproj` in Xcode and build the `Seafood Guide` scheme. The bundle identifier remains `com.jonbrown.org.Seafood-Guide`.
