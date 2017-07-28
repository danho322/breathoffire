//
//  TechniqueSearchViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/10/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class TechniqueSearchViewController: UIViewController, TechniqueSearchable {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchableArray: [SearchableData] = []
    var filteredSearchableArray: [SearchableData] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        isHeroEnabled = false
        
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        tableView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        ThemeManager.sharedInstance.formatSearchBar(searchBar)
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TechniqueTableCell", bundle: nil), forCellReuseIdentifier: "TechniqueCell")
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        searchableArray = DataLoader.sharedInstance.allSearchableData()
    }
}

// MARK: - SearchBarDelegate
extension TechniqueSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        handleSearchText(searchText: searchText) { [unowned self] filteredArray in
            self.filteredSearchableArray = filteredArray
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - TableViewDataSource
extension TechniqueSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSearchableArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TechniqueCell", for: indexPath)
        if let cell = cell as? TechniqueTableCell {
            if let data = filteredSearchableArray[safe: indexPath.row] {
                cell.titleLabel?.text = data.searchableString()
            }
        }
        return cell
    }
}
