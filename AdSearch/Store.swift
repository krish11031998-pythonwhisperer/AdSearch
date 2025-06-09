//
//  Store.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 05/06/2025.
//

import Foundation
import Combine
import Model

class Store {
    
    @Published private(set) var savedAds: [SavedAd] = []
    private var subscribers: Set<AnyCancellable> = .init()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        CoreDataManager.shared.changeInContextPublisher
            .prepend(())
            .flatMap { _ in
                let savedAds: [SavedAd]? = CoreDataManager.shared.fetch()
                return Just(savedAds ?? []).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] savedAds in
                print("(DEBUG) savedAds: ", savedAds)
                self?.savedAds = savedAds
            }
            .store(in: &subscribers)
    }
    
}
