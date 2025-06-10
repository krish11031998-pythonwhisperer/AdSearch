//
//  AdFetchViewModelType.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 10/06/2025.
//

import Foundation
import UIKit
import Combine
import Model

protocol AdFetchViewModelType: AnyObject {
    var selectedTab: PageFilter { get set }
    func fetchAds()
    func saveAd(id: String, adType: String, location: String?, price: Double?, title: String?, image: UIImage?) async -> Bool
    func deleteAd(id: String) async -> Bool
    var ads: AnyPublisher<AdResult, Never> { get }
}
