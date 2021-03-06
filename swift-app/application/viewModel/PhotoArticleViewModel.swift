//
//  PhotoArticleViewModel.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 2017/03/19.
//  Copyright © 2017 Shoumei Yamamoto. All rights reserved.
//

import RxSwift

struct PhotoArticleEntity {
    let albumId: Int
    let id: Int
    let userId: Int
    let name: String
    let website: String?
    let title: String
    let description: String
    let url: String?
    
    init(_ photoEntity: PhotoModel, _ userEntity: UserModel) {
        self.albumId = photoEntity.albumId
        self.id = photoEntity.id
        self.userId = userEntity.id
        self.name = userEntity.name
        self.website = userEntity.website
        self.title = photoEntity.title
        self.description = [String](repeating: photoEntity.title, count: 3).joined(separator: " ")
        self.url = photoEntity.url
    }
}

struct PhotoArticleViewModel {
    static func getPhotoArticle(id: Int?) -> Observable<PhotoArticleEntity> {
        guard let id = id else {
            return Observable.error(APIError.otherError)
        }
        
        let photoObservable = API.searchPhoto(id: id)
            .flatMap { (result) -> Observable<PhotoModel> in
                if let result = result.first {
                    return Observable.just(result)
                }
                return Observable.empty()
            }
            .share(replay: 1)
        
        let userObservable = photoObservable
            .flatMap { API.searchAlbum(id: $0.albumId)
                .flatMap { (result) -> Observable<AlbumModel> in
                    if let result = result.first {
                        return Observable.just(result)
                    }
                    return Observable.empty()
                }
            }
            .flatMap { API.searchUser(id: $0.userId)
                .flatMap { (result) -> Observable<UserModel> in
                    if let result = result.first {
                        return Observable.just(result)
                    }
                    return Observable.empty()
                }
            }
        
        return Observable.zip(photoObservable, userObservable) { PhotoArticleEntity($0, $1) }
    }
}
