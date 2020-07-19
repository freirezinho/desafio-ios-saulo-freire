//
//  MarvelCharacterCell.swift
//  desafio-ios-saulo-freire
//
//  Created by mac on 04/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import UIKit

class MarvelCharacterCell: UITableViewCell {

    @IBOutlet weak var heroSmallPortrait: UIImageView!
    @IBOutlet weak var heroTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
