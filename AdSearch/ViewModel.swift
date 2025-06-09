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
    private var savedAdIds: [String] = []
    @Published var selectedTab: PageFilter = .all
    
    struct Output {
        #warning("Use another transient model")
        let ads: AnyPublisher<AdResult, Never>
    }
    
    func transform() -> Output {
        
        let savedAds = CoreDataManager.shared.changeInContextPublisher
            .prepend(())
            .flatMap { [unowned self] _ in
                let savedAds: [SavedAd]? = CoreDataManager.shared.fetch()
                self.savedAdIds = savedAds?.compactMap(\.id) ?? []
                return Just(savedAds ?? []).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        let fetchedAds: AnyPublisher<[Ad], Never> = $fetchedAds
            .drop(while: { $0.isEmpty })
            .eraseToAnyPublisher()
        
        let ads: AnyPublisher<AdResult, Never> = $selectedTab
            .combineLatest(savedAds)
            .flatMap { (filter, savedAds) -> AnyPublisher<AdResult, Never> in
                switch filter {
                case .all:
                    return fetchedAds
                        .removeDuplicates()
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
    
    func saveAd(_ ad: AdModel, image: UIImage) async -> Bool {
        let imageURL: URL?
        switch await ImageFileManager.shared.addImage(image: image, name: ad.id) {
        case .success(let url):
            imageURL = url
        case .failure:
            imageURL = nil
        }
        
        let wasSucessfullySaved = SavedAd.create(id: ad.id,
                              adType: ad.adType,
                              location: ad.location,
                              price: ad.price,
                              title: ad.title,
                              imageString: imageURL?.path())
        return wasSucessfullySaved
    }
    
    
    func deleteAd(_ ad: AdModel) async -> Bool {
        let wasDeleted = SavedAd.delete(adId: ad.id)
        return wasDeleted
    }
    
}
