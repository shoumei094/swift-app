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
    private let searchBar = UISearchBar()
    private let disposeBag = DisposeBag()
    private let initialAlbumId = "1"
    private let viewModel = SearchPhotoViewModel()
    private var firstPhoto: SearchPhotoEntity?
    private var photo: [SearchPhotoEntity] = []
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
        searchBar.showsCancelButton = true
        searchBar.keyboardAppearance = .dark
        searchBar.keyboardType = .asciiCapableNumberPad
        searchBar.tintColor = .gray
        searchBar.barTintColor = .white
        searchBar.placeholder = R.string.localizable.searchBarPlaceholder()
        navigationItem.titleView = searchBar
        
        // dismiss keyboard when the cancel button is clicked
        searchBar.rx.cancelButtonClicked
            .asDriver()
            .drive(
                onNext: { [weak self] _ in
                    self?.searchBar.resignFirstResponder()
                }
            )
            .disposed(by: disposeBag)
        
        // API calls
        let firstPhotoDriver = viewModel.searchFirstPhoto(albumId: initialAlbumId)
            .asDriver(onErrorJustReturn: nil)
        let photoDriver = viewModel.searchPhoto(albumId: initialAlbumId)
            .asDriver(
                onErrorRecover: { [weak self] error in
                    self?.handleError(error: error)
                    return Driver.just([])
                }
            )
        let searchDriver = searchBar.rx.searchButtonClicked
            .flatMapLatest { [weak self] _ in
                return self?.viewModel.searchPhoto(albumId: self?.searchBar.text) ?? Observable.empty()
            }
            .asDriver(
                onErrorRecover: { [weak self] error in
                    self?.handleError(error: error)
                    return Driver.just([])
                }
            )
        
        // populate table view
        Driver.combineLatest(firstPhotoDriver, Driver.merge(photoDriver, searchDriver)) { ($0, $1) }
            .filter { $0.0.map { _ in true } ?? false && !$0.1.isEmpty }
            .drive(
                onNext: { [weak self] (firstPhoto, photo) in
                    guard let `self` = self else {
                        return
                    }
                    self.firstPhoto = firstPhoto
                    self.photo = photo
                    self.tableView.reloadData()
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
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.header.rawValue:
            return firstPhoto.map { _ in 1 } ?? 0
        case Section.list.rawValue:
            return photo.count
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
                cell.setCell(data: photo[indexPath.row])
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
                viewController.id = photo[indexPath.row].id
                navigationController?.pushViewController(viewController, animated: true)
            }
        default:
            return
        }
    }
    
    // MARK: BaseViewController
    
    override func handleErrorExplicitly(error: APIError, completion: (() -> Void)?) {
        let alert = UIAlertController(title: R.string.localizable.loadErrorMessage(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
