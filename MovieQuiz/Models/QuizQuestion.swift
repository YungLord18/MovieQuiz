//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Ден on 30.10.2025.
//

import UIKit

//MARK: - Struct

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
