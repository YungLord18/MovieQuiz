import UIKit

//MARK: - Struct

//для состояния вопрос показан
struct QuizStepViewModel {
    //картинка с афишей фильма с типом UIImage
    let image: UIImage
    //вопрос о рейтинге квиза
    let question: String
    //строка с порядковым номером этого вопроса (ex. "1/10")
    let questionNumber: String
}

//для состояния "Pезультат квиза"
struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

//состовляем mock данные для вопроса
struct QuizQuestion {
    // строка с названием фильма,
    // совпадает с названием картинки афиши фильма в Assets
    let image: String
    // строка с вопросом о рейтинге фильма
    let text: String
    // булевое значение (true, false), правильный ответ на вопрос
    let correctAnswer: Bool
}

//MARK: - MovieQuizViewController

final class MovieQuizViewController: UIViewController {
    
    //MARK: - Private Outlet
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    //MARK: - Private Action
    
    //метод вызывается когда пользователь нажимает нет
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex] //по индексу текущего вопроса находим нужный нам вопрос
        let givenAnswer = false //создаем константу которая в зависимости от ответа дает нам правду или ложь
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) //передаем в метод покраски рамок значение сравнивая ответы пользователя и нащ
    }
    
    //метод вызывается когда пользователь нажимает да
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //MARK: - Private Properties
    
    //создаем массив моковых вопросов
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0
    
    //создаем переменную со счетчиком правильных ответов, где начальное значение равно 0
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //получаем теккущий вопрос из массива вопросов по индексу текущего вопроса
        let currentQuestion = questions[currentQuestionIndex]
        // Конвертируем его в модель для отображения
        let viewModel = convert(model: currentQuestion)
        // Показываем вопрос на экране
        show(quiz: viewModel)
    }
    
    //MARK: - Private Methods
    
    //метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
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
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
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
        if currentQuestionIndex == questions.count - 1 {
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
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
}
