//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Phong on 17/2/17.
//  Copyright © 2017 Phong. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    
    @IBOutlet weak var movieTableView: UITableView!
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var viewModeSegmentedControl: UISegmentedControl!
    
    var movies: [NSDictionary]?
    var endpoint: String?
    var refreshControl: UIRefreshControl!
    var isListviewMode: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign configuration for table view.
        movieTableView.dataSource = self
        movieTableView.delegate = self
        
        
        // Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshMoviesList(_:)), for: UIControlEvents.valueChanged)
        movieTableView.insertSubview(refreshControl, at: 0)
        
        fetchMoviesDB()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if let movies = movies{
            return movies.count
        }
        else{
            return 0
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        let baseURL = "https://image.tmdb.org/t/p/w342"
        if let posterPath = movie["poster_path"] as? String {
           
            let imageURL = URL(string: baseURL + posterPath)
            cell.posterImage.setImageWith(imageURL!)
        }
        else {
            cell.posterImage.image = nil
        }
    
        return cell;
    }
    
    func refreshMoviesList(_ refreshControl: UIRefreshControl) {
        print("Refresh movies list")
        fetchMoviesDB()
    }
    
    func fetchMoviesDB()  {
        
        // Pull movie db from network
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        self.movies = responseDictionary["results"] as! [NSDictionary]
                                        self.movieTableView.reloadData()
                                        
                                        // Hide HUD once the network request comes back (must be done on main UI thread)
                                        MBProgressHUD.hide(for: self.view, animated: true)
                                        
                                        // Tell the refreshControl to stop spinning movies list
                                        self.refreshControl.endRefreshing()
                                    }
                                } else {
                                    self.networkErrorView.isHidden = false
                                    self.networkErrorView.superview?.bringSubview(toFront: self.networkErrorView)
                                    print("Network Error")
                                }
            })
        task.resume()
    }
    
    @IBAction func viewModeChanged(_ sender: Any) {
        print("view mode changed")
        switch viewModeSegmentedControl.selectedSegmentIndex {
        case 1:
            isListviewMode = false
        default:
            isListviewMode = true
        }
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = movieTableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
    }
    

}
