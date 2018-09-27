//
//  Comment.swift
//  Continuum
//
//  Created by Cody on 9/25/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import Foundation
import CloudKit

class Comment{
    
    let typeKey = "Comment"
    fileprivate let textKey = "text"
    fileprivate let timestampKey = "timestamp"
    fileprivate let postKey = "postReference"
    
    var recordID = CKRecord.ID(recordName: UUID().uuidString)
    var text: String
    var timeStamp: Date
    weak var post: Post?
    
    init (text: String, timestamp: Date = Date(), post: Post?){
        self.text = text
        self.timeStamp = timestamp
        self.post = post
    }
    
    convenience required init?(record: CKRecord) {
        guard let text = record["text"] as? String,
            let timestamp = record.creationDate else {return nil}
        self.init(text: text, timestamp: timestamp, post: nil)
        self.recordID = record.recordID
        
    }
}

extension CKRecord {
    convenience init(_ comment: Comment){
        guard let post = comment.post else {
            fatalError("comment doesn't have a post relationship")
        }
        self.init(recordType: comment.typeKey, recordID: comment.recordID)
        self.setValue(comment.text, forKey: comment.textKey)
        self.setValue(comment.timeStamp, forKey: comment.timestampKey)
        self.setValue(CKRecord.Reference(recordID: post.recordID, action: .deleteSelf), forKey: comment.postKey)
    }
}

extension Comment: SearchableRecord{
    
    func matches(searchTerm: String) -> Bool {
        return self.text.lowercased().contains(searchTerm.lowercased())
    }
}
