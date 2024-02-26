//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 12.02.2024.
//

import Foundation

protocol QuestionFactoryProtocol {
  var delegate: QuestionFactoryDelegate? { get set }
  func requestNextQuestion()
  func loadData()
}
