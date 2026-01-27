//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ден on 19.01.2026.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    //MARK: - Private Properties
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewController?
    
    private var currentQuestionIndex: Int = 0
    private var currentQuestion: QuizQuestion? //вопрос который видит пользователь
    
    //MARK: - Properties
    
    let statisticService: StatisticServiceProtocol! //добавили статистику
    
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }

    
    //MARK: - Methods
    
    //метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    //метод вызывается когда пользователь нажимает да
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    //метод вызывается когда пользователь нажимает нет
   func noButtonClicked() {
       didAnswer(isYes: false)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        //проверка что вопрос не nil
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    
    //MARK: - Private Methods
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //создаем метод который менят цвет рамки в зависимости от правильного ответа пользователя
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    //метод, который содержит логику перехода в один из сценариев
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            //сохраняем результат текущей игры
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            //идем в состояние результата квиза
            let text = "Ваш результат: \(correctAnswers)/10" //создаем константу с основным текстом алерта
            let viewModel = QuizResultsViewModel( //вызываем конструктор вью модели и передаем туда данные из макета и созданную выше константу для текста алерта
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            viewController?.show(quiz: viewModel) //вызываем метод и передаем туда созданную вью модель из константы
        } else {
            self.switchToNextQuestion()
            //идем в состояние вопрос показан
            questionFactory?.requestNextQuestion()
        }
    }
}
