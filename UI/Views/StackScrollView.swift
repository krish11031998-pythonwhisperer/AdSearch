//
//  StackScrollView.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 05/06/2025.
//

import UIKit

public class StackScrollView: UIScrollView {
    
    private lazy var scrollView: UIScrollView = .init()
    private lazy var stackView: UIStackView = .init()
    private var stackCenterXConstraint: NSLayoutConstraint!
    private var stackCenterYConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func setupView() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        stackCenterXConstraint = stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        stackCenterYConstraint = stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        stackCenterXConstraint.isActive = true
        stackCenterYConstraint.isActive = false
    }
    
    
    // MARK: - Exposed
    
    public func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    
    public var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set {
            stackView.axis = newValue
            switch newValue {
            case .vertical:
                stackCenterXConstraint.isActive = true
                stackCenterYConstraint.isActive = false
            case .horizontal:
                stackCenterXConstraint.isActive = false
                stackCenterYConstraint.isActive = true
            @unknown default:
                fatalError("Unknown axis")
            }
        }
    }
    
    public var insets: NSDirectionalEdgeInsets {
        get {
            stackView.directionalLayoutMargins
        }
        
        set {
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.directionalLayoutMargins = newValue
        }
    }
}
