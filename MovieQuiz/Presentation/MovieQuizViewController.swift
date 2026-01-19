import UIKit

//MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - Private Outlet
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Private Action
    
    //метод вызывается когда пользователь нажимает нет
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false //создаем константу которая в зависимости от ответа дает нам правду или ложь
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) //передаем в метод покраски рамок значение сравнивая ответы пользователя и наш
    }
    
    //метод вызывается когда пользователь нажимает да
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //MARK: - Private Properties
    
    private let presenter = MovieQuizPresenter()
    
    //создаем переменную со счетчиком правильных ответов, где начальное значение равно 0
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol? //фабрика вопросов, к ней будет обращаться контроллер
    private var currentQuestion: QuizQuestion? //вопрос который видит пользователь
    private var alertPresenter = AlertPresenter() //добавили презентер
    private var statisticService: StatisticServiceProtocol = StatisticService() //добавили статистику
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        //проверка что вопрос не nil
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    //MARK: - Methods
    
    func show(quiz result: QuizResultsViewModel) {
        let bestDate = statisticService.bestGame.date.dateTimeString
        let bestScore = statisticService.bestGame.correct
        let totalGames = statisticService.gamesCount
        let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
        
        let message = """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
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
            self.restartGame()
        }
        alertPresenter.show(in: self, model: model)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true //скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) //возьмем в качестве сообщения описание ошибки
    }
    
    //MARK: - Private Methods
    
    private func restartGame() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    //приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        imageView.layer.borderWidth = 0 //установили толщину рамки 0, для того что бы скрывать цвет после перехода на новый вопрос
        imageView.layer.borderColor = UIColor.clear.cgColor //меняем цвет рамки на прозрачный, после перехода на новый вопрос
        imageView.layer.cornerRadius = 20 //делаем скругление углов при показе 1-го вопроса
    }
    
    //создаем метод который менят цвет рамки в зависимости от правильного ответа пользователя
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { //проверяем правильно ли ответил пользователь
            correctAnswers += 1 //увеличиваем счетчик правильных ответов correctAnswers, если человек ответил верно
        }
        
        imageView.layer.masksToBounds = true //даем разрешение на рисование рамки
        imageView.layer.borderWidth = 8 //толщина рамки
        imageView.layer.cornerRadius = 20 //скругление углов
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreenIOS.cgColor : UIColor.ypRedIOS.cgColor //задаем проверку для покраски рамки
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in //слабая ссылка на self
            guard let self = self else { return } //разворачиваем слабую ссылку
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
    }
    
    //приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            //сохраняем результат текущей игры
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            //идем в состояние результата квиза
            let text = "Ваш результат: \(correctAnswers)/10" //создаем константу с основным текстом алерта
            let viewModel = QuizResultsViewModel( //вызываем конструктор вью модели и передаем туда данные из макета и созданную выше константу для текста алерта
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel) //вызываем метод и передаем туда созданную вью модель из константы
        } else {
            presenter.switchToNextQuestion()
            //идем в состояние вопрос показан
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false //говорим что индикатор загрузки не скрыт
        activityIndicator.startAnimating() //включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
}
