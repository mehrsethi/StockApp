//
//  StockItem.swift
//  HW9_CSCI571
//
//  Created by Mehr Sethi on 11/27/20.
//

import Foundation
import SwiftyJSON

class StockItem: Identifiable, ObservableObject, Codable {
    
    var id = UUID()
    var ticker: String
    @Published var stockName: String
    @Published var numShares: Float
    @Published var price: Float
    @Published var change: Float
    @Published var description: String
    
    @Published var open: Float
    @Published var high: Float
    @Published var low: Float
    @Published var mid: Float
    @Published var volume: Float
    @Published var bid: Float

    init(ticker: String = "", stockName: String = "" , numShares: Float = 0.0, price: Float = 0.0, change: Float = 0.0, description: String = "", open: Float = 0.0, high: Float = 0.0, low: Float = 0.0, mid: Float = 0.0, volume: Float = 0.0, bid: Float = 0.0) {
        self.ticker = ticker
        self.stockName = stockName
        self.numShares = numShares
        self.price = price
        self.change = change
        self.description = description
        
        self.open = open
        self.high = high
        self.low = low
        self.mid = mid
        self.volume = volume
        self.bid = bid
        
    }
    
    enum CodingKeys: CodingKey {
        case ticker
        case stockName
        case numShares
        case price
        case change
        case description
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.ticker = try container.decode(String.self, forKey: .ticker)
        self.stockName = try container.decode(String.self, forKey: .stockName)
        self.numShares = try container.decode(Float.self, forKey: .numShares)
        self.price = try container.decode(Float.self, forKey: .price)
        self.change = try container.decode(Float.self, forKey: .change)
        self.description = try container.decode(String.self, forKey: .description)
        
        self.open = 0
        self.high = 0
        self.low = 0
        self.mid = 0
        self.volume = 0
        self.bid = 0
        
//        self.priceGetCall()
    }
    
    func stockGetCall() {
        let urlTiingoPrice = "https://api.tiingo.com/tiingo/daily/\(self.ticker)?token=53e6f1e82b9a80fc51d90ba68b9118383aaecd9f"
        getJSON(url: urlTiingoPrice, callback: getCallBack)
    }
    
    func getCallBack(json: JSON) {
        print(json)
        ticker = json["ticker"].string!
        stockName = json["name"].string!
        description = json["description"].string!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ticker, forKey: .ticker)
        try container.encode(stockName, forKey: .stockName)
        try container.encode(numShares, forKey: .numShares)
        try container.encode(price, forKey: .price)
        try container.encode(change, forKey: .change)
        try container.encode(description, forKey: .description)
    }
    
    
    func copy(other: StockItem) {
        self.ticker = other.ticker
        self.stockName = other.stockName
        self.numShares = other.numShares
        self.price = other.price
        self.change = other.change
        self.description = other.description
        
        self.open = other.open
        self.high = other.high
        self.low = other.low
        self.mid = other.mid
        self.volume = other.volume
        self.bid = other.bid
    }
    
    func priceGetCall() {
        let urlTiingoPrice = "https://api.tiingo.com/iex?tickers=\(self.ticker)&token=53e6f1e82b9a80fc51d90ba68b9118383aaecd9f"
        getJSON(url: urlTiingoPrice, callback: self.updatePrice)
    }
    
    func updatePrice(json: JSON) {
        let json1 = json[0]
        self.price = json1["last"].float ?? 0.0
        self.change = (json1["last"].float ?? 0.0) - (json1["prevClose"].float ?? 0.0)
        self.open = json1["open"].float ?? 0.0
        self.high = json1["high"].float ?? 0.0
        self.low = json1["low"].float ?? 0.0
        self.mid = json1["mid"].float ?? 0.0
        self.volume = json1["volume"].float ?? 0.0
        self.bid = json1["bidPrice"].float ?? 0.0
        
    }
}


//var stockListSample = [
//    StockItem(ticker: "APPL", stockName: "Apple", numShares: 10.0, price: 111.20, change: -5.4, description: "Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple"),
//    StockItem(ticker: "MSFT", stockName: "Microsoft", numShares: 5.0, price: 202.68, change: -10.57, description: "Sample description for Microsoft"),
//]
//
//var stockListSample2 = [
//    StockItem(ticker: "APPL", stockName: "Apple", numShares: 10.0, price: 111.20, change: -5.4, description: "Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple Sample description for Apple"),
//    StockItem(ticker: "MSFT", stockName: "Microsoft", numShares: 5.0, price: 202.68, change: -10.57, description: "Sample description for Microsoft"),
//    StockItem(ticker: "GOOG", stockName: "Google", numShares: 0.0, price: 1516.62, change: 87.64, description: "Sample description for Google")
//]
