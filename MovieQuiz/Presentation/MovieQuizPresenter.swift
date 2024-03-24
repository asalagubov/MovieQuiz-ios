//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 17.03.2024.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
  
  private var statisticService: StatisticService = StatisticServiceImplementation()
  private var questionFactory: QuestionFactoryProtocol?
  private weak var viewController: MovieQuizViewControllerProtocol?
  
  private var currentQuestion: QuizQuestion?
  private var alertPresenter: AlertPresenting?
  private var currentQuestionIndex: Int = 0
  private let questionsAmount: Int = 10
  private var correctAnswers = 0
  
  init(viewController: MovieQuizViewControllerProtocol) {
    self.viewController = viewController
    
    questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    questionFactory?.loadData()
    viewController.showLoadingIndicator()
  }
  // MARK: - QuestionFactoryDelegate
  func didLoadDataFromServer() {
    viewController?.hideLoadingIndicator()
    questionFactory?.requestNextQuestion()
  }
  
  func didFailToLoadData(with error: String) {
    viewController?.showNetworkError(message: error)
    self.questionFactory?.loadData()
  }
  
  func didRecieveNextQuestion(question: QuizQuestion?) {
    guard let question = question else {
      return
    }
    
    currentQuestion = question
    let viewModel = convert(model: question)
    DispatchQueue.main.async { [weak self] in
      self?.viewController?.show(quiz: viewModel)
    }
  }
  
  func didFailToLoadImage() {
    let model = AlertModel(
      title: "Ошибка",
      message: "Не удалось загрузить изображение",
      buttonText: "Попробовать еще раз") { [weak self] in
        self?.questionFactory?.requestNextQuestion()
      }
    
    alertPresenter?.show(model: model)
  }
  
  func yesButtonClicked() {
    didAnswer(isYes: true)
  }
  
  func noButtonClicked() {
    didAnswer(isYes: false)
  }
  
  func didAnswer(isCorrectAnswer: Bool) {
    if isCorrectAnswer {
      correctAnswers += 1
    }
  }
  
  func isLastQuestion() -> Bool {
    currentQuestionIndex == questionsAmount - 1
  }
  
  func restartGame() {
    currentQuestionIndex = 0
    correctAnswers = 0
    questionFactory?.requestNextQuestion()
  }
  
  func switchToNextQuestion() {
    currentQuestionIndex += 1
  }
  
  func convert(model: QuizQuestion) -> QuizStepViewModel {  // добавлен метод конвертации
    let questionStep = QuizStepViewModel (
      image: UIImage(data: model.image) ?? UIImage(),
      question: model.text,
      questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    return questionStep
  }
  
  func didReceiveNextQuestion(question: QuizQuestion?) {
    viewController?.hideLoadingIndicator()
    guard let question = question else {
      return
    }
    
    currentQuestion = question
    let viewModel = convert(model: question)
    DispatchQueue.main.async { [weak self] in
      self?.viewController?.show(quiz: viewModel)
    }
  }
  
  private func proceedToNextQuestionOrResults() {  // добавлен метод перехода к следующему вопросу или завершения квиза
    viewController?.changeButtonState(isEnabled: true)
    viewController?.showLoadingIndicator()
    if currentQuestionIndex == questionsAmount - 1 { // 1
      var text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
      statisticService.store(correct: correctAnswers, total: questionsAmount)
      text += """
        \nКоличество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
      let viewModel = QuizResultsViewModel (
        title: "Этот раунд окончен!",
        text: text,
        buttonText: "Сыграть ещё раз")
      viewController?.show(quiz: viewModel)
    } else {
      currentQuestionIndex += 1
      
      questionFactory?.requestNextQuestion()
      
    }
  }
  
  private func proceedWithAnswer(isCorrect: Bool) {
    didAnswer(isCorrectAnswer: isCorrect)
    
    viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self = self else { return }
      self.proceedToNextQuestionOrResults()
      
    }
  }
  private func didAnswer(isYes: Bool) {
    guard let currentQuestion = currentQuestion else {
      return
    }
    
    let givenAnswer = isYes
    
    proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
  }
}
