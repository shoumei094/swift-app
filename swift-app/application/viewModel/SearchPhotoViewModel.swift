//
//  SearchPhotoViewModel.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 9/19/16.
//  Copyright © 2016 Shoumei Yamamoto. All rights reserved.
//

import RxSwift

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

class SearchPhotoViewModel {
    func searchFirstPhoto(albumId: String?) -> Observable<SearchPhotoEntity?> {
        let targetAlbumId: Int
        if let unwrappedAlbumId = albumId, let intAlbumId = Int(unwrappedAlbumId.trimmingCharacters(in: .whitespaces)) {
            targetAlbumId = intAlbumId
        } else {
            targetAlbumId = 1
        }
        
        return API.searchPhoto(albumId: targetAlbumId)
            .map { $0.map { SearchPhotoEntity($0) }.first }
    }
    
    func searchPhoto(albumId: String?) -> Observable<[SearchPhotoEntity]> {
        let targetAlbumId: Int
        if let unwrappedAlbumId = albumId, let intAlbumId = Int(unwrappedAlbumId.trimmingCharacters(in: .whitespaces)) {
            targetAlbumId = intAlbumId
        } else {
            targetAlbumId = 1
        }
        
        return API.searchPhoto(albumId: targetAlbumId)
            .map { $0.map { SearchPhotoEntity($0) } }
    }
}
