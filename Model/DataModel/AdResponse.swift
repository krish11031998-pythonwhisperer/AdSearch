//
//  AdResponse.swift
//  Model
//
//  Created by Krishna Venkatramani on 04/06/2025.
//

import Foundation

public struct AdResponse: Decodable {
    public let isPersonal: Bool
    public let hasConsent: Bool
    public let items: [Ad]
    public let uuid: String
    
    public init(isPersonal: Bool, hasConsent: Bool, items: [Ad], uuid: String) {
        self.isPersonal = isPersonal
        self.hasConsent = hasConsent
        self.items = items
        self.uuid = uuid
    }
    
    public static let empty: AdResponse = .init(isPersonal: false, hasConsent: false, items: [], uuid: "")
}
