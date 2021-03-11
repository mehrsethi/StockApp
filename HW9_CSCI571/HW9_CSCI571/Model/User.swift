//
//  User.swift
//  HW9_CSCI571
//
//  Created by Mehr Sethi on 11/28/20.
//

import Foundation
import SwiftyJSON


class User: ObservableObject, Codable {
    @Published var portfolioStocks: [StockItem]
    @Published var favoriteStocks: [StockItem]
    @Published var money: Float
    @Published var networth: Float
//    var numSharesTemp: Float
    
    
    init(portfolioStocks: [StockItem] = [], favoriteStocks: [StockItem] = [], money: Float = 20000.00) {
        self.portfolioStocks = portfolioStocks
        self.favoriteStocks = favoriteStocks
        self.money = money
        self.networth = money
//        self.numSharesTemp = 0.0
        
        //test data add
//        self.populateTest()
    }
    
    func populateTest() {
        var ticker = "AAPL"
        stockGetCall(ticker: ticker, callback: self.addStockFavorites)
        
        ticker = "GOOG"
        stockGetCall(ticker: ticker, callback: self.addStockFavorites)
        
        ticker = "JJP"
        stockGetCall(ticker: ticker, callback: self.addStockFavorites)
        
        ticker = "AAPL"
//        stockGetCall(ticker: ticker, callback: self.addStockPortfolio)
//        numSharesTemp = 5.0
        
        ticker = "MSFT"
//        stockGetCall(ticker: ticker, callback: self.addStockPortfolio)
//        numSharesTemp = 10.0
    }
    
    //function for the call to the Tiingo API to get the stock based ticker
    func stockGetCall(ticker: String, callback: @escaping (JSON) -> Void) {
        let urlTiingoPrice = "https://api.tiingo.com/tiingo/daily/\(ticker)?token=53e6f1e82b9a80fc51d90ba68b9118383aaecd9f"
        getJSON(url: urlTiingoPrice, callback: callback)
    }
    
    //function for the call to the Tiingo API to get the latest price values for a ticker
    func priceGetCall(ticker: String) {
        let urlTiingoPrice = "https://api.tiingo.com/iex?tickers=\(ticker)&token=53e6f1e82b9a80fc51d90ba68b9118383aaecd9f"
        getJSON(url: urlTiingoPrice, callback: self.updatePrice)
    }
    
    //add a stock to one of the stock lists -- callback to getJSON (main Tiingo)
    func addStockFavorites(json: JSON) {
        favoriteStocks.append(StockItem(ticker: json["ticker"].string!, stockName: json["name"].string!, numShares: 0, price: 0.0, change: 0.0, description: json["description"].string!))
        self.priceGetCall(ticker: json["ticker"].string!)
    }
//    func addStockPortfolio(json: JSON) {
//        let s = StockItem(ticker: json["ticker"].string!, stockName: json["name"].string!, numShares: 0, price: 0.0, change: 0.0, description: json["description"].string!)
//        portfolioStocks.append(s)
//        self.priceGetCall(ticker: json["ticker"].string!)
//        print("num shares temp is \(numSharesTemp)")
//        self.updateFavorites(ticker: json["ticker"].string!, numShares: numSharesTemp)
//        money -= numSharesTemp*s.price
//    }
    
    //updates the prices of all stocks in both lists -- callback to getJSON (price Tiingo)
    func updatePrice(json: JSON) {
        let json1 = json[0]
        print(json1)
        if favoriteStocks.count > 0 {
            for i in 0...favoriteStocks.count-1 {
                if favoriteStocks[i].ticker == json1["ticker"].string {
                    favoriteStocks[i].price = json1["last"].float ?? 0.0
                    favoriteStocks[i].change = (json1["last"].float ?? 0.0) - (json1["prevClose"].float ?? 0.0)
                    print(favoriteStocks[i].change, json1["last"], json1["prevClose"].float ?? 0.0)
                    favoriteStocks[i].open = json1["open"].float ?? 0.0
                    favoriteStocks[i].high = json1["high"].float ?? 0.0
                    favoriteStocks[i].low = json1["low"].float ?? 0.0
                    favoriteStocks[i].mid = json1["mid"].float ?? 0.0
                    favoriteStocks[i].volume = json1["volume"].float ?? 0.0
                    favoriteStocks[i].bid = json1["bidPrice"].float ?? 0.0
                }
            }
        }
        if portfolioStocks.count > 0 {
            for i in 0...portfolioStocks.count-1 {
                if portfolioStocks[i].ticker == json1["ticker"].string {
                    portfolioStocks[i].price = json1["last"].float ?? 0.0
                    portfolioStocks[i].change = (json1["last"].float ?? 0.0) - (json1["prevClose"].float ?? 0.0)
                    portfolioStocks[i].open = json1["open"].float ?? 0.0
                    portfolioStocks[i].high = json1["high"].float ?? 0.0
                    portfolioStocks[i].low = json1["low"].float ?? 0.0
                    portfolioStocks[i].mid = json1["mid"].float ?? 0.0
                    portfolioStocks[i].volume = json1["volume"].float ?? 0.0
                    portfolioStocks[i].bid = json1["bidPrice"].float ?? 0.0
                }
            }
        }
    }
    
