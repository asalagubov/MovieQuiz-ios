import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

  // MARK: - IB Outlets
  @IBOutlet private var imageView: UIImageView! // добавлено изображение
  @IBOutlet private var textLabel: UILabel! // добавлен лейбл с вопросом
  @IBOutlet private var counterLabel: UILabel! // добавлен лейбл каунтер
  @IBOutlet private var noButton: UIButton! // добавил кнопку Нет
  @IBOutlet private var yesButton: UIButton! // добавил кнопку Да
  @IBOutlet private var activityIndicator: UIActivityIndicatorView! // добавил элемент загрузки

  // MARK: - Private Properties
  private var currentQuestionIndex = 0 // начально значение текущего вопроса 0
  private var correctAnswers = 0 // начально значение каунтера текущего ответа 0
  private let questionsAmount = 10
  private var questionFactory: QuestionFactoryProtocol?
  private var currentQuestion: QuizQuestion?
  private var alertPresenter: AlertPresenting?
  private var statisticService: StatisticService?

  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.layer.cornerRadius = 20
    questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    statisticService = StatisticServiceImplementation()
    questionFactory?.delegate = self
    questionFactory?.requestNextQuestion()
    alertPresenter = AlertPresenter()
    alertPresenter?.view = self
    statisticService = StatisticServiceImplementation()
    showLoadingIndicator()
    questionFactory?.loadData()
    activityIndicator.hidesWhenStopped = true
    
  }
  // MARK: - Status bar style
  override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
  }
  // MARK: - QuestionFactoryDelegate

  func didReceiveNextQuestion(question: QuizQuestion?) {
    activityIndicator.stopAnimating()
    guard let question = question else {
      return
    }

    currentQuestion = question
    let viewModel = convert(model: question)
    DispatchQueue.main.async { [weak self] in
      self?.show(quiz: viewModel)
    }
  }

  // MARK: - Private functions

  private func convert(model: QuizQuestion) -> QuizStepViewModel {  // добавлен метод конвертации
    let questionStep = QuizStepViewModel (
      image: UIImage(data: model.image) ?? UIImage(),
      question: model.text,
      questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    return questionStep
  }

  private func show(quiz step: QuizStepViewModel) { // добавлен метод вывода на экран вопроса
    counterLabel.text = step.questionNumber
    imageView.image = step.image
    textLabel.text = step.question
  }

  private func showAnswerResult(isCorrect: Bool) { // добавлен метод обработки ответа и подсвечивания рамки
    if isCorrect { // 1
      correctAnswers += 1 // 2
    }
    imageView.layer.masksToBounds = true
    imageView.layer.borderWidth = 8
    imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      guard let self = self else { return }
      self.showNextQuestionOrResults()
      self.imageView.layer.borderColor = UIColor.clear.cgColor
    }
  }
  private func showNextQuestionOrResults() {  // добавлен метод перехода к следующему вопросу или завершения квиза
    changeButtonState(isEnabled: true)
    activityIndicator.startAnimating()
    if currentQuestionIndex == questionsAmount - 1 { // 1
      var text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
      if let statisticService = statisticService {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        text += """
        \nКоличество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
      }
      let viewModel = QuizResultsViewModel (
        title: "Этот раунд окончен!",
        text: text,
        buttonText: "Сыграть ещё раз")
      show(quiz: viewModel)
    } else {
      currentQuestionIndex += 1

      questionFactory?.requestNextQuestion()
      
    }
  }
  private func show(quiz result: QuizResultsViewModel) { // метод показывающий результаты квиза
    alertPresenter?.show(model: AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: { [weak self] in guard let self = self else { return }
      self.currentQuestionIndex = 0
      self.correctAnswers = 0

      questionFactory?.requestNextQuestion()
    } ))
  }

  func changeButtonState(isEnabled: Bool) {
    yesButton.isEnabled = isEnabled
    noButton.isEnabled = isEnabled
  }

  private func showLoadingIndicator() {
    // activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
    activityIndicator.startAnimating() // включаем анимацию
  }

  private func showNetworkError(message: String) {
    showLoadingIndicator() // скрываем индикатор загрузки
    let model = AlertModel(
      title: "Ошибка",
      message: message,
      buttonText: "Попробовать еще раз") { [weak self] in guard let self = self else { return }

        self.currentQuestionIndex = 0
        self.correctAnswers = 0

        self.questionFactory?.loadData()
      }

    alertPresenter?.show(model: model)

  }

  func didFailToLoadData(with error: String) {
    showNetworkError(message: error) // возьмём в качестве сообщения описание ошибки
  }

  func didFailToLoadImage() {
    let model = AlertModel(
      title: "Ошибка",
      message: "Alex will become an senior ios developer!",
      buttonText: "Попробовать еще раз") { [weak self] in 
        self?.questionFactory?.requestNextQuestion()
      }

    alertPresenter?.show(model: model)
  }

  func didLoadDataFromServer() {
    activityIndicator.stopAnimating() // останаливаем анимацию индикатора загрузки
    //  activityIndicator.isHidden = true // скрываем индикатор загрузки
    
    questionFactory?.requestNextQuestion()
  }

  @IBAction private func noButtonClicked(_ sender: UIButton) { // добавлем логику на нажатие "Нет"
    changeButtonState(isEnabled: false)
    guard let currentQuestion = currentQuestion else {
      return
    }
    let giveAnswer = false

    showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
  }

  @IBAction private func yesButtonClicked(_ sender: UIButton) { // добавлем логику на нажатие "Да"
    changeButtonState(isEnabled: false)
    guard let currentQuestion = currentQuestion else {
      return
    }
    let giveAnswer = true

    showAnswerResult(isCorrect: giveAnswer == currentQuestion.correctAnswer)
  }
}

