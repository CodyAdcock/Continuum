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
        }
    }
    
    @IBOutlet weak var postImage: UIImageView!
    
    
    func updateViews(){
        postImage.image = post?.photo
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

