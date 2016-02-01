//
//  ViewController.swift
//  Instagram
//
//  Created by William Tong on 1/28/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    var media: [NSDictionary]?
    @IBOutlet weak var tableView: UITableView!
    
    let CellIdentifier = "PhotoIdentifier", HeaderViewIdentifier = "TableViewHeaderView"
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 320;
        
        //tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "PhotoCell")
        //tableView.registerClass(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)

        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.media = (responseDictionary["data"] as! [NSDictionary])
                            self.tableView.reloadData()
                    }
                }
        });
        task.resume()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let media = media{
            return media.count
        }else{
            return 0
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! PhotoCell
        
        let insta = media![indexPath.section]
        let images = insta["images"] as! NSDictionary
        let thumbnail = images["standard_resolution"] as! NSDictionary
        let url = thumbnail["url"] as! String
        
        let imageURL = NSURL(string: url)
        
        cell.PhotoView.setImageWithURL(imageURL!)
        //cell.PhotoView.setImageWithURL(profileURL!)
        
        
        print("row\(indexPath.row)")
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).CGColor
        profileView.layer.borderWidth = 1;

        let insta = media![section]
        let user = insta["user"] as! NSDictionary
        let posterPath = user["profile_picture"] as! String
        let profileURL = NSURL(string: posterPath)
        
        profileView.setImageWithURL(profileURL!)
        headerView.addSubview(profileView)
        
        let labelView = UILabel(frame: CGRect(x: 50, y: 10, width: 200, height: 30))
        let userPath = user["username"] as! String
        labelView.text = userPath
        headerView.addSubview(labelView)
        
        return headerView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

