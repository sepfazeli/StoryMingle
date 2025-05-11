//
//  MainTabView.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07.
//
// MainTabView.swift

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            StoryListView()
                .tabItem { Label("Stories", systemImage: "book") }

            GenreListView()
                .tabItem { Label("Genres", systemImage: "tag") }

            MyStoriesView()
                .tabItem { Label("My Stories", systemImage: "person.crop.rectangle") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
        }
        .accentColor(AppColors.accent)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
}
