//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ден on 30.10.2025.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?) //его вызывает фабрика когда вопрос готов
    func didLoadDataFromServer() //сообщение об успешной загрузки
    func didFailToLoadData(with error: Error) //сообщение об ошибке загрузки
}
