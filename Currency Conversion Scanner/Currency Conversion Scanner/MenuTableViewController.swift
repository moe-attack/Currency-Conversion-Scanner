//
//  MenuTableViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 16/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    let constants = Constants.menu.self
    
    /*
     This function defines what happens when view is going to appear
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = constants.tabBarTitle
    }
    
    /*
     This function defines what happens when a view is loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    /*
     This function defines the number of sections in a tableview
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return constants.numberOfSection
    }

    /*
     This function defines the number of rows in each tableview section
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  constants.numberOfRow
    }

    /*
     This function defines how to set up a cell in a given tableview section
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: constants.MENU_CELL, for: indexPath) as! MenuTableViewCell
        switch indexPath.row{
        case 0:
            cell.containerText.text = constants.cellTextDefaultCurrency
        case 1:
            cell.containerText.text = constants.cellTextAbout
        default:
            ()
        }
        return cell
    }

    /*
     This function sets up the consequence after selected a row in the tableview
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "defaultCurrencySegue", sender: nil)
        case 1:
            performSegue(withIdentifier: "aboutSegue", sender: nil)
        default:
            ()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
