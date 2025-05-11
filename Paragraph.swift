//
//  Paragraph.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07.
//

import Foundation

struct Paragraph: Identifiable {
    var id: String
    var storyID: String
    var authorID: String
    var authorName: String
    var text: String
    var timestamp: Date?
    var upvotes: Int
}
