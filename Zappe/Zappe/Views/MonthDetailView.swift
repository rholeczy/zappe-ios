import SwiftUI
import Photos
import Network

struct MonthDetailView: View {
    let month: String
    var onZapped: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    
    private let buttonOKLabel = LocalizedStringKey("buttonOKLabel")
    private let buttonBackLabel = LocalizedStringKey("MonthDetailView_ButtonBackLabel")
    private let buttonCancelLabel = LocalizedStringKey("MonthDetailView_ButtonCancelLabel")
    private let keepButtonLabel = LocalizedStringKey("MonthDetailView_KeepButtonLabel")
    private let loadingLabel = LocalizedStringKey("MonthDetailView_LoadingLabel")
    private let offlineModeMessage = LocalizedStringKey("MonthDetailView_OfflineModeMessage")
    private let offlineModeTitle = LocalizedStringKey("MonthDetailView_OfflineModeTitle")
    private let zappeActionLabel = LocalizedStringKey("MonthDetailView_ZappeActionLabel")
    private let zappeButtonTitle = LocalizedStringKey("MonthDetailView_ZappeButtonTitle")
    private let zappedPhotosMessage = LocalizedStringKey("MonthDetailView_ZappedPhotosMessage")
    
    private let backButtonImage = "chevron.left"
    private let cancelZappeButtonImage = "arrow.uturn.left.circle.fill"
    private let creationDateKey = "creationDate"
    private let networkMonitor = "NetworkMonitor"
    
    @State private var assets: [PHAsset] = []
    @State private var currentIndex: Int = 0
    @State private var currentImage: UIImage? = nil
    @State private var zappedPhotos: [PHAsset] = []
    @State private var keepPhotos: [PHAsset] = []
    @State private var isLoading: Bool = true
    @State private var isDeleting: Bool = false
    @State private var showOfflineAlert: Bool = false
    @State private var isOffline: Bool = false
    
