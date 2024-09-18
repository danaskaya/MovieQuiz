import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var yesButtonLabel: UIButton!
    @IBOutlet weak var noButtonLabel: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private let presenter = MovieQuizPresenter()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
            }

            currentQuestion = question
        let viewModel = presenter.convert(model: question)
        show(quiz: viewModel)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    private func showNetworkError(message: String) {
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз", completion: { [weak self] in
            guard let self = self else {return}
            self.questionFactory?.loadData()
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        )
        let alertPresenter = AlertPresenter(alertModel: model, viewController: self)
        alertPresenter.showAlert(model)
    }
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    private func show(quiz result: QuizResultsViewModel) {
        let completion = { [weak self] in
            self?.presenter.resetQuestionIndex()
            self?.correctAnswers = 0
            self?.questionFactory?.requestNextQuestion()
        }
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: completion)
        let alertPresenter = AlertPresenter(alertModel: alertModel, viewController: self)
        alertPresenter.showAlert(alertModel)
    }
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect == true {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButtonLabel.isEnabled = false
        noButtonLabel.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderColor = nil
            self.yesButtonLabel.isEnabled = true
            self.noButtonLabel.isEnabled = true
        }
    }
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let bestGame = statisticService.bestGame
            let text = """
Ваш результат: \(correctAnswers)/10
Количество сыгранных игр: \(statisticService.gamesCount)
Рекордная игра: \(bestGame.correct)/\(bestGame.total) \(bestGame.date)
Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
"""
            let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!", text: text,
                                                 buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
}
/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
