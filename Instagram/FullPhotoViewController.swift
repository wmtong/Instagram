//
//  FullPhotoViewController.swift
//  Instagram
//
//  Created by Jordi Turner on 2/8/16.
//  Copyright © 2016 William Tong. All rights reserved.
//

import UIKit

class FullPhotoViewController: UIViewController, UIScrollViewDelegate {
    var image: UIImage!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func didScroll(sender: UIPinchGestureRecognizer) {
    }
    @IBAction func cancelButton(sender: UIButton) {
        print("cancel1")
        dismissViewControllerAnimated(false, completion: nil)
        print("cancel2")
    }
    @IBOutlet weak var fullImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullImageView.image = image
        scrollView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return fullImageView
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