    var isSummaryScreen: Bool {
        !isLoading && (currentIndex >= assets.count)
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack {
                if isLoading {
                    ProgressView(self.loadingLabel)
                        .font(.headline)
                        .padding()
                } else if currentIndex < assets.count, let image = currentImage {
                    VStack(spacing: 16) {
                        Text(month.capitalized)
                            .font(.title.bold())
                            .padding(.top, 8)
                        Text("\(currentIndex + 1)/\(assets.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 350, maxHeight: 350)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(radius: 8)
                        Spacer()
                        HStack(spacing: 24) {
                            Button(action: {
                                zappedPhotos.append(assets[currentIndex])
                                showNextImage()
                            }) {
                                Text(self.zappeButtonTitle)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 100, maxWidth: 120, minHeight: 35)
                                    .minimumScaleFactor(0.7)
                                    .lineLimit(1)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                            }
                            .disabled(isLoading)
                            
                            Button(action: {
                                undoLastAction()
                            }) {
                                Image(systemName: self.cancelZappeButtonImage)
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.yellow)
                                    .shadow(radius: 2)
                            }
                            .opacity(currentIndex > 0 ? 1 : 0)
                            .disabled(currentIndex == 0 || isLoading)
                            
                            Button(action: {
                                keepPhotos.append(assets[currentIndex])
                                showNextImage()
                            }) {
                                Text(self.keepButtonLabel)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 100, maxWidth: 120, minHeight: 35)
                                    .minimumScaleFactor(0.7)
                                    .lineLimit(1)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [.green, .mint]), startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                            }
                            .disabled(isLoading)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 24) {
                        Text("\(self.zappedPhotosMessage) (\(zappedPhotos.count))")
                            .font(.title2.bold())
                            .foregroundColor(.red)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(zappedPhotos, id: \.localIdentifier) { asset in
                                    AssetThumbnailView(asset: asset)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .shadow(radius: 2)
                                }
                            }
                            .padding(.horizontal)
                        }
                        Button(action: zapPhotos) {
                            if isDeleting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 24, height: 24)
                            } else {
                                Text(self.zappeActionLabel)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 32)
                                    .background(
                                        LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .leading, endPoint: .trailing)
                                    )
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                            }
                        }
                        .disabled(zappedPhotos.isEmpty || isDeleting || isLoading)
                        HStack(spacing: 20) {
                            Button(action: { dismiss() }) {
                                Label(self.buttonBackLabel, systemImage: self.backButtonImage)
                                    .font(.body)
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            if !zappedPhotos.isEmpty || !keepPhotos.isEmpty {
                                Button {
                                    undoLastAction()
                                } label: {
                                    Label(self.buttonCancelLabel,
                                          systemImage: self.cancelZappeButtonImage)
                                    .foregroundColor(.yellow)
                                    .font(.body)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground).opacity(0.95))
                            .shadow(radius: 8)
                    )
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: self.backButtonImage)
                        .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            checkNetwork()
            fetchAllAssetsForMonth()
        }
        .onChange(of: isSummaryScreen) {
            if isSummaryScreen && zappedPhotos.isEmpty {
                onZapped?()
                dismiss()
            }
        }
        .alert(isPresented: $showOfflineAlert) {
            Alert(
                title: Text(self.offlineModeTitle),
                message: Text(self.offlineModeMessage),
                dismissButton: .default(Text(self.buttonOKLabel))
            )
        }
    }
    
    /**
        Fetches all assets for the specified month.
        Uses `PHAsset.fetchAssets` with a predicate to filter by creation date.
        Sorts the assets by creation date.
        Updates the `assets` state with the fetched assets and resets the current index.
        Sets `isLoading` to false once the fetch is complete.
     */
    func fetchAllAssetsForMonth() {
        isLoading = true
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        guard let monthDate = formatter.date(from: month) else { isLoading = false; return }
        
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)) else { isLoading = false; return }
        var comps = DateComponents()
        comps.month = 1
        comps.day = -1
        guard let endOfMonth = calendar.date(byAdding: comps, to: startOfMonth) else { isLoading = false; return }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(
            format: "mediaType == %d AND creationDate >= %@ AND creationDate <= %@",
            PHAssetMediaType.image.rawValue,
            startOfMonth as NSDate,
            endOfMonth as NSDate
        )
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: self.creationDateKey, ascending: true)]
        
        let fetchedAssets = PHAsset.fetchAssets(with: fetchOptions)
        var loadedAssets: [PHAsset] = []
        fetchedAssets.enumerateObjects { asset, _, _ in
            loadedAssets.append(asset)
        }
        
        self.assets = loadedAssets
        self.currentIndex = 0
        self.isLoading = false
        loadCurrentImage()
    }
    
    
    /**
        Loads the current image based on the current index.
        If the index is out of bounds, it sets `currentImage` to nil.
        Uses `PHImageManager` to request the image for the asset at the current index.
        Updates `isLoading` state during the image loading process.
     */
    func loadCurrentImage() {
        guard currentIndex < assets.count else {
            currentImage = nil
            return
        }
        
        let asset = assets[currentIndex]
        let manager = PHImageManager.default()
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = !isOffline
        options.deliveryMode = .opportunistic
        options.isSynchronous = false
        
        options.progressHandler = { progress, error, _, _ in
            DispatchQueue.main.async { self.isLoading = true }
        }
        
        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 600, height: 600),
            contentMode: .aspectFit,
            options: options
        ) { image, info in
            DispatchQueue.main.async {
                self.isLoading = false
                if let img = image {
                    self.currentImage = img
                } else {
                    self.showNextImage()
                }
            }
        }
    }
    
    
    /**
        Advances to the next image in the assets array.
        If the current index exceeds the number of assets, it does nothing.
        If successful, loads the next image.
        If there are no more images, it will not change the current image.
     */
    func showNextImage() {
        currentIndex += 1
        loadCurrentImage()
    }
    
    
    /**
        Deletes all zapped photos from the photo library.
        If successful, clears the `zappedPhotos` array and calls `onZapped` closure.
        If there are no zapped photos, does nothing.
     */
    func zapPhotos() {
        guard !zappedPhotos.isEmpty else { return }
        isDeleting = true
        let assetIdentifiers = zappedPhotos.map { $0.localIdentifier }
        let assetsToDelete = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete)
        }) { success, error in
            DispatchQueue.main.async {
                self.isDeleting = false
                if success {
                    self.zappedPhotos.removeAll()
                    onZapped?()
                    dismiss()
                }
            }
        }
    }
    
    
    /**
        Undoes the last action performed by the user.
        If the last action was zapping a photo, it will be removed from `zappedPhotos`.
        If the last action was keeping a photo, it will be removed from `keepPhotos`.
        If there are no actions to undo, nothing happens.
     */
    func undoLastAction() {
        if currentIndex > 0 {
            currentIndex -= 1
            if !zappedPhotos.isEmpty, zappedPhotos.last == assets[currentIndex] {
                zappedPhotos.removeLast()
            } else if !keepPhotos.isEmpty, keepPhotos.last == assets[currentIndex] {
                keepPhotos.removeLast()
            }
            loadCurrentImage()
        }
    }
    
    
    /**
        Checks the network status and updates the `isOffline` state.
        If offline, shows an alert to the user.
     */
    func checkNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isOffline = path.status != .satisfied
                if self.isOffline {
                    self.showOfflineAlert = true
                }
            }
        }
        let queue = DispatchQueue(label: self.networkMonitor)
        monitor.start(queue: queue)
    }
}
