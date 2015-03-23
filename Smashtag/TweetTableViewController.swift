//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Martin Mandl on 06.03.15.
//  Copyright (c) 2015 m2m server software gmbh. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets = [[Tweet]]()
    
    var lastSuccessfulRequest: TwitterRequest?
    var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                var query = searchText!
                if query.hasPrefix("@") {
                    query = "\(query) OR from:\(query)"
                }
                return TwitterRequest(search: query, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
        
    }
    
    var searchText: String? = "#stanford" {
        didSet {
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
        }
    }
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 {
            tableView.estimatedRowHeight = tableView.rowHeight
            tableView.rowHeight = UITableViewAutomaticDimension
        }
        
        if let first = navigationController?.viewControllers.first as? TweetTableViewController {
            if first == self {
                navigationItem.rightBarButtonItem = nil
            }
        }

        refresh()
    }

    func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            RecentSearches().add(searchText!)
            if let request = nextRequestToAttempt {
                request.fetchTweets { (newTweets) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if newTweets.count > 0 {
                            self.tweets.insert(newTweets, atIndex: 0)
                            self.tableView.reloadData()
                            self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections())), withRowAnimation: .None)
                            sender?.endRefreshing()
                            self.title = self.searchText
                        }
                    })
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
        static let MentionsIdentifier = "Show Mentions"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as TweetTableViewCell

        cell.tweet = tweets[indexPath.section][indexPath.row]

        return cell
    }
    
    // MARK: - Navitation
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == Storyboard.MentionsIdentifier {
            if let tweetCell = sender as? TweetTableViewCell {
                if tweetCell.tweet!.hashtags.count + tweetCell.tweet!.urls.count + tweetCell.tweet!.userMentions.count + tweetCell.tweet!.media.count == 0 {
                    return false
                }
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.MentionsIdentifier {
                if let mtvc = segue.destinationViewController as? MentionsTableViewController {
                    if let tweetCell = sender as? TweetTableViewCell {
                        mtvc.tweet = tweetCell.tweet
                    }
                }
            }
        }
    }
    
    @IBAction func unwindToRoot(sender: UIStoryboardSegue) { }
    
    override func canPerformUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject) -> Bool {
        if let first = navigationController?.viewControllers.first as? TweetTableViewController {
            if first == self {
                return true
            }
        }
        return false
    }
    
}
