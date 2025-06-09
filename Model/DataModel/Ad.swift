//
//  Ad.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 04/06/2025.
//

import Foundation

public enum AdType: String, Decodable {
    case realEstate = "REALESTATE"
    case bap = "BAP"
    case car = "CAR"
    case b2b = "B2B"
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        
        if let adType = AdType(rawValue: stringValue) {
            self = adType
        } else {
            fatalError("Unsupported ad type: \(stringValue)")
        }
    }
    
    public var description: String {
        switch self {
        case .realEstate:
            return "Real Estate"
        case .bap:
            return "BAP"
        case .car:
            return "Car"
        case .b2b:
            return "B2B"
        }
    }
}

public struct Ad: Hashable, Decodable {
    public let description: String?
    public let id: String
    public let urlPath: String?
    public let adType: AdType
    public let location: String?
    #warning("Maybe make this an enum ?")
    public let type: String?
    public let price: AdPrice?
    public let image: AdImage?
    public let score: Double?
    public let categories: AdCategory?
    public let favorite: AdFavorite?
    public let shippingOptions: AdShippingOptions?
    
    
    enum CodingKeys: String, CodingKey {
        case description
        case id
        case urlPath
        case adType = "ad-type"
        case location
        case type
        case price
        case image
        case score
        case categories
        case favorite
        case shippingOptions
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.id = try container.decode(String.self, forKey: .id)
        self.urlPath = try container.decodeIfPresent(String.self, forKey: .urlPath)
        self.adType = try container.decode(AdType.self, forKey: .adType)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.price = try container.decodeIfPresent(AdPrice.self, forKey: .price)
        self.image = try container.decodeIfPresent(AdImage.self, forKey: .image)
        self.score = try container.decodeIfPresent(Double.self, forKey: .score)
        self.categories = try container.decodeIfPresent(AdCategory.self, forKey: .categories)
        self.favorite = try container.decodeIfPresent(AdFavorite.self, forKey: .favorite)
        self.shippingOptions = try container.decodeIfPresent(AdShippingOptions.self, forKey: .shippingOptions)
    }
    
}

public struct AdPrice: Hashable, Codable {
    public let value: Double?
    public let total: Double?
}

public struct AdImage: Hashable, Codable {
    public let url: String
    public let height: Int
    public let width: Int
    #warning("make an enum")
    public let type: String?
    public let scalable: Bool?
}

public struct AdFavorite: Hashable, Codable {
    public let itemId: String?
    #warning("make an enum")
    public let itemType: String?
}

public struct AdCategory: Hashable, Codable {
    public let mainCategory: String?
    public let subCategory: String?
    public let prodCategory: String?
}

public struct AdShippingOptions: Hashable, Codable {
    public let label: String?
}
