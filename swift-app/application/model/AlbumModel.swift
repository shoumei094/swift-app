//
//  AlbumModel.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 2017/03/19.
//  Copyright © 2017 Shoumei Yamamoto. All rights reserved.
//

import Himotoki

struct AlbumModel: Decodable {
    let userId: Int
    let id: Int
    let title: String?
    
    static func decode(_ e: Extractor) throws -> AlbumModel {
        return try AlbumModel(
            userId:         e <| "userId",
            id:             e <| "id",
            title:          e <|? "title"
        )
    }
}

struct AlbumModelSocket: NetworkSocket, GetRequest {
    typealias Model = AlbumModel
    var path: String
    let id: Int
    
    init(id: Int) {
        self.path = "/albums"
        self.id = id
    }
    
    var parameters: [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        params["id"] = id as AnyObject?
        return params
    }
}
