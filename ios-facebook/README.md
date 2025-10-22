# Facebook iOS (SwiftUI) Skeleton

A SwiftUI app skeleton replicating Facebook tabs and Reels with an O, O, Ad, O pattern.

## Tabs
- Home
- Reels
- Marketplace
- Dating

## Tech
- SwiftUI
- iOS 17+ (uses materials for "liquid glass" look)

## Open/Run
1. Install Xcodegen: `brew install xcodegen`
2. From project root, run: `xcodegen generate`
3. Open `FacebookApp.xcodeproj` in Xcode and run on iOS 17+ simulator/device.

### Notes
- Requires macOS with Xcode 15+.
- Reels uses iOS 17 vertical paging via `ScrollView(.vertical)` with `.scrollTargetBehavior(.paging)`.

## Structure
- `App/` – app entry and app-wide UI
- `Features/Tabs/` – tab bar and tab shells
- `Features/Reels/` – reels models, view models, and vertical paging UI
- `Resources/Assets.xcassets/` – colors, images
