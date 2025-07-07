//
//  ZappeHeaderContainer.swift
//  Zappe
//
//  Created by Romain Holeczy on 06/07/2025.
//

import SwiftUI

struct ZappeHeaderContainer<Content: View>: View {
    private let zappeTitle = LocalizedStringKey("AppTitle")
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image("zappeIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text(zappeTitle)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(
                Color(.systemBackground)
                    .opacity(0.95)
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
            )
            content
        }
    }
}
