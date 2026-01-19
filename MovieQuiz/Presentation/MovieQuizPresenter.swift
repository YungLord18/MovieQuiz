//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Ден on 19.01.2026.
//

import UIKit

final class MovieQuizPresenter {
    //MARK: - Private Properties
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    //MARK: - Methods
    
    //метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
