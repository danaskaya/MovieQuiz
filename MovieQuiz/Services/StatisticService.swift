//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Diliara Sadrieva on 16.09.2024.
//

import Foundation
final class StatisticService: StatisticServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let result = try? JSONDecoder().decode(GameResult.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date().dateTimeString)
            }
            return result
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Сохранить результат невозможно")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            gamesCount != 0 ? Double(score) / Double(gamesCount) * 10 : 0
        }
    }
    var score: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    func store(correct count: Int, total amount: Int) {
        let gameResult = bestGame
        let newGameResult = GameResult(correct: count, total: amount, date: Date().dateTimeString)
        gamesCount += 1
        if gameResult < newGameResult {
            bestGame = newGameResult
        }
    }
    
    
}
