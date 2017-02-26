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
}


