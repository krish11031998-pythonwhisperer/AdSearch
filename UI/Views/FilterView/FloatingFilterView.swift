//
//  FloatingFilterView.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 05/06/2025.
//

import UIKit

internal enum TestingFilters: CaseIterable, FloatingFilterType {
    case option1
    case option2
    case option3
    
    var title: String {
        switch self {
        case .option1:
            return "Option 1"
        case .option2:
            return "Option 2"
        case .option3:
            return "Option 3"
        }
    }
    
    var colorOnSelection: UIColor {
        switch self {
        case .option1:
            return .systemBlue
        case .option2:
            return .systemOrange
        case .option3:
            return .systemGreen
        }
    }
}

public class FloatingFilterView<Filter: FloatingFilterType>: UICollectionReusableView {
    
    private lazy var scrollView: StackScrollView = {
        let scrollView = StackScrollView()
        scrollView.axis = .horizontal
        scrollView.spacing = 8
        return scrollView
    }()
    
    private var allFilters: Set<Filter> = .init()
    private var selectedFilterChip: FloatingFilterChip<Filter>?
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
        scrollView.insets = .init(top: 8, leading: 1, bottom: 8, trailing: 1)
        scrollView.backgroundColor = .systemBackground
        
    }
    
    public var insets: NSDirectionalEdgeInsets {
        get { scrollView.insets }
        set { scrollView.insets = newValue }
    }
    
    public func configure(filters: [Filter], selectedFilter: Filter, onSelectingFilter: @escaping (Filter) -> Void) {
        let newFilters = allFilters.isEmpty ? Set(filters) : allFilters.subtracting(filters)
        guard !newFilters.isEmpty else { return }
        newFilters.sorted(by: {$0.title < $1.title}).forEach { filter in
            allFilters.insert(filter)
            let chip = FloatingFilterChip(filter: filter)
            scrollView.addArrangedSubview(chip)
            chip.onTap { [weak self] in
                guard let self else { return }
                self.updateSelectedChip(chip)
                onSelectingFilter(filter)
            }
            
            if selectedFilter == filter {
                updateSelectedChip(chip)
            }
        }
    }
    
    private func updateSelectedChip(_ chip: FloatingFilterChip<Filter>) {
        
        if let selectedFilterChip = self.selectedFilterChip {
            selectedFilterChip.isSelected = false
        }
        
        chip.isSelected = true
        self.selectedFilterChip = chip
    }
}

#Preview {
    let filter = FloatingFilterView<TestingFilters>()
    filter.configure(filters: TestingFilters.allCases, selectedFilter: .option1) { filter in
        print("(DEBUG) tapped on filter: ", filter.title)
    }
    return filter
}


