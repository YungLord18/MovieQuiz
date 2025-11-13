//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Ден on 13.11.2025.
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
