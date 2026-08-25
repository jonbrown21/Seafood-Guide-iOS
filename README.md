# Seafood Guide

This branch is the SwiftUI rewrite of Seafood Guide. It preserves the existing bundle identifier while replacing the UIKit, Core Data, storyboard, XIB, and image-era interface with a SwiftUI app for modern iOS.

## Current scope

- Eight seafood categories with searchable, XML-backed species profiles.
- A sourced glossary, ten current aquaculture risks, and a three-section guide information area.
- Tappable citations to NOAA Fisheries, FDA, EPA, and USDA guidance.
- Generated promotional share cards from seafood details.
- Native SwiftUI loading experience with SF Symbols instead of launch-image screens or image-based UI icons.
- No photo assets or legacy graphic elements are used; visual language is built with SwiftUI shapes, gradients, and SF Symbols.
- Educational content is stored as text-only XML resources with structured source metadata.
- iOS 26.0 or later, with iPhone and iPad support.

Open `Seafood Guide.xcodeproj` in Xcode and build the `Seafood Guide` scheme. The bundle identifier remains `com.jonbrown.org.Seafood-Guide`.
