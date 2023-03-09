//
//  NewConversationViewController.swift
//  MessengerApp
//
//  Created by sixpep on 21/02/23.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD()

    private let searchBar:UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()
    
//    private let tableView:UITableView = {
//       let table = UITableView()
//        table.isHidden = true
//        table.register(UITableView.self, forCellReuseIdentifier: "cell")
//        return table
//    }()

    private let noResultsLabel:UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Resuls"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21,weight: .medium)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
     
    
    @objc private func dismissSelf(){
        dismiss(animated: true)
    }

}

extension NewConversationViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
