//
//  PostController.swift
//  Continuum
//
//  Created by Cody on 9/25/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import Foundation
import UIKit

class PostController{
    //singleton
    static let shared = PostController()
    //SOURCE OF TRUTH
    var posts: [Post] = []
    
    func addComment(text: String, to post: Post, completion: @escaping (Comment?) -> ()){
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Post?) -> ()){
        let post = Post(caption: caption, photo: image)
        self.posts.append(post)
    }
    
}
