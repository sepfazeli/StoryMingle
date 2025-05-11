//
//   StoryListViewModel.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07.
//

import Foundation
import Combine

class StoryListViewModel: ObservableObject {
    @Published var stories: [Story] = []
    init() { fetch() }
    func fetch() { FirestoreService.shared.fetchStories { [weak self] in self?.stories = $0 } }
}
