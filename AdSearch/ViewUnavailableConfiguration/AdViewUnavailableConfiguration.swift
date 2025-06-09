//
//  AdViewUnavailableConfiguration.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 05/06/2025.
//

import Foundation
import UIKit

enum AdViewUnavailableConfiguration {
    case loading
    case notLoading
    case noSavedAds
}

extension UIConfigurationStateCustomKey {
    static let adViewUnavailableConfiguration: UIConfigurationStateCustomKey = .init("adViewUnavailableConfiguration")
}


extension UIConfigurationState {
    
    var adViewUnavailableConfiguration: AdViewUnavailableConfiguration? {
        get {
            self[UIConfigurationStateCustomKey.adViewUnavailableConfiguration] as? AdViewUnavailableConfiguration
        } set {
            self[UIConfigurationStateCustomKey.adViewUnavailableConfiguration] = newValue
        }
    }
    
}
