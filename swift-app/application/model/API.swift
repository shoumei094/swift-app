//
//  API.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 9/19/16.
//  Copyright © 2016 Shoumei Yamamoto. All rights reserved.
//

import RxSwift

struct API {
    static func searchPhoto(albumId: Int) -> Observable<[PhotoModel]> {
        return PhotoModelSocket(albumId: albumId).call()
    }
    
    static func searchPhoto(id: Int) -> Observable<[PhotoModel]> {
        return PhotoModelSocket(id: id).call()
    }
    
    static func searchAlbum(id: Int) -> Observable<[AlbumModel]> {
        return AlbumModelSocket(id: id).call()
    }
    
    static func searchUser(id: Int) -> Observable<[UserModel]> {
        return UserModelSocket(id: id).call()
    }
}

