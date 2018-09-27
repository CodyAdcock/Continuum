//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Cody on 9/25/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, UISearchBarDelegate{
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var resultsArray: [SearchableRecord]?
    var isSearching: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        fetchAllPosts()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(updateViews(_:)), name: PostController.PostsChangedNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.fetchAllPosts()
            self.resultsArray = PostController.shared.posts
            self.tableView.reloadData()
        }
    }
    
    @objc func updateViews(_ notification: Notification) {
        tableView.reloadData()
    }
    
    func fetchAllPosts(){
        PostController.shared.fetchAllPostsFromCloudKit { (posts) in
            if posts != nil {
                self.resultsArray = posts
                
                guard let posts = posts else {return}
                for post in posts {
                    PostController.shared.fetchComments(from: post, completion: { (success) in
                        if success{
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }else{
                self.showAlertMessage(titleStr: "Welp that's really not great....", messageStr: "I'm pretty sure there was an error Fetching all Posts")
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let resultsArray = resultsArray else {return 0}
        return resultsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postListCell", for: indexPath) as? PostTableViewCell
        guard let resultsArray = resultsArray else {return UITableViewCell()}
        let post = resultsArray[indexPath.row] as? Post
        cell?.post = post
        return cell ?? UITableViewCell()

    }
 

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let destinationVC = segue.destination as? PostDetailTableViewController
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let post = PostController.shared.posts[indexPath.row]
            destinationVC?.post = post
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBar.text else {return}
        let posts = PostController.shared.posts
        let filteredPosts = posts.filter{$0.matches(searchTerm: searchText)}
        let results = filteredPosts.map{$0 as SearchableRecord}
        resultsArray = results
        tableView.reloadData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        resultsArray = PostController.shared.posts
        tableView.reloadData()
    }


}
