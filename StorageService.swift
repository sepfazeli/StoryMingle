//
//  StorageService.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07.
//

import Foundation
import FirebaseStorage

class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage().reference()
    private init() {}
    
    func uploadAvatar(userID: String, data: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = storage.child("avatars/\(userID).jpg")
        ref.putData(data, metadata: nil) { _, error in
            if let err = error { completion(.failure(err)); return }
            ref.downloadURL { url, err in
                if let e = err { completion(.failure(e)) }
                else if let url = url { completion(.success(url.absoluteString)) }
            }
        }
    }
}
