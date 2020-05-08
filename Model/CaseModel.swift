//
//  CaseModel.swift
//  COVID19
//
//  Created by Harris Zacharis on 2/5/20.
//  Copyright © 2020 Harris Zacharis. All rights reserved.
//

import Foundation

struct CaseModel {
    let recoveredCases: Int
    let confirmedCases : Int
    let deathCases : Int
    
    var confirmed : Float {
        return Float(confirmedCases)
    }
    
    var recovered : Float {
        return Float(recoveredCases)
    }
    
    var deaths : Float {
        return Float(deathCases)
    }
    
}
