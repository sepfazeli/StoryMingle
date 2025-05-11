//
//  AuthorDetailView.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07.
//

// AuthorDetailView.swift
// Shows a tapped paragraph's author details
import SwiftUI

struct AuthorDetailView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    let userID: String
    @State private var user: User?

    var body: some View {
        NavigationView {
            Group {
                if let u = user {
                    VStack(spacing: 16) {
                        if let urlS = u.avatarURL, let url = URL(string: urlS) {
                            AsyncImage(url: url) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                        }
                        Text(u.name).font(.title)
                        Text(u.bio).font(AppFonts.body)
                        Spacer()
                    }
                    .padding()
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Author")
            .navigationBarItems(trailing: Button("Done") {
                user = nil
            })
        }
        .onAppear {
            FirestoreService.shared.fetchUser(id: userID) { fetched in
                user = fetched
            }
        }
    }
}
