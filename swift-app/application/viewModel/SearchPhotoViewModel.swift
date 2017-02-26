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
    func searchPhoto(albumId: Int) -> Observable<[SearchPhotoEntity]> {
        return API.searchPhoto(albumId: albumId)
            .map { $0.map { SearchPhotoEntity($0) } }
    }
}
