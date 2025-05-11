//
//  StoryDetailViewModel.swift
//  StoryMingle
//
//  Updated 2025-05-10 – Added paragraph continuation logic
//

import Foundation
import Combine

@MainActor
final class StoryDetailViewModel: ObservableObject {

    @Published var paragraphs: [Paragraph] = []
    @Published var likedIDs: Set<String> = []

    let story: Story
    var authVM: AuthViewModel! // injected by the view

    init(story: Story) {
        self.story = story
    }

    // ── Fetch all paragraphs
    func fetchParagraphs() {
        FirestoreService.shared.fetchParagraphs(for: story.id) { [weak self] arr in
            Task { @MainActor in
                self?.paragraphs = arr
            }
        }
    }

    // ── Upvote a paragraph
    func upvote(_ para: Paragraph) {
        guard
            let uid = AuthService.shared.currentUserID,
            likedIDs.contains(para.id) == false
        else { return }

        FirestoreService.shared.likeParagraph(
            storyID: story.id,
            paragraphID: para.id,
            userID: uid
        ) { [weak self] recorded in
            guard recorded, let self = self else { return }
            Task { @MainActor in
                if let idx = self.paragraphs.firstIndex(where: { $0.id == para.id }) {
                    self.paragraphs[idx].upvotes += 1
                }
                self.likedIDs.insert(para.id)
            }
        }
    }

    // ── Add new paragraph
    func addParagraph(text: String) {
        guard
            let uid = AuthService.shared.currentUserID,
            let user = authVM?.user
        else { return }

        let para = Paragraph(
            id: UUID().uuidString,
            storyID: story.id,
            authorID: uid,
            authorName: user.name,
            text: text,
            timestamp: Date(),
            upvotes: 0
        )

        FirestoreService.shared.addParagraph(para) { [weak self] _ in
            self?.fetchParagraphs()
        }
    }

    // ── Append text to last paragraph (for "Continue Previous")
    func appendToParagraph(id: String, text: String) {
        guard
            let index = paragraphs.firstIndex(where: { $0.id == id })
        else { return }

        var updated = paragraphs[index]
        updated.text += " " + text

        FirestoreService.shared.updateParagraphText(
            storyID: story.id,
            paragraphID: id,
            newText: updated.text
        ) { [weak self] success in
            if success {
                Task { @MainActor in
                    self?.paragraphs[index] = updated
                }
            }
        }
    }
}
