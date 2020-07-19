//
//  CharacterViewController.swift
//  desafio-ios-saulo-freire
//
//  Created by mac on 07/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import UIKit

class CharacterViewController: UIViewController {

    @IBOutlet weak var characterBigPortrait: UIImageView!
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterDescription: UILabel!
    var charID: Int = 0
    var charName = "No name available"
    var charDesc = "No description available."
    var charImage = UIImage()
    var mostExpensiveComic: APIComic?
    var mostExpensivePrice = 0.0
    var loadData: (()->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = charName
        loadData = assignDataToUI
        loadData!()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == K.comicSegue) {
                 let comicView = segue.destination as! ComicDetailViewController
                comicView.charID = charID
        }
    }
    
    func assignDataToUI() {
        guard let characterName = characterName else { return }
        guard let characterDescription = characterDescription else { return }
        guard let characterBigPortrait = characterBigPortrait else { return }
        characterName.text = charName
        characterDescription.text = charDesc
        characterBigPortrait.image = charImage
        
    }
    
}
