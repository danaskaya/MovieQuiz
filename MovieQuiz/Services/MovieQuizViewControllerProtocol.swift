//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Diliara Sadrieva on 19.09.2024.
//

import Foundation
protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func deselectImageBorder()
    
    func showNetworkError(message: String)
}
