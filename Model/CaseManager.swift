//
//  CaseManager.swift
//  Clima
//
//  Created by Harris Zacharis on 1/5/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol CaseManagerDelegate {
    func didUpdateCases(cases: CaseModel)
}

struct CaseManager {
    let caseURL = "https://disease.sh/v2/countries"


    var delegate: CaseManagerDelegate?
    
    
    func fetchCases(countryName: String) {
        let urlString = "\(caseURL)/\(countryName)"
        performRequest(urlString: urlString)
        print(urlString)
    }
    
    func handle(data: Data?, response: URLResponse?, error: Error?) {

    }
    
    func performRequest(urlString: String) {
        // 1.
        
        
        
        if let url = URL(string: urlString) {
            // 2.
            
            let session = URLSession(configuration: .default)
            
            // 3.
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let data = data {
                    if let countryCases = self.parseJSON(caseData: data) {
                        self.delegate?.didUpdateCases(cases: countryCases)
                    }
                    
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(caseData: Data) -> CaseModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CaseData.self, from: caseData)
            let confirmedCases = decodedData.cases.formattedWithSeparator
            let recoveredCases = decodedData.recovered.formattedWithSeparator
            let deaths = decodedData.deaths.formattedWithSeparator
            let countryCases = CaseModel(recoveredCases: recoveredCases, confirmedCases: confirmedCases, deaths: deaths)
        
            return countryCases
        } catch {
            print(error)
            return nil
        }
}

}


//MARK: - Formatter Extension

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
}

//MARK: - Int Formatter Extension

extension Int{
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
}

