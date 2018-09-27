//
//  Post.swift
//  Continuum
//
//  Created by Cody on 9/25/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import Foundation
import UIKit

class Post {
    
    var caption: String
    var photoData: Data?
    var timestamp: Date
    var comments: [Comment] = []
    
    
    var photo: UIImage?{
        get{
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
        }
        set{
            photoData = newValue?.jpegData(compressionQuality: 0.6)
        }
    }
    
    init(caption: String, photo: UIImage, timestamp: Date = Date(), comments: [Comment] = []){
        self.caption = caption
        self.timestamp = timestamp
        self.comments = comments
        self.photo = photo
    }
}

extension Post: SearchableRecord{
    func matches(searchTerm: String) -> Bool {
        
        if caption.lowercased().contains(searchTerm.lowercased()){
            return true
        }
        
        for comment in self.comments{
            if comment.matches(searchTerm: searchTerm){
                return true
            }
        }
        return false
    }
}