    func updateFavorites(ticker: String, numShares: Float) {
        if favoriteStocks.count > 0 {
            for i in 0...favoriteStocks.count-1 {
                if favoriteStocks[i].ticker == ticker {
                    favoriteStocks[i].numShares = numShares
                }
            }
        }
    }
    
    
    func addShares(stock: StockItem, numShares: Float) {
//        stockGetCall(ticker: ticker, callback: self.addStockPortfolio)
        stock.numShares = numShares
        portfolioStocks.append(stock)
        self.priceGetCall(ticker: stock.ticker)
        print("num shares temp is \(numShares)")
        self.updateFavorites(ticker: stock.ticker, numShares: numShares)
        money -= numShares*stock.price
        
//        for i in 0...portfolioStocks.count-1 {
//            if portfolioStocks[i].ticker == ticker {
//                portfolioStocks[i].numShares = numShares
//                money -= numShares*portfolioStocks[i].price
//            }
//        }
//
//        for i in 0...favoriteStocks.count-1 {
//            if favoriteStocks[i].ticker == ticker {
//                favoriteStocks[i].numShares = numShares
//            }
//        }
    }
    
    func updateShares(index: Int, numShares: Float) {
        portfolioStocks[index].numShares += numShares
        money -= numShares*portfolioStocks[index].price
        if favoriteStocks.count > 0 {
            for i in 0...favoriteStocks.count-1 {
                if favoriteStocks[i].ticker == portfolioStocks[index].ticker {
                    favoriteStocks[i].numShares += numShares
                }
            }
        }
    }
    
    func getNetworth() {
        networth = money
        if portfolioStocks.count > 0 {
            for i in 0...portfolioStocks.count-1 {
                networth += portfolioStocks[i].price*portfolioStocks[i].numShares
            }
        }
    }
    
    enum CodingKeys: CodingKey {
        case money
        case portfolioStocks
        case favoriteStocks
        case networth
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        money = try container.decode(Float.self, forKey: .money)
        networth = try container.decode(Float.self, forKey: .networth)
        favoriteStocks = try container.decode([StockItem].self, forKey: .favoriteStocks)
        let temp = try container.decode([StockItem].self, forKey: .portfolioStocks)
        portfolioStocks = try container.decode([StockItem].self, forKey: .portfolioStocks)
        print("Loaded stocks", temp.count)
        if temp.count > 0 {
            for c in temp {
                print(c.ticker)
            }
        }
//        numSharesTemp = 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(money, forKey: .money)
        try container.encode(networth, forKey: .networth)
        try container.encode(favoriteStocks, forKey: .favoriteStocks)
        print("Num stock atm", portfolioStocks.count)
        try container.encode(portfolioStocks, forKey: .portfolioStocks)
    }
    
    func favoriteStocksHas(ticker: String) -> Bool {
        if favoriteStocks.count > 0 {
            for i in 0...favoriteStocks.count-1 {
                if favoriteStocks[i].ticker == ticker {
                    return true
                }
            }
        }
        return false
    }
    
    func portfolioStocksHas(ticker: String) -> Bool {
        if portfolioStocks.count > 0 {
            for i in 0...portfolioStocks.count-1 {
                if portfolioStocks[i].ticker == ticker {
                    return true
                }
            }
        }
        return false
    }
    
    func getStock(ticker: String) -> StockItem {
        if portfolioStocks.count > 0 {
            for i in 0...portfolioStocks.count-1 {
                if portfolioStocks[i].ticker == ticker {
                    return portfolioStocks[i]
                }
            }
        }
        if favoriteStocks.count > 0 {
            for i in 0...favoriteStocks.count-1 {
                if favoriteStocks[i].ticker == ticker {
                    return favoriteStocks[i]
                }
            }
        }
        return StockItem()
    }
}


//let sampleUser = User(portfolioStocks: stockListSample, favoriteStocks: stockListSample2, money: 20000.00)
