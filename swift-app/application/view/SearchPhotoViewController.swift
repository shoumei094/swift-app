//
//  SearchPhotoViewController.swift
//  swift-app
//
//  Created by Shoumei Yamamoto on 9/18/16.
//  Copyright © 2016 Shoumei Yamamoto. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class SearchPhotoViewController: CommonViewController, UISearchBarDelegate {
    // MARK: outlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: private
    private let disposeBag = DisposeBag()
    private let viewModel = SearchPhotoViewModel()
    private let searchBar = UISearchBar()
    
    // MARK: object lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // table view configuration
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        tableView.tableFooterView = UIView(frame: .zero)
        
        // search bar configuration
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.gray
        searchBar.showsCancelButton = true
        searchBar.placeholder = R.string.localizable.searchBarPlaceholder()
        searchBar.keyboardType = .decimalPad
        searchBar.keyboardAppearance = .dark
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        // keyboard configuration
        NotificationCenter.default.addObserver(self, selector: #selector(SearchPhotoViewController.keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchPhotoViewController.keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        
        // fetch search results
        searchBar.rx.text.orEmpty
            .asDriver()
            .throttle(0.3)
            .map { Int($0.trimmingCharacters(in: .whitespaces)) }
            .filter { $0 != nil }
            .map { $0! }
            .flatMapLatest { [weak self] (albumId) -> Driver<[SearchPhotoEntity]> in
                guard let strongSelf = self else {
                    return Driver.just([])
                }
                
                return strongSelf.viewModel.searchPhoto(albumId: albumId)
                    .asDriver(
                        onErrorRecover: { (error) in
                            strongSelf.handleError(error: error, completion: nil)
                            return Driver.just([])
                        }
                    )
            }
            .drive(tableView.rx.items(cellIdentifier: R.reuseIdentifier.searchPhotoCell.identifier, cellType: SearchPhotoCell.self)) { (_, item, cell) in
                cell.setCell(data: item)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    // MARK: CommonViewController
    
    override func handleErrorExplicitly(error: APIError, completion: (() -> Void)?) {
        let alert = UIAlertController(title: R.string.localizable.failedToLoadSearchResultsErrorMessage(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: keyboard utility
    
    func keyboardWillShow(notification: NSNotification) {
        var userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, to: view as UIView?)
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.size.height + 20, 0)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
    }
}

