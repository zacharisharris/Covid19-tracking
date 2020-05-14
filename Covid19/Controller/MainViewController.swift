//
//  MainViewController.swift
//  COVID19
//
//  Created by Harris Zacharis on 1/5/20.
//  Copyright © 2020 Harris Zacharis. All rights reserved.
//

import UIKit
import CountryPickerView
import EFCountingLabel

class MainViewController: UIViewController {
    
    var caseManager = CaseManager()
    let defaults = UserDefaults.standard
    lazy private var numberFormatter = makeNumberFormatter()
    var favorites : [Country] = []
    

    @IBOutlet weak var countryPickerView: CountryPickerView!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var recoveredLabel: EFCountingLabel!
    @IBOutlet weak var deathsLabel: EFCountingLabel!
    @IBOutlet weak var confirmedLabel: EFCountingLabel!
    @IBOutlet weak var redBlinkImage: UIImageView!
    @IBOutlet weak var orangeBlinkImage: UIImageView!
    @IBOutlet weak var greenBlinkImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        caseManager.delegate = self
        
        retrieveUserData()
        
        // Timer for blips
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.animateBlips), userInfo: nil, repeats: true)
    }
    
    func makeNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesSignificantDigits = false
        formatter.usesGroupingSeparator = true
        formatter.groupingSize = 3
        return formatter
    }
    
    
    @IBAction func detailPressed(_ sender: UIButton) {
        
    }
    
    //MARK: - UI & Animation Methods
    
    func getUpdateTime() {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        let dateTimeString = formatter.string(from: currentDateTime)
        timeLabel.text = "Last updated on: " + dateTimeString
    }
    
    
    @objc func animateBlips(){
        UIView.animate(withDuration: 2.0) {
            self.orangeBlinkImage.alpha = self.orangeBlinkImage.alpha == 1.0 ? 0.0 : 1.0
            self.redBlinkImage.alpha = self.redBlinkImage.alpha == 1.0 ? 0.0 : 1.0
            self.greenBlinkImage.alpha = self.greenBlinkImage.alpha == 1.0 ? 0.0 : 1.0
        }
    }
    
    func setCompletionBlocks() {
        confirmedLabel.completionBlock = { [weak self] in
            if let currentValue = self?.confirmedLabel.counter.currentValue {
                self?.confirmedLabel.text = self?.numberFormatter.string(from: NSNumber(value: Float(currentValue)))
            }
        }
        
        deathsLabel.completionBlock = { [weak self] in
            if let currentValue = self?.deathsLabel.counter.currentValue {
                self?.deathsLabel.text = self?.numberFormatter.string(from: NSNumber(value: Float(currentValue)))
            }
        }
        
        recoveredLabel.completionBlock = { [weak self] in
            if let currentValue = self?.recoveredLabel.counter.currentValue {
                self?.recoveredLabel.text = self?.numberFormatter.string(from: NSNumber(value: Float(currentValue)))
            }
        }
    }
}

//MARK: - CountryPickerView Delegate Methods

extension MainViewController: CountryPickerViewDelegate, CountryPickerViewDataSource {
    
    
    @IBAction func showCountryList(_ sender: Any) {
        countryPickerView.showCountriesList(from: self)
    }
    
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        caseManager.fetchCases(countryCode: country.code)
        countryButton.setTitle(country.name, for: .normal)
        countryButton.setImage(country.flag, for: .normal)
        getUpdateTime()
        saveCountryData(country)
}

    //MARK: - User Defaults
    
    private func saveCaseData(_ cases: CaseModel) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(cases) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedCases")
        }
}

    private func saveCountryData(_ country: Country) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(country) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedCountry")
        }
    }
    
    private func retrieveUserData() {
        let decoder = JSONDecoder()
        if let savedCountry = defaults.object(forKey: "SavedCountry") as? Data {
            if let loadedCountry = try? decoder.decode(Country.self, from: savedCountry) {
                countryButton.setTitle(loadedCountry.name, for: .normal)
                countryButton.setImage(loadedCountry.flag, for: .normal)
            }
        }
        
        if let savedCases = defaults.object(forKey: "SavedCases") as? Data {
            if let loadedCases = try? decoder.decode(CaseModel.self, from: savedCases) {
                self.confirmedLabel.text = numberFormatter.string(from: NSNumber(value: loadedCases.confirmedCases))
                self.deathsLabel.text = numberFormatter.string(from: NSNumber(value: loadedCases.deathCases))
                self.recoveredLabel.text = numberFormatter.string(from: NSNumber(value: loadedCases.recoveredCases))
            }
        }
    }
}

//MARK: - CaseManager Delegate Methods

extension MainViewController: CaseManagerDelegate {
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            
            self.confirmedLabel.text = "N/A"
            self.deathsLabel.text = "N/A"
            self.recoveredLabel.text = "N/A"
        }
        print(error)
    }
    
    func didUpdateCases(cases: CaseModel) {
        DispatchQueue.main.async {
            self.setCompletionBlocks()
            
            self.confirmedLabel.countFromCurrentValueTo(CGFloat(cases.confirmed))
            self.deathsLabel.countFromCurrentValueTo(CGFloat(cases.deaths))
            self.recoveredLabel.countFromCurrentValueTo(CGFloat(cases.recovered))
            self.saveCaseData(cases)
        }
    }
    
    //MARK: - Might be removed
    
    func setUpdateBlocks() {
        confirmedLabel.setUpdateBlock { [weak self] value, label in
            label.text = self?.numberFormatter.string(from: NSNumber(value: Float(value)))
        }
        deathsLabel.setUpdateBlock { [weak self] value, label in
            label.text = self?.numberFormatter.string(from: NSNumber(value: Float(value)))
        }
        recoveredLabel.setUpdateBlock { [weak self] value, label in
            label.text = self?.numberFormatter.string(from: NSNumber(value: Float(value)))
        }
    }
}

