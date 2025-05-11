🚀 StoryMingle

Collaborative Storytelling Platform

[] [] [] []

🔍 Overview

StoryMingle is an iOS application enabling real-time, multi-author storytelling. Contributors can start, continue, and upvote paragraphs within a shared narrative, leveraging SwiftUI, Combine, and Firebase (Auth, Firestore, Messaging, App Check).

✨ Key Highlights

Real-Time Collaboration: Live updates via Firestore snapshot listeners.

Secure Authentication: Phone-based SMS 2FA with synthetic email namespace.

Interactive UI: SwiftUI-driven components with animations and tap-to-reveal author metadata.

Modular Architecture: MVVM pattern, clear separation of Views, ViewModels, Services, Models.

Analytics & Logging: Crash reporting and usage metrics via Firebase Analytics.

🛠️ Tech Stack

Category

Technology

UI & UX

SwiftUI, UIKit (AppDelegate)

State Management

Combine, @Published, @StateObject

Backend

Firebase Auth, Firestore, Cloud Messaging (FCM)

Security

Firebase App Check, SMS Multi-Factor Auth

Dependency Mgmt

CocoaPods / Swift Package Manager

CI/CD

GitHub Actions, Fastlane, TestFlight

🔧 Setup & Installation

Clone the repository

git clone https://github.com/sepfazeli/StoryMingle.git
cd StoryMingle

Install dependencies

CocoaPods:

pod install
open StoryMingle.xcworkspace

SwiftPM: Add Firebase SDKs in Project Settings → Swift Packages

Configure Firebase

Copy your GoogleService-Info.plist into the project root.

In Firebase Console, enable:

Authentication → Phone Provider

Firestore → Set rules for real-time access

App Check → Device integrity checks

Cloud Messaging → APNs & FCM integration

Environment Variables
Create an .env file (ignored by Git) to override any sensitive configs.

Build & Run

Select iOS 16.0+ simulator or device

Hit Run in Xcode

📂 Project Architecture

StoryMingle
├── AppDelegate.swift       # UIKit integration, Firebase init, APNs
├── StoryMingleApp.swift    # @main entry, SwiftUI Scene
├── Models/                 # Codable structs: User, Story, Paragraph, Reaction
├── Services/               # Firebase wrappers: AuthService, FirestoreService, StorageService
├── ViewModels/             # ObservableObjects: AuthViewModel, StoryListViewModel, etc.
├── Views/                  # SwiftUI screens & reusable components
│   ├── Auth/               # Login, SignUp, SMSCode View
│   ├── Home/               # StoryListView, GenreListView, ProfileView
│   └── StoryDetail/        # StoryDetailView, Create/Edit Story
├── Resources/              # Assets, LaunchScreen, Info.plist
├── CI/                     # GitHub Actions workflows, Fastlane config
└── README.md               # Project documentation

🚦 CI/CD & Testing

GitHub Actions: Automated linting, unit tests, UI tests on each PR.

Fastlane: Builds, exports, and uploads to TestFlight.

TestFlight: Internal & external beta distribution with customized test instructions.

Unit Tests: XCTest for ViewModels and Services.

UI Tests: SwiftUI snapshots and interaction flows.

🤝 Contributing

Fork the repo

Create a feature branch: git checkout -b feat/YourFeature

Implement and test your changes

Commit with clear messages: git commit -m "feat: Add ..."

Push and open a PR against main

Please follow the Code of Conduct and check existing issues before submitting.

📄 License

This project is licensed under the MIT License © 2025 Sepehr Fazely

