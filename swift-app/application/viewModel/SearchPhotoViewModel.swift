//
//  SearchPhotoViewModel.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 9/19/16.
//  Copyright © 2016 Shoumei Yamamoto. All rights reserved.
//

import Foundation
import RxSwift

struct SearchPhotoEntity {
    let albumId: Int
    let id: Int
    let title: String?
    let url: String?
    let thumbnailUrl: String?
    
    init(_ entity: PhotoModel) {
        self.albumId = entity.albumId
        self.id = entity.id
        self.title = entity.title
        self.url = entity.url
        self.thumbnailUrl = entity.thumbnailUrl
    }
}

class SearchPhotoViewModel {
    // MARK: flag
    enum SearchStatus {
        case success
        case failure(errorMessage: String)
    }
    
    // MARK: private
    private(set) var status: Variable<SearchStatus?> = Variable(nil)
    private(set) var dto: [SearchPhotoEntity]?
    private let disposeBag = DisposeBag()
    
    // MARK: API request
    func searchPhoto(albumId: Int) -> Observable<[PhotoModel]> {
        return API.searchPhoto(albumId: albumId)
            .do(
                onNext: { [weak self] results in
                    self?.dto = results.map { SearchPhotoEntity($0) }
                    self?.status.value = .success
                },
                onError: { [weak self] error in
                    self?.status.value = .failure(errorMessage: R.string.localizable.loadingErrorMessage())
                }
            )
    }
}
