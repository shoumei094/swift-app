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

class SearchPhotoViewController: CommonViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
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
        tableView.dataSource = self
        tableView.delegate = self
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
        
        // bind
        bind()
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dto?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = viewModel.dto?[indexPath.row], let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchPhotoCell) else {
            return UITableViewCell()
        }
        
        cell.title.text = data.title
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        if let thumbnailUrl = data.thumbnailUrl, let url = URL(string: thumbnailUrl) {
            cell.coverImage.kf.setImage(with: url) { [weak cell] (image, error, cachType, url) in
                if let _ = image, let cell = cell {
                    cell.coverImage.clipsToBounds = true
                    cell.coverImage.contentMode = .scaleAspectFill
                }
            }
        } else {
            cell.coverImage.image = nil
            cell.coverImage.clipsToBounds = false
            cell.coverImage.contentMode = .scaleToFill
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
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
    
    // MARK: data binding
    
    func bind() {
        searchBar.rx.text.orEmpty.asObservable()
            .observeOn(MainScheduler.instance)
            .throttle(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] query -> Observable<[PhotoModel]> in
                guard let sSelf = self, let albumId = Int(query.trimmingCharacters(in: .whitespaces)) else {
                    return Observable.just([])
                }
                
                return sSelf.viewModel.searchPhoto(albumId: albumId)
            }
            .subscribe()
            .addDisposableTo(disposeBag)
        
        viewModel.status.asObservable()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] result in
                    guard let result = result, let sSelf = self else {
                        return
                    }
                    
                    switch result {
                    case .success:
                        sSelf.tableView.reloadData()
                    case .failure(let errorMessage):
                        let alert = UIAlertController(title: errorMessage, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: R.string.localizable.okAction(), style: .default, handler: nil))
                        sSelf.present(alert, animated: true, completion: nil)
                    }
                }
            ).addDisposableTo(disposeBag)
    }
}

