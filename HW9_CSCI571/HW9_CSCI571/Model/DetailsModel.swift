//
//  DetailsModel.swift
//  HW9_CSCI571
//
//  Created by Mehr Sethi on 11/29/20.
//

import Foundation
import SwiftyJSON

class DetailsModel: ObservableObject {
    @Published var newsList : [NewsItem]
//    @Published var stock: StockItem
    
    init(newsList: [NewsItem] = []) {
//        self.stock = stock
        self.newsList = newsList
    }
    
    func getNews(ticker: String) {
        let urlTiingoPrice = "https://newsapi.org/v2/everything?apiKey=b88549def1ed4e6bab1a0dad6e594390&q=\(ticker)"
        getJSON(url: urlTiingoPrice, callback: self.addToList)
    }
    
    func addToList(json: JSON){
        let currentDateTime = Date()
        let fmt = ISO8601DateFormatter()
        newsList = []
        
        let jsonBig = json["articles"]
        if jsonBig.count > 0 {
            for i in 0...jsonBig.count-1 {
                let json1 = jsonBig[i]
                
                let date1 = fmt.date(from: json1["publishedAt"].string!)!
                let diffs = Calendar.current.dateComponents([.minute, .hour, .day], from: date1, to: currentDateTime)
                var daysAgo: String
                
                
                if (diffs.day ?? 0) > 0 {
                    daysAgo = "\(diffs.day ?? 0) days ago"
                }
                else if (diffs.hour ?? 0) > 0 {
                    daysAgo = "\(diffs.hour ?? 0) hours ago"
                }
                else {
                    daysAgo = "\(diffs.minute ?? 0) minutes ago"
                }
                            
                self.newsList.append(NewsItem(headline: json1["title"].string ?? "", source: json1["source"]["name"].string ?? "", publishDate: json1["publishedAt"].string ?? "", imageURL: json1["urlToImage"].string ?? "", sourceURL: json1["url"].string ?? "", daysAgo: daysAgo))
            }
        }
    }
    
//    func priceGetCall(stock: StockItem) {
//        self.stock = stock
//        let urlTiingoPrice = "https://api.tiingo.com/iex?tickers=\(stock.ticker)&token=53e6f1e82b9a80fc51d90ba68b9118383aaecd9f"
//        getJSON(url: urlTiingoPrice, callback: stock.updatePrice)
//    }
    
//    func updatePrice(json: JSON) {
//        let json1 = json[0]
//        stock.price = json1["last"].float ?? 0.0
//        stock.change = (json1["last"].float ?? 0.0) - (json1["prevClose"].float ?? 0.0)
//        stock.open = json1["open"].float ?? 0.0
//        stock.high = json1["high"].float ?? 0.0
//        stock.low = json1["low"].float ?? 0.0
//        stock.mid = json1["mid"].float ?? 0.0
//        stock.volume = json1["volume"].float ?? 0.0
//        stock.bid = json1["bidPrice"].float ?? 0.0
//    }
}
