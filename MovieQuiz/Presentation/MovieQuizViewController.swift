import UIKit

//MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - Private Outlet
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
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
    
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0
    //создаем переменную со счетчиком правильных ответов, где начальное значение равно 0
    private var correctAnswers = 0
    
    private let questionsAmount = 10 //общее количество вопросов для квиза
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory() //фабрика вопросов, к ней будет обращаться контроллер
    private var currentQuestion: QuizQuestion? //вопрос который видит пользователь
    private var alertPresenter = AlertPresenter() //добавили презентер
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        //проверка что вопрос не nil
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    //MARK: - Methods
    
    func show(quiz result: QuizResultsViewModel) {
        let message = "Вы ответили правильно на \(correctAnswers) из \(questionsAmount) вопросов!"
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
    
    //MARK: - Private Methods
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
    
    //метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
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
        if currentQuestionIndex == questionsAmount - 1 {
            //идем в состояние результата квиза
            let text = "Ваш результат: \(correctAnswers)/10" //создаем константу с основным текстом алерта
            let viewModel = QuizResultsViewModel( //вызываем конструктор вью модели и передаем туда данные из макета и созданную выше константу для текста алерта
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel) //вызываем метод и передаем туда созданную вью модель из константы
        } else {
            currentQuestionIndex += 1
            //идем в состояние вопрос показан
            questionFactory.requestNextQuestion()
        }
    }
}
