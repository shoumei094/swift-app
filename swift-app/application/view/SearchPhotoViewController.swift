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

class SearchPhotoViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    // outlet
    @IBOutlet weak var tableView: UITableView!
    
    // private
    private let initialAlbumId = 1
    private let searchController = UISearchController(searchResultsController: nil)
    private let disposeBag = DisposeBag()
    private var photoList: [SearchPhotoViewModel.SearchPhotoEntity] = []
    private enum Section: Int {
        case list = 0
        case count
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.keyboardType = .asciiCapableNumberPad
        searchController.searchBar.placeholder = R.string.localizable.searchBarPlaceholder()
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        title = "Search Photos"
        definesPresentationContext = true
        
        let viewModel = SearchPhotoViewModel()
        let initialSearch = viewModel.searchPhoto(albumId: initialAlbumId)
        let searchButtonClicked = searchController
            .searchBar
            .rx
            .searchButtonClicked
            .asDriver()
            .withLatestFrom(searchController.searchBar.rx.text.orEmpty.asDriver()) { $1 }
            .flatMapLatest { viewModel.searchButtonClicked(searchText: $0) }
        let cancelButtonClicked = searchController
            .searchBar
            .rx
            .cancelButtonClicked
            .asDriver()
            .flatMapLatest { [weak self] _ -> Driver<SearchPhotoViewModel.SearchResult> in
                return viewModel.searchPhoto(albumId: self?.initialAlbumId)
            }
        Driver.merge(initialSearch, searchButtonClicked, cancelButtonClicked)
            .drive(
                onNext: { [weak self] searchResult in
                    guard let `self` = self else {
                        return
                    }
                    switch searchResult {
                    case .success(let result):
                        self.photoList = result
                        self.tableView.reloadData()
                    case .error(let error):
                        self.handleCustomError(error: error)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.list.rawValue:
            return photoList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.list.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchPhotoCell.identifier) as? SearchPhotoCell  {
                cell.setCell(data: photoList[indexPath.row])
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Section.list.rawValue == indexPath.section, let viewController = R.storyboard.photoArticle.instantiateInitialViewController() {
            viewController.id = photoList[indexPath.row].id
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: BaseViewController
    
    override func handleCustomError(error: Error) {
        switch error {
        case SearchPhotoViewModel.ViewModelError.missingAlbumId:
            fallthrough
        default:
            let alert = UIAlertController(title: R.string.localizable.loadErrorMessage(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
