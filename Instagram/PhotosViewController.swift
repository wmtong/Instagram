//
//  ViewController.swift
//  Instagram
//
//  Created by William Tong on 1/28/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{

    var media: [NSDictionary]?
    var loadingMoreView:InfiniteScrollActivityView?
    var isMoreDataLoading = false
    
    @IBOutlet weak var tableView: UITableView!
    
    let CellIdentifier = "PhotoIdentifier", HeaderViewIdentifier = "TableViewHeaderView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 320;
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
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
        
        //tableView:didSelectRowAtIndexPath
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
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
    
    
    func loadMoreData() {
        
        // ... Create the NSURLRequest (myRequest) ...
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)

        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                // Update flag
                self.isMoreDataLoading = false
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                // ... Use the new data to update the data source ...
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.media = (responseDictionary["data"] as! [NSDictionary])
                            self.tableView.reloadData()
                    }
                }

                
                // Reload the tableView now that there is new data
                self.tableView.reloadData()
        });
        task.resume()
    }
    
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                loadMoreData()
            }
            
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        

        // Configure session so that completion handler is executed on main UI thread
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
                
                // Reload the tableView now that there is new data
                self.tableView.reloadData()
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()	
        });
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        let insta = media![indexPath!.section]
        
        let vc = segue.destinationViewController as! PhotoDetailsViewController
        
        vc.insta = insta
        
        
        
    }
    

}

class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .Gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.hidden = true
    }
    
    func startAnimating() {
        self.hidden = false
        self.activityIndicatorView.startAnimating()
    }
}

