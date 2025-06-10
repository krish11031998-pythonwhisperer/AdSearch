//
//  RemoteImage.swift
//  UI
//
//  Created by Krishna Venkatramani on 04/06/2025.
//

import Foundation
import SwiftUI
import ImageManager

public struct RemoteImage: View {
    
    public enum Photo: Hashable, Identifiable {
        case remote(String)
        case local(String)
        case none
        
        public func hash(into hasher: inout Hasher) {
            switch self {
            case .remote(let string):
                hasher.combine("remote")
                hasher.combine(string)
            case .local(let string):
                hasher.combine("local")
                hasher.combine(string)
            case .none:
                hasher.combine("none")
            }
        }
        
        public static func == (lhs: RemoteImage.Photo, rhs: RemoteImage.Photo) -> Bool {
            switch (lhs, rhs) {
            case (.remote(let string1), .remote(let string2)):
                return string1 == string2
            case (.local(let string1), .local(let string2)):
                return string1 == string2
            case (.none, .none):
                return true
            default:
                return false
            }
        }
        
        public var id: String {
            switch self {
            case .remote(let string):
                return "remote-\(string)"
            case .local(let string):
                return "local-\(string)"
            case .none:
                return "none"
            }
        }
    }
    
    enum ImageState: Hashable {
        case loading
        case image(UIImage)
        case failedToLoad
    }
    
    @State private var loading: Bool = false
    @State private var imageState: ImageState = .loading
    private let photoURL: Photo
    private let contentMode: ContentMode
    
    public init(photoURL: Photo, contentMode: ContentMode = .fill) {
        self.photoURL = photoURL
        self.contentMode = contentMode
    }
    
    public var body: some View {
        switch photoURL {
        case .remote, .local:
            imageViewWithLoading()
        case .none:
            Image(systemName: "photo.fill")
                .font(.largeTitle)
        }
    }
    
    
    // MARK: - ViewBuilders
    
    private func imageViewBuilder(image: UIImage) -> some View {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
                .transition(.blurReplace.combined(with: .opacity))
    }
    
    private var progressIndicator: some View {
        ProgressView()
            .opacity(loading ? 1 : 0)
            .transition(.opacity)
            .animation(.easeInOut, value: loading)
            .task { @MainActor in
                try? await Task.sleep(for: .milliseconds(50))
                if self.imageState == .loading {
                    self.loading = true
                }
            }
    }
    
    private func imageViewWithLoading() -> some View {
        ZStack(alignment: .center) {
            switch imageState {
            case .loading:
                progressIndicator
            case .image(let uIImage):
                imageViewBuilder(image: uIImage)
            case .failedToLoad:
                Image(systemName: "photo.fill")
                    .font(.largeTitle)
            }
        }
        .task(id: photoURL.id, priority: .userInitiated) {
            let image = await fetchImage()
            await MainActor.run {
                switch image {
                case .success(let image):
                    self.imageState = .image(image)
                case .failure(let error):
                    print("(DEBUG) \(#file) - \(#line) error: ", error.localizedDescription)
                    self.imageState = .failedToLoad
                }
            }
        }
        .onDisappear {
            self.imageState = .loading
        }
    }
    
    private func fetchImage() async -> Result<UIImage, Error> {
        let image: Result<UIImage, Error>
        switch photoURL {
        case .remote(let urlString):
            image = await RemoteImageManager.shared.fetchImage(urlString: urlString)
        case .local(let string):
            image = await ImageFileManager.shared.retrieveImage(name: string)
        case .none:
            preconditionFailure("No loading should be done for images with none as URL")
        }
        
        return image
    }
    
}

#Preview {
    RemoteImage(photoURL: .remote("https://images.finncdn.no/dynamic/480x360c/2019/8/vertical-2/04/l/nul/l_1451344711.jpg"), contentMode: .fill)
        .frame(width: 200, height: 300, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 24))
}
