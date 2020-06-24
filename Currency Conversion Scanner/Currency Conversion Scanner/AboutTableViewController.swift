//
//  AboutTableViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 19/6/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {

    let constants = Constants.about.self
    
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
        return 2
    }

    /*
     This function defines the number of rows in each tableview section
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case constants.ABOUT_CELL_INDEX:
            return 1
        case constants.CREDIT_CELL_INDEX:
            return constants.creditList.count
        default:
            return 0
        }
    }

    /*
     This function defines how to set up a cell in a given tableview section
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == constants.ABOUT_CELL_INDEX {
            let cell = tableView.dequeueReusableCell(withIdentifier: constants.ABOUT_CELL, for: indexPath) as! MenuTableViewCell
            cell.containerText.text = constants.aboutBodyText
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: constants.CREDIT_CELL, for: indexPath) as! CreditTableViewCell
            cell.header.text = constants.creditList[indexPath.row].name
            cell.body.text = constants.creditList[indexPath.row].link
            return cell
        }
    }

    /*
     This function shows the header of a tableview section
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case constants.CREDIT_CELL_INDEX:
            return constants.creditListHeader
        default:
            return nil
        }
    }
    
    /*
     This function deselect row when row is selected, as all currency list rows doesn't have explicit selection functionality
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
