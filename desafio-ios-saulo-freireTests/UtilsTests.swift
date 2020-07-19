//
//  UtilsTests.swift
//  desafio-ios-saulo-freireTests
//
//  Created by mac on 18/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import XCTest
@testable import desafio_ios_saulo_freire

class UtilsTests: XCTestCase {
    
    var sut: HomeViewController!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        sut = HomeViewController()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()
    }
    
    func testSuccessfulFetch(){
        let expect = expectation(description: "Successful fetch")

        var heroesResult: [APICharacter] = []
        let dummyCharacterData = APICharacter(id: 1011334, name: "3-D Man", description: "", thumbnail: Thumbnail(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"))
        Utils.fetchResult(sut, apiUri: K.characterEndpoint, limit: 20, offset: 0) { (response) in
            if case .success(let heroes) = response {
                heroesResult = heroes.results
                XCTAssertEqual(heroesResult[0].id, dummyCharacterData.id)
                XCTAssertEqual(heroesResult[0].name, dummyCharacterData.name)
                XCTAssertEqual(heroesResult[0].description, dummyCharacterData.description)
                XCTAssertEqual(heroesResult[0].thumbnail.extension, dummyCharacterData.thumbnail.extension)
                XCTAssertEqual(heroesResult[0].thumbnail.path, dummyCharacterData.thumbnail.path)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 8)
    }
    
    func testFetchWithOtherError() {
        let expect = expectation(description: "Fetch without url")

        Utils.fetchResult(sut, apiUri: "") { (response) in
            if case .failure(let error as APIError) = response {
                XCTAssertEqual(error, APIError.notFound)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 8)
    }
    
    func testFetchWithDecodingError() {
        let expect = expectation(description: "Fetch with decoding error")

        Utils.fetchResult(sut, apiUri: "https://cat-fact.herokuapp.com/facts") { (response) in
            if case .failure(let error as APIError) = response {
                XCTAssertEqual(error, APIError.decodingError)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 8)
    }
    
    func testFetchWithMessageReturn() {
        let expect = expectation(description: "Fetch with message return")

        Utils.fetchResult(sut, apiUri: "https://gateway.marvel.com/v1/public/characters?ts=\(K.ts)&apikey=\(K.publicKey)&hash=1234&limit=20", limit: 20, offset: 0) { (response) in
            if case .failure(let error as APIError) = response {
                XCTAssertEqual(error, APIError.invalidRefer)
            }
            expect.fulfill()
        }
        wait(for: [expect], timeout: 8)
    }
    
    func testApiErrorChecker(){
        let missingAPIMsg = "You must provide a user key."
        let missingHashMsg = "You must provide a hash."
        let missingTSMsg = "You must provide a timestamp."
        let invalidRefMsg = "That hash, timestamp and key combination is invalid."
        let invalidHashMsg = "Invalid Hash"
        let method403Msg = "Method Not Allowed"
        let forbiddenMsg = "Forbidden"
        let otherMsg = "qoasijflksa"
        
        let mAPIErrorType = Utils.apiErrorChecker(message: missingAPIMsg)
        let mHashErrorType = Utils.apiErrorChecker(message: missingHashMsg)
        let mTSErrorType = Utils.apiErrorChecker(message: missingTSMsg)
        let iRefErrorType = Utils.apiErrorChecker(message: invalidRefMsg)
        let iHashErrorType = Utils.apiErrorChecker(message: invalidHashMsg)
        let m403Msg = Utils.apiErrorChecker(message: method403Msg)
        let fbidMsg = Utils.apiErrorChecker(message: forbiddenMsg)
        let otrMsg = Utils.apiErrorChecker(message: otherMsg)
        
        XCTAssertEqual(mAPIErrorType, APIError.missingAPIKey)
        XCTAssertEqual(mHashErrorType, APIError.missingHash)
        XCTAssertEqual(mTSErrorType, APIError.missingTimestamp)
        XCTAssertEqual(iRefErrorType, APIError.invalidRefer)
        XCTAssertEqual(iHashErrorType, APIError.invalidHash)
        XCTAssertEqual(m403Msg, APIError.methodNotAllowed)
        XCTAssertEqual(fbidMsg, APIError.forbidden)
        XCTAssertEqual(otrMsg, APIError.networkError)
        
    }
    
    func testTurnErrorToMessage(){
        let notFoundError = APIError.notFound
        let networkError = APIError.networkError
        let missingTSError = APIError.missingTimestamp
        let missingHashError = APIError.missingHash
        let missingAPIKeyError = APIError.missingAPIKey
        let methodNotAllowedError = APIError.methodNotAllowed
        let invalidReferError = APIError.invalidRefer
        let invalidHashError = APIError.invalidHash
        let forbiddenError = APIError.forbidden
        let decodingError = APIError.decodingError

        let notFoundErrorMessage = Utils.turnErrorToMessage(error: notFoundError)
        let networkErrorMessage = Utils.turnErrorToMessage(error: networkError)
        let missingTSErrorMessage = Utils.turnErrorToMessage(error: missingTSError)
        let missingHashErrorMessage = Utils.turnErrorToMessage(error: missingHashError)
        let missingAPIKeyErrorMessage = Utils.turnErrorToMessage(error: missingAPIKeyError)
        let methodNotAllowedErrorMessage = Utils.turnErrorToMessage(error: methodNotAllowedError)
        let invalidReferErrorMessage = Utils.turnErrorToMessage(error: invalidReferError)
        let invalidHashErrorMessage = Utils.turnErrorToMessage(error: invalidHashError)
        let forbiddenErrorMessage = Utils.turnErrorToMessage(error: forbiddenError)
        let decodingErrorMessage = Utils.turnErrorToMessage(error: decodingError)
        
        XCTAssertEqual(notFoundErrorMessage.0, "Not Found")
        XCTAssertEqual(notFoundErrorMessage.1, "No resource found.")
        XCTAssertEqual(networkErrorMessage.0, "Network Error")
        XCTAssertEqual(networkErrorMessage.1, "There was a connection error.\nPlease try again later.")
        XCTAssertEqual(missingTSErrorMessage.0, "Network Error")
        XCTAssertEqual(missingTSErrorMessage.1, "There was a network error while requesting data. (timestamp)")
        XCTAssertEqual(missingHashErrorMessage.0, "Network Error")
        XCTAssertEqual(missingHashErrorMessage.1, "There was a network error while requesting data. (hash)")
        XCTAssertEqual(missingAPIKeyErrorMessage.0, "Network Error")
        XCTAssertEqual(missingAPIKeyErrorMessage.1, "There was a network error while requesting data. (API key)")
        XCTAssertEqual(methodNotAllowedErrorMessage.0, "Network Error")
        XCTAssertEqual(methodNotAllowedErrorMessage.1, "There was a network method error (not allowed).")
        XCTAssertEqual(invalidReferErrorMessage.0, "Network Error")
        XCTAssertEqual(invalidReferErrorMessage.1, "There was a network method error (referrer not valid).")
        XCTAssertEqual(invalidHashErrorMessage.0, "Network Error")
        XCTAssertEqual(invalidHashErrorMessage.1, "There was a network method error (hash not valid).")
        XCTAssertEqual(forbiddenErrorMessage.0, "Network Error")
        XCTAssertEqual(forbiddenErrorMessage.1, "Forbidden.")
        XCTAssertEqual(decodingErrorMessage.0, "Network Error")
        XCTAssertEqual(decodingErrorMessage.1, "There was an error while decoding data.")

    }
    
    func testThumbnailDownload() {
        let thumb = Thumbnail(path: "http://i.annihil.us/u/prod/marvel/i/mg/d/03/58dd080719806", extension: "jpg")
        let smallImage = thumb.downloadImage(imageSize: .Small)
        let mediumImage = thumb.downloadImage(imageSize: .Medium)
        let largeImage = thumb.downloadImage(imageSize: .Large)
        let imageArray = [smallImage, mediumImage, largeImage]
        for image in imageArray {
            XCTAssertNotNil(image)
        }
    }
    func testThumbnailDownloadError() {
        let thumb = Thumbnail(path: "http://i.annihil.us/u/prod/marvel/i/mg/d/03/58dd080719806", extension: "xpto")
        let smallImage = thumb.downloadImage(imageSize: .Small)
        XCTAssertNil(smallImage)
    }
    func testThumbnailWithNothing() {
        let thumb = Thumbnail(path: "", extension: "")
        let smallImage = thumb.downloadImage(imageSize: .Small)
        XCTAssertNil(smallImage)
    }

}
