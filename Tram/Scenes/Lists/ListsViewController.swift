//
//  ListsViewController.swift
//  Tram
//
//  Created by Roman Abuzyarov on 27.02.2018.
//  Copyright (c) 2018 Tram, inc.. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ListsDisplayLogic: class
{
    func displayWatchlist(viewModel: Lists.Watchlist.ViewModel)
    func displayWatched(viewModel: Lists.Watched.ViewModel)
}

class ListsViewController: UICollectionViewController, ListsDisplayLogic
{
    var interactor: ListsBusinessLogic?
    var router: (NSObjectProtocol & ListsRoutingLogic & ListsDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = ListsInteractor()
        let presenter = ListsPresenter()
        let router = ListsRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.collectionView?.register(UINib(nibName: "ListMovieCell", bundle: nil), forCellWithReuseIdentifier: "movieCell")
        self.collectionView?.register(UINib(nibName: "ListHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "sectionHeader")
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: (self.collectionView?.frame.width)!-(8*2), height: 100)
            flowLayout.headerReferenceSize = CGSize(width: (self.collectionView?.frame.width)!-(8*2), height: 50)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadWatchlist()
        loadWatched()
    }
    
    // MARK: Do something
    
    //@IBOutlet weak var nameTextField: UITextField!
    
    enum SectionIndex: Int{
        case Watchlist = 0
        case Watched = 1
    }
    
    var watchlist = HideableDataSource(items: [Movie](), hidden: false)
    var watched = HideableDataSource(items: [Movie](), hidden: true)
    
    func loadWatchlist()
    {
        let request = Lists.Watchlist.Request()
        interactor?.loadWatchlist(request: request)
    }
    
    func loadWatched()
    {
        let request = Lists.Watched.Request()
        interactor?.loadWatched(request: request)
    }
    
    func displayWatchlist(viewModel: Lists.Watchlist.ViewModel)
    {
        watchlist.setItems(items: viewModel.watchlist)
        self.collectionView?.reloadData()
    }
    
    func displayWatched(viewModel: Lists.Watched.ViewModel) {
        watched.setItems(items: viewModel.watched)
        self.collectionView?.reloadData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case SectionIndex.Watchlist.rawValue:
            return watchlist.dataSource.count
        case SectionIndex.Watched.rawValue:
            return watched.dataSource.count
        default:
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! ListMovieCell
        var item: Movie?
        switch indexPath.section{
        case SectionIndex.Watchlist.rawValue:
            item = watchlist.dataSource[indexPath.row]
        case SectionIndex.Watched.rawValue:
            item = watched.dataSource[indexPath.row]
        default:
            ()
        }
        if let item = item{
            cell.movie = item
            cell.titleLabel.text = item.title
            
            cell.imageView.alpha = 0
            ImageCacheManager.getImageInBackground(url: URL(string: item.imageUrl)) { (image) in
                if cell.movie?.id ?? -1 == item.id{
                    cell.imageView.image = image
                    UIView.animate(withDuration: 0.2) {
                        cell.imageView.alpha = 1
                    }
                }
            }
            
            cell.ratingLabel.text = item.rating
            cell.yearLabel.text = item.year
            cell.lengthLabel.text = item.length
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath) as! ListHeaderCollectionReusableView
        header.hideButton.removeTarget(self, action: #selector(toggleWatchlist(_:)), for: .touchUpInside)
        header.hideButton.removeTarget(self, action: #selector(toggleWatched(_:)), for: .touchUpInside)
        switch indexPath.section {
        case SectionIndex.Watchlist.rawValue:
            header.sectionTitle.text = "Watchlist"
            header.hideButton.addTarget(self, action: #selector(toggleWatchlist(_:)), for: .touchUpInside)
        case SectionIndex.Watched.rawValue:
            header.sectionTitle.text = "Watched"
            header.hideButton.addTarget(self, action: #selector(toggleWatched(_:)), for: .touchUpInside)
        default:
            ()
        }
        
        var transform: CGFloat?
        switch indexPath.section {
        case SectionIndex.Watchlist.rawValue:
            transform = watchlist.hidden ? CGFloat.pi : 0
        case SectionIndex.Watched.rawValue:
            transform = watched.hidden ? CGFloat.pi : 0
        default:
            ()
        }
        if let transform = transform{
            header.hideButton.transform = CGAffineTransform(rotationAngle: transform)
        }
        
        return header
    }
    
    @objc func toggleWatchlist(_ sender: Any){
        if let button = sender as? UIButton{
            let indexPaths = watchlist.indexPaths(for: SectionIndex.Watchlist.rawValue)
            
            if watchlist.hidden{
                watchlist.toggle()
                self.collectionView?.insertItems(at: indexPaths)
            }
            else{
                watchlist.toggle()
                self.collectionView?.deleteItems(at: indexPaths)
            }
            
            UIView.animate(withDuration: 0.25) { () -> Void in
                button.transform = button.transform.rotated(by: CGFloat.pi)
            }
        }
    }
    
    @objc func toggleWatched(_ sender: Any){
        if let button = sender as? UIButton{
            let indexPaths = watched.indexPaths(for: SectionIndex.Watched.rawValue)
            
            if watched.hidden{
                watched.toggle()
                self.collectionView?.insertItems(at: indexPaths)
            }
            else{
                watched.toggle()
                self.collectionView?.deleteItems(at: indexPaths)
            }
            
            UIView.animate(withDuration: 0.25) { () -> Void in
                button.transform = button.transform.rotated(by: CGFloat.pi)
            }
        }
    }
}
