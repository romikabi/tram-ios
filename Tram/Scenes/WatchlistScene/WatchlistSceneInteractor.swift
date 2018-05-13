//
//  WatchlistSceneInteractor.swift
//  Tram
//
//  Created by Roman Abuzyarov on 22.03.2018.
//  Copyright (c) 2018 Tram, inc.. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol WatchlistSceneBusinessLogic
{
    func getUser(request: WatchlistScene.GetUser.Request)
}

protocol WatchlistSceneDataStore
{
    var movies : [Movie]? {get set}
    var shows : [TVShow]? {get set}
}

class WatchlistSceneInteractor: WatchlistSceneBusinessLogic, WatchlistSceneDataStore
{
    var movies: [Movie]?
    
    var shows: [TVShow]?
    
    init(){
        worker = WatchlistSceneWorker()
    }
    var presenter: WatchlistScenePresentationLogic?
    var worker: WatchlistSceneWorker?
    //var name: String = ""
    
    // MARK: Do something
    
    func getUser(request: WatchlistScene.GetUser.Request)
    {
        worker?.getUser(id: -1, onSuccess: { (u) in
            u.movieWatchlist?.sort { $0.title < $1.title }
            u.showWatchlist?.sort { $0.name<$1.name }
            self.movies = u.movieWatchlist
            self.shows = u.showWatchlist
            let response = WatchlistScene.GetUser.Response(user: u)
            self.presenter?.presentUser(response: response)
        })
        
    }
}