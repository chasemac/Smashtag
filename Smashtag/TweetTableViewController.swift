//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Chase McElroy on 5/8/17.
//  Copyright © 2017 Chase McElroy. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewController: UITableViewController, UITextFieldDelegate {

    private var tweets = [Array<Twitter.Tweet>]() {
        didSet {
           // print(tweets)
        }
    }
    
    var searchText: String? {
        didSet {
            searchTextField?.text = searchText
            searchTextField?.resignFirstResponder()
            lastTwitterRequest = nil
            tweets.removeAll()
            tableView.reloadData()
            searchForTweets()
            title = searchText
        }
    }
    
    func insertTweets(_ newTweets: [Twitter.Tweet]) {
        self.tweets.insert(newTweets, at: 0)
        self.tableView.insertSections([0], with: .fade)
    }
    
    private func twitterRequest() -> Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: query, count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        if let request = lastTwitterRequest?.newer ?? twitterRequest() {
            lastTwitterRequest = request
            request.fetchTweets { [weak self] newTweets in
                DispatchQueue.main.async {
                    if request == self?.lastTwitterRequest {
                        self?.insertTweets(newTweets)
                    }
                    self?.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    @IBAction func refresh(_ sender: UIRefreshControl) {
        searchForTweets()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            searchText = searchTextField.text
        }
        return true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Tweet", for: indexPath)

        // Configure the cell...
        let tweet: Twitter.Tweet = tweets[indexPath.section][indexPath.row]
        
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
    
//        cell.textLabel?.text = tweet.text
//        cell.detailTextLabel?.text = tweet.user.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tweets.count-section)"
    }

    
}
