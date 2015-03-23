//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Martin Mandl on 06.03.15.
//  Copyright (c) 2015 m2m server software gmbh. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell
{
    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    var hashtagColor = UIColor.blueColor()
    var urlColor = UIColor.redColor()
    var userMentionsColor = UIColor.greenColor()
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    func updateUI() {
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        if let tweet = self.tweet {
            var text = tweet.text
            
            for _ in tweet.media {
                text += " 📷"
            }
            
            var attributedText = NSMutableAttributedString(string: text)
            attributedText.changeKeywordsColor(tweet.hashtags, color: hashtagColor)
            attributedText.changeKeywordsColor(tweet.urls, color: urlColor)
            attributedText.changeKeywordsColor(tweet.userMentions, color: userMentionsColor)
            
            attributedText.changeKeywordsColor(tweet.mediaMentions, color: urlColor)
            
            tweetTextLabel?.attributedText = attributedText
            
            tweetScreenNameLabel?.text = "\(tweet.user)"
            
            self.tweetProfileImageView?.image = nil
            if let profileImageURL = tweet.user.profileImageURL {
                dispatch_async(dispatch_get_global_queue(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 ? Int(QOS_CLASS_USER_INITIATED.value) : DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    let imageData = NSData(contentsOfURL: profileImageURL)
                    dispatch_async(dispatch_get_main_queue()) {
                        if profileImageURL == tweet.user.profileImageURL {
                            if imageData != nil {
                                self.tweetProfileImageView?.image = UIImage(data: imageData!)
                            }
                        }
                    }
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
            
            if tweet.hashtags.count + tweet.urls.count + tweet.userMentions.count + tweet.media.count > 0 {
                accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            } else {
                accessoryType = UITableViewCellAccessoryType.None
            }
        }
    }
}

// MARK: - Extensions

private extension NSMutableAttributedString {
    func changeKeywordsColor(keywords: [Tweet.IndexedKeyword], color: UIColor) {
        for keyword in keywords {
            addAttribute(NSForegroundColorAttributeName, value: color, range: keyword.nsrange)
        }
    }
}
