//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Alexander Salagubov on 17.03.2024.
//

import XCTest

class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()

        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }
  func testYesButton() {
    sleep(2) // дилей 2 сек

    let firstPoster = app.images["Poster"] // находим 1-й постер
    let firstPosterData = firstPoster.screenshot().pngRepresentation // делаем скринщот 1-го постера

    app.buttons["Yes"].tap() // находим кнопку "Да" и тапаем по ней
    sleep(2) // дилей 2 сек

    let secondPoster = app.images["Poster"] // еще раз находим постер
    let secondPesterData = secondPoster.screenshot().pngRepresentation // делаем скриншот второго постера

    let indexLabel = app.staticTexts["Index"]

    XCTAssertNotEqual(firstPosterData, secondPesterData) // проверяем что постеры разные
    XCTAssertEqual(indexLabel.label, "2/10")

  }

  func testNoButton() {
    sleep(2)

    let firstPoster = app.images["Poster"]
    let firstPosterData = firstPoster.screenshot().pngRepresentation

    app.buttons["No"].tap()
    sleep(2)

    let secondPoster = app.images["Poster"]
    let secondPosterData = secondPoster.screenshot().pngRepresentation

    let indexLabel = app.staticTexts["Index"]

    XCTAssertNotEqual(firstPosterData, secondPosterData)
    XCTAssertEqual(indexLabel.label, "2/10")


  }

  func testGameFinish() {
    sleep (2)
    for _ in 1...10 {
      app.buttons["No"].tap()
      sleep(2)
    }
    let alert = app.alerts["Alert"]

    XCTAssertTrue(alert.exists)
    XCTAssertTrue(alert.label == "Этот раунд окончен!")
    XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
  }

  func testAllertButton() {
    sleep (2)
    for _ in 1...10 {
      app.buttons["No"].tap()
      sleep(2)
    }
    let alert = app.alerts["Alert"]
    alert.buttons.firstMatch.tap()

    sleep(2)

    let indexLabel = app.staticTexts["Index"]

    XCTAssertFalse(alert.exists)
    XCTAssertTrue(indexLabel.label == "1/10")
  }
}
