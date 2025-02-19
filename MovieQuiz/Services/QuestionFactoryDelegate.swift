//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Diliara Sadrieva on 14.09.2024.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
