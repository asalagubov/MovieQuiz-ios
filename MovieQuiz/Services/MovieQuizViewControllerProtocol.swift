//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 18.03.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)

    func highlightImageBorder(isCorrectAnswer: Bool)

    func changeButtonState(isEnabled: Bool)

    func showLoadingIndicator()
    func hideLoadingIndicator()

    func showNetworkError(message: String)
    func resetImageBorder()
}
