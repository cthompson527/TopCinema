//
//  DetailsViewController.swift
//  TopCinema
//
//  Created by Cory Thompson on 1/28/16.
//  Copyright © 2016 Cory Thompson. All rights reserved.
//  swiftlint:disable trailing_whitespace
//  swiftlint:disable line_length

import UIKit

class DetailsViewController: UIViewController {
  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  @IBOutlet weak var infoView: UIView!
  var movie: NSDictionary!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let title = movie["title"] as? String
    titleLabel.text = title
    
    let overview = movie["overview"] as? String
    overviewLabel.text = overview
    overviewLabel.sizeToFit()
    
    if let posterPath = movie["poster_path"] as? String {
      let baseUrl = "http://image.tmdb.org/t/p/w500"
      let imageUrl = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
      
      posterImageView.setImageWithURLRequest(imageUrl,
        placeholderImage: nil,
        success: { (imageUrl, imageResponse, image) -> Void in
          if imageResponse != nil {
            print("Image was NOT cached, fade in image")
            self.posterImageView.alpha = 0.0
            self.posterImageView.image = image
            UIView.animateWithDuration(0.3,
              animations: {
                () -> Void in
                self.posterImageView.alpha = 1.0
            })
          } else {
            print("Image was cached so just update the image")
            self.posterImageView.image = image
          }
        },
        failure: { (imageRequest, imageResponse, error) -> Void in
          print("Image load failed")
      })
    }
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func hideDetails(sender: UITapGestureRecognizer) {
    if infoView.hidden {
      infoView.hidden = false
    } else {
      infoView.hidden = true
    }
    
  }
  /*
  // MARK: - Navigation
  // In a storyboard-based application, you will often want to do a little preparation before nav
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
}
