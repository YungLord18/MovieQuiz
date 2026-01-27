import UIKit

//MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController {
    
    //MARK: - Private Outlet
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    
    //MARK: - Private Properties
    
    private lazy var presenter: MovieQuizPresenter = {
        return MovieQuizPresenter(viewController: self)
    }()
    
    private var alertPresenter = AlertPresenter() //добавили презентер
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //presenter = MovieQuizPresenter(viewController: self)
        
        imageView.layer.cornerRadius = 20
        
        showLoadingIndicator()
    }
    
    //MARK: - Private Action
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    //MARK: - Methods
    
    func show(quiz result: QuizResultsViewModel) {
        let bestDate = presenter.statisticService.bestGame.date.dateTimeString
        let bestScore = presenter.statisticService.bestGame.correct
        let totalGames = presenter.statisticService.gamesCount
        let accuracy = String(format: "%.2f", presenter.statisticService.totalAccuracy)
        
        let message = """
            Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(totalGames)
            Рекорд: \(bestDate)
            Средняя точность: \(accuracy)%
            """
        
        let model = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText
        ) { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        alertPresenter.show(in: self, model: model)
    }
    

    //метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0 //установили толщину рамки 0, для того что бы скрывать цвет после перехода на новый вопрос
        imageView.layer.borderColor = UIColor.clear.cgColor //меняем цвет рамки на прозрачный, после перехода на новый вопрос
        imageView.layer.cornerRadius = 20 //делаем скругление углов при показе 1-го вопроса
    }
    
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true //даем разрешение на рисование рамки
        imageView.layer.borderWidth = 8 //толщина рамки
        imageView.layer.cornerRadius = 20 //скругление углов
        //задаем проверку для покраски рамки
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false //говорим что индикатор загрузки не скрыт
        activityIndicator.startAnimating() //включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.presenter.correctAnswers = 0
        }
        
        alertPresenter.show(in: self, model: model)
    }
}
