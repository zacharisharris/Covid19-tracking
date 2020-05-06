//
//  CaseData.swift
//  COVID19
//
//  Created by Harris Zacharis on 1/5/20.
//  Copyright © 2020 Harris Zacharis. All rights reserved.
//

import Foundation

struct CaseData: Codable {
    let cases : Int
    let deaths: Int
    let recovered: Int
}
