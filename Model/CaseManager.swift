//
//  CaseManager.swift
//  COVID19
//
//  Created by Harris Zacharis on 1/5/20.
//  Copyright © 2020 Harris Zacharis. All rights reserved.
//

import Foundation

protocol CaseManagerDelegate {
    func didUpdateCases(cases: CaseModel)
    func didFetchModel(cases: CaseModel) -> CaseModel?
    func didFailWithError(error: Error)
}

struct CaseManager {
    let caseURL = "https://disease.sh/v2/countries"


    var delegate: CaseManagerDelegate?
    
    
    func fetchCases(countryCode: String) {
        let urlString = "\(caseURL)/\(countryCode)"
        performRequest(urlString)
        print(urlString)
    }
    
    func performRequest(_ urlString: String) {
        // 1.
        if let url = URL(string: urlString) {
            // 2.
            let session = URLSession(configuration: .default)
            // 3.
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let data = data {
                    if let countryCases = self.parseJSON(data) {
                        self.delegate?.didUpdateCases(cases: countryCases)
                    }
                    
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(_ caseData: Data) -> CaseModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CaseData.self, from: caseData)
            let confirmedCases = decodedData.cases
            let recoveredCases = decodedData.recovered
            let deaths = decodedData.deaths
            let countryCases = CaseModel(recoveredCases: recoveredCases, confirmedCases: confirmedCases, deathCases: deaths)
            return countryCases
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
}

}
