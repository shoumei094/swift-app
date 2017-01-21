//
//  AppSessionManager.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 2017/01/17.
//  Copyright © 2017 Shoumei Yamamoto. All rights reserved.
//

import Foundation
import Alamofire

class AppSessionManager {
    public static let sharedManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        return Alamofire.SessionManager(configuration: configuration)
    }()
}
