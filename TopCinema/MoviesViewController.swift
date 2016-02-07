//
//  MoviesViewController.swift
//  TopCinema
//
//  Created by Cory Thompson on 1/13/16.
//  Copyright © 2016 Cory Thompson. All rights reserved.
//  swiftlint:disable trailing_whitespace
//  swiftlint:disable line_length
//  swiftlint:disable force_try

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController {
  
  @IBOutlet weak var navigationBar: UINavigationItem!
  @IBOutlet weak var collectionView: UICollectionView!
  
  var movies: [NSDictionary]?
  var endpoint: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    // Do any additional setup after loading the view.
    
    loadDataFromNetwork()
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
    collectionView.insertSubview(refreshControl, atIndex: 0)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if let movies = movies {
      return movies.count
    } else {
      return 0
    }
  }
  
  
  func loadDataFromNetwork() {
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
    let request = NSURLRequest(URL: url!)
    
    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate:nil,
      delegateQueue:NSOperationQueue.mainQueue()
    )
    
    let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
      completionHandler: { (dataOrNil, response, error) in
        if let data = dataOrNil {
          if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
            data, options:[]) as? NSDictionary {
              NSLog("response: \(responseDictionary)")
              
              self.movies = responseDictionary["results"] as? [NSDictionary]
              self.collectionView.reloadData()
              MBProgressHUD.hideHUDForView(self.view, animated: true)
              
          }
        }
    });
    task.resume()
  }
  
  func refreshControlAction(refreshControl: UIRefreshControl) {
    // fetch latest data
    
    // request is successful
    self.collectionView.reloadData()
    refreshControl.endRefreshing()
  }
  
  
  
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let cell = sender as? UICollectionViewCell {
      let indexPath = collectionView.indexPathForCell(cell)
      let movie = movies![indexPath!.row]
      if let detailViewController = segue.destinationViewController as? DetailsViewController {
        detailViewController.movie = movie
      }
    }
    
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
  }
  
  
}

extension MoviesViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let movies = movies {
      return movies.count
    } else {
      return 0
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell: MovieCell!
    cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as? MovieCell
    let movie = movies![indexPath.row]
    let _ = movie["title"] as? String
    let _ = movie["overview"] as? String
    
    if let posterPath = movie["poster_path"] as? String {
      let baseUrl = "http://image.tmdb.org/t/p/w500"
      let imageUrl = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
      
      cell.posterView.setImageWithURLRequest(imageUrl,
        placeholderImage: nil,
        success: { (imageUrl, imageResponse, image) -> Void in
          if imageResponse != nil {
            print("Image was NOT cached, fade in image")
            cell.posterView.alpha = 0.0
            cell.posterView.image = image
            UIView.animateWithDuration(0.3,
              animations: {
                () -> Void in
                cell.posterView.alpha = 1.0
            })
          } else {
            print("Image was cached so just update the image")
            cell.posterView.image = image
          }
        },
        failure: { (imageRequest, imageResponse, error) -> Void in
          print("Image load failed")
      })
    }
    
    print("row \(indexPath.row)")
    return cell
    
  }
}
