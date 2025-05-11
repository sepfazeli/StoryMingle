//
//  CreateStoryViewModel.swift
//  StoryMingle
//
//  Requires an injected AuthViewModel (so we don’t create a new one)
//

import Foundation
import Combine

@MainActor     // all methods & properties run on the main actor
final class CreateStoryViewModel: ObservableObject {
    
    // ── Published inputs
    @Published var title            = ""
    @Published var genre            = ""
    @Published var firstParagraph   = ""
    @Published var maxContributions = ""
    
    // ── Published outputs
    @Published var creationError: String?
    @Published var isCreating = false
    
    private let authVM: AuthViewModel
    
    // Inject the existing AuthViewModel from the view
    init(authVM: AuthViewModel) {
        self.authVM = authVM
    }
    
    /// Creates a new story (title + first paragraph) in Firestore.
    func create(completion: @escaping (Error?) -> Void) {
        
        // 1️⃣ Validate inputs
        guard
            let uid  = AuthService.shared.currentUserID,
            let user = authVM.user,
            !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !genre.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let max  = Int(maxContributions), max > 0,
            !firstParagraph.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            creationError = "Please fill all fields (title, genre, first paragraph, max contributions)."
            completion(nil)
            return
        }
        
        // 2️⃣ Build model
        let newStory = Story(
            id: UUID().uuidString,
            title: title,
            genre: genre,
            authorID: uid,
            authorName: user.name,
            maxContributions: max,
            timestamp: Date(),
            mainText: firstParagraph
        )
        
        // 3️⃣ Persist
        isCreating = true
        FirestoreService.shared.createStory(newStory) { [weak self] error in
            Task { @MainActor in
                self?.isCreating = false
                if let err = error {
                    self?.creationError = "Failed to create story: \(err.localizedDescription)"
                }
                completion(error)
            }
        }
    }
}
