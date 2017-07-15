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
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var articleTitle: UITextView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var articleDescription: UITextView!
    
    // private
    private let disposeBag = DisposeBag()
    
    // public
    var id: Int?
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PhotoArticleViewModel.getPhotoArticle(id: id)
            .asDriver(
                onErrorRecover: { [weak self] (error) in
                    self?.handleError(error: error)
                    return Driver.empty()
                }
            )
            .drive(
                onNext: { [weak self] entity in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    if let imageUrl = entity.url, let url = URL(string: imageUrl) {
                        strongSelf.coverImage.kf.setImage(with: url) { [weak self] (_, error, _, _) in
                            if let strongSelf = self, error == nil {
                                strongSelf.coverImage.clipsToBounds = true
                                strongSelf.coverImage.contentMode = .scaleAspectFill
                            }
                        }
                    } else {
                        strongSelf.coverImage.image = nil
                        strongSelf.coverImage.clipsToBounds = false
                        strongSelf.coverImage.contentMode = .scaleToFill
                    }
                    strongSelf.articleTitle.text = entity.title
                    strongSelf.username.text = entity.name
                    strongSelf.articleDescription.text = entity.description
                }
            )
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        articleDescription.setContentOffset(.zero, animated: false)
        
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
