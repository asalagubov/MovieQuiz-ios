//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Alexander Salagubov on 16.02.2024.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date

  func isBetterThan(_ another: GameRecord) -> Bool {
    correct > another.correct
  }
}
