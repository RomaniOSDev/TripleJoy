//
//  ContentView.swift
//  TripleJoy
//
//  Created by Роман Главацкий on 10.09.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        Group {
            if settingsViewModel.isOnboardingCompleted {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            // Initialize settings if needed
            _ = settingsViewModel
        }
        .preferredColorScheme(settingsViewModel.currentColorScheme == .system ? nil : (settingsViewModel.currentColorScheme == .light ? .light : .dark))
    }
}

#Preview {
    ContentView()
}
