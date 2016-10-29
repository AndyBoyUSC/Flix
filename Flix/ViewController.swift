//
//  ViewController.swift
//  Flix
//
//  Created by Andrew Szot on 9/20/16.
//  Copyright © 2016 AndrewSzot. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var movieTableView: UITableView!

    var allMovieData:[NSDictionary] = []
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieTableView.delegate = self
        movieTableView.dataSource = self
        
        self.loadData()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        movieTableView.addSubview(refreshControl)
    }
    
    func refresh(sender:AnyObject) {
        self.loadData()
        
        refreshControl.endRefreshing()
    }
    
    func loadData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.allMovieData = responseDictionary["results"] as! [NSDictionary]
                            self.movieTableView.reloadData()
                    }
                }
        })
        task.resume()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allMovieData.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieTableViewCellId", forIndexPath:indexPath) as! MovieTableViewCell
        
        let movieData = self.allMovieData[indexPath.row]
        if let posterLoc = movieData["poster_path"] as? String {
            let posterPath = "https://image.tmdb.org/t/p/w342" + posterLoc
            let posterURL = NSURL(string: posterPath)
            let data = NSData(contentsOfURL: posterURL!)
            
            cell.moviePosterImageView.image = UIImage(data: data!)
        }
        
        if let titleTxt = movieData["title"] as? String {
            cell.movieTitleLbl.text = titleTxt
        }
        
        if let descTxt = movieData["overview"] as? String {
            cell.movieDescLbl.text = descTxt
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

