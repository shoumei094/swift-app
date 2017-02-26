//
//  APIErrorManager.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 2017/02/20.
//  Copyright © 2017 Shoumei Yamamoto. All rights reserved.
//

protocol APIErrorDelegate {
    func handleError(error: Error, completion: (() -> Void)?)
}
