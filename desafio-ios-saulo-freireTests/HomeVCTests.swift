//
//  HomeVCTests.swift
//  desafio-ios-saulo-freireTests
//
//  Created by mac on 18/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import XCTest
@testable import desafio_ios_saulo_freire

class HomeVCTests: XCTestCase {
    var sut: HomeViewController!
    var window: UIWindow!
    var charvc: CharacterViewController!
    var charSegue: UIStoryboardSegue!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        window = UIWindow()
        sut = HomeViewController()
        charvc = CharacterViewController()
        charSegue = UIStoryboardSegue(identifier: K.characterSegue, source: sut, destination: charvc)
    }
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        window = nil
        super.tearDown()
    }
    
    func convertJsonToData()->Data? {
        do {
            guard let bundlePath = Bundle(for: type(of: self)).path(forResource: "mockData",
                                                 ofType: "json")
                else {
                    fatalError("could not get bundlePath")
            }
            if let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            } else {
                fatalError("could not read file")
            }
        } catch {
            print(error)
            fatalError(error.localizedDescription)
        }
        return nil
    }
    
    func fillMarvelHeroesArray(){
        let characters: APIResponse<[APICharacter]>
        if let data = convertJsonToData() {
            do {

                characters = try JSONDecoder().decode(APIResponse<[APICharacter]>.self, from: data)
                if let decodedCharacters = characters.data {
                    sut.updateCharactersArray(decodedCharacters)
                }
            } catch {
              print(error)
            }
        }
    }
    
    func testPrepareSegueMethod() {
        let dummyCharacterData = APICharacter(id: 1011334, name: "3-D Man", description: "", thumbnail: Thumbnail(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"))
        loadView()
        sut.prepare(for: charSegue, sender: dummyCharacterData)
        XCTAssertEqual(dummyCharacterData.id, charvc.charID)
    }
    
    func testPrepareSegueMethodWithDescription() {
        let dummyCharacterData = APICharacter(id: 1011334, name: "3-D Man", description: "I do not know he has this name.", thumbnail: Thumbnail(path: "http://i.annihil.us/u/prod/marvel/i/mg/c/e0/535fecbbb9784", extension: "jpg"))
        loadView()
        sut.prepare(for: charSegue, sender: dummyCharacterData)
        XCTAssertEqual(dummyCharacterData.description, charvc.charDesc)
    }
    
    func testTableView() {
        let bundle = Bundle(for: self.classForCoder)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        
        _ = homeViewController.view
        let table = homeViewController.charTable
        XCTAssertNotNil(table)
    }
    func testTableViewDataSource() {
        let bundle = Bundle(for: self.classForCoder)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        
        _ = homeViewController.view
        let table = homeViewController.charTable
        let tableDS = CharactersDataSourceMock()
        table?.dataSource = tableDS
        XCTAssertTrue(table?.dataSource === tableDS)
    }
    
    func testTableViewDataSourceProtocol(){
        let bundle = Bundle(for: self.classForCoder)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        
        _ = homeVC.view
        let characters: APIResponse<[APICharacter]>
        if let data = convertJsonToData() {
            do {

                characters = try JSONDecoder().decode(APIResponse<[APICharacter]>.self, from: data)
                if let decodedCharacters = characters.data {
                    homeVC.updateCharactersArray(decodedCharacters)
                   let marvelHeroCount = homeVC.marvelHeroes.count
                    homeVC.charTable.dataSource = homeVC
                    homeVC.charTable.register(UINib(nibName: K.cellNibName, bundle: bundle), forCellReuseIdentifier: K.cellIdentifier)
                   homeVC.charTable.reloadData()
                   let numOfRows = homeVC.tableView(homeVC.charTable, numberOfRowsInSection: 0)
                   XCTAssertEqual(numOfRows, marvelHeroCount)
//                   let iPath = IndexPath(row: numOfRows - 1, section: 0)
//                    homeVC.charTable.scrollToRow(at: iPath, at: .bottom, animated: false)
//                    let expect = expectation(description: "Test scroll")
//                    print(homeVC.marvelHeroes.count)
//                   XCTAssertEqual(marvelHeroCount * 2, homeVC.marvelHeroes.count)
                   let iPath2 = IndexPath(row: 1, section: 0)
           
                   let tableCell = homeVC.tableView(homeVC.charTable, cellForRowAt: iPath2)
                   XCTAssertTrue(tableCell is MarvelCharacterCell)
//                   XCTAssertTrue(homeVC.blockRequests)
//                    expect.fulfill()
//                    wait(for: [expect], timeout: 10)
                }
            } catch {
              print(error)
            }
        }

    }
    
    func testUpdateCharactersArrayWithEmptyInit(){
        let fetchSpy = FetchCallSpy()
        sut.fetchCall = fetchSpy.fetchCall()
        loadView()
        fillMarvelHeroesArray()
        XCTAssertTrue(sut.marvelHeroes.count > 0)
    }
    
    func testUpdateCharactersArrayWithInitialValue(){
        let fetchSpy = FetchCallSpy()
        sut.fetchCall = fetchSpy.fetchCall()
        loadView()
        fillMarvelHeroesArray()
        let marvelHeroCount = sut.marvelHeroes.count
        XCTAssertTrue(sut.marvelHeroes.count > 0)
        fillMarvelHeroesArray()
        XCTAssertEqual(sut.marvelHeroes.count, marvelHeroCount * 2)
    }
    
    func testViewDidLoad(){
        let fetchSpy = FetchCallSpy()
        sut.fetchCall = fetchSpy.fetchCall()
        loadView()
        XCTAssertTrue(sut.isViewLoaded)
        XCTAssertTrue(fetchSpy.fetchCallSpyCalled)
    }
    
}

class CharactersDataSourceMock: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
}
