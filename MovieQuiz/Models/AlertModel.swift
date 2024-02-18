//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 12.02.2024.
//

import Foundation

struct AlertModel {
  // текст заголовка алерта
  let title: String
  // текст сообщения алерта
  let message: String
  // текст для кнопки алерта
  let buttonText: String
  // замыкание без параметров для действия по кнопке алерта
  let completion: () -> Void
}

