//
//  NetworkManager.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 9/18/16.
//  Copyright © 2016 Shoumei Yamamoto. All rights reserved.
//

import Alamofire
import RxSwift
import Himotoki

protocol RequestType {
    associatedtype Model: Decodable
    var parameters: [String: AnyObject]? { get }
    var baseUrl: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
}
protocol GetRequest {
}
protocol PostRequest {
}
protocol NetworkSocket: RequestType {
    func call() -> Observable<[Model]>
}

enum APIError: Error {
    case offlineError
    case decodeError
    case httpError
}

extension GetRequest {
    var method: HTTPMethod {
        return HTTPMethod.get
    }
}
extension PostRequest {
    var method: HTTPMethod {
        return HTTPMethod.post
    }
}
extension NetworkSocket {
    var baseUrl: String {
        return Configuration.baseUrl
    }
    var url: String {
        return "\(baseUrl)\(path)"
    }
    
    func call() -> Observable<[Model]> {
        return Observable.create { observer in
            let request = AppSessionManager.sharedManager
                .request(self.url, method: self.method, parameters: self.parameters, encoding: URLEncoding.default)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        if let entity = try? decodeArray(value) as [Model] {
                            observer.onNext(entity)
                            observer.onCompleted()
                        } else {
                            observer.onError(APIError.decodeError)
                        }
                    case .failure(let error):
                        #if DEBUG
                            print(error)
                        #endif
                        observer.onError(error)
                    }
            }
            return Disposables.create { request.cancel() }
        }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
}
