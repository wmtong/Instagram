//
//  PhotoDetailsViewController.swift
//  Instagram
//
//  Created by Jordi Turner on 2/4/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    
    
    @IBAction func didTouch(sender: UITapGestureRecognizer) {
        performSegueWithIdentifier("firstSegue", sender: self)
        
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var detailProfileView: UIImageView!
    @IBOutlet weak var detailImageView: UIImageView!
    var insta: NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let images = insta["images"] as! NSDictionary
        let thumbnail = images["standard_resolution"] as! NSDictionary
        let url = thumbnail["url"] as! String
        let user = insta["user"] as! NSDictionary
        let userPath = user["username"] as! String
        let posterPath = user["profile_picture"] as! String
        let profileURL = NSURL(string: posterPath)
        usernameLabel.text = userPath
        detailProfileView.setImageWithURL(profileURL!)

        
        let imageURL = NSURL(string: url)
        detailImageView.setImageWithURL(imageURL!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let destinationViewController = segue.destinationViewController as! FullPhotoViewController
        
        destinationViewController.image = self.detailImageView.image
        
    }

}
