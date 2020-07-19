//
//  APICharacter.swift
//  desafio-ios-saulo-freire
//
//  Created by mac on 04/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import Foundation

// Character Codables

struct APICharacter: Codable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: Thumbnail
}
