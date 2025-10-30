import UIKit

//MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController {
    
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
    
    private let questionsAmount = 10 //общее количество вопросов для квиза
    private var questionFactory: QuestionFactory = QuestionFactory()//фабрика вопросов, к ней будет обращаться контроллер
    private var currentQuestion: QuizQuestion? //вопрос который видит пользователь
    
    //создаем переменную со счетчиком правильных ответов, где начальное значение равно 0
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    }
    
    //MARK: - Private Methods
    
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
    
    // приватный метод для показа результатов раунда квиза
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in //слабая сслка на self
            guard let self = self else { return } //разворачиваем слабую ссылку
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
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
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                
                show(quiz: viewModel)
            }
        }
    }
}
