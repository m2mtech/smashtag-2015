//
//  WebViewController.swift
//  Smashtag
//
//  Created by Martin Mandl on 23.03.15.
//  Copyright (c) 2015 m2m server software gmbh. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
 
    var url: NSURL? {
        didSet {
            if view.window != nil {
                loadURL()
            }
        }
    }
    
    private func loadURL() {
        if url != nil {
            webView.loadRequest(NSURLRequest(URL: url!))
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        webView.scalesPageToFit = true
        loadURL()
    }
    
    // MARK: - UIWebView delegate

    var activeDownloads = 0
    
    func webViewDidStartLoad(webView: UIWebView) {
        activeDownloads++
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activeDownloads--
        if activeDownloads < 1 {
            spinner.stopAnimating()
        }
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
}
