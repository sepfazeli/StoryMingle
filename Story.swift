// Story.swift
// StoryMingle
//
// Created by Sepehr Fazely on 2025-05-07.
//

import Foundation

struct Story: Identifiable {
    var id: String
    var title: String
    var genre: String
    var authorID: String
    var authorName: String
    var maxContributions: Int
    var timestamp: Date?
    var mainText: String   // ← new
}
