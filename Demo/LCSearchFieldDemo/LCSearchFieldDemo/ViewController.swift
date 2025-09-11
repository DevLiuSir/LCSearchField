//
//  ViewController.swift
//  LCSearchFieldDemo
//
//  Created by DevLiuSir on 2022/3/2.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var searchBar: LCSearchField!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.borderWidth = 2
        searchBar.customFocusRingType = .none
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

