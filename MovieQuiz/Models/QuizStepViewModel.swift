//
//  QuizStepViewModel.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 11.02.2024.
//

import UIKit

struct QuizStepViewModel {  // структура для показа вопроса
  // картинка с афишей фильма с типом UIImage
  let image: UIImage
  // вопрос о рейтинге квиза
  let question: String
  // строка с порядковым номером этого вопроса (ex. "1/10")
  let questionNumber: String
}
