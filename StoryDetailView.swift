//
//  StoryDetailView.swift
//  StoryMingle
//
//  Updated 2025-05-14 – multi-author reveals + tip added
//

import SwiftUI

struct StoryDetailView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    let story: Story
    @StateObject private var vm: StoryDetailViewModel

    @State private var newText = ""
    @State private var showError = false
    @State private var continuePrevious = false
    @State private var revealedIDs: Set<String> = []
    @State private var paragraphAuthors: [String: [String]] = [:]
    @Namespace private var namespace

    init(story: Story) {
        self.story = story
        _vm = StateObject(wrappedValue: StoryDetailViewModel(story: story))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerCard
                flowCard
                composerCard
                contributionsSection
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground).ignoresSafeArea())
        .navigationTitle(story.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.authVM = authVM
            vm.fetchParagraphs()
        }
        .onReceive(vm.$paragraphs) { paras in
            // Initialize authors list for each paragraph
            for p in paras {
                if paragraphAuthors[p.id] == nil {
                    paragraphAuthors[p.id] = [p.authorName]
                }
            }
        }
    }

    // MARK: Header

    private var headerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.blue)
                Text(story.genre)
                    .font(.subheadline)
                    .foregroundColor(.pink)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    // MARK: Full Story Flow

    private var flowCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Full Story Flow")
                .font(.headline)
                .foregroundColor(.blue)

            Text("Tap a paragraph to reveal its author(s).")
                .font(.caption2).italic()
                .foregroundColor(.gray)
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 12) {
                storyBlock(text: story.mainText,
                           id: "main")

                ForEach(vm.paragraphs) { para in
                    storyBlock(text: para.text,
                               id: para.id)
                        .onTapGesture {
                            withAnimation {
                                if revealedIDs.contains(para.id) {
                                    revealedIDs.remove(para.id)
                                } else {
                                    revealedIDs.insert(para.id)
                                }
                            }
                        }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }

    private func storyBlock(text: String, id: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(.body)
                .foregroundColor(.primary)

            if revealedIDs.contains(id),
               let names = paragraphAuthors[id] {
                Text("— " + names.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .transition(.opacity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 2)
    }

    // MARK: Composer

    private var composerCard: some View {
        VStack(spacing: 16) {
            Text("Add Your Paragraph")
                .font(.headline)
                .foregroundColor(.blue)

            Toggle("Continue Previous Paragraph", isOn: $continuePrevious)
                .toggleStyle(SwitchToggleStyle(tint: .blue))

            if showError {
                Text("Cannot add: empty or max reached.")
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity)
            }

            TextEditor(text: $newText)
                .frame(height: 100)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Button(action: addParagraph) {
                Text("Submit")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private func addParagraph() {
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty && vm.paragraphs.count < story.maxContributions else {
            withAnimation { showError = true }
            return
        }

        if continuePrevious, let last = vm.paragraphs.last {
            vm.appendToParagraph(id: last.id, text: trimmed)
            // Track the new contributor
            let author = authVM.user?.name ?? "Unknown"
            paragraphAuthors[last.id]?.append(author)
        } else {
            vm.addParagraph(text: trimmed)
        }

        // reset composer
        newText = ""
        showError = false
        continuePrevious = false
    }

    // MARK: Contributions

    private var contributionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contributions")
                .font(.headline)
                .foregroundColor(.blue)

            ForEach(vm.paragraphs) { para in
                ContributionCard(paragraph: para,
                                 liked: vm.likedIDs.contains(para.id)) {
                    vm.upvote(para)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

private struct ContributionCard: View {
    let paragraph: Paragraph
    let liked: Bool
    let action: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(paragraph.text)
                    .font(.body)
                    .foregroundColor(.primary)
                Text("— \(paragraph.authorName)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(spacing: 4) {
                Button(action: action) {
                    Image(systemName: liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .font(.title3)
                        .foregroundColor(liked ? .gray : .pink)
                }
                .buttonStyle(.borderless)

                Text("\(paragraph.upvotes)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
}

struct StoryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sample = Story(
            id: "1",
            title: "Sample Story",
            genre: "Fantasy",
            authorID: "u1",
            authorName: "Alice",
            maxContributions: 3,
            timestamp: Date(),
            mainText: "Once upon a time..."
        )
        NavigationView {
            StoryDetailView(story: sample)
                .environmentObject(AuthViewModel())
        }
    }
}
