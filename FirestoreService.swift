//
//  FirestoreService.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07.
//  Updated 2025-05-10 – added paragraph text update for continuation support
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {
        // Enable offline persistence
        db.settings.isPersistenceEnabled = true
    }

    // MARK: – USERS

    func createUser(
        id: String,
        name: String,
        bio: String,
        avatarURL: String?,
        phone: String?,
        completion: @escaping (Error?) -> Void
    ) {
        let data: [String: Any] = [
            "name":       name,
            "bio":        bio,
            "avatarURL":  avatarURL ?? "",
            "phone":      phone ?? ""
        ]
        db.collection("users")
            .document(id)
            .setData(data, completion: completion)
    }

    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        guard let uid = AuthService.shared.currentUserID else {
            return completion(nil)
        }
        fetchUser(id: uid, completion: completion)
    }

    func fetchUser(
        id: String,
        completion: @escaping (User?) -> Void
    ) {
        db.collection("users")
            .document(id)
            .getDocument { snap, _ in
                guard let doc = snap, doc.exists, let d = doc.data() else {
                    return completion(nil)
                }

                let user = User(
                    id:        doc.documentID,
                    name:      d["name"] as? String ?? "",
                    bio:       d["bio"] as? String ?? "",
                    phone:     d["phone"] as? String,
                    avatarURL: (d["avatarURL"] as? String).flatMap { $0.isEmpty ? nil : $0 }
                )
                completion(user)
            }
    }

    func updateUser(
        id: String,
        name: String,
        bio: String,
        avatarURL: String?,
        phone: String?,
        completion: @escaping (Error?) -> Void
    ) {
        let data: [String: Any] = [
            "name":       name,
            "bio":        bio,
            "avatarURL":  avatarURL ?? "",
            "phone":      phone ?? ""
        ]
        db.collection("users")
            .document(id)
            .updateData(data, completion: completion)
    }


    // ────────────────────────────────
    // MARK: – STORIES
    // ────────────────────────────────

    func fetchStories(completion: @escaping ([Story]) -> Void) {
        db.collection("stories")
            .order(by: "timestamp", descending: true)
            .limit(to: 50)
            .addSnapshotListener { snap, _ in
                let list = snap?.documents.compactMap { doc -> Story? in
                    let d = doc.data()
                    return Story(
                        id: doc.documentID,
                        title: d["title"] as? String ?? "",
                        genre: d["genre"] as? String ?? "",
                        authorID: d["authorID"] as? String ?? "",
                        authorName: d["authorName"] as? String ?? "",
                        maxContributions: d["maxContributions"] as? Int ?? 0,
                        timestamp: (d["timestamp"] as? Timestamp)?.dateValue(),
                        mainText: d["mainText"] as? String ?? ""
                    )
                } ?? []
                completion(list)
            }
    }

    func createStory(
        _ story: Story,
        completion: @escaping (Error?) -> Void
    ) {
        let data: [String: Any] = [
            "title": story.title,
            "genre": story.genre,
            "authorID": story.authorID,
            "authorName": story.authorName,
            "maxContributions": story.maxContributions,
            "timestamp": FieldValue.serverTimestamp(),
            "mainText": story.mainText
        ]
        db.collection("stories")
            .addDocument(data: data, completion: completion)
    }

    // ────────────────────────────────
    // MARK: – PARAGRAPHS
    // ────────────────────────────────

    func fetchParagraphs(
        for storyID: String,
        completion: @escaping ([Paragraph]) -> Void
    ) {
        db.collection("stories")
            .document(storyID)
            .collection("paragraphs")
            .order(by: "timestamp")
            .addSnapshotListener { snap, _ in
                let list = snap?.documents.compactMap { doc -> Paragraph? in
                    let d = doc.data()
                    return Paragraph(
                        id: doc.documentID,
                        storyID: storyID,
                        authorID: d["authorID"] as? String ?? "",
                        authorName: d["authorName"] as? String ?? "",
                        text: d["text"] as? String ?? "",
                        timestamp: (d["timestamp"] as? Timestamp)?.dateValue(),
                        upvotes: d["upvotes"] as? Int ?? 0
                    )
                } ?? []
                completion(list)
            }
    }

    func addParagraph(
        _ para: Paragraph,
        completion: @escaping (Error?) -> Void
    ) {
        let data: [String: Any] = [
            "authorID": para.authorID,
            "authorName": para.authorName,
            "text": para.text,
            "timestamp": FieldValue.serverTimestamp(),
            "upvotes": para.upvotes
        ]
        db.collection("stories")
            .document(para.storyID)
            .collection("paragraphs")
            .addDocument(data: data, completion: completion)
    }

    /// Append text to an existing paragraph
    func updateParagraphText(
        storyID: String,
        paragraphID: String,
        newText: String,
        completion: @escaping (Bool) -> Void
    ) {
        let ref = db.collection("stories")
                    .document(storyID)
                    .collection("paragraphs")
                    .document(paragraphID)

        ref.updateData(["text": newText]) { error in
            completion(error == nil)
        }
    }

    func likeParagraph(
        storyID: String,
        paragraphID: String,
        userID: String,
        completion: @escaping (Bool) -> Void
    ) {
        let likeRef = db.collection("stories")
            .document(storyID)
            .collection("paragraphs")
            .document(paragraphID)
            .collection("likes")
            .document(userID)

        db.runTransaction({ txn, _ -> Any? in
            if (try? txn.getDocument(likeRef))?.exists == true {
                return false // duplicate like
            }
            txn.setData(["ts": FieldValue.serverTimestamp()], forDocument: likeRef)
            let paraRef = likeRef.parent.parent!
            txn.updateData(["upvotes": FieldValue.increment(Int64(1))], forDocument: paraRef)
            return true
        }) { value, _ in
            completion((value as? Bool) == true)
        }
    }
}
