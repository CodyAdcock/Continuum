//
//  PostController.swift
//  Continuum
//
//  Created by Cody on 9/25/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import UserNotifications

class PostController{
    //singleton
    static let shared = PostController()
    
    //SOURCE OF TRUTH
    var posts: [Post] = []
    
    let publicDB = CKContainer.default().publicCloudDatabase
    private init(){
        //subscribeToNewPosts(completion: nil)
    }
    
    func addComment(text: String, to post: Post, completion: @escaping (Comment?) -> ()){
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        
        publicDB.save(CKRecord(comment)) { (record, error)  in
            if let error = error{
                print("🤬 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 🤬")
                completion(nil);return
            }
            completion(comment)
        }
    }
    
    func createPostWith(image: UIImage, caption: String, completion: @escaping (Post?) -> ()){
        let post = Post(caption: caption, photo: image)
        self.posts.append(post)
        CKContainer.default().publicCloudDatabase.save(CKRecord(post)) { (_, error) in
            if let error = error {
                print("🤬 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 🤬")
                completion(nil);return
            }
            completion(post)
        }
    }
    
    func fetchAllPostsFromCloudKit(completion: @escaping([Post]?) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Post", predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print("Error fetching posts from cloudKit \(#function) \(error) \(error.localizedDescription)")
                completion(nil);return
            }
            
            guard let records = records else {completion(nil); return }
            
            let posts = records.compactMap{Post(record: $0)}
            
            self.posts = posts
            completion(posts)
        }
    }
    
    func fetchComments(from post: Post, completion: @escaping (Bool) -> Void) {
        let postRefence = post.recordID
        let predicate = NSPredicate(format: "postReference == %@", postRefence)
        let commentIDs = post.comments.compactMap({$0.recordID})
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        
        let query = CKQuery(recordType: "Comment", predicate: compoundPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print("Error fetching comments from cloudKit \(#function) \(error) \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let records = records else {completion(false); return }
            
            let comments = records.compactMap{Comment(record: $0)}
            post.comments.append(contentsOf: comments)
            completion(true)
        }
    }
    
    func checkAccountStatus(completion: @escaping (_ isLoggedIn: Bool) -> Void) {
        CKContainer.default().accountStatus { [weak self] (status, error) in
            if let error = error {
                print("Error checking accountStatus \(error) \(error.localizedDescription)")
                completion(false); return
            } else {
                let errrorText = "Sign into iCloud in Settings"
                switch status {
                case .available:
                    completion(true)
                case .noAccount:
                    let noAccount = "No account found"
                    self?.presentErrorAlert(errorTitle: errrorText, errorMessage: noAccount)
                    completion(false)
                case .couldNotDetermine:
                    self?.presentErrorAlert(errorTitle: errrorText, errorMessage: "Error with iCloud account status")
                    completion(false)
                case .restricted:
                    self?.presentErrorAlert(errorTitle: errrorText, errorMessage: "Restricted iCloud account")
                    completion(false)
                }
            }
        }
    }

    
    func presentErrorAlert(errorTitle: String, errorMessage: String) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.showAlertMessage(titleStr: errorTitle, messageStr: errorMessage)
            }
        }
        
    }
}

extension UIViewController {
    func showAlertMessage(titleStr:String, messageStr:String) {
        let alert = UIAlertController(title: titleStr, message: messageStr, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension PostController {
    static let PostsChangedNotification = Notification.Name("PostsChangedNotification")
}
