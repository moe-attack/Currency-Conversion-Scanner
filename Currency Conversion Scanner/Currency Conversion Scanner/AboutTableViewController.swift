//
//  AboutTableViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 19/6/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {

    let ABOUT_CELL = "AboutCell"
    let ABOUT_CELL_INDEX = 0
    let CREDIT_CELL = "CreditCell"
    let CREDIT_CELL_INDEX = 1
    let creditList = [(name: String, link: String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case ABOUT_CELL_INDEX:
            return 1
        case CREDIT_CELL_INDEX:
            return creditList.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == ABOUT_CELL_INDEX {
            let cell = tableView.dequeueReusableCell(withIdentifier: ABOUT_CELL, for: indexPath) as! MenuTableViewCell
            cell.containerText.text = "About The App:\n\nThis app aims to provide travellers a way to easily convert the price tag of something they want to purchase in a foreign country, to their home currency (or any other currency they want). If there is any suggestion, do not hesitate to email:\n\n jlow0001@student.monash.edu\n\nHave a great day\n\n( ﾟ▽ﾟ)/\n\nApp Version 1.0"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CREDIT_CELL, for: indexPath) as! CreditTableViewCell
            cell.header.text = creditList[indexPath.row].name
            cell.body.text = creditList[indexPath.row].link
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case CREDIT_CELL_INDEX:
            return "Credit List"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
