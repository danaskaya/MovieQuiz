//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Diliara Sadrieva on 16.09.2024.
//

import Foundation
struct GameResult: Codable, Comparable {
    let correct: Int
    let total: Int
    let date: String
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.correct < rhs.correct
    }
}
