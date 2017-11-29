//
//  UserModel.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 2017/03/19.
//  Copyright © 2017 Shoumei Yamamoto. All rights reserved.
//

import Himotoki

struct UserModel: Himotoki.Decodable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address?
    let phone: String?
    let website: String?
    let company: Company?
    
    struct Address: Himotoki.Decodable {
        let street: String
        let suite: String?
        let city: String
        let zipcode: String
        let geo: Geo?
        
        struct Geo: Himotoki.Decodable {
            let lat: String
            let lng: String
            
            static func decode(_ e: Extractor) throws -> Geo {
                return try Geo(
                    lat:            e <| "lat",
                    lng:            e <| "lng"
                )
            }
        }
        
        static func decode(_ e: Extractor) throws -> Address {
            return try Address(
                street:         e <| "street",
                suite:          e <|? "suite",
                city:           e <| "city",
                zipcode:        e <| "zipcode",
                geo:            e <|? "geo"
            )
        }
    }
    
    struct Company: Himotoki.Decodable {
        let name: String
        let catchPhrase: String?
        let bs: String?
        
        static func decode(_ e: Extractor) throws -> Company {
            return try Company(
                name:           e <| "name",
                catchPhrase:    e <|? "catchPhrase",
                bs:             e <|? "bs"
            )
        }
    }
    
    static func decode(_ e: Extractor) throws -> UserModel {
        return try UserModel(
            id:             e <| "id",
            name:           e <| "name",
            username:       e <| "username",
            email:          e <| "email",
            address:        e <|? "address",
            phone:          e <|? "phone",
            website:        e <|? "website",
            company:        e <|? "company"
        )
    }
}

struct UserModelSocket: NetworkSocket, GetRequest {
    typealias Model = UserModel
    var path = "/users"
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
    var parameters: [String : AnyObject]? {
        var params: [String: AnyObject] = [:]
        params["id"] = id as AnyObject?
        return params
    }
}
