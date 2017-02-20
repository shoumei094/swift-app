//
//  CommonViewController.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 2017/01/21.
//  Copyright © 2017 Shoumei Yamamoto. All rights reserved.
//

import UIKit

class CommonViewController: UIViewController, APIErrorDelegate {
    func handleError(error: Error, completion: (() -> Void)?) {
        guard let error = error as? APIError else {
            let alert = UIAlertController(title: R.string.localizable.genericErrorMessage(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: completion)
            return
        }
        
        switch error {
        case .decodeError, .httpError, .timeoutError, .unknownError:
            handleErrorExplicitly(error: error, completion: completion)
            break
        case .networkError:
            let alert = UIAlertController(title: R.string.localizable.networkConnectionErrorMessage(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: completion)
            break
        }
    }
    
    func handleErrorExplicitly(error: APIError, completion: (() -> Void)?) {
        // override in sub-class if necessary
    }
}
