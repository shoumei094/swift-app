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

class SearchPhotoViewController: BaseViewController {
    // outlet
    @IBOutlet weak var tableView: UITableView!
    
    // private
    private let searchBar = UISearchBar()
    private let disposeBag = DisposeBag()
    private let viewModel = SearchPhotoViewModel()
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure search bar
        searchBar.showsCancelButton = true
        searchBar.keyboardAppearance = .dark
        searchBar.keyboardType = .asciiCapableNumberPad
        searchBar.tintColor = .gray
        searchBar.barTintColor = .white
        searchBar.placeholder = R.string.localizable.searchBarPlaceholder()
        
        // dismiss keyboard when the cancel button is clicked
        searchBar.rx.cancelButtonClicked
            .asDriver()
            .drive(
                onNext: { [weak self] _ in
                    self?.searchBar.resignFirstResponder()
                }
            )
            .disposed(by: disposeBag)
        
        // load search results when text is entered in the search bar
        searchBar.rx.text.orEmpty
            .asDriver()
            .throttle(1)
            .distinctUntilChanged()
            .flatMapLatest { [weak self] (albumId) -> Driver<[SearchPhotoEntity]> in
                guard let strongSelf = self, let albumId = Int(albumId.trimmingCharacters(in: .whitespaces)) else {
                    return Driver.just([])
                }
                
                return strongSelf.viewModel.searchPhoto(albumId: albumId)
                    .asDriver(
                        onErrorRecover: { [weak self] (error) in
                            self?.handleError(error: error)
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
        
        // push photo article view controller
        tableView.rx.modelSelected(SearchPhotoEntity.self)
            .asDriver()
            .drive(
                onNext: { [weak self] entity in
                    guard let strongSelf = self, let viewController = R.storyboard.photoArticle.instantiateInitialViewController() else {
                        return
                    }
                    
                    viewController.id = entity.id
                    strongSelf.navigationController?.pushViewController(viewController, animated: true)
                }
            )
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        searchBar.becomeFirstResponder()
        searchBar.isUserInteractionEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar.resignFirstResponder()
        searchBar.isUserInteractionEnabled = false
    }
    
    // MARK: BaseViewController
    
    override func handleErrorExplicitly(error: APIError, completion: (() -> Void)?) {
        let alert = UIAlertController(title: R.string.localizable.loadErrorMessage(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
