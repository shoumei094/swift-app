//
//  PhotoArticleViewController.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 2017/03/18.
//  Copyright © 2017 Shoumei Yamamoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PhotoArticleViewController: BaseViewController {
    // outlet
    
    // private
    private let disposeBag = DisposeBag()
    private let viewModel = PhotoArticleViewModel()
    
    // public
    var id: Int?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.getPhotoArticle(id: id)
            .asDriver(
                onErrorRecover: { [weak self] (error) in
                    self?.handleError(error: error)
                    return Driver.empty()
                }
            )
            .drive(
                onNext: { print($0) }
            )
            .disposed(by: disposeBag)
    }
    
    // MARK: BaseViewController
    
    override func handleErrorExplicitly(error: APIError, completion: (() -> Void)?) {
        let alert = UIAlertController(title: R.string.localizable.loadErrorMessage(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default) { [weak self] _ in
                _ = self?.navigationController?.popViewController(animated: true)
            }
        )
        self.present(alert, animated: true, completion: nil)
    }
}
