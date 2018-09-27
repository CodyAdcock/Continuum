//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Cody on 9/25/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    
    var post: Post?{
        didSet{
            updateViews()
        }
    }
    
    func updateViews(){
        guard let post = post else {return}
        postImage.image = post.photo
        captionLabel.text = post.caption
        commentCountLabel.text = "Comments: \(post.comments.count)"
    }
    
    

}
