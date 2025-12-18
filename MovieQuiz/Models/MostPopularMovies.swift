//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Ден on 18.12.2025.
//

import UIKit

//создаем структуру, которая будет дублировать компоновку JSON
struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    //добавляем вычесляемое значение для новой ссылки
    var resizedImageURL: URL {
        //создаем строку из адреса
        let urlString = imageURL.absoluteString
        //обрезаем лишнюю часть и добовляем модификатор желаемого качества
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        //пытаемся создать новый адрес если не получается, то вернем старый
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        
        return newURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
