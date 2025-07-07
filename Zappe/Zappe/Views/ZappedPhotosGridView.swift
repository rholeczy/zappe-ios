//
//  ZappedPhotosGridView.swift
//  Zappe
//
//  Created by Romain Holeczy on 03/07/2025.
//


import SwiftUI
import Photos

struct ZappedPhotosGridView: View {
    let assets: [PHAsset]
    
    let columns = Array(repeating: GridItem(.fixed(40), spacing: 4), count: 8)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(assets, id: \.localIdentifier) { asset in
                    AssetThumbnailView(asset: asset)
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 8)
        }
    }
}
