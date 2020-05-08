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
    var countries: [String] = []
    
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
        
        makeCountries()
        setUpdateBlocks()
        
        // Timer for blinker
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.animateBlinkers), userInfo: nil, repeats: true)
        
        
        dropper.delegate = self // Insert this before you show your Dropper
        caseManager.delegate = self        
    }
    
    @objc func animateBlinkers(){
        UIView.animate(withDuration: 2.0) {
            self.orangeBlinkImage.alpha = self.orangeBlinkImage.alpha == 1.0 ? 0.0 : 1.0
            self.redBlinkImage.alpha = self.redBlinkImage.alpha == 1.0 ? 0.0 : 1.0
            self.greenBlinkImage.alpha = self.greenBlinkImage.alpha == 1.0 ? 0.0 : 1.0
        }
    }
    
    func setCompletionBlocks() {
        self.confirmedLabel.completionBlock = { () in
            let currentValue: CGFloat = self.confirmedLabel.counter.currentValue
            var formattedWithSeparator: String {
                return Formatter.withSeparator.string(for: currentValue) ?? ""
            }
            self.confirmedLabel.text = formattedWithSeparator
        }
        
        self.deathsLabel.completionBlock = { () in
            let currentValue: CGFloat = self.deathsLabel.counter.currentValue
            var formattedWithSeparator: String {
                return Formatter.withSeparator.string(for: currentValue) ?? ""
            }
            self.deathsLabel.text = formattedWithSeparator
        }
        
        self.recoveredLabel.completionBlock = { () in
            let currentValue: CGFloat = self.recoveredLabel.counter.currentValue
            var formattedWithSeparator: String {
                return Formatter.withSeparator.string(for: currentValue) ?? ""
            }
            self.recoveredLabel.text = formattedWithSeparator
        }
    }
    
    
    func setUpdateBlocks() {
        
        confirmedLabel.counter.timingFunction = EFTimingFunction.easeIn(easingRate: 2)
        
        
        confirmedLabel.setUpdateBlock { value, label in
            label.text = String(format: "%.0f", value)
        }
        
        deathsLabel.setUpdateBlock { value, label in
            label.text = String(format: "%.0f", value)
        }
        
        recoveredLabel.setUpdateBlock { value, label in
            label.text = String(format: "%.0f", value)
        }
        
    }
    
    func makeCountries(){
        //Returns an array of country names
        
        for localeCode in NSLocale.isoCountryCodes  {
            let countryName = NSLocale(localeIdentifier: Locale.current.identifier).displayName(forKey: NSLocale.Key.countryCode, value: localeCode) ?? "Country not found for code: \(localeCode)"
            countries.append(countryName)
        }
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
            dropper.items = countries // Items to be displayed
            dropper.theme = Dropper.Themes.black(nil)
            dropper.cornerRadius = 10
            dropper.showWithAnimation(0.15, options: Dropper.Alignment.center, button: countryButton)
        } else {
            dropper.hideWithAnimation(0.1)
        }
    }
    
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        let trimmedContents = contents.replacingOccurrences(of: " ", with: "%20")
        print(trimmedContents)
        caseManager.fetchCases(countryName: trimmedContents)
        countryButton.setTitle(contents, for: .normal)
        countryButton.setImage(UIImage(named: "\(locale(for: contents)).png"), for: .normal)
        if countryButton.imageView == nil { countryButton.setImage(UIImage(named: "marker.png"), for: .normal) }
        getUpdateTime()
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
        }
        
    }
}

//MARK: - Locale Methods

private func locale(for fullCountryName : String) -> String {
    let locales : String = ""
    for localeCode in NSLocale.isoCountryCodes {
        let identifier = NSLocale(localeIdentifier: Locale.current.identifier)
        let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
        if fullCountryName.lowercased() == countryName?.lowercased() {
            print("ISO Code: \(localeCode)")
            return localeCode
        }
    }
    return locales
}
