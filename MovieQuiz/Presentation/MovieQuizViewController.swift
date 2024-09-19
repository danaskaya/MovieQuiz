import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet weak var yesButtonLabel: UIButton!
    @IBOutlet weak var noButtonLabel: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    private var presenter: MovieQuizPresenter!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
    }
    func showNetworkError(message: String) {
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз", completion: { [weak self] in
            guard let self = self else {return}
            self.presenter.questionFactory?.loadData()
            self.presenter.restartGame()
        }
        )
        let alertPresenter = AlertPresenter(alertModel: model, viewController: self)
        alertPresenter.showAlert(model)
    }
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
                
                let alert = UIAlertController(
                    title: result.title,
                    message: message,
                    preferredStyle: .alert)
                    
                let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        
                        self.presenter.restartGame()
                }
                
                alert.addAction(action)
                
                self.present(alert, animated: true, completion: nil)
            }
    }
func highlightImageBorder(isCorrectAnswer: Bool) {
    imageView.layer.masksToBounds = true
    imageView.layer.borderWidth = 8
    imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
}
   
