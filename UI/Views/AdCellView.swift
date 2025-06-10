//
//  AdCellView.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 04/06/2025.
//

import SwiftUI
import ImageManager

public struct AdCellView: View {
    
    public struct Model: Hashable {
        public let id: String
        public let adType: String
        public let photoURL: RemoteImage.Photo
        public let price: Double?
        public let location: String?
        public let title: String?
        public let isSaved: Bool
        
        public init(id: String, adType: String, photoURL: RemoteImage.Photo, price: Double?, location: String?, title: String?, isSaved: Bool) {
            self.id = id
            self.adType = adType
            self.photoURL = photoURL
            self.price = price
            self.location = location
            self.title = title
            self.isSaved = isSaved
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(adType)
            hasher.combine(price)
            hasher.combine(location)
            hasher.combine(title)
            hasher.combine(isSaved)
        }
        
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id && lhs.adType == rhs.adType && lhs.price == rhs.price && lhs.location == rhs.location && lhs.title == rhs.title && lhs.isSaved == rhs.isSaved
        }
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var didSaveLink: Bool
    @State private var size: CGSize = .zero
    @State private var disableSaveButton: Bool = false
    private let model: Model
    private let saveLinkTask: (UIImage?) async -> Bool
    private let deletedSavedLink: () async  -> Bool
    
    public init(model: Model, saveLinkTask: @escaping (UIImage?) async -> Bool, deletedSavedLink: @escaping () async -> Bool) {
        self.model = model
        self._didSaveLink = .init(initialValue: model.isSaved)
        self.saveLinkTask = saveLinkTask
        self.deletedSavedLink = deletedSavedLink
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RemoteImage(photoURL: imageURLPath)
                .frame(width: size.width, height: size.height * 0.5, alignment: .center)
                .overlay(alignment: .topTrailing) {
                    saveButton
                        .disabled(disableSaveButton)
                        .padding(.top, 8)
                        .padding(.horizontal, 8)
                }
                .clipShape(UnevenRoundedRectangle(cornerRadii: .init(topLeading: 22, bottomLeading: 8, bottomTrailing: 8, topTrailing: 22)))
            
            VStack(alignment: .leading, spacing: 8) {
                adTypeView
                
                Text(adTitle)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(adLocation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(priceFormattedString)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            .padding(.init(top: 8, leading: 8, bottom: 12, trailing: 8))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onGeometryChange(for: CGSize.self, of: { $0.size }) { newValue in
            self.size = newValue
        }
        .padding(.all, 4)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .tertiarySystemFill))
        }
        
    }
    
    
    // MARK: - Helpers
    
    private var imageURLPath: RemoteImage.Photo {
        guard case .remote(let urlPath) = model.photoURL else {
            return model.photoURL
        }
        return .remote("\(RemoteImageManager.adURLBasePath)\(urlPath)")
    }
    
    private var adTitle: String {
        model.title ?? "No Title"
    }
    
    private var adLocation: String {
        model.location ?? "No Location"
    }
    
    private var priceFormattedString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "SEK"
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.locale = .current
        
        if let price = model.price {
            return numberFormatter.string(from: price as NSNumber) ?? "\(price)"
        } else {
            return "No Price Info"
        }
    }
    
    
    // MARK: - ViewBuilders
    
    private var adTypeView: some View {
        Text(model.adType)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
            .background(.fill, in: .capsule)
    }
    
    private var saveButton: some View {
        Button(action: favoriteButtonTapAction) {
            Group {
                if didSaveLink {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(Color.red)
                } else {
                    Image(systemName: "bookmark")
                        .foregroundStyle(Color.red)
                }
            }
            .animation(.snappy, value: didSaveLink)
            .font(.headline)
            .frame(width: 44, height: 44, alignment: .center)
            .background(.fill.secondary, in: .circle)
        }
    }
    
    
    // MARK: - Button Action
    
    private func imageOfAd() async -> UIImage? {
        let imageResult: Result<UIImage, Error>
        switch model.photoURL {
        case .remote(let string):
            imageResult = await RemoteImageManager.shared.fetchImageWithoutRequest(urlString: "\(RemoteImageManager.adURLBasePath)\(string)")
        case .local(let string):
            imageResult = await ImageFileManager.shared.retrieveImage(name: string)
        case .none:
            return nil
        }
        
        switch imageResult {
        case .success(let image):
            return image
        case .failure:
            return nil
        }
    }
    
    private func favoriteButtonTapAction() {
        Task {
            await updateButtonDisability(true)
            if didSaveLink {
                await updateDidSaveLink(false)
                let wasSuccessfullyDeleted =  await deletedSavedLink()
                if !wasSuccessfullyDeleted {
                    await updateDidSaveLink(true)
                }
                await updateButtonDisability(false)
            } else {
                await updateDidSaveLink(true)
                
                guard case .remote = imageURLPath else {
                    await updateDidSaveLink(false)
                    await updateButtonDisability(false)
                    return
                }
                
                let image = await imageOfAd()
                let wasSaved = await saveLinkTask(image)
                if !wasSaved {
                    await updateDidSaveLink(false)
                }
                
                await updateButtonDisability(false)
            }
        }
    }
    
    @MainActor
    private func updateButtonDisability(_ isDisabled: Bool) async {
        self.disableSaveButton = isDisabled
    }
    
    @MainActor
    private func updateDidSaveLink(_ wasSaved: Bool) async {
       self.didSaveLink = wasSaved
    }
}

#Preview {
    
    let saveFn: (UIImage?) async -> Bool =  { _ in
        try? await Task.sleep(for: .milliseconds(12500))
        return false
    }
    
    let deletedSavedLink: () async -> Bool = {
        try? await Task.sleep(for: .milliseconds(12500))
        return false
    }
    
    AdCellView(model: .init(id: UUID().uuidString, adType: "AD", photoURL: .remote("https://images.finncdn.no/dynamic/480x360c/2019/8/vertical-2/04/l/nul/l_1451344711.jpg"),
                            price: 6500000,
                            location: "Stavanger",
                            title: "Attraktiv, gjennomgående selveierleilighet i Straen Terrasse. Alt på ett plan. Heis. Garasje. Sørvendt altan.", isSaved: false), saveLinkTask: saveFn, deletedSavedLink: deletedSavedLink)
    .frame(height: 300)
    .padding(.horizontal, 12)
}
