//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Cody on 9/25/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {

    var post: Post?{
        didSet{
            loadViewIfNeeded()
            updateViews()
            loadComments()
        }
    }
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    
    func updateViews(){
        guard let post = post else {return}
        postImage.image = post.photo
        captionLabel.text = post.caption
        
        PostController.shared.checkForSubscription(to: post) { (isSubbed) in
            DispatchQueue.main.async {
                let status = isSubbed ? "Unfollow" : "Follow"
                self.followButton.setTitle(status, for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 350
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadComments(){
        guard let post = post else {return}
        PostController.shared.fetchComments(from: post) { (success) in
            if success{
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let post = post else {return 0}
        return post.comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        if let time = comment?.timeStamp {
            cell.detailTextLabel?.text = dateFormatter.string(from: time)
        }
        return cell
    }
 
    @IBAction func commentButtonTapped(_ sender: Any) {
        presentCommentAlertController()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    @IBAction func shareButtonTapped(_ sender: Any) {
        guard let post = post, let photo = post.photo else {return}
        let activityViewController = UIActivityViewController(activityItems: [photo, post.caption], applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true)
        }
    }
    @IBAction func followButtonTapped(_ sender: Any) {
        guard let post = post else {return}
        PostController.shared.toggleSubscriptionTo(commentsForPost: post) { (success, error) in
            if let error = error{
                print("🤬 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 🤬")
                return
            }
            if success{
                DispatchQueue.main.async {
                    self.updateViews()
                }
            }
        }
    }
    
    func presentCommentAlertController(){
        let alertController = UIAlertController(title: "Comment", message: "", preferredStyle: .alert)
        
        alertController.addTextField { (commentTextField) in
            commentTextField.placeholder = "Leave a comment!"
        }
        
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            guard var commentText = alertController.textFields?.first?.text, let post = self.post else {return}
            guard !commentText.isEmpty else {return}
            PostController.shared.addComment(text: commentText, to: post, completion: { (comment) in
                DispatchQueue.main.async {
                    guard let comment = comment else { return }
                    commentText = comment.text
                    self.tableView.reloadData()
                }
            })
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    
}

