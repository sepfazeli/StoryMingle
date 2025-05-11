//
//  StoryListView.swift
//  StoryMingle
//
//  Updated 2025-05-11 – revamped with white card-style list & interactive shadows
//
import SwiftUI

struct StoryListView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var vm = StoryListViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Crisp white background
                Color.white
                    .ignoresSafeArea()

                if vm.stories.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.accent)
                        Text("No Stories Yet")
                            .font(AppFonts.title)
                            .foregroundColor(AppColors.primary)
                        Text("Tap + to create the first one!")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.subtleText)
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                } else {
                    // Scrollable card list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(vm.stories) { story in
                                NavigationLink(destination: StoryDetailView(story: story)
                                                .environmentObject(authVM)) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(story.title)
                                                .font(AppFonts.headline)
                                                .foregroundColor(AppColors.primary)
                                            Text(story.genre)
                                                .font(AppFonts.caption)
                                                .foregroundColor(AppColors.subtleText)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
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
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("Stories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination:
                                    CreateStoryView()
                                        .environmentObject(authVM)
                    ) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.accent)
                    }
                }
            }
            .onAppear { vm.fetch() }
        }
    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListView()
            .environmentObject(AuthViewModel())
    }
}
