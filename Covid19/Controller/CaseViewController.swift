//
//  ViewController.swift
//  COVID19
//
//  Created by Harris Zacharis on 1/5/20.
//  Copyright © 2020 Harris Zacharis. All rights reserved.
//

import UIKit
import Dropper

class CaseViewController: UIViewController {
    
    let dropper = Dropper(width: 125, height: 100)
    
    let countries = ["Afghanistan","Albania","Algeria","Andorra","Angola","Argentina","Armenia","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bhutan","Bolivia","Bosnia and Herzegovina","Botswana","Brazil","Brunei","Bulgaria","Burkina Faso","Burma","Burundi","Cabo Verde", "Cambodia","Cameroon","Canada","Chile","China","Colombia","Comoros","Costa Rica","Croatia","Cuba","Cyprus","Czechia","Denmark","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Estonia","Ethiopia","Fiji","Finland","France","Gabon","Gambia","Georgia","Germany","Ghana","Greece","Grenada","Guatemala","Guinea","Haiti","Honduras","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland","Israel","Italy","Jamaica","Japan","Jordan","Kazakhstan","Kenya","South Korea","Kosovo","Kuwait","Kyrgyzstan","Laos","Latvia","Lebanon","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Madagascar", "Malaysia","Maldives","Mali","Malta","Mauritania","Mauritius","Mexico","Moldova","Monaco","Mongolia","Montenegro","Morocco","Mozambique","Nepal","Netherlands","New Zealand","Nicaragua","Nigeria","North Macedonia","Norway","Oman","Pakistan","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal","Qatar","Romania","Russia","Rwanda","San Marino","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia","Somalia","South Africa","Spain","Sri Lanka","Sudan","Sweden","Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Tunisia","Turkey","United States","Uganda","Ukraine","United Arab Emirates","United Kingdom","Uruguay","Uzbekistan","Venezuela","Vietnam","Yemen","Zambia","Zimbabwe"]
    
    @IBOutlet weak var myButton: UIButton!
    @IBOutlet weak var recoveredLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    @IBOutlet weak var confirmedLabel: UILabel!
    @IBOutlet weak var redBlinkImage: UIImageView!
    @IBOutlet weak var orangeBlinkImage: UIImageView!
    @IBOutlet weak var greenBlinkImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    var caseManager = CaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            dropper.showWithAnimation(0.15, options: Dropper.Alignment.center, button: myButton)
        } else {
            dropper.hideWithAnimation(0.1)
        }
    }
    
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        let trimmedContents = contents.replacingOccurrences(of: " ", with: "%20")
        print(trimmedContents)
        caseManager.fetchCases(countryName: trimmedContents)
        myButton.setTitle(contents, for: .normal)
        getUpdateTime()
    }
    
}

//MARK: - CaseManager Delegate Methods

extension CaseViewController: CaseManagerDelegate {
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdateCases(cases: CaseModel) {
        DispatchQueue.main.async {
            self.confirmedLabel.text = cases.confirmedCases
            self.deathsLabel.text = cases.deaths
            self.recoveredLabel.text = cases.recoveredCases
        }
        
    }
}
