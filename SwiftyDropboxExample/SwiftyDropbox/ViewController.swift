//
//  ViewController.swift
//  SwiftyDropbox
//
//  Created by krivoblotsky on 1/9/16.
//  Copyright © 2016 Home. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    //MARK: Properties
    
    dynamic var filenames: Array<DropBoxEntry>? = []

    //MARK: Actions
    
    @IBAction func getImagesButtonClicked(sender: AnyObject)
    {
        if let client = Dropbox.authorizedClient
        {
            self.filenames = []
            
            // List contents of app folder
            client.files.listFolder(path: "").response { response, error in
                if let result = response
                {
                    self.filenames = []
                    
                    var names:Array<String> = []
                    for entry in result.entries
                    {
                        // Check that file is a photo (by file extension)
                        if entry.name.hasSuffix(".jpg") || entry.name.hasSuffix(".png")
                        {
                            names.append(entry.name)
                        }
                    }
                    
                    self.filenames = names.map
                    {
                        let entry = DropBoxEntry(name: $0)
                        return entry
                    }
                }
            }
        }
        else
        {
            print("User is not authorized")
        }

    }
    @IBAction func linkToDropBoxButtonClicked(sender: AnyObject)
    {
        if (Dropbox.authorizedClient == nil)
        {
            Dropbox.authorizeFromController(self)
        }
        else
        {
            print("User is already authorized!")
        }
    }
    
    @IBAction func logoutButtonClicked(sender: AnyObject)
    {
        if let _ = Dropbox.authorizedClient
        {
            Dropbox.unlinkClient()
            self.filenames = []
        }
        else
        {
            print("User is not authorized")
        }
    }
}

