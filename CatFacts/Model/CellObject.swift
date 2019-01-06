//
//  CellObject.swift
//  CatFacts
//
//  Created by Игорь on 06/01/2019.
//  Copyright © 2019 Igor Podosonov. All rights reserved.
//

import UIKit

class CellObject {
    let userName: String
    let catFact: String
    
    init(_ userName: String, _ catFact: String) {
        self.userName = userName
        self.catFact = catFact
    }
}
