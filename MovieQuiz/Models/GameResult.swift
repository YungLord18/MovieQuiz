//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Ден on 27.11.2025.
//

import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    //метод сравнения по количеству верных ответов
    func isBetter(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
