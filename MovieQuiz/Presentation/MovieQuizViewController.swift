import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
  
  // MARK: - IB Outlets
  @IBOutlet private var imageView: UIImageView! // добавлено изображение
  @IBOutlet private var textLabel: UILabel! // добавлен лейбл с вопросом
  @IBOutlet private var counterLabel: UILabel! // добавлен лейбл каунтер
  @IBOutlet private var noButton: UIButton! // добавил кнопку Нет
  @IBOutlet private var yesButton: UIButton! // добавил кнопку Да
  @IBOutlet private var activityIndicator: UIActivityIndicatorView! // добавил элемент загрузки
  
  // MARK: - Private Properties
  private var alertPresenter: AlertPresenting?
  private var presenter: MovieQuizPresenter!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.layer.cornerRadius = 20
    alertPresenter = AlertPresenter()
    alertPresenter?.view = self
    showLoadingIndicator()
    activityIndicator.hidesWhenStopped = true
    presenter = MovieQuizPresenter(viewController: self)
    resetImageBorder()
  }
  // MARK: - Status bar style
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  // MARK: - Actions
  @IBAction private func noButtonClicked(_ sender: UIButton) { // добавлем логику на нажатие "Нет"
    changeButtonState(isEnabled: false)
    presenter.noButtonClicked()
  }
  
  @IBAction private func yesButtonClicked(_ sender: UIButton) { // добавлем логику на нажатие "Да"
    changeButtonState(isEnabled: false)
    presenter.yesButtonClicked()
  }
  // MARK: - Private functions
  func show(quiz step: QuizStepViewModel) { // добавлен метод вывода на экран вопроса
    resetImageBorder()
    counterLabel.text = step.questionNumber
    imageView.image = step.image
    textLabel.text = step.question
  }
  
  func show(quiz result: QuizResultsViewModel) { // метод показывающий результаты квиза
    alertPresenter?.show(model: AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: { [weak self] in guard let self = self else { return }
      self.presenter.restartGame()
    } ))
  }
  
  func highlightImageBorder(isCorrectAnswer: Bool) { // добавлен метод обработки ответа и подсвечивания рамки
    imageView.layer.masksToBounds = true
    imageView.layer.borderWidth = 8
    imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
  }
  
  func changeButtonState(isEnabled: Bool) {
    yesButton.isEnabled = isEnabled
    noButton.isEnabled = isEnabled
  }
  
  func showLoadingIndicator() {
    activityIndicator.startAnimating() // включаем анимацию
  }
  
  func hideLoadingIndicator() {
    activityIndicator.stopAnimating() // включаем анимацию
  }
  
  func showNetworkError(message: String) {
    showLoadingIndicator() // скрываем индикатор загрузки
    let model = AlertModel(
      title: "Ошибка",
      message: message,
      buttonText: "Попробовать еще раз") { [weak self] in guard let self = self else { return }
        
        self.presenter.restartGame()
      }
    
    alertPresenter?.show(model: model)
    
  }
  
  func resetImageBorder() {
    imageView.layer.borderColor = UIColor.clear.cgColor
  }
}
