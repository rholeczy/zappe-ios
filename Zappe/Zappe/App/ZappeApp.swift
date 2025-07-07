//
//  ZappeApp.swift
//  Zappe
//
//  Created by Romain Holeczy on 02/07/2025.
//

import SwiftUI

@main
struct ZappeApp: App {
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                LoadingView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isLoading = false
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}
