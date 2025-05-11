//
//  CreateStoryView.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07
//  Updated 2025-05-14 – moved to standard nav bar for back button, removed custom close button
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateStoryView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var title = ""
    @State private var selectedGenre: Genre? = nil
    @State private var firstParagraph = ""
    @State private var maxContributions = 5
    @State private var showError = false
    @State private var animateButton = false
    @Namespace private var namespace

    private let genres = Genre.allCases
    private var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedGenre != nil &&
        !firstParagraph.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        maxContributions > 0
    }

    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                content
            }
            .navigationTitle("New Story")
            // Default back button is shown automatically
        }
    }

    // MARK: - Background
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Content Stack
    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                titleField
                genreSelection
                openingParagraphField
                maxContributionsField
                errorMessage
                createButton
            }
            .padding(.vertical)
        }
    }

    // MARK: - Title Field
    private var titleField: some View {
        InputCard(icon: "textformat", title: "Story Title") {
            TextField("Enter your story title...", text: $title)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 8)
        }
        .matchedGeometryEffect(id: "titleCard", in: namespace)
    }

    // MARK: - Improved Genre Selection
    private var genreSelection: some View {
        InputCard(icon: "tag", title: "Genre") {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100), spacing: 8)],
                spacing: 8
            ) {
                ForEach(genres, id: \.self) { genre in
                    Text(genre.rawValue)
                        .font(.subheadline).bold()
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(genre == selectedGenre ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(genre == selectedGenre ? Color.accentColor : Color.gray.opacity(0.2), lineWidth: genre == selectedGenre ? 2 : 1)
                        )
                        .foregroundColor(genre == selectedGenre ? .accentColor : .primary)
                        .onTapGesture {
                            withAnimation(.spring()) { selectedGenre = genre }
                        }
                }
            }
            .padding(.vertical, 4)
        }
        .matchedGeometryEffect(id: "genreCard", in: namespace)
    }

    // MARK: - Opening Paragraph Field
    private var openingParagraphField: some View {
        InputCard(icon: "doc.text", title: "Opening Paragraph") {
            TextEditor(text: $firstParagraph)
                .frame(height: 140)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - Max Contributions Field
    private var maxContributionsField: some View {
        InputCard(icon: "person.3.sequence", title: "Max Contributions") {
            Stepper("\(maxContributions)", value: $maxContributions, in: 1...20)
                .padding(.vertical, 8)
        }
    }

    // MARK: - Error Message
    private var errorMessage: some View {
        Group {
            if showError {
                Text("Please fill all fields correctly.")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 8)
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Create Button
    private var createButton: some View {
        Button(action: createStory) {
            Text("Create Story")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    Group {
                        if canSubmit {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.gray.opacity(0.5)
                        }
                    }
                )
                .cornerRadius(12)
                .scaleEffect(animateButton && canSubmit ? 1.05 : 1.0)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .disabled(!canSubmit)
        .padding(.horizontal)
        .padding(.top, 16)
        .onChange(of: canSubmit) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    animateButton = true
                }
            } else {
                animateButton = false
            }
        }
    }

    // MARK: - Actions
    private func createStory() {
        guard let uid = AuthService.shared.currentUserID,
              let user = authVM.user,
              let genre = selectedGenre else {
            withAnimation { showError = true }
            return
        }
        let story = Story(
            id: UUID().uuidString,
            title: title,
            genre: genre.rawValue,
            authorID: uid,
            authorName: user.name,
            maxContributions: maxContributions,
            timestamp: Date(),
            mainText: firstParagraph
        )
        FirestoreService.shared.createStory(story) { error in
            if let e = error {
                print("Failed to create story: \(e.localizedDescription)")
                return
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - InputCard Component
private struct InputCard<Content: View>: View {
    let icon: String
    let title: String
    let content: () -> Content

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                content()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct CreateStoryView_Previews: PreviewProvider {
    static var previews: some View {
        CreateStoryView()
            .environmentObject(AuthViewModel())
    }
}
