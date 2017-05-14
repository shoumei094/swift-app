//
//  BaseViewController.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 2017/01/21.
//  Copyright © 2017 Shoumei Yamamoto. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    func handleError(error: Error) {
        guard let error = error as? APIError else {
            let alert = UIAlertController(title: R.string.localizable.genericErrorMessage(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        switch error {
        case .decodeError, .httpError, .otherError:
            handleErrorExplicitly(error: error, completion: nil)
            break
        case .networkError:
            let alert = UIAlertController(title: R.string.localizable.networkConnectionErrorMessage(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        case .timeoutError:
            let alert = UIAlertController(title: R.string.localizable.serverBusyErrorMessage(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        }
    }
    
    func handleErrorExplicitly(error: APIError, completion: (() -> Void)?) {
        // override in sub-class if necessary
    }
}
