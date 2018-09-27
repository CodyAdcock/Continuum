//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Cody on 9/25/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    @IBOutlet weak var captionTextField: UITextField!
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoSelectVC"{
            guard let destinationVC = segue.destination as? PhotoSelectViewController else {return}
            destinationVC.delegate = self
        }
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let photo = photo,
            let caption = captionTextField.text,
            !caption.isEmpty else {return}
        PostController.shared.createPostWith(image: photo, caption: caption) { (post) in
            
        }
        captionTextField.text = ""
        self.tabBarController?.selectedIndex = 0

    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        captionTextField.text = ""
        self.tabBarController?.selectedIndex = 0

    }

}
extension AddPostTableViewController: PhotoSelectViewControllerDelegate{
    func photoSelected(_ photo: UIImage) {
        self.photo = photo
    }
    
}

