//
//  User.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07.
//  Updated 2025-05-12 – added phone property
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    let name: String               // immutable username from backend
    var bio: String                // editable profile bio
    var phone: String?             // E.164 phone for verification & 2FA
    var avatarURL: String?         // optional remote avatar image URL
}
