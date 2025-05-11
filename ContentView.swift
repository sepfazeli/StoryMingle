//
//  ContentView.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    var body: some View {
        Group {
            if authVM.isSignedIn { MainTabView() }
            else { LoginView() }
        }
    }
}
