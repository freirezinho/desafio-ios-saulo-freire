//
//  MD5Swift.swift
//  desafio-ios-saulo-freire
//
//  Created by mac on 05/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

enum APIError: Error {
    case notFound // no comic results on request
    case networkError // connection error
    case missingAPIKey // when the apikey parameter is not included with a request
    case missingHash // when an apikey parameter is included with a request, a ts parameter is present, but no hash parameter is sent
    case missingTimestamp // when an apikey parameter is included with a request, a hash parameter is present, but no ts parameter is sent
    case invalidRefer // when a referrer which is not valid for the passed apikey parameter is sent
    case invalidHash // when a ts, hash and apikey parameter are sent but the hash is not valid per the above hash generation rule
    case methodNotAllowed // when an API endpoint is accessed using an HTTP verb which is not allowed for that endpoint
    case forbidden // when a user with an otherwise authenticated request attempts to access an endpoint to which they do not have access
    case decodingError // something happened while turning JSON into decodable
}

typealias Callback<Value> = (Result<Value, Error>)->Void


class Utils {
    
    static func md5(_ string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }
    
    static func apiErrorChecker(message: String) -> APIError {
        switch message {
            case "You must provide a user key.":
                return .missingAPIKey
            case "You must provide a hash.":
                return .missingHash
            case "You must provide a timestamp.":
                return .missingTimestamp
            case "That hash, timestamp and key combination is invalid.":
                return .invalidRefer
            case "Invalid Hash":
                return .invalidHash
            case "Method Not Allowed":
                return .methodNotAllowed
            case "Forbidden":
                return .forbidden
            default:
                return .networkError
        }
    }
    
    static func turnErrorToMessage(error: APIError)->(String, String) {
        switch error {
            case .notFound:
                return("Not Found", "No resource found.")
            case .networkError:
                return("Network Error", "There was a connection error.\nPlease try again later.")
            case .missingTimestamp:
                return("Network Error", "There was a network error while requesting data. (timestamp)")
            case .missingHash:
                return("Network Error", "There was a network error while requesting data. (hash)")
            case .missingAPIKey:
                return("Network Error", "There was a network error while requesting data. (API key)")
            case .methodNotAllowed:
                return("Network Error", "There was a network method error (not allowed).")
            case .invalidRefer:
                return("Network Error", "There was a network method error (referrer not valid).")
            case .invalidHash:
                return("Network Error", "There was a network method error (hash not valid).")
            case .forbidden:
                return("Network Error", "Forbidden.")
            case .decodingError:
                return("Network Error", "There was an error while decoding data.")
        }
    }
    
    static func fetchResult<T: APIWorker>(_: T, apiUri: String, limit: Int? = nil, offset: Int? = nil, completion: @escaping Callback<APIData<T.Response>>) {
        var uri = apiUri
        if let offset = offset, let limit = limit {
            uri = "\(apiUri)&limit=\(limit)&offset=\(offset)"
        }
        if let endpoint = URL(string: uri) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: endpoint) {
                data, response, error in
                if let data = data {
                    do {
                        let res = try JSONDecoder().decode(APIResponse<T.Response>.self, from: data)
                        if let apiData = res.data {
                            completion(.success(apiData))
                        } else if let message = res.message {
                            let checkError = apiErrorChecker(message: message)
                            completion(.failure(checkError))
                        } else {
                            completion(.failure(APIError.decodingError))
                        }
                    } catch {
                        completion(.failure(APIError.decodingError))
                    }
                } else if error != nil {
                    completion(.failure(APIError.networkError))
                }
            }
            task.resume()
        } else {
            completion(.failure(APIError.notFound))
        }
        
    }
    
}



