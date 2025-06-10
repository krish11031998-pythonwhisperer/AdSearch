//
//  AdFetchViewModel.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 04/06/2025.
//

import Combine
import Model
import UI
import UIKit
import ImageManager

class AdFetchViewModel: AdFetchViewModelType {
    
    typealias AdModel = AdCellView.Model
    
    private var fetchAdTask: Task<Void, Never>?
    @Published private var fetchedAds: [Ad] = []
    private var savedAdIds: [String] = []
    @Published var selectedTab: PageFilter = .all
    
    var ads: AnyPublisher<AdResult, Never> {
        let savedAds = CoreDataManager.shared.changeInContextPublisher
            .prepend(())
            .flatMap { [unowned self] _ in
                let savedAds: [SavedAd]? = CoreDataManager.shared.fetch()
                self.savedAdIds = savedAds?.compactMap(\.id) ?? []
                return Just(savedAds ?? []).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        let fetchedAds: AnyPublisher<[Ad], Never> = $fetchedAds
//            .drop(while: { $0.isEmpty })
            .eraseToAnyPublisher()
        
        return $selectedTab
            .combineLatest(savedAds)
            .flatMap { (filter, savedAds) -> AnyPublisher<AdResult, Never> in
                switch filter {
                case .all:
                    return fetchedAds
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
    }
    
    
    // MARK: - Exposed Methods
    
    func fetchAds() {
        guard fetchAdTask == nil else {
            return
        }
        
        fetchAdTask = Task(priority: .userInitiated) {
            let adResponse: AdResponse
            do {
                adResponse = try await NetworkManager.fetchData(urlString: "https://gist.githubusercontent.com/baldermork/6a1bcc8f429dcdb8f9196e917e5138bd/raw/discover.json")
            } catch {
                print("(ERROR) error: ", error.localizedDescription)
                adResponse = .empty
            }

            await MainActor.run {
                self.fetchedAds = adResponse.items
            }
        }
    }
    
    func saveAd(id: String, adType: String, location: String?, price: Double?, title: String?, image: UIImage?) async -> Bool {
        if let image {
            await ImageFileManager.shared.addImage(image: image, name: id)
        }
        
        let wasSucessfullySaved = SavedAd.create(id: id,
                                                 adType: adType,
                                                 location: location,
                                                 price: price,
                                                 title: title)
        return wasSucessfullySaved
    }
    
    
    func deleteAd(id: String) async -> Bool {
        let wasDeleted = SavedAd.delete(adId: id)
        await ImageFileManager.shared.removeImage(name: id)
        return wasDeleted
    }
    
}
