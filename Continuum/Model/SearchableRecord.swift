//
//  SearchableRecord.swift
//  Continuum
//
//  Created by Cody on 9/26/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matches(searchTerm: String) -> Bool
}
