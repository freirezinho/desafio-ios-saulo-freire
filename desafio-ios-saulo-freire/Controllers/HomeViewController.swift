//
//  ViewController.swift
//  desafio-ios-saulo-freire
//
//  Created by mac on 04/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, APIWorker {
    typealias Response = [APICharacter]
    
    var marvelHeroes: [APICharacter] = []
    var heroName = "No name"
    var heroDescription = "No description available"
    var heroID = 0
    var heroThumbnail = UIImage()
    var pageIndex = 0
    var blockRequests = false
    var errorView: UIView!
    var errorLabel: UILabel!
    //for testing
    var fetchCall: (()->Void)?
    @IBOutlet weak var charTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainStackView: UIStackView!
    // MARK: - Fetch Characters
    override func viewDidLoad() {
        super.viewDidLoad()
        if let charTableView = charTable {
            charTableView.isHidden = true
        }
        fetchCall = fetchCallService
        fetchCall!()
    }
    
    func fetchCallService() {
        Utils.fetchResult(self, apiUri: K.characterEndpoint, limit: 20, offset: pageIndex * 20) { (response) in
            if case .success(let characters) = response {
                self.updateCharactersArray(characters)
                DispatchQueue.main.async {
                    if let table = self.charTable, let loadingIndicator = self.activityIndicator  {
                        table.delegate = self
                        table.dataSource = self
                        table.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
                        table.reloadData()
                        loadingIndicator.isHidden = true
                        table.isHidden = false
                    }
                    
                }
                
            }
            if case .failure(let error as APIError) = response {
                let errorToMessage = Utils.turnErrorToMessage(error: error)
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.errorView = UIView()
                    self.errorView.isHidden = false
                    self.errorView.backgroundColor = .white
                self.errorView.translatesAutoresizingMaskIntoConstraints = false
                    self.errorLabel = UILabel()
                self.errorLabel.translatesAutoresizingMaskIntoConstraints = false
                    self.errorLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                    self.errorLabel.alpha = 0.35
                    self.errorLabel.numberOfLines = 2
                    self.errorLabel.textAlignment = .center
                    self.errorLabel.text = errorToMessage.1
                self.mainStackView.addArrangedSubview(self.errorView)
                    self.errorView.addSubview(self.errorLabel)
                self.errorView.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
                    NSLayoutConstraint.activate([
                    self.errorView.bottomAnchor.constraint(equalTo: self.mainStackView.layoutMarginsGuide.bottomAnchor, constant: 0),
                    self.errorView.heightAnchor.constraint(greaterThanOrEqualToConstant: 500),
                    self.errorView.trailingAnchor.constraint(equalTo: self.mainStackView.layoutMarginsGuide.trailingAnchor),
                    self.errorView.leadingAnchor.constraint(equalTo: self.mainStackView.layoutMarginsGuide.leadingAnchor),
                    self.errorView.centerXAnchor.constraint(equalTo: self.mainStackView.centerXAnchor),
                    self.errorLabel.topAnchor.constraint(equalTo: self.errorView.centerYAnchor),
                    self.errorLabel.trailingAnchor.constraint(equalTo: self.errorView.layoutMarginsGuide.trailingAnchor, constant: 1),
                     self.errorLabel.leadingAnchor.constraint(equalTo: self.errorView.layoutMarginsGuide.leadingAnchor, constant: 1)
                    ])
                }
            }
        }
    }
    
    func updateCharactersArray(_ characters: APIData<HomeViewController.Response>) {
        if self.marvelHeroes.count == 0 {
            self.marvelHeroes = characters.results
        } else {
            for character in characters.results {
                self.marvelHeroes.append(character)
            }
        }
    }
    // MARK: - Send CharacterID to Segue Destination
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
            if (segue.identifier == K.characterSegue) {
                let charView = segue.destination as! CharacterViewController
                    if let senderObj = sender as? APICharacter {
                        charView.charID = senderObj.id
                        charView.charName =  senderObj.name
                        if senderObj.description.count > 0 {
                            charView.charDesc = senderObj.description
                        }
                        charView.charImage = senderObj.thumbnail.downloadImage(imageSize: .Large)!
                    }
            }
    }
}
// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return marvelHeroes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let heroBlock = marvelHeroes[indexPath.row]
        let thumb = heroBlock.thumbnail.downloadImage(imageSize: .Large)
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MarvelCharacterCell
        cell.heroSmallPortrait.image = thumb
        cell.heroTitle.text = heroBlock.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == marvelHeroes.count - 1 && !blockRequests {
            pageIndex = pageIndex + 1
            blockRequests = true
            activityIndicator.isHidden = false
            Utils.fetchResult(self, apiUri: K.characterEndpoint, limit: 20, offset: pageIndex * 20) { (response) in
                if case .success(let characters) = response {
                    self.updateCharactersArray(characters)
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                        self.charTable.reloadData()
                        self.blockRequests = false
                    }
                    
                }
            }
        }
    }
}
// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        heroName = String(marvelHeroes[indexPath.row].name)
        heroDescription = String(marvelHeroes[indexPath.row].description)
        heroID = marvelHeroes[indexPath.row].id
        performSegue(withIdentifier: K.characterSegue, sender: APICharacter(id: heroID, name: heroName, description: heroDescription, thumbnail: marvelHeroes[indexPath.row].thumbnail))
    }
}
