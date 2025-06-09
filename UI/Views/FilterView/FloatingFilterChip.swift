//
//  FloatingFilterChip.swift
//  UI
//
//  Created by Krishna Venkatramani on 05/06/2025.
//

import Foundation
import UIKit

public class FloatingFilterChip<Filter: FloatingFilterType>: UIControl {
    
    private lazy var chipLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    private var borderLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        return shapeLayer
    }()
    
    private let chipFilter: Filter
    
    public init(filter: Filter) {
        self.chipFilter = filter
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: min(bounds.size.width, bounds.size.height)/2).cgPath
    }
    
    private func setupView() {
        
        layer.addSublayer(borderLayer)
        borderLayer.fillColor = UIColor.systemFill.cgColor
        borderLayer.strokeColor = UIColor.secondarySystemFill.cgColor
        
        chipLabel.text = chipFilter.title
        addSubview(chipLabel)
        chipLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chipLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            chipLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            trailingAnchor.constraint(equalTo: chipLabel.trailingAnchor, constant: 12),
            bottomAnchor.constraint(equalTo: chipLabel.bottomAnchor, constant: 8)
        ])
    }
    
    public override var isSelected: Bool {
        didSet {
            self.borderLayer.strokeColor = self.isSelected ? chipFilter.colorOnSelection.cgColor : UIColor.secondarySystemFill.cgColor
            self.borderLayer.fillColor = self.isSelected ? chipFilter.colorOnSelection.withAlphaComponent(0.25).cgColor : UIColor.systemFill.cgColor
            self.chipLabel.textColor = self.isSelected ? chipFilter.colorOnSelection : .label
        }
    }

    func onTap(_ callback: @escaping () -> Void) {
        let actionHandler: UIActionHandler = { _ in
            callback()
        }
        addAction(.init(handler: actionHandler), for: .touchUpInside)
    }
}


#Preview {
    let chip = FloatingFilterChip(filter: TestingFilters.option1)
    chip.onTap {
        chip.isSelected.toggle()
    }
    return chip
}
