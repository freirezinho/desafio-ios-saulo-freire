//
//  ComicDetailVCTests.swift
//  desafio-ios-saulo-freireTests
//
//  Created by mac on 18/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import XCTest
@testable import desafio_ios_saulo_freire
class ComicDetailVCTests: XCTestCase {
    var sut: ComicDetailViewController!
    var window: UIWindow!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        window = UIWindow()
        setupComicDetailViewController()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        window = nil
        super.tearDown()
    }
    
    func setupComicDetailViewController() {
        sut = ComicDetailViewController()
        let bundle = Bundle(for: self.classForCoder)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        sut = (storyboard.instantiateViewController(withIdentifier: "ComicDetailViewController") as! ComicDetailViewController)
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    func testCalcMostExpensiveComic() {
        let comic1 = APIComic(id: 1, title: "Avengers: The Initiative (2007) #19", description: "1", thumbnail: Thumbnail(path: "http://i.annihil.us/u/prod/marvel/i/mg/d/03/58dd080719806", extension: "jpg"), prices: [Price(type: "printPrice", price: 50), Price(type: "digitalPrice", price: 12.9)])
        let comic2 = APIComic(id: 1, title: "Avengers: The Initiative (2007) #20", description: "1", thumbnail: Thumbnail(path: "http://i.annihil.us/u/prod/marvel/i/mg/d/03/58dd080719806", extension: "jpg"), prices: [Price(type: "printPrice", price: 100), Price(type: "digitalPrice", price: 10.9)])
        let comics = [comic1, comic2]
        sut.calcMostExpensiveComic(comics) { (response) in
            if case .success(let result) = response {
                XCTAssertEqual(result.prices[0].price, comic2.prices[0].price)
            }
            else if case .failure(let error) = response {
                print(error)
                XCTFail()
            }
        }
    }
    func testCalcMostExpensiveComicWithSameValue() {
        let comic1 = APIComic(id: 1, title: "Avengers: The Initiative (2007) #19", description: "1", thumbnail: Thumbnail(path: "http://i.annihil.us/u/prod/marvel/i/mg/d/03/58dd080719806", extension: "jpg"), prices: [Price(type: "printPrice", price: 0), Price(type: "digitalPrice", price: 0)])
        let comic2 = APIComic(id: 1, title: "Avengers: The Initiative (2007) #20", description: "1", thumbnail: Thumbnail(path: "http://i.annihil.us/u/prod/marvel/i/mg/d/03/58dd080719806", extension: "jpg"), prices: [Price(type: "printPrice", price: 0), Price(type: "digitalPrice", price: 0)])
        let comics = [comic1, comic2]
        sut.calcMostExpensiveComic(comics) { (response) in
            if case .success(let result) = response {
                XCTAssertEqual(result.title, comics[0].title)
            }
            else if case .failure(let error) = response {
                print(error)
                XCTFail()
            }
        }
    }
    func testCalcMostExpensiveComicWithNoComics() {

        let comics: [APIComic] = []
        sut.calcMostExpensiveComic(comics) { (response) in
            if case .success(let result) = response {
                print(result)
                XCTFail()
            }
            else if case .failure(let error as APIError) = response {
                XCTAssertEqual(error, APIError.notFound)
            }
        }
    }
    func testChangeLoadingState() {
        loadView()
        sut.changeLoadingState()
        if let activityIndicator = sut.activityIndicator {
            XCTAssertTrue(activityIndicator.isHidden)
        }
        XCTAssertFalse(sut.isLoading)
    }
    
    func testChangeLoadingStateWithTitle() {
        loadView()
        let loadingText = "Loading..."
        sut.changeLoadingState(withTitle: loadingText)
        XCTAssertEqual(sut.title, loadingText)
    }
    
    func testRenderComic() {
        loadView()
        let comicTitle = "Teste"
        sut.renderComic(title: comicTitle, description: "This is a test", image: UIImage(), price: 99.99)
        XCTAssertEqual(sut.title, comicTitle)
    }
    
    func testShowErrorToUser(){
        loadView()
        let error = Utils.turnErrorToMessage(error: .networkError)
        sut.showErrorToUser(error: error)
        XCTAssertEqual(sut.title, error.0)
    }
    
    func testViewDidLoad(){
        let fetchSpy = FetchCallSpy()
        sut.fetchCall = fetchSpy.fetchCall()
        loadView()
        XCTAssertTrue(sut.isViewLoaded)
        XCTAssertTrue(fetchSpy.fetchCallSpyCalled)
    }

}

class FetchCallSpy {
    var fetchCallSpyCalled = false
    func fetchCall()->(()->Void)?
    {
        fetchCallSpyCalled = true
        return nil
    }
}
