//
//  GenreListView.swift
//  StoryMingle
//
//  Updated 2025-05-11 – revamped with white card-style list & interactive shadows
//
import SwiftUI

struct GenreListView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    private let genres = Genre.allCases

    var body: some View {
        NavigationView {
            ZStack {
                // White canvas
                Color.white
                    .ignoresSafeArea()

                if genres.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tag")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.accent)
                        Text("No Genres Found")
                            .font(AppFonts.title)
                            .foregroundColor(AppColors.primary)
                        Text("Add or explore stories to see genres.")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.subtleText)
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(genres, id: \.self) { genre in
                                NavigationLink(
                                    destination: StoriesByGenreView(genre: genre)
                                        .environmentObject(authVM)
                                ) {
                                    HStack {
                                        Text(genre.rawValue)
                                            .font(AppFonts.headline)
                                            .foregroundColor(AppColors.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right.circle.fill")
                                            .foregroundColor(AppColors.accent)
                                            .font(.title3)
                                            .scaleEffect(1.2)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
                                    )
                                    .scaleEffect(1.0)
                                    .onHover { hovering in
                                        // hover effect for macOS
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("Genres")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StoriesByGenreView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    let genre: Genre
    @StateObject private var vm = StoryListViewModel()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if vm.stories.filter({ $0.genre == genre.rawValue }).isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.accent)
                    Text("No " + genre.rawValue + " Stories")
                        .font(AppFonts.title)
                        .foregroundColor(AppColors.primary)
                    Text("Be the first to contribute!")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.subtleText)
                }
                .multilineTextAlignment(.center)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(vm.stories.filter { $0.genre == genre.rawValue }) { story in
                            NavigationLink(
                                destination: StoryDetailView(story: story)
                                    .environmentObject(authVM)
                            ) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(story.title)
                                            .font(AppFonts.headline)
                                            .foregroundColor(AppColors.primary)
                                        Text(story.authorName)
                                            .font(AppFonts.caption)
                                            .foregroundColor(AppColors.subtleText)
                                    }
                                    Spacer()
                                    Image(systemName: "book.fill")
                                        .foregroundColor(AppColors.accent)
                                        .font(.headline)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .navigationTitle(genre.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.fetch() }
    }
}

struct GenreListView_Previews: PreviewProvider {
    static var previews: some View {
        GenreListView()
            .environmentObject(AuthViewModel())
    }
}
