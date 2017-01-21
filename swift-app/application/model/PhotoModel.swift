//
//  PhotoModel.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 9/24/16.
//  Copyright © 2016 Shoumei Yamamoto. All rights reserved.
//

import Himotoki

struct PhotoModel: Decodable {
    let albumId: Int
    let id: Int
    let title: String?
    let url: String?
    let thumbnailUrl: String?
    
    static func decode(_ e: Extractor) throws -> PhotoModel {
        return try PhotoModel(
            albumId:        e <| "albumId",
            id:             e <| "id",
            title:          e <|? "title",
            url:            e <|? "url",
            thumbnailUrl:   e <|? "thumbnailUrl"
        )
    }
}

struct PhotoModelSocket: NetworkSocket, GetRequest {
    typealias Model = PhotoModel
    var path: String
    let albumId: Int
    
    init(albumId: Int) {
        self.path = "/photos"
        self.albumId = albumId
    }
    
    var parameters: [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        params["albumId"] = albumId as AnyObject?
        return params
    }
}
