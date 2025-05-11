//
//  ProfileView.swift
//  StoryMingle
//
//  Redesigned on 2025-05-10 for a cleaner, interactive layout with modern visuals
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var bio = ""
    @State private var originalBio = ""
    @State private var phone = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showDeleteAlert = false
    @Namespace private var avatarNS

    @State private var storyCount = 0
    @State private var contributionCount = 0

    private var isGuest: Bool { !authVM.isSignedIn }

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // MARK: Avatar + Welcome
                        VStack(spacing: 12) {
                            avatarView

                            Text(authVM.user?.name ?? "Guest")
                                .font(.title.bold())
                                .foregroundColor(.blue)

                            if !isGuest {
                                Text(phone)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            if isGuest {
                                Button("Exit Guest") {
                                    authVM.signOut()
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .padding(.top, 4)
                            }
                        }
                        .padding(.top, 32)

                        // MARK: Stats Section
                        statSection

                        // MARK: Bio + Account
                        if !isGuest {
                            profileDetailsSection
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 60)
                    }
                    .padding(.bottom)
                }

                // MARK: Floating Action
                if !isGuest {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                showDeleteAlert = true
                            } label: {
                                Image(systemName: "trash")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.pink)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                authVM.fetchUser()
                let userBio = authVM.user?.bio ?? ""
                bio = userBio
                originalBio = userBio
                phone = authVM.user?.phone ?? ""
                loadStats()
            }
            .onReceive(authVM.$user) { user in
                bio = user?.bio ?? ""
                originalBio = user?.bio ?? ""
                phone = user?.phone ?? ""
            }
            .alert("Confirm Delete", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { performDeleteAccount() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
    }

    // MARK: Avatar Zone
    private var avatarView: some View {
        Group {
            if !isGuest,
               let urlStr = authVM.user?.avatarURL,
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable().scaledToFit()
                    .padding(20)
                    .foregroundColor(.white.opacity(0.7))
                    .background(Color.blue)
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
        .matchedGeometryEffect(id: "avatar", in: avatarNS)
    }

    // MARK: Stats View
    private var statSection: some View {
        HStack(spacing: 16) {
            statCard(count: storyCount, label: "Stories")
            statCard(count: contributionCount, label: "Contributions")
        }
        .padding(.horizontal)
    }

    private func statCard(count: Int, label: String) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title2.bold())
                .foregroundColor(.blue)
            Text(label)
                .font(.caption)
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.pink.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
        )
    }

    // MARK: Profile Info
    private var profileDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About You")
                .font(.headline)
                .foregroundColor(.blue)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "quote.bubble")
                    .foregroundColor(.pink)

                ZStack(alignment: .trailing) {
                    TextField("Short bio", text: $bio)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .padding(.trailing, 40)
                        .font(.body)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )

                    if bio != originalBio {
                        Button {
                            attemptSave()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                        .padding(.trailing, 8)
                    }
                }
            }

            if showError {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Divider().padding(.vertical, 4)

            Button("Log Out") {
                authVM.signOut()
            }
            .buttonStyle(ScaleButtonStyle())
            .foregroundColor(.blue)
        }
    }

    // MARK: Button Style
    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.pink.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        }
    }

    // MARK: Logic
    private func loadStats() {
        guard let uid = authVM.user?.id else { return }
        let db = Firestore.firestore()
        db.collection("stories").whereField("authorID", isEqualTo: uid)
            .getDocuments { snap, _ in storyCount = snap?.documents.count ?? 0 }
        db.collectionGroup("paragraphs").whereField("authorID", isEqualTo: uid)
            .getDocuments { snap, _ in contributionCount = snap?.documents.count ?? 0 }
    }

    private func attemptSave() {
        guard let uid = authVM.user?.id,
              let username = authVM.user?.name
        else { return }
        FirestoreService.shared.updateUser(
            id: uid,
            name: username,
            bio: bio,
            avatarURL: authVM.user?.avatarURL,
            phone: phone
        ) { err in
            if let err = err {
                errorMessage = "Save failed: \(err.localizedDescription)"
                showError = true
            } else {
                originalBio = bio
                authVM.fetchUser()
            }
        }
    }

    private func performDeleteAccount() {
        guard let uid = authVM.user?.id else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).delete { fsError in
            if let fsError = fsError {
                errorMessage = "Failed to delete profile: \(fsError.localizedDescription)"
                showError = true
                return
            }
            if let user = Auth.auth().currentUser {
                user.delete { authError in
                    if let authError = authError {
                        errorMessage = "Failed to delete account: \(authError.localizedDescription)"
                        showError = true
                    } else {
                        authVM.signOut()
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AuthViewModel())
    }
}
