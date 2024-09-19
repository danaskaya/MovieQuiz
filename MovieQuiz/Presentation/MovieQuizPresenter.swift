//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Diliara Sadrieva on 18.09.2024.
//

import Foundation
import UIKit
final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers = 0
    
    private let statisticService: StatisticServiceProtocol!
    private var currentQuestion: QuizQuestion?
    private var viewController: MovieQuizViewControllerProtocol
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol
    
    lazy var message = makeResultsMessage()
    
    init(viewController: MovieQuizViewControllerProtocol, alertPresenter: AlertPresenterProtocol) {
        self.viewController = viewController
        self.alertPresenter = alertPresenter
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.proceedToNextQuestionOrResults()
            viewController.deselectImageBorder()
            
        }
    }
    func makeResultsMessage() -> String {
        guard let statisticService = statisticService else {return ""}
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let bestGame = statisticService.bestGame
            
            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let resultMessage = [
                currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")
            
            return resultMessage
        }
    func didLoadDataFromServer() {
            viewController.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
        
    func didFailToLoadData(with error: Error) {
            let message = error.localizedDescription
            viewController.showNetworkError(message: message)
        }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController.show(quiz: viewModel)
        }
    }
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func convert (model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    func showNetworkError(message: String) {
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз", completion: { [weak self] in
            guard let self = self else {return}
            questionFactory?.loadData()
            restartGame()
        }
        )
        alertPresenter.showAlert(model)
    }
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
                    return
                }
                
                let givenAnswer = isYes
                
                proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    func didRecieveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController.show(quiz: viewModel)
            }
        }
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            viewController.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
        }
    func show(quiz result: QuizResultsViewModel) {
        let completion = { [weak self] in
            guard let self = self else {return}
            self.restartGame()
        }
        let alertModel = AlertModel(title: result.title, message: message, buttonText: result.buttonText, completion: completion)
        alertPresenter.showAlert(alertModel)
    }
    }
