//
//  CharacterViewControllerTests.swift
//  desafio-ios-saulo-freireTests
//
//  Created by mac on 18/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import XCTest
@testable import desafio_ios_saulo_freire

class CharacterViewControllerTests: XCTestCase {
    var sut: CharacterViewController!
    var window: UIWindow!
    var comicvc: ComicDetailViewController!
    var comicSegue: UIStoryboardSegue!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        window = UIWindow()
        setupCharacterViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        window = nil
        super.tearDown()
    }

    func setupCharacterViewController() {
        sut = CharacterViewController()
        let bundle = Bundle(for: self.classForCoder)
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        sut = (storyboard.instantiateViewController(withIdentifier: "CharacterViewController") as! CharacterViewController)
        comicvc = ComicDetailViewController()
        comicSegue = UIStoryboardSegue(identifier: K.comicSegue, source: sut, destination: comicvc)
    }
    
    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    
    func testIfAssignDataToUIHasBeenCalled() {
//        let assignDataToUiSpy = AssignDataToUISpy()
//        sut.loadData = assignDataToUiSpy.assignDataToUI()
        loadView()
        XCTAssertTrue(sut.isViewLoaded)
        XCTAssertEqual(sut.title, sut.charName)
//        XCTAssertTrue(assignDataToUiSpy.assignDataToUISpyCalled)
    }
    func testPrepareSegueMethod() {
        loadView()
        sut.prepare(for: comicSegue, sender: sut)
        XCTAssertEqual(sut!.charID, comicvc!.charID)
    }
}
