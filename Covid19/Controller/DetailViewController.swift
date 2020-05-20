//
//  DetailViewController.swift
//  COVID19
//
//  Created by Harris Zacharis on 13/5/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CountryPickerView

protocol DetailViewControllerDelegate: class {
    func detailViewControllerIsCountryFavorite(vc: DetailViewController) -> Bool
    func detailViewControllerGetCountry(vc: DetailViewController) -> Country
    func detailViewController(vc: DetailViewController, setCountryFavorite: Bool)

}

class DetailViewController: UIViewController {
    
    var countryCases : CaseModel?
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var flagImageView: UIImageView!
    
    weak var delegate : DetailViewControllerDelegate?
    
    private var isFavorite = false {
        didSet {
            updateFavoriteButton()
        }
    }
    
    public var country: Country? {
        didSet {
            updateUI()
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        country = delegate?.detailViewControllerGetCountry(vc: self)
        isFavorite = delegate?.detailViewControllerIsCountryFavorite(vc: self) ?? false
        print(countryCases!)
}
    
    func updateUI() {
        if let country = country {
            loadViewIfNeeded()
            navigationItem.title = country.name
            flagImageView.image = country.flag
            updateFavoriteButton()
        }
    }
    
    @IBAction func toggleFavorite(_ sender: Any) {
        if isFavorite {
            isFavorite = false
        } else {
            isFavorite = true
        }
    }
    
    func updateFavoriteButton() {
        if isFavorite {
            favoriteButton.setImage(UIImage(named: "remove.png"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(named: "add.png"), for: .normal)
        }
    }
}
