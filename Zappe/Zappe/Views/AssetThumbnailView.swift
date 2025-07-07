//
//  AssetThumbnailView.swift
//  Zappe
//
//  Created by Romain Holeczy on 03/07/2025.
//

import SwiftUI
import Photos

/**
    A SwiftUI view that displays a thumbnail image for a given `PHAsset`.
 */
struct AssetThumbnailView: View {
    let asset: PHAsset
    
    @State private var thumbnail: UIImage? = nil
    
    var body: some View {
        Group {
            if let thumbnail = thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipped()
            } else {
                Color.gray.opacity(0.2)
                    .frame(width: 40, height: 40)
            }
        }
        .onAppear {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            
            options.isSynchronous = false
            options.deliveryMode = .fastFormat
            manager.requestImage(for: asset, targetSize: CGSize(width: 40, height: 40), contentMode: .aspectFill, options: options) { image, _ in
                self.thumbnail = image
            }
        }
    }
}

