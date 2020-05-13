//
//  ViewController.swift
//  COVID19
//
//  Created by Harris Zacharis on 1/5/20.
//  Copyright © 2020 Harris Zacharis. All rights reserved.
//

import UIKit
import Dropper
import EFCountingLabel

class CaseViewController: UIViewController {
    
    var caseManager = CaseManager()
    let dropper = Dropper(width: 125, height: 100)
    lazy var countries = makeCountries()
    let defaults = UserDefaults.standard
    lazy private var numberFormatter = makeNumberFormatter()

    
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
        
//        setUpdateBlocks()
        retrieveUserData()
        // Timer for blinker
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.animateBlips), userInfo: nil, repeats: true)
        
        
        dropper.delegate = self // Insert this before you show your Dropper
        caseManager.delegate = self        
    }
    
    func makeNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesSignificantDigits = false
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = "."
        return formatter
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

    func makeCountries() -> [CountryModel] {
        var countries = [CountryModel]()
        for code in NSLocale.isoCountryCodes {
            var countryName = NSLocale.autoupdatingCurrent.localizedString(forRegionCode: code)
            if countryName == nil {
                countryName = code
            }
            if let countryName = countryName {
                countries.append(CountryModel(code: code, name: countryName, flagName: code.uppercased()))
            }
        }
        countries.sort(by: { l, r in return l.name < r.name})
        return countries
    }

    func getUpdateTime() {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        
        let dateTimeString = formatter.string(from: currentDateTime)
        timeLabel.text = "Last updated on: " + dateTimeString
    }
}

//MARK: - Dropper Delegate Methods

extension CaseViewController: DropperDelegate {
    
    @IBAction func DropdownAction() {
        if dropper.status == .hidden {
            dropper.maxHeight = 200
            dropper.width = 325
            dropper.items = countryNames() // Items to be displayed
            dropper.theme = Dropper.Themes.black(nil)
            dropper.cornerRadius = 10
            dropper.showWithAnimation(0.15, options: Dropper.Alignment.center, button: countryButton)
        } else {
            dropper.hideWithAnimation(0.1)
        }
    }
    
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        let row = path.row
        let country = countries[row]
        didSelectCountry(country)
    }
    
//    func searchFor(_ countryName: String) -> CountryModel? {
//        return countries.first(where: {$0.name == countryName})
//    }
    
    private func didSelectCountry(_ country: CountryModel) {
        let countryName = country.name
        let countryCode = country.code
        
        caseManager.fetchCases(countryCode: countryCode)
        countryButton.setTitle(countryName, for: .normal)
        countryButton.setImage(country.flag, for: .normal)
        getUpdateTime()
        saveCountryData(country)
    }

    
    //TODO: Add updateLabels function & separated Labels functions
    
    private func countryNames() -> [String] {
        return countries.map({$0.name})
    }

//MARK: - User Defaults


private func saveCaseData(_ cases: CaseModel) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(cases) {
        let defaults = UserDefaults.standard
        defaults.set(encoded, forKey: "SavedCases")
    }
}

private func saveCountryData(_ country: CountryModel) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(country) {
        let defaults = UserDefaults.standard
        defaults.set(encoded, forKey: "SavedCountry")
    }
}

private func retrieveUserData() {
    let decoder = JSONDecoder()
    if let savedCountry = defaults.object(forKey: "SavedCountry") as? Data {
        if let loadedCountry = try? decoder.decode(CountryModel.self, from: savedCountry) {
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

extension CaseViewController: CaseManagerDelegate {
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

