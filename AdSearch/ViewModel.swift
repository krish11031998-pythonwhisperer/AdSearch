//
//  ViewModel.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 04/06/2025.
//

import Combine
import Model
import UI
import UIKit

class ViewModel: ObservableObject {
    
    typealias AdModel = AdCellView.Model
    
    enum AdResult {
        case fetchAds([(Ad, Bool)])
        case savedAds([SavedAd])
    }
    
    private var fetchAdTask: Task<Void, Never>?
    @Published private var fetchedAds: [Ad] = []
    @Published var selectedTab: PageFilter = .all
    private let store: Store
    
    init(store: Store) {
        self.store = store
    }
    
    struct Output {
        #warning("Use another transient model")
        let ads: AnyPublisher<AdResult, Never>
    }
    
    func transform() -> Output {
        
        let ads: AnyPublisher<AdResult, Never> = $selectedTab
            .combineLatest(store.$savedAds)
            .print("(DEBUG) selectedTab: ")
            .flatMap { [unowned self] (filter, savedAds) -> AnyPublisher<AdResult, Never> in
                switch filter {
                case .all:
                    return $fetchedAds
                        .map { ads in
                            var adAndSavedStatus: [(Ad, Bool)] = []
                            for ad in ads {
                                adAndSavedStatus.append((ad, savedAds.contains(where: { $0.id == ad.id })))
                            }
                            return .fetchAds(adAndSavedStatus)
                        }
                        .eraseToAnyPublisher()
                case .saved:
                    return Just(savedAds)
                        .map { .savedAds($0) }
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
        
        return .init(ads: ads)
    }
    
    
    // MARK: - Exposed Methods
    
    func fetchAds() {
        guard fetchAdTask == nil else {
            return
        }
        
        fetchAdTask = Task(priority: .userInitiated) {
            guard let adResponse: AdResponse = try? await NetworkManager.fetchData(urlString: "https://gist.githubusercontent.com/baldermork/6a1bcc8f429dcdb8f9196e917e5138bd/raw/discover.json") else {
                return
            }
            await MainActor.run {
                self.fetchedAds = adResponse.items
            }
        }
    }
    
    func saveAd(_ ad: AdModel) async -> Bool {
        let imageURL: URL?
//        if case .remote(let photoURLString) = ad.photoURL {
//            let image = await ImageManager.shared.fetchImage(urlString: "\(ImageManager.adURLBasePath)\(photoURLString)")
//            switch await ImageFileManager.shared.addImage(image: image, name: photoURLString) {
//            case .success(let url):
//                imageURL = url
//            case .failure:
//                imageURL = nil
//            }
//        } else {
            imageURL = nil
//        }
        
        return SavedAd.create(id: ad.id,
                              adType: ad.adType,
                              location: ad.location,
                              price: ad.price,
                              title: ad.title,
                              imageString: imageURL?.lastPathComponent)
    }
}
