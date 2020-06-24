//
//  AddCurrencyViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 11/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation
import UIKit

class AddCurrencyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
        
    @IBOutlet weak var pickerView: UIPickerView!
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        buttonTapped()
    }
    
    weak var addCurrencyDelegate: AddCurrencyDelegate?
    let constants = Constants.addCurrency.self
    
    let pickerData = Constants.allCurrencies.ALL_CURRENCIES.sorted{ $0.country < $1.country }
    var selectedItem = ("", "")
    
    /*
     This function defines what happens when a view is loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Round corner and shadows to make app more presenting, also as one of the signature of the app.
        pickerView.layer.cornerRadius = 10
        addShadowsToView(view: pickerView)
        pickerView.setValue(UIColor(named: "maroonPurple"), forKey: "textColor")
        pickerView.delegate = self
        pickerView.dataSource = self
        // initiate the selected item to prevent error when save is tapped without selecting
        selectedItem = pickerData[0]
    }
    
    /*
     This function defines the number of components in pickerview
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /*
     This function defines the number of rows in each components in pickerview
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    /*
     This function defines the title for each row in pickerview
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: constants.pickerViewFormat, pickerData[row].country, pickerData[row].abbre)
    }
    
    /*
     This function defines the consequences after selecting a row in the pickerview
     */

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = pickerData[row]
    }
    
    /*
     This function is called when user tapped the Save button, and will pop the current view controller from stack
     */
    func buttonTapped(){
        navigationController?.popViewController(animated: true)
        // call the delegate function in CurrencyListeViewController and add the new currency in
        addCurrencyDelegate?.addNewCurrency(country_name: selectedItem.0, currencyAbbreviation: selectedItem.1)
    }
}
