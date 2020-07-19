//
//  APIGenericCodables.swift
//  desafio-ios-saulo-freire
//
//  Created by mac on 18/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import Foundation
import UIKit

// Generic Marvel API response starts with these

struct APIResponse<Response: Decodable>: Decodable {
    let status: String?
    let message: String?
    let data: APIData<Response>?
}

struct APIData<Results: Decodable>: Decodable {
    let offset: Int
    let limit: Int
    let total: Int
    let count: Int
    let results: Results
}

// Enum created in order to specify image size on request

enum portraitSize {
    case Small
    case Medium
    case Large
}

// Thumbnail Codable to manage characters and comics thumbnails

struct Thumbnail: Codable {
    let path: String
    let `extension`: String
    
    func downloadImage(imageSize: portraitSize)-> UIImage? {
        var size: String
        if imageSize == portraitSize.Small {
            size = "portrait_medium"
        } else if imageSize == portraitSize.Medium {
            size = "portrait_xlarge"
        } else {
            size = "portrait_uncanny"
        }
        guard let url = URL(string: "\(path)/\(size).\(`extension`)")
            else {return nil}
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        } else {
            print(APIError.decodingError)
            return nil
        }
    }
}

// Protocol for controllers that do the API requests

protocol APIWorker {
    associatedtype Response: Decodable
}
