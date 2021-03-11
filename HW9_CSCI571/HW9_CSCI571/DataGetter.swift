//
//  DataGetter.swift
//  HW9_CSCI571
//
//  Created by Mehr Sethi on 11/28/20.
//

import Foundation
import Alamofire
import SwiftyJSON

func getJSON(url: String, callback:@escaping (_ json: JSON) -> Void) {
    if let url = URL(string: (url)) {
        print("requesting: \(url)")
        AF.request(url).validate().responseJSON { (response) in
            if let data = response.data {
                let json = JSON(data)
                callback(json)
                return
            }
        }
    }
}

func printJSON(json: JSON) {
    print(json["ticker"].string!)
}


//var ticker = "AAPL"
//var urlTiingo = "https://api.tiingo.com/tiingo/daily/\(ticker)?token=53e6f1e82b9a80fc51d90ba68b9118383aaecd9f"
//getJSON(url: urlTiingo, callback: printJSON)


//other urls
//news api
//'https://newsapi.org/v2/everything?apiKey=b88549def1ed4e6bab1a0dad6e594390&q='+ticker
//search api
//https://api.tiingo.com/tiingo/utilities/search?query='+q.ticker+'&token=53e6f1e82b9a80fc51d90ba68b9118383aaecd9f'
