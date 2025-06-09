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
}
