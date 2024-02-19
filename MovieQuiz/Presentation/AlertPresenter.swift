//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 12.02.2024.
//

import UIKit

protocol AlertPresenting {
  func show(model: AlertModel)
  var view: UIViewController? { get set }
}

final class AlertPresenter: AlertPresenting {

  weak var view: UIViewController?

  func show(model: AlertModel) {
    let alert = UIAlertController(
      title: model.title,
      message: model.message,
      preferredStyle: .alert)

    let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
      model.completion()
    }

    alert.addAction(action)

    view?.present(alert, animated: true, completion: nil)
  }
}
