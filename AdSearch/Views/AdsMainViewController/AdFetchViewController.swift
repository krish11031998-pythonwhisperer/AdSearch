//
//  ViewController.swift
//  AdSearch
//
//  Created by Krishna Venkatramani on 04/06/2025.
//

import UIKit
import SwiftUI
import Model
import UI
import Combine

enum AdResult {
    case fetchAds([(Ad, Bool)])
    case savedAds([SavedAd])
}

enum PageFilter: FloatingFilterType {
    case all
    case saved
    
    var title: String {
        switch self {
        case .all:
            return "All"
        case .saved:
            return "Saved"
        }
    }
    
    var colorOnSelection: UIColor {
        switch self {
        case .all:
            return .systemBlue
        case .saved:
            return .systemOrange
        }
    }
}

extension AdCellView.Model {
    init(ad: Ad, isSaved: Bool) {
        let remoteImagePhoto: RemoteImage.Photo
        if let urlString = ad.image?.url {
            remoteImagePhoto = .remote(urlString)
        } else {
            remoteImagePhoto = .none
        }
        
        self.init(id: ad.id,
                  adType: ad.adType.rawValue,
                  photoURL: remoteImagePhoto,
                  price: ad.price?.value,
                  location: ad.location,
                  title: ad.description,
                  isSaved: isSaved)
    }
}

class AdFetchViewController: UIViewController, UICollectionViewDelegate {

    enum Section: Int, Hashable {
        case ads = 0
    }
    
    enum Item: Hashable {
        case ad(AdCellView.Model)
    }
    
    typealias Datasource = UICollectionViewDiffableDataSource<Section, Item>
    typealias  Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private var datasource: Datasource!
    
    private lazy var collectionView: UICollectionView = .init(frame: .init(), collectionViewLayout: .init())
    private lazy var filterView: FloatingFilterView<PageFilter> = .init()
    private var filterTopHeaderConstraint: NSLayoutConstraint!
    private let viewModel: any AdFetchViewModelType
    private var subscribers: Set<AnyCancellable> = .init()
    private var viewUnavailableContentConfiguration: AdViewUnavailableConfiguration? = nil {
        didSet {
            if oldValue != viewUnavailableContentConfiguration {
                setNeedsUpdateContentUnavailableConfiguration()
            }
        }
    }
    
