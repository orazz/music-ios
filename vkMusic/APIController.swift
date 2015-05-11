//
//  APIController.swift
//  vkMusic
//
//  Created by Atakishiyev Orazdurdy on 5/9/15.
//  Copyright (c) 2015 veriloft. All rights reserved.
//

import Foundation

struct Config {
    
    static let VK_SERVER = "https://api.vk.com/"
    static let VK_AUDIO_SEARCH = VK_SERVER + "method/audio.search"
    static let ACCESS_TOKEN = "4d45c6ebef3b05a910071c948bb1374015c9e47ad953fba2f631d8bc1fca425a0a0bffcb4955d3af90c07"
}

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
}

class APIController {
    
    var delegate: APIControllerProtocol
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    
    func get(path: String) {
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            if let results: NSArray = jsonResult["response"] as? NSArray{
                self.delegate.didReceiveAPIResults(jsonResult) // THIS IS THE NEW LINE!!
            }
            
            
        })
        task.resume()
    }
    
    func searchVKFor(searchTerm: String, sort: String, count: String) {
        
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let VKSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = VKSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = Config.VK_AUDIO_SEARCH + "?q=\(escapedSearchTerm)" + "&sort=\(sort)" + "&access_token=\(Config.ACCESS_TOKEN)" + "&count=\(count)"// + "&v=5.31"
            get(urlPath)
        }
    }
    
    func lookupAlbum(collectionId: Int) {
        get("https://itunes.apple.com/lookup?id=\(collectionId)&entity=song")
    }
    
}