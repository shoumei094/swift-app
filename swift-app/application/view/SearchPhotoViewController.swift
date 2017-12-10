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
    private let viewModel = SearchPhotoViewModel()
    private var firstPhoto: SearchPhotoEntity?
    private var photoList: [SearchPhotoEntity] = []
    private enum Section: Int {
        case header = 0
        case list
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
        title = "Test"
        definesPresentationContext = true
        
        // API calls
        let firstPhotoDriver = viewModel.searchFirstPhoto(albumId: initialAlbumId)
            .asDriver(onErrorJustReturn: nil)
        let photoDriver = viewModel.searchPhoto(albumId: initialAlbumId)
            .asDriver(
                onErrorRecover: { [weak self] error in
                    guard let `self` = self else {
                        return Driver.empty()
                    }
                    return Driver.just(self.photoList)
                        .do(
                            onNext: { [weak self] _ in
                                self?.handleError(error: error)
                            }
                        )
                }
            )
        let searchDriver = searchController
            .searchBar
            .rx
            .searchButtonClicked
            .asDriver()
            .withLatestFrom(searchController.searchBar.rx.text.orEmpty.asDriver()) { $1 }
            .flatMapLatest { [weak self] text -> Driver<[SearchPhotoEntity]> in
                guard let `self` = self, let albumId = Int(text.trimmingCharacters(in: .whitespaces)) else {
                    return Driver.empty()
                }
                return self.viewModel.searchPhoto(albumId: albumId)
                    .asDriver(
                        onErrorRecover: { [weak self] error in
                            guard let `self` = self else {
                                return Driver.empty()
                            }
                            return Driver.just(self.photoList)
                                .do(
                                    onNext: { [weak self] _ in
                                        self?.handleError(error: error)
                                    }
                                )
                        }
                    )
            }
        let cancelDriver = searchController
            .searchBar
            .rx
            .cancelButtonClicked
            .asDriver()
            .flatMapLatest { [weak self] _ -> Driver<[SearchPhotoEntity]> in
                guard let `self` = self else {
                    return Driver.empty()
                }
                return self.viewModel.searchPhoto(albumId: self.initialAlbumId)
                    .asDriver(
                        onErrorRecover: { [weak self] error in
                            guard let `self` = self else {
                                return Driver.empty()
                            }
                            return Driver.just(self.photoList)
                                .do(
                                    onNext: { [weak self] _ in
                                        self?.handleError(error: error)
                                    }
                                )
                        }
                    )
            }
        
        // populate table view
        Driver.combineLatest(firstPhotoDriver, Driver.merge(photoDriver, searchDriver, cancelDriver)) { ($0, $1) }
            .drive(
                onNext: { [weak self] (firstPhoto, photoList) in
                    guard let `self` = self else {
                        return
                    }
                    self.firstPhoto = firstPhoto
                    self.photoList = photoList
                    self.tableView.reloadData()
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
        case Section.header.rawValue:
            return firstPhoto == nil ? 0 : 1
        case Section.list.rawValue:
            return photoList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.header.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchPhotoCell.identifier) as? SearchPhotoCell, let entity = firstPhoto {
                cell.setCell(data: entity)
                return cell
            }
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
        switch indexPath.section {
        case Section.list.rawValue:
            if let viewController = R.storyboard.photoArticle.instantiateInitialViewController() {
                viewController.id = photoList[indexPath.row].id
                navigationController?.pushViewController(viewController, animated: true)
            }
        default:
            return
        }
    }
    
    // MARK: BaseViewController
    
    override func handleCustomError(error: Error) {
        switch error {
        case SearchPhotoViewModelError.missingAlbumId:
            fallthrough
        default:
            let alert = UIAlertController(title: R.string.localizable.loadErrorMessage(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
