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

        searchBar.useAccentColorWhenEditing = false
        searchBar.borderWidth = 2
        searchBar.customFocusRingType = .none
    }
    
}

