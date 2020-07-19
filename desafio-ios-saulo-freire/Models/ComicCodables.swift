//
//  APIComic.swift
//  desafio-ios-saulo-freire
//
//  Created by mac on 04/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import Foundation

// Comic Codables

struct APIComic: Codable {
    let id: Int
    let title: String
    let description: String?
    let thumbnail: Thumbnail
    let prices: [Price]
}

struct Price: Codable {
    let type: String
    let price: Double
}
