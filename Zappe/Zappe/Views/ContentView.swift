//
//  ContentView.swift
//  Zappe
//
//  Created by Romain Holeczy on 02/07/2025.
//
import SwiftUI
import Photos
import Foundation

struct ContentView: View {
    private let checkmarkSymbol = "✅"
    private let currentMonthLabel = LocalizedStringKey("ContentView_CurrentMonthLabel")
    private let photoCountLabel = "photos"
    
    private let zappedMonthsKey = "ZappedMonths"
    
    private var currentMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale.current
        return formatter.string(from: Date())
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var monthsWithPhotos: [String] = []
    @State private var monthPhotoCounts: [String: Int] = [:]
    @State private var selectedMonths: Set<String> = []
    @State private var selectedMonth: String? = nil
    @State private var zappedMonths: Set<String> = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZappeHeaderContainer {
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(monthsWithPhotos, id: \.self) { month in
                            let isCurrentMonth = month == currentMonthString
                            NavigationLink(value: MonthType(name: month)) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        isCurrentMonth ? Color.gray :
                                            (zappedMonths.contains(month) ? Color.green : Color.blue)
                                    )
                                    .aspectRatio(1, contentMode: .fit)
                                    .overlay(
                                        VStack(spacing: 2) {
                                            Spacer(minLength: 0)
                                            if isCurrentMonth {
                                                Text(self.currentMonthLabel)
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.7))
                                                    .padding(.bottom, 2)
                                            }
                                            let count = monthPhotoCounts[month] ?? 0
                                            Text("\(count) \(self.photoCountLabel)")
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.7))
                                                .padding(.bottom, 2)
                                            Text(month.capitalized)
                                                .foregroundColor(isCurrentMonth ? .black : .white)
                                                .multilineTextAlignment(.center)
                                            if zappedMonths.contains(month) && !isCurrentMonth {
                                                Text(self.checkmarkSymbol)
                                                    .font(.title2)
                                                    .padding(.top, 2)
                                            }
                                            Spacer(minLength: 0)
                                        }
                                    )
                            }
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                fetchMonthsWithPhotos()
                loadZappedMonths()
            }
            .navigationDestination(for: MonthType.self) { monthType in
                MonthDetailView(month: monthType.name, onZapped: {
                    if monthType.name != currentMonthString {
                        zappedMonths.insert(monthType.name)
                        saveZappedMonths()
                    }
                })
            }
        }
    }
    
    /**
        Toggles the selection state of a month.
        If the month is already selected, it will be deselected, and vice versa.
     */
    func fetchMonthsWithPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }
            let fetchOptions = PHFetchOptions()
            let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            var monthsSet = Set<String>()
            var counts: [String: Int] = [:]
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            formatter.locale = Locale.current
            assets.enumerateObjects { asset, _, _ in
                if let date = asset.creationDate {
                    let month = formatter.string(from: date)
                    monthsSet.insert(month)
                    counts[month, default: 0] += 1
                }
            }
            let sortedMonths = Array(monthsSet).sorted {
                guard let date1 = formatter.date(from: $0),
                      let date2 = formatter.date(from: $1) else { return false }
                return date1 > date2
            }
            DispatchQueue.main.async {
                self.monthsWithPhotos = sortedMonths
                self.monthPhotoCounts = counts
            }
        }
    }
    
    /**
        Saves the zapped months to UserDefaults.
     */
    func saveZappedMonths() {
        let array = Array(zappedMonths)
        UserDefaults.standard.set(array, forKey: self.zappedMonthsKey)
    }
    
    /**
        Loads the zapped months from UserDefaults.
     */
    func loadZappedMonths() {
        if let array = UserDefaults.standard.array(forKey: self.zappedMonthsKey) as? [String] {
            zappedMonths = Set(array)
        }
    }
}
