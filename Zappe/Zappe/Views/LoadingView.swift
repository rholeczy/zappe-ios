//
//  LoadingView.swift
//  Zappe
//
//  Created by Romain Holeczy on 03/07/2025.
//

import SwiftUI

/**
    A view that displays a loading indicator with a label.
 */
struct LoadingView: View {
    private let loadingLabel = LocalizedStringKey("LoadingView_LoadingLabel")
    var body: some View {
        VStack {
            Image("zappeIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(.bottom, 20)
            ProgressView()
            Text(self.loadingLabel)
                .font(.headline)
                .padding(.top, 20)
        }
    }
}
