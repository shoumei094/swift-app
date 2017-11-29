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
        let firstPhotoObservable = viewModel.searchFirstPhoto(albumId: initialAlbumId)
        let photoObservable = viewModel.searchPhoto(albumId: initialAlbumId)
        let searchObservable = searchBar.rx.searchButtonClicked
            .flatMapLatest { [weak self] _ -> Observable<[SearchPhotoEntity]> in
                guard let `self` = self else {
                    return Observable.empty()
                }
                return self.viewModel.searchPhoto(albumId: self.searchBar.text)
            }
        
        // populate table view
        Observable.combineLatest(firstPhotoObservable, Observable.merge(photoObservable, searchObservable)) { ($0, $1) }
            .filter { $0.0.map { _ in true } ?? false && !$0.1.isEmpty }
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] (firstPhoto, photo) in
                    guard let `self` = self else {
                        return
                    }
                    self.firstPhoto = firstPhoto
                    self.photo = photo
                    self.tableView.reloadData()
                },
                onError: { [weak self] error in
                    self?.handleError(error: error)
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
            return UITableViewCell()
        case Section.list.rawValue:
            if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchPhotoCell.identifier) as? SearchPhotoCell  {
                cell.setCell(data: photo[indexPath.row])
                return cell
            }
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
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
