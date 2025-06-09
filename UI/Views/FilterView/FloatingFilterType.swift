//
//  FloatingFilterType.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 05/06/2025.
//

import Foundation
import UIKit

public protocol FloatingFilterType: CaseIterable, Hashable {
    var title: String { get }
    var colorOnSelection: UIColor { get }
}

public extension FloatingFilterType {
    var colorOnSelection: UIColor {
        .systemBlue
    }
}

