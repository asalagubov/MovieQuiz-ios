//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 11.02.2024.
//

import Foundation


final class QuestionFactory: QuestionFactoryProtocol {

  var delegate: QuestionFactoryDelegate?

  private let moviesLoader: MoviesLoading
  private var movies: [MostPopularMovie] = []
  //  private var allmovies: [MostPopularMovie] = []


  init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
    self.moviesLoader = moviesLoader
    self.delegate = delegate
  }

  func loadData() {
    moviesLoader.loadMovies { [weak self] result in
      DispatchQueue.main.async {
        guard let self = self else { return }
        switch result {
        case .success(let mostPopularMovies):
          if mostPopularMovies.items.isEmpty && !mostPopularMovies.errorMessage.isEmpty {
            self.delegate?.didFailToLoadData(with: mostPopularMovies.errorMessage)
          } else {
            self.movies = mostPopularMovies.items 
            self.delegate?.didLoadDataFromServer()
          }
        case .failure(let error):
          self.delegate?.didFailToLoadData(with: error.localizedDescription) // сообщаем об ошибке нашему MovieQuizViewController
        }
      }
    }
  }

  func requestNextQuestion() {
    DispatchQueue.global().async { [weak self] in
      guard let self = self else { return }
      let index = (0..<self.movies.count).randomElement() ?? 0

      guard let movie = self.movies[safe: index] else { return }

      var imageData = Data()

      do {
        imageData = try Data(contentsOf: movie.resizedImageURL)
      } catch {
        DispatchQueue.main.async {
          self.delegate?.didFailToLoadImage()

        }
        return
        /* DispatchQueue.main.async { [weak self] in
         guard let self = self else { return }
         self.delegate?.didReceiveNextQuestion(question: question) */
      }


      let rating = Float(movie.rating) ?? 0

      let ratingQuestion = Bool.random()

      let text: String
      let correctAnswer: Bool
      if ratingQuestion {
        text = "Рейтинг этого фильма больше, чем 7?"
        correctAnswer = rating > 7
      } else {
        text = "Рейтинг этого фильма меньше, чем 7?"
        correctAnswer = rating < 7
      }

      let question = QuizQuestion(image: imageData,
                                  text: text,
                                  correctAnswer: correctAnswer)

      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        self.delegate?.didReceiveNextQuestion(question: question)
      }
    }
  }
}


