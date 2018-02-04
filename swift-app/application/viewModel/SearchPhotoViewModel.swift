//
//  SearchPhotoViewModel.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 9/19/16.
//  Copyright © 2016 Shoumei Yamamoto. All rights reserved.
//

import RxSwift
import RxCocoa

class SearchPhotoViewModel {
    struct SearchPhotoEntity {
        let albumId: Int
        let id: Int
        let title: String
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
    
    enum SearchResult {
        case success(result: [SearchPhotoEntity])
        case error(error: Error)
    }
    
    enum ViewModelError: Error {
        case missingAlbumId
    }
    
    func searchButtonClicked(searchText: String?) -> Driver<SearchResult> {
        guard let searchText = searchText else {
            return Driver.never()
        }
        guard let albumId = Int(searchText.trimmingCharacters(in: .whitespaces)) else {
            return Driver.never()
        }
        return searchPhoto(albumId: albumId)
    }
    
    func searchPhoto(albumId: Int?) -> Driver<SearchResult> {
        guard let albumId = albumId else {
            return Driver.just(SearchResult.error(error: ViewModelError.missingAlbumId))
        }
        return API.searchPhoto(albumId: albumId)
            .map { SearchResult.success(result: $0.map { SearchPhotoEntity($0) }) }
            .asDriver(
                onErrorRecover: { Driver.just(SearchResult.error(error: $0)) }
            )
    }
}
