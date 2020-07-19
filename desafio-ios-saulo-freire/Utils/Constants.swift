//
//  Constants.swift
//  desafio-ios-saulo-freire
//
//  Created by mac on 05/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import Foundation

// Constants struct

struct K {
    static let publicKey = "9b29197bcd9f81bde2a3f307235fbc88"
    static let privateKey = "7b6fb6590b7382710a5dfeb5887a4fabda06b585"
    static let ts = NSDate().timeIntervalSince1970.description
    static let hashData = Utils.md5("\(ts)\(privateKey)\(publicKey)")
    static let hash = hashData.map {String(format: "%02hhx", $0)}.joined()
    static let cellIdentifier = "characterCell"
    static let cellNibName = "MarvelCharacterCell"
    static let characterSegue = "tableToChar"
    static let comicSegue = "showExpensiveComic"
    static let characterEndpoint = "https://gateway.marvel.com/v1/public/characters?ts=\(ts)&apikey=\(publicKey)&hash=\(hash)&limit=20"
}
