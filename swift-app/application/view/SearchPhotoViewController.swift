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
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // search bar configuration
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.gray
        searchBar.showsCancelButton = true
        searchBar.placeholder = R.string.localizable.searchBarPlaceholder()
        searchBar.keyboardType = .decimalPad
        searchBar.keyboardAppearance = .dark
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
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
                        onErrorRecover: { [weak self] (error) in
                            self?.handleError(error: error, completion: nil)
                            return Driver.just([])
                        }
                    )
                    .do(
                        onCompleted: { [weak self] in
                            self?.tableView.setContentOffset(.zero, animated: false)
                        }
                    )
            }
            .drive(tableView.rx.items(cellIdentifier: R.reuseIdentifier.searchPhotoCell.identifier, cellType: SearchPhotoCell.self)) { (_, item, cell) in
                cell.setCell(data: item)
            }
            .disposed(by: disposeBag)
        
        // shrink table view size when the keyboard is shown
        NotificationCenter.default.rx.notification(.UIKeyboardWillShow)
            .subscribe(
                onNext: { [weak self] sender in
                    guard let strongSelf = self, let info = sender.userInfo, let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size else {
                        return
                    }
                    
                    let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
                    strongSelf.tableView.contentInset = contentInsets
                    strongSelf.tableView.scrollIndicatorInsets = contentInsets
                }
            )
            .disposed(by: disposeBag)
        
        // revert table view size when the keyboard is hidden
        NotificationCenter.default.rx.notification(.UIKeyboardWillHide)
            .subscribe(
                onNext: { [weak self] sender in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    let contentInsets = UIEdgeInsets.zero
                    strongSelf.tableView.contentInset = contentInsets
                    strongSelf.tableView.scrollIndicatorInsets = contentInsets
                }
            )
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
}

