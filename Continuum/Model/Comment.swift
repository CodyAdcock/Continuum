//
//  Comment.swift
//  Continuum
//
//  Created by Cody on 9/25/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import Foundation

class Comment{
    
    var text: String
    var timeStamp: Date
    weak var post: Post?
    
    init (text: String, timestamp: Date = Date(), post: Post){
        self.text = text
        self.timeStamp = timestamp
        self.post = post
    }
    
}

extension Comment: SearchableRecord{
    
    func matches(searchTerm: String) -> Bool {
        return self.text.lowercased().contains(searchTerm.lowercased())
    }
}
