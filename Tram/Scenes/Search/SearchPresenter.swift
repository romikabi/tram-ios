//
//  SearchPresenter.swift
//  Tram
//
//  Created by Roman Abuzyarov on 06.01.2018.
//  Copyright (c) 2018 Roman Abuzyarov. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol SearchPresentationLogic
{
    func presentMovies(response: Search.SearchMovies.Response)
}

class SearchPresenter: SearchPresentationLogic
{
    weak var viewController: SearchDisplayLogic?
    
    // MARK: Do something
    
    func presentMovies(response: Search.SearchMovies.Response)
    {
        let shortMovies = response.movies.map { (movie) -> Search.SearchMovies.ViewModel.ShortMovie in
            return Search.SearchMovies.ViewModel.ShortMovie(title: movie.title, year: movie.year, rating: movie.rating, stars: ["Not avaliable"], imageUrl: movie.imageUrl, movie: movie)
        }
        
        let viewModel = Search.SearchMovies.ViewModel(movies: shortMovies)
        viewController?.displayMovies(viewModel: viewModel)
    }
}
