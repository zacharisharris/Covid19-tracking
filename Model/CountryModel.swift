//
//  CountryModel.swift
//  COVID19
//
//  Created by Harris Zacharis on 8/5/20.
//  Copyright © 2020 Harris Zacharis. All rights reserved.
//

import UIKit

struct CountryModel: Codable {
    var code: String
    var name: String
    var flagName: String
    var flag: UIImage? {
          return UIImage(named: flagName)
      }
    
    init(code: String, name: String, flagName: String) {
        self.code = code
        self.name = name
        self.flagName = flagName
    }

}
