//
//  ContentView.swift
//  HW9_CSCI571
//
//  Created by Mehr Sethi on 11/26/20.
//

import SwiftUI

extension Date {
    func monthAsString() -> String {
            let df = DateFormatter()
            df.setLocalizedDateFormatFromTemplate("MMMM")
            return df.string(from: self)
    }
}

struct ContentView: View {
    @AppStorage("user")
    var userData: Data = Data()
    
    @State var update = false
    
    @ObservedObject var user: User = User()
//    var portfolioStocks: [StockItem] = stockListSample
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @ObservedObject var detailsModel: DetailsModel = DetailsModel()
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
//    let planets =
//            ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"] +
//            ["Ceres", "Pluto", "Haumea", "Makemake", "Eris"]
    
    var body: some View {
            NavigationView {
                if update {
                    List {
                    if self.searchBar.text.isEmpty {
//                        List {
                            //Date at the top
                            let currentDateTime = Date()
                            let calendar = Calendar.current
                            Text("\(currentDateTime.monthAsString()) "+"\(calendar.component(.day, from:currentDateTime)), "+"\(calendar.component(.year, from:currentDateTime))")
                                .foregroundColor(.secondary)
                                .fontWeight(.bold)
                                .font(.system(size:28))
                            
                            //Portfolio section
                        Section(header: Text("Portfolio").font(.system(size: 14)).fontWeight(.semibold)) {
                                VStack (alignment: .leading) {
                                    Text("Net Worth")
                                        .font(.system(size:26))
                                    Text("$ \(user.networth, specifier: "%.2f")")
                                        .font(.system(size:26))
                                        .fontWeight(.bold)
                                }
                                ForEach(user.portfolioStocks) { stock in
                                    StockCell(stock: stock, user: user, detailsModel: detailsModel)
                                }
                                .onMove(perform: moveStockPortfolio)
                            }
                            
                            //Favorite stocks section
                        Section(header: Text("Favorites").font(.system(size: 14)).fontWeight(.semibold)) {
                                ForEach(user.favoriteStocks) { stock in
                                    StockCell(stock: stock, user: user, detailsModel: detailsModel)
                                }
                                .onMove(perform: moveStockFavorites)
                                .onDelete(perform: deleteStockFavorites)
                            }
                            
                            //Powered by Tiingo
                            HStack {
                                Spacer()
                                Link("Powered by Tiingo", destination: URL(string: "https://www.tiingo.com")!)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
//                        }
//                        .navigationTitle("Stocks")
//                        .add(self.searchBar)
//                        .toolbar(content: {
//                            EditButton()
//                        })
//                        .onAppear {
//                            user.getNetworth()
//                        }
                    }
                    else {
//                        List {
                            ForEach(searchBar.stockTickerList, id: \.self) { eachStock in
                                let stockItem = searchBar.stockDict[eachStock] ?? StockItem(ticker:"N/A", stockName:"N/A", numShares:0.0, price:0.0, change:0.0, description:"N/A")
                                StockCellSmall(stock: stockItem, user: user, detailsModel: detailsModel)
                            }
//                        }
                    }
                    }
                    .navigationTitle("Stocks")
                    .add(self.searchBar)
                    .toolbar(content: {
                        EditButton()
                    })
                }
                else {
                    VStack {
                        ProgressView("Fetching Data...")
                            .scaleEffect(1, anchor: .center)
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    .navigationTitle("Stocks")
                }
                
            }
            .onAppear {
                self.user.objectWillChange.send()
                guard let u =  try? JSONDecoder().decode(User.self, from:userData) else { return }
                user.money = u.money
                user.networth = u.networth
                user.portfolioStocks = u.portfolioStocks
                user.favoriteStocks = u.favoriteStocks
                
                if user.portfolioStocks.count > 0 {
                    for i in 0...user.portfolioStocks.count-1 {
                        user.portfolioStocks[i].priceGetCall()
                    }
                }
                if user.favoriteStocks.count > 0 {
                    for i in 0...user.favoriteStocks.count-1 {
                        user.favoriteStocks[i].priceGetCall()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    user.getNetworth()
                    update = true
                }
//                        print("update toggled")
                print(user.portfolioStocks.count)
            }
            .onDisappear {
                guard let uData = try? JSONEncoder().encode(user) else { return }
                self.userData = uData
                update = false
            }
            .onReceive(timer) {  time in
                if user.portfolioStocks.count > 0 {
                    for i in 0...user.portfolioStocks.count-1 {
                        user.portfolioStocks[i].priceGetCall()
                    }
                }
                if user.favoriteStocks.count > 0 {
                    for i in 0...user.favoriteStocks.count-1 {
                        user.favoriteStocks[i].priceGetCall()
                    }
                }
                user.getNetworth()
            }
    }
    
    func moveStockFavorites(from:IndexSet, to:Int) {
        withAnimation {
            user.favoriteStocks.move(fromOffsets: from, toOffset: to)
        }
    }

    func deleteStockFavorites(offsets:IndexSet) {
        withAnimation {
            user.favoriteStocks.remove(atOffsets: offsets)
        }
    }
    
    func moveStockPortfolio(from:IndexSet, to:Int) {
        withAnimation {
            user.portfolioStocks.move(fromOffsets: from, toOffset: to)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(user: User())
    }
}

struct StockCell: View {
    @ObservedObject var stock: StockItem
    @ObservedObject var user: User
    var detailsModel: DetailsModel
    var body: some View {
        NavigationLink (destination: StockDetailView(stock: stock, ticker: stock.ticker.copy() as! String, user: user, detailsModel: detailsModel)){
            HStack {
                VStack(alignment: .leading) {
                    Text(stock.ticker)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                    if stock.numShares > 0 {
                        Text("\(stock.numShares, specifier: "%.2f") shares")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    else {
                        Text("\(stock.stockName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
//                .onAppear {
//                    stock.stockGetCall()
//                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(stock.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    if stock.change < 0 {
                        HStack {
                            Image(systemName: "arrow.down.forward")
                                .foregroundColor(.red)
                            Text("\(stock.change, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(Color.red)
                        }
                    }
                    else if stock.change > 0 {
                        HStack {
                            Image(systemName: "arrow.up.forward")
                                .foregroundColor(.green)
                            Text("\(stock.change, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(Color.green)
                        }
                    }
                    else {
                        Text("\(stock.change, specifier: "%.2f")")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                }
            }
        }
    }
}


struct StockCellSmall: View {
    @ObservedObject var stock: StockItem
    @ObservedObject var user: User
    var detailsModel: DetailsModel
    var body: some View {
        NavigationLink (destination: StockDetailView(stock: stock, ticker: stock.ticker.copy() as! String, user: user, detailsModel: detailsModel)){
            HStack {
                VStack(alignment: .leading) {
                    Text(stock.ticker)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                    if stock.numShares > 0 {
                        Text("\(stock.numShares, specifier: "%.2f") shares")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    else {
                        Text("\(stock.stockName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
//                .onAppear {
//                    stock.stockGetCall()
//                }
                Spacer()
            }
        }
    }
}
