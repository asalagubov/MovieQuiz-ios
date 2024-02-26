//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 11.02.2024.
//

import Foundation

struct QuizQuestion { // структура для вопроса
  // строка с названием фильма, совпадает с названием картинки афиши фильма в Assets
  let image: Data
  // строка с вопросом о рейтинге фильма
  let text: String
  // булевое значение (true, false), правильный ответ на вопрос
  let correctAnswer: Bool
}
