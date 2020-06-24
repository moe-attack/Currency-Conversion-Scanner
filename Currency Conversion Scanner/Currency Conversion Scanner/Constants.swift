//
//  Constants.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 11/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation

/*
 The idea of having a Constant class is to minimize or even completely eliminate the number of hardcoded strings and magic numbers, by centralizing them into one file. It will make the constant strings highly manageable and maintainable, improving code quality.
 */
class Constants {
    
    enum persistentKey {
        static let currentLocation = "CurrentLocation"
        static let defaultCurrency = "DefaultCurrency"
    }
    
    enum allCurrencies {
        static let QUERY_URL = "https://api.exchangeratesapi.io/latest?base=%@"
        static let ALL_CURRENCIES: [(country: String, abbre: String)] = [
            ("Canada", "CAD"),
            ("Hong Kong", "HKD"),
            ("Iceland", "ISK"),
            ("Philippines", "PHP"),
            ("Denmark", "DKK"),
            ("Hungary", "HUF"),
            ("Czech Republic", "CZK"),
            ("United Kingdom", "GBP"),
            ("Romania", "RON"),
            ("Sweden", "SEK"),
            ("Indonesia", "IDR"),
            ("India", "INR"),
            ("Brazil", "BRL"),
            ("Russia", "RUB"),
            ("Croatia", "HRK"),
            ("Japan", "JPY"),
            ("Thailand", "THB"),
            ("Switzerland", "CHF"),
            ("Malaysia", "MYR"),
            ("Bulgaria", "BGN"),
            ("Turkey", "TRY"),
            ("China", "CNY"),
            ("Norway", "NOK"),
            ("New Zealand", "NZD"),
            ("South Africa", "ZAR"),
            ("United States of America", "USD"),
            ("Mexico", "MXN"),
            ("Singapore", "SGD"),
            ("Australia", "AUD"),
            ("Israel", "ILS"),
            ("South Korea", "KRW"),
            ("Poland", "PLN"),
        ]
    }
    
    enum splashScreen {
        static let logoText = "Travel anywhere\tScan anywhere"
    }
    
    enum currencyList {
        static let tabBarTitle = "Currency List"
        
        static let CURRENCY_CELL = "CurrencyListCell"
        static let ADD_CELL = "AddCurrencyCell"
        static let CURRENCY_CELL_INDEX = 0
        static let ADD_CELL_INDEX = 1
        
        static let defaultCurrencyHeaderFormat = "Default Currency: %@"
        static let rateLabelFormat = "1 %@ = %@ %@"
    }
    
    enum addCurrency {
        static let pickerViewFormat = "%@ - %@"
    }
    
    enum scanner {
        static let tabBarTitle = "Scanner"
    }
    
    enum defaultCurrency {
        static let pickerViewFormat = "%@ - %@"
    }
    
    enum menu {
        static let tabBarTitle = "Menu"
        
        static let MENU_CELL = "MenuCell"
        
        static let numberOfSection = 1
        static let numberOfRow = 2
        
        static let cellTextDefaultCurrency = "Change Default Currency"
        static let cellTextAbout = "About"
        
    }
    
    enum about {
        static let ABOUT_CELL = "AboutCell"
        static let CREDIT_CELL = "CreditCell"
        
        static let ABOUT_CELL_INDEX = 0
        static let CREDIT_CELL_INDEX = 1
        
        static let creditListHeader = "Credit List"
        
        static let aboutBodyText = "About The App:\n\nThis app aims to provide travellers a way to easily convert the price tag of something they want to purchase in a foreign country, to their home currency (or any other currency they want). If there is any suggestion, do not hesitate to email:\n\n jlow0001@student.monash.edu\n\nHave a great day\n\n( ﾟ▽ﾟ)/\n\nApp Version 1.0"
        
        static let creditList: [(name: String, link: String)] = [
            ("exchangeratesapi", "https://github.com/exchangeratesapi/exchangeratesapi"),
            ("LTMorphingLabel", "https://github.com/lexrus/LTMorphingLabel"),
            ("RAMAnimatedTabBarController", "https://github.com/Ramotion/animated-tab-bar"),
            ("Vision Text Recognition", "https://developer.apple.com/videos/play/wwdc2019/234")
        ]
    }
    
    enum alert {
        static let titleUnableProcess = "Unable to Process"
        static let titleScannedResult = "%@ %@ = %@ %@"
        
        static let dismiss = "Gotcha!"
        
        static let messageCurrencyLimit = "You can only add up to 8 currencies to monitor! \n m(_ _;m)"
        static let messageCurrencyExisted = "This currency already exists in the list! \nm(_ _;m)"
        static let messageINF = "If value 'INF' showed up, please try again! m(_ _;m)"
        static let messageLocationDisabled = "The current location service is disabled! Please enable it in device setting and try again!"
        static let messageNoCurrencyAbbre = "Sorry! We couldn't retreive the currency right now, please try to restart the app!"
    }
}
