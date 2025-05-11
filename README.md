# 🚀 StoryMingle
**Collaborative Storytelling Platform**

![Platform](https://img.shields.io/badge/platform-iOS-blue.svg) ![SwiftUI](https://img.shields.io/badge/SwiftUI-Compatible-brightgreen.svg) ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg) ![Build Status](https://img.shields.io/github/actions/workflow/status/sepfazeli/StoryMingle/ci.yml?branch=main)

![StoryMingle Banner](./Assets/banner.png)

---

## 🔍 Overview
StoryMingle is a SwiftUI iOS application that enables real-time, multi-author storytelling. Users can start a story, add or continue paragraphs, and upvote contributions. Backend is powered by Firebase Auth, Firestore, App Check, and Cloud Messaging.

---

## 🛠 Tech Stack & Architecture
| Layer             | Technology                                     |
| ----------------- | ---------------------------------------------- |
| **UI**            | SwiftUI, UIKit (AppDelegate)                   |
| **State**         | Combine, @Published, @StateObject              |
| **Backend**       | Firebase Auth, Firestore, App Check, FCM       |
| **Security**      | SMS 2FA, Synthetic Email, App Check            |
| **Dependency**    | CocoaPods / SwiftPM                            |
| **CI/CD & Tests** | GitHub Actions, Fastlane, TestFlight, XCTest   |

**Architecture** follows MVVM with clear separation:
StoryMingle/
├ AppDelegate.swift # Firebase, APNs
├ StoryMingleApp.swift # @main, SwiftUI Scene
├ Models/ # User, Story, Paragraph, Reaction
├ Services/ # AuthService, FirestoreService, StorageService
├ ViewModels/ # ObservableObjects for each feature
├ Views/ # SwiftUI screens & reusable components
├ Resources/ # Assets, Plists, LaunchScreen
├ CI/ # Workflows & Fastlane configs
└ README.md # Project documentation


---

## 🔥 Features
- **Real-Time Collaboration**: Firestore snapshot listeners deliver live updates.
- **Secure Authentication**: Phone-based SMS 2FA with synthetic email addresses.
- **Story Management**: Create, edit, delete stories with configurable max contributions.
- **Collaborative Flow**:
  - Add new paragraphs or continue the previous one
  - Upvote to influence story direction
  - Tap any paragraph to reveal its author
- **Genre Browser**: Filter by Fantasy, Horror, Romance, Sci-Fi, Mystery, Thriller, Historical, Comedy, Adventure.
- **Profile & Stats**: Update bio, view stories & contributions count, guest mode, account deletion.

---

## 🚀 Quick Start
1. **Clone & Install**
   ```bash
   git clone https://github.com/sepfazeli/StoryMingle.git
   cd StoryMingle
Dependencies
CocoaPods:
pod install
open StoryMingle.xcworkspace
SwiftPM: Add Firebase packages via Xcode’s Swift Packages tab.
Firebase Setup
Copy GoogleService-Info.plist into the project root.
In Firebase Console:
Auth → enable Phone provider
Firestore → configure security rules
App Check → enable for device integrity
Cloud Messaging → configure APNs
Environment
Create a .env file (ignored by Git) for any secret toggles or flags.
Run
xcodebuild -scheme StoryMingle -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
or open in Xcode and press ▶️
✅ CI/CD & Testing

GitHub Actions: Lint, unit tests, UI tests on PRs.
Fastlane: Automate builds, screenshots, TestFlight deployments.
TestFlight: Internal & External beta groups with customized instructions.
Unit Tests: XCTest coverage for ViewModels & Services.
UI Tests: SwiftUI interaction and snapshot tests.
🤝 Contribute

Fork and clone this repo.
Create a branch: git checkout -b feat/YourFeature
Develop and test your changes.
Commit with semantic messages:
git commit -m "feat: add new paragraph feature"
Push and open a pull request targeting main.
