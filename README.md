# StoryMingle
Collaborative storytelling iOS app built with SwiftUI &amp; Firebase (SMS-2FA, real-time contributions)


An interactive iOS app that lets you co-write and share stories paragraph by paragraph. Built with SwiftUI and Firebase, StoryMingle features SMS-based two-factor authentication, real-time story flows, upvoting, genre browsing, and personal profile stats.



🚀 Features

Secure AuthenticationUsername + synthetic email + SMS two-factor via Firebase Auth

Create & Manage Stories• New story setup: title, genre, opening paragraph, max contributions• Edit or delete your own stories in My Stories

Collaborative Flow• Read “Full Story Flow” and tap a paragraph to reveal its author• Add a fresh paragraph or continue the previous one• Upvote contributions to influence story direction

Genre BrowserFilter stories by Fantasy, Horror, Romance, Sci-Fi, Mystery, Thriller, Historical, Comedy, Adventure

Profile & Stats• Edit your bio• View counts for stories created and contributions made• Guest mode and delete-account flow

📋 Requirements

Xcode 15+

iOS 16+ deployment target

CocoaPods or Swift Package Manager

A Firebase project with Auth, Firestore, App Check & FCM configured

🔧 Getting Started

Clone the repo

git clone https://github.com/sepfazeli/StoryMingle.git
cd StoryMingle

Install Dependencies

If using CocoaPods:

pod install
open StoryMingle.xcworkspace

If using Swift Package Manager, add the Firebase packages to the project.

Firebase Setup

Copy your GoogleService-Info.plist into the Xcode project’s root.

Enable Phone Auth, Firestore, App Check, Cloud Messaging in the Firebase console.

RunBuild and run on a simulator or device.

🛠 Project Structure

StoryMingle/
├─ AppDelegate.swift       # Firebase & APNs setup
├─ StoryMingleApp.swift    # SwiftUI App entry point
├─ Views/                  # All SwiftUI screens and components
├─ ViewModels/             # Combine-based state managers
├─ Services/               # AuthService, FirestoreService, StorageService
├─ Models/                 # User, Story, Paragraph, Genre
├─ Assets/                 # Images, Colors, Fonts
├─ Resources/              # Launch screens, Plists
├─ README.md               # Project documentation
└─ .gitignore              # Excludes build files & secrets

🤝 Contributing

Fork this repository

Create a feature branch (git checkout -b feat/YourFeature)

Commit your changes (git commit -m "Add feature")

Push to your branch (git push origin feat/YourFeature)

Open a Pull Request

Please open issues for bugs or feature requests!

📄 License

This project is licensed under the MIT License © 2025 Sepehr Fazely
