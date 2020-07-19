//
//  ComicDetailViewController.swift
//  desafio-ios-saulo-freire
//
//  Created by mac on 16/07/20.
//  Copyright © 2020 Saulo Freire. All rights reserved.
//

import UIKit

class ComicDetailViewController: UIViewController, APIWorker {
    typealias Response = [APIComic]
    
    var comicTitle = "No title available"
    var comicDescription = "No description available"
    var comicPrice = 0.0
    var comicImage = UIImage()
    var mostExpensiveComic: APIComic?
    var mostExpensivePrice = 0.0
    var charID = 0
    var noComicAvailable = false
    var isLoading = false
    // for testing purposes
    var fetchCall: (()->Void)?
    @IBOutlet weak var comicPortraitView: UIImageView!
    @IBOutlet weak var comicTitleLabel: UILabel!
    @IBOutlet weak var comicDescriptionLabel: UILabel!
    @IBOutlet weak var comicPriceLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeLoadingState(withTitle: "Loading")
        fetchCall = fetchCallService
        fetchCall!()
        
    }
    
    func calcMostExpensiveComic(_ comics: [APIComic], completion: @escaping Callback<APIComic>) {
        if comics.count > 0 {
            var highPricedComic: APIComic?;
            var higherPricedComicHigherPrice = 0.0
            
            for (comic) in comics {
                let prices = comic.prices
                let higherPrice = prices.map {$0.price}.max() ?? 0.0
                if higherPrice > higherPricedComicHigherPrice {
                   highPricedComic = comic
                   higherPricedComicHigherPrice = higherPrice
                }
            }
            if let mostExpensiveComic = highPricedComic {
                mostExpensivePrice = higherPricedComicHigherPrice
                completion(.success(mostExpensiveComic))
            } else {
                mostExpensivePrice = higherPricedComicHigherPrice
                mostExpensiveComic = comics[0]
                completion(.success(mostExpensiveComic!))
            }
        } else {
            completion(.failure(APIError.notFound))
        }
    }
    
    func changeLoadingState(withTitle: String? = nil) {
        guard let loadingIndicator = activityIndicator else { return }
        guard let portraitView = comicPortraitView else { return }
        guard let titleLabel = comicTitleLabel else {return}
        guard let descriptionLabel = comicDescriptionLabel else { return }
        guard let priceLabel = comicPriceLabel else {return}
        loadingIndicator.isHidden = !loadingIndicator.isHidden
        portraitView.isHidden = !portraitView.isHidden
        titleLabel.isHidden = !titleLabel.isHidden
        descriptionLabel.isHidden = !descriptionLabel.isHidden
        priceLabel.isHidden = !priceLabel.isHidden
        
        isLoading = !isLoading
        if let title = withTitle {
            self.title = title
        }
    }
    
    func fetchCallService(){
        let endpoint = "https://gateway.marvel.com/v1/public/characters/\(charID)/comics?ts=\(K.ts)&apikey=\(K.publicKey)&hash=\(K.hash)"
        // this function is tested on its own file
        Utils.fetchResult(self, apiUri: endpoint) { response in
            if case .success(let comics) = response {
                self.calcMostExpensiveComic(comics.results) { (result) in
                    if case .success(let comic) = result {
                        DispatchQueue.main.async {
                            let comicPortrait = comic.thumbnail.downloadImage(imageSize: .Medium)!
                            self.renderComic(title: comic.title, description: comic.description, image: comicPortrait, price: self.mostExpensivePrice)
                        }
                    }
                    else if case .failure(let error as APIError) = result {
                        let getError = Utils.turnErrorToMessage(error: error)
                        DispatchQueue.main.async{
                            self.showErrorToUser(error: getError)
                        }
                    }
                    
                }
            } else if case .failure(let error as APIError) = response {
                let getError = Utils.turnErrorToMessage(error: error)
                DispatchQueue.main.async{
                    self.showErrorToUser(error: getError)
                }
            }
        }
    }
    
    func renderComic(title: String, description: String?, image: UIImage, price: Double ) {
        guard let titleLabel = comicTitleLabel else {return}
        guard let descriptionLabel = comicDescriptionLabel else {return}
        guard let priceLabel = comicPriceLabel else {return}
        guard let portraitView = comicPortraitView else {return}
    
        titleLabel.text = title

        if description != nil && description!.count > 0 {
            descriptionLabel.text = description
        } else {
            descriptionLabel.text = "No description recorded."
        }

        priceLabel.text = "$\(price)"
        portraitView.image = image
    
        self.title = title
        changeLoadingState()
    }
    
    
    
    func showErrorToUser(error: (String, String)) {
        guard let loadingIndicator = self.activityIndicator else { return }
        guard let titleLabel = self.comicTitleLabel else { return
        }
        loadingIndicator.isHidden = true
        titleLabel.text = error.1
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0.39
        titleLabel.isHidden = false
        self.title = error.0
    }
    
}
