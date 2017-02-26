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

class SearchPhotoViewController: CommonViewController {
    // outlet
    @IBOutlet weak var tableView: UITableView!
    
    // private
    private let disposeBag = DisposeBag()
    private let viewModel = SearchPhotoViewModel()
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure search bar
        let searchBar = UISearchBar()
        searchBar.keyboardAppearance = .dark
        searchBar.keyboardType = .decimalPad
        searchBar.tintColor = .gray
        searchBar.placeholder = R.string.localizable.searchBarPlaceholder()
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
        
        // place search bar inside of the navigation bar
        navigationItem.titleView = searchBar
    }
    
    // MARK: CommonViewController
    
    override func handleErrorExplicitly(error: APIError, completion: (() -> Void)?) {
        let alert = UIAlertController(title: R.string.localizable.failedToLoadSearchResultsErrorMessage(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
