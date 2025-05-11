//
//  MyStoriesView.swift
//  StoryMingle
//
//  Updated 2025-05-11 – revamped with white card-style list, swipe actions & interactive shadows
//
import SwiftUI
import FirebaseFirestore

struct MyStoriesView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var vm = StoryListViewModel()
    @State private var editingStory: Story? = nil

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                if userStories.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "text.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.accent)
                        Text("No Stories Yet")
                            .font(AppFonts.title)
                            .foregroundColor(AppColors.primary)
                        Text("Tap + to write your first story!")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.subtleText)
                    }
                    .multilineTextAlignment(.center)
                    .padding()
                } else {
                    List {
                        ForEach(userStories) { story in
                            NavigationLink(destination:
                                StoryDetailView(story: story)
                                    .environmentObject(authVM)
                            ) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(story.title)
                                            .font(AppFonts.headline)
                                            .foregroundColor(AppColors.primary)
                                        Text(story.genre)
                                            .font(AppFonts.caption)
                                            .foregroundColor(AppColors.subtleText)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right.circle.fill")
                                        .foregroundColor(AppColors.accent)
                                        .font(.title3)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    delete(story)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    editingStory = story
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(AppColors.secondary)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("My Stories")
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
            .sheet(item: $editingStory) { story in
                EditStoryView(story: story)
                    .environmentObject(authVM)
            }
            .onAppear { vm.fetch() }
        }
    }

    private var userStories: [Story] {
        vm.stories.filter { $0.authorID == authVM.user?.id }
    }

    private func delete(_ story: Story) {
        Firestore.firestore()
            .collection("stories")
            .document(story.id)
            .delete { error in
                if let error {
                    print("Delete error: \(error.localizedDescription)")
                } else {
                    vm.fetch()
                }
            }
    }
}

struct MyStoriesView_Previews: PreviewProvider {
    static var previews: some View {
        MyStoriesView()
            .environmentObject(AuthViewModel())
    }
}
