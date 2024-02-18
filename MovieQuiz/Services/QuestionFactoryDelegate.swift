//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 12.02.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)    
}
