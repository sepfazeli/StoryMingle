//
//  Genre.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-10.
//


import Foundation

enum Genre: String, CaseIterable, Identifiable {
    case fantasy        = "Fantasy"
    case scienceFiction = "Science Fiction"
    case romance        = "Romance"
    case mystery        = "Mystery"
    case horror         = "Horror"
    case thriller       = "Thriller"
    case historical     = "Historical"
    case comedy         = "Comedy"
    case adventure      = "Adventure"

    var id: String { rawValue }
}
