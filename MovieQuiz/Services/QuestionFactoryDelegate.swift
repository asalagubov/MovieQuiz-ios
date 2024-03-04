//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 12.02.2024.
//

import Foundation

protocol QuestionFactoryDelegate {
  func didReceiveNextQuestion(question: QuizQuestion?)
  func didLoadDataFromServer() // сообщение об успешной загрузке
  func didFailToLoadData(with error: String) // сообщение об ошибке загрузки
  func didFailToLoadImage()
}
