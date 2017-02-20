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
    
    private var entity: [SearchPhotoEntity]? = nil
    
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
        return entity?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = entity?[indexPath.row], let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.searchPhotoCell) else {
            return UITableViewCell()
        }
        
        cell.setCell(data: data)
        
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
    
    // MARK: data binding
    
    func bind() {
        searchBar.rx.text.orEmpty.asObservable()
            .observeOn(MainScheduler.instance)
            .throttle(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] query -> Observable<[SearchPhotoEntity]> in
                guard let strongSelf = self, let albumId = Int(query.trimmingCharacters(in: .whitespaces)) else {
                    return Observable.just([])
                }
                
                return strongSelf.viewModel.searchPhoto(albumId: albumId)
            }
            .subscribe(
                onNext: { [weak self] result in
                    guard let strongSelf = self, !result.isEmpty else {
                        return
                    }
                    
                    strongSelf.entity = result
                    strongSelf.tableView.reloadData()
                },
                onError: { [weak self] error in
                    self?.handleError(error: error, completion: nil)
                }
            )
            .disposed(by: disposeBag)
    }
}

