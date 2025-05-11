//
//  EditStoryView.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-10.
//  Updated 2025-05-14 – Fully restyled with inline white-card UI and custom inputs
//

import SwiftUI
import FirebaseFirestore

struct EditStoryView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    let story: Story

    @State private var title            : String
    @State private var selectedGenre    : Genre?
    @State private var maxContributions : String
    @State private var showError        = false
    @State private var errorMessage     = ""

    private let genres = Genre.allCases

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedGenre != nil &&
        Int(maxContributions) != nil
    }

    init(story: Story) {
        self.story = story
        _title            = State(initialValue: story.title)
        _selectedGenre    = State(initialValue: Genre(rawValue: story.genre))
        _maxContributions = State(initialValue: String(story.maxContributions))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        headerCard
                        inputCard(label: "Title") {
                            TextField("Enter story title", text: $title)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                        }

                        inputCard(label: "Genre") {
                            Picker(selection: $selectedGenre, label: Text(selectedGenre?.rawValue ?? "Select genre")) {
                                ForEach(genres) { genre in
                                    Text(genre.rawValue).tag(Optional(genre))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                        }

                        inputCard(label: "Max Contributions") {
                            TextField("e.g. 5", text: $maxContributions)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                        }

                        if showError {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button(action: save) {
                            Text("Save Changes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canSave ? Color.pink : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .disabled(!canSave)

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    // MARK: Components

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Edit Story")
                .font(.largeTitle.bold())
                .foregroundColor(.blue)
            Text("Make changes to your story settings below.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private func inputCard<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.headline)
                .foregroundColor(.blue)
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }

    // MARK: Actions

    private func save() {
        guard let genre = selectedGenre,
              let max   = Int(maxContributions)
        else {
            showError = true
            errorMessage = "Please fill all fields correctly."
            return
        }

        let data: [String: Any] = [
            "title":           title,
            "genre":           genre.rawValue,
            "maxContributions": max
        ]

        Firestore.firestore()
            .collection("stories")
            .document(story.id)
            .updateData(data) { error in
                if let error {
                    showError = true
                    errorMessage = "Update failed: \(error.localizedDescription)"
                } else {
                    dismiss()
                }
            }
    }
}

struct EditStoryView_Previews: PreviewProvider {
    static var previews: some View {
        EditStoryView(story: Story(
            id: "id",
            title: "Sample Story",
            genre: "Fantasy",
            authorID: "u1",
            authorName: "Alice",
            maxContributions: 5,
            timestamp: Date(),
            mainText: "Hello"
        ))
        .environmentObject(AuthViewModel())
    }
}
