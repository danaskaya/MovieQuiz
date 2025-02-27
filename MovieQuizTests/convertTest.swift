//
//  convertTest.swift
//  MovieQuizTests
//
//  Created by Diliara Sadrieva on 19.09.2024.
//

import Foundation
import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {
    
    }
    
    func show(quiz result: QuizResultsViewModel) {
    
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    
    }
    
    func showLoadingIndicator() {
    
    }
    
    func hideLoadingIndicator() {
    
    }
    func deselectImageBorder() {
        
    }
    
    func showNetworkError(message: String) {
    
    }
}
final class AlertPresenterMock: AlertPresenterProtocol {
    func showAlert(_ alertModel: AlertModel) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let alertPresenterMock = AlertPresenterMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock, alertPresenter: alertPresenterMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
