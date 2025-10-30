//
//  Untitled.swift
//  MovieQuiz
//
//  Created by Ден on 30.10.2025.
//

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