    init(viewModel: any AdFetchViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        
        navigationItem.title = "Ads"
        navigationController?.navigationBar.prefersLargeTitles = true
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        
        setupCollectionView()
        setupFilterView()
        setupDataSource()
        setupCollectionViewLayout()
        bind()
        
        viewModel.fetchAds()
        viewUnavailableContentConfiguration = .loading
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset.top = filterView.bounds.maxY
    }
    
    
    // MARK: - Setup CollectionView
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
        collectionView.delegate = self
    }
    
    
    // MARK: - Setup FilterView
    
    private func setupFilterView() {
        view.addSubview(filterView)
        filterView.configure(filters: PageFilter.allCases, selectedFilter: .all) { [weak self] filter in
            self?.viewModel.selectedTab = filter
        }
        filterView.insets = .init(top: 8, leading: 20, bottom: 8, trailing: 20)
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterTopHeaderConstraint = filterView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        
        NSLayoutConstraint.activate([
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterTopHeaderConstraint!,
            view.trailingAnchor.constraint(equalTo: filterView.trailingAnchor)
        ])
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let adResult: AnyPublisher<AdResult, Never> = viewModel.ads
        
        adResult
            .dropFirst(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (adResult: AdResult) in
                guard let self else { return }
                switch adResult  {
                case .fetchAds(let ads):
                    self.reloadDataWithFetchedAds(ads: ads)
                case .savedAds(let savedAds):
                    self.reloadDataWithSavedAds(savedAds: savedAds)
                }
            }
            .store(in: &subscribers)
    }
    
    
    // MARK: - Setup Datasource
    
    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, AdCellView.Model> { cell, indexPath, model in
            cell.configurationUpdateHandler = { cell, cellState in
                cell.contentConfiguration = UIHostingConfiguration {
                    AdCellView(model: model) { [unowned self] image in
                        await self.viewModel.saveAd(id: model.id, adType: model.adType, location: model.location, price: model.price, title: model.title, image: image)
                    } deletedSavedLink: { [unowned self] in
                        await self.viewModel.deleteAd(id: model.id)
                    }
                }.margins(.all, .zero)
            }
        }
        
        datasource = Datasource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .ad(let model):
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: model)
            }
        }
    }
    
    
    // MARK: - CollectionView Layout
    
    private func setupCollectionViewLayout() {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.75)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.75)), subitems: [item])
        group.interItemSpacing = .fixed(10)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 16, leading: 20, bottom: 16, trailing: 20)
        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout(section: section), animated: false)
    }
    
    
    // MARK: - Reload Data
    
    private func reloadDataWithFetchedAds(ads: [(Ad, Bool)]) {
        guard !ads.isEmpty else {
            reloadCollectionViewWithEmptyData(unavailableContentConfiguration: .noAds)
            return
        }
        viewUnavailableContentConfiguration = .none
        let adCellViewsModels: [AdCellView.Model] = ads.map { AdCellView.Model(ad: $0.0, isSaved: $0.1) }
        reloadData(ads: adCellViewsModels)
    }
    
    private func reloadDataWithSavedAds(savedAds: [SavedAd]) {
        guard !savedAds.isEmpty else {
            reloadCollectionViewWithEmptyData(unavailableContentConfiguration: .noSavedAds)
            return
        }
        viewUnavailableContentConfiguration = .none
        
        
        let adCellViewModels: [AdCellView.Model] = savedAds.map {
            let remoteImagePhoto: RemoteImage.Photo = .local($0.id)
            return .init(id: $0.id, adType: $0.adType.rawValue, photoURL: remoteImagePhoto, price: $0.price, location: $0.location, title: $0.title, isSaved: true)
        }
        reloadData(ads: adCellViewModels)
    }
    
    private func reloadData(ads: [AdCellView.Model]) {
        guard !ads.isEmpty else { return }
        var snapshot = Snapshot()
        snapshot.appendSections([.ads])
        let items: [Item] = ads.map{ .ad($0) }
        
        snapshot.appendItems(items, toSection: .ads)
        if datasource.snapshot().numberOfItems == 0 {
            datasource.applySnapshotUsingReloadData(snapshot)
        } else {
            datasource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func reloadCollectionViewWithEmptyData(unavailableContentConfiguration: AdViewUnavailableConfiguration) {
        var snapshot = datasource.snapshot()
        snapshot.deleteItems(snapshot.itemIdentifiers)
        datasource.apply(snapshot, animatingDifferences: true) { [weak self] in
            self?.viewUnavailableContentConfiguration = unavailableContentConfiguration
        }
    }


    // MARK: - UICollectionView Deleagate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.adjustedContentInset.top + scrollView.contentOffset.y <= 0 else { return }
        let deltaY = abs(scrollView.contentOffset.y) - scrollView.adjustedContentInset.top
        filterTopHeaderConstraint?.constant = deltaY
    }
    
    // MARK: - UIContentStateConfiguration
    
    override var contentUnavailableConfigurationState: UIContentUnavailableConfigurationState {
        var state = super.contentUnavailableConfigurationState
        state.adViewUnavailableConfiguration = viewUnavailableContentConfiguration
        return state
    }
    
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        switch state.adViewUnavailableConfiguration {
        case .loading:
            var loadingContentConfiguration = UIContentUnavailableConfiguration.loading()
            loadingContentConfiguration.text = nil
            contentUnavailableConfiguration = loadingContentConfiguration
        case .noSavedAds:
            var noSavedAdsConfiguration = UIContentUnavailableConfiguration.empty()
            noSavedAdsConfiguration.text = "No saved Ads yet"
            noSavedAdsConfiguration.image = .init(systemName: "exclamationmark.circle.fill")
            noSavedAdsConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            self.contentUnavailableConfiguration = noSavedAdsConfiguration
        case .noAds:
            var noSavedAdsConfiguration = UIContentUnavailableConfiguration.empty()
            noSavedAdsConfiguration.text = "Failed to fetch ads"
            noSavedAdsConfiguration.image = .init(systemName: "xmark.seal.fill")
            noSavedAdsConfiguration.textProperties.font = .preferredFont(forTextStyle: .headline)
            self.contentUnavailableConfiguration = noSavedAdsConfiguration
        case .notLoading, .none:
            contentUnavailableConfiguration = nil
        }
    }
}

