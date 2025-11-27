//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Ден on 27.11.2025.
//

import UIKit

final class StatisticService {
    //задаем приватное свойство тем самым избавляемся от дубляции кода и повышаем читаемсоть
    private let storage: UserDefaults = .standard
    
    //добавляем enum и кладем в него ключи для всех сущностей которые надо сохранить
    private enum Keys: String {
        case gamesCount //для счетчика сыгранных игр
        case bestGameCorrect //для количества правильных ответов в лучшей игре
        case bestGameTotal //для общего количества вопросов в лучшей игре
        case bestGameDate //для даты лучшей игры
        case totalCorrectAnswers //для общего количества правильных ответов за все игры
        case totalQuestionsAsked //для общего количества вопросов, заданных за все игры
    }
}

extension StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            // Добавьте чтение значения из UserDefaults
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            // Добавьте запись значения newValue в UserDefaults
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            // добавили чтение значений полей GameResult(correct, total и date) из UserDefaults,
            // затем создаеем GameResult от полученных значений
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            if let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date {
                return GameResult(correct: correct, total: total, date: date)
            } else {
                return GameResult(correct: 0, total: 0, date: Date())
            }
        }
        set {
            // добавили запись значений каждого поля из newValue в UserDefaults
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    
    var totalAccuracy: Double {
        // отношение общего числа правильных ответов
        // ко всем заданным вопросам за все игры
        guard totalQuestionsAsked > 0 else {
            return 0.0
        }
        return (Double(totalCorrectAnswers) / Double(totalQuestionsAsked)) * 100
    }
    
    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        //Обновляем данные
        totalCorrectAnswers += count
        totalQuestionsAsked += amount
        gamesCount += 1
        
        //создаем текущий результат
        let currentResult = GameResult(correct: count, total: amount, date: Date())
        
        //Делаем проверку лучший ли результат сохраненного рекорда
        if currentResult.isBetter(bestGame) {
            bestGame = currentResult
        }
    }
    
    
}
