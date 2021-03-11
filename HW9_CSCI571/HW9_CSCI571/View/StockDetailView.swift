//
//  StockDetailView.swift
//  HW9_CSCI571
//
//  Created by Mehr Sethi on 11/27/20.
//

import SwiftUI
import KingfisherSwiftUI

struct StockDetailView: View {
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    @State var expanded = false
    @State var popped = false
    
    @ObservedObject var stock: StockItem
    @State var ticker: String
    @ObservedObject var user: User
    @ObservedObject var detailsModel: DetailsModel
    
    @State var showToastAdded: Bool = false
    @State var showToastRemoved: Bool = false
    
//    @ObservedObject var newsItemList: [NewsItem] = []
    var body: some View {
        if stock.description == "" || stock.open == 0.0 || detailsModel.newsList.count == 0 {
            ProgressView("Fetching Data...")
                .scaleEffect(1, anchor: .center)
                .progressViewStyle(CircularProgressViewStyle())
                .onAppear {
                    print("main", detailsModel.newsList.count)
                    print("ticker", ticker)
                    if user.favoriteStocksHas(ticker: stock.ticker) {
                        stock.copy(other: user.getStock(ticker: stock.ticker))
                    }
                    if user.portfolioStocksHas(ticker: stock.ticker) {
                        stock.copy(other: user.getStock(ticker: stock.ticker))
                    }
        //            self.detailsModel.objectWillChange.send()
        //            stock.priceGetCall()
    //                            let t = stock.ticker
                    detailsModel.getNews(ticker: stock.ticker)
        //            stock.copy(other: detailsModel.stock)
                    stock.stockGetCall()
                    stock.priceGetCall()
                }
                .onReceive(timer) { time in
                    stock.priceGetCall()
                    print(detailsModel.newsList.count)
                }
                .onDisappear {
                    self.timer.upstream.connect().cancel()
                }
        }
        else {
            ZStack {
                ScrollView(.vertical) {
                    VStack {
                        //top
                        HStack {
                            VStack (alignment: .leading) {
    //                            Text("\(stock.ticker)")
    //                                .font(.system(size: 30))
    //                                .fontWeight(.bold)
    //                                .baselineOffset(10.0)
    //                                .multilineTextAlignment(.leading)

                                Text(stock.stockName)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.gray)
                                HStack {
                                    Text("$\(stock.price, specifier: "%.2f")")
                                        .font(.system(size: 28))
                                        .fontWeight(.bold)
                                    if stock.change < 0 {
                                        Text("($\(stock.change, specifier: "%.2f"))")
                                            .font(.system(size: 18))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.red)
                                            .baselineOffset(0.0)
                                    }
                                    else if stock.change > 0 {
                                        Text("($\(stock.change, specifier: "%.2f"))")
                                            .font(.system(size: 18))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.green)
                                            .baselineOffset(0.0)
                                    }
                                    else {
                                        Text("($\(stock.change, specifier: "%.2f"))")
                                            .font(.system(size: 18))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color.gray)
                                            .baselineOffset(0.0)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        
                        //HighChartsView
                        
                        //Portfolio section
                        Section {
                            PortfolioSection(stock: stock, user: user, popped: popped)
                        }
                        
                        //Stats Section
                        Section {
                            StatsSection(stock: stock)
                        }
                        .frame(minHeight: 130)
                        
                        //About Section
                        Section {
                            AboutSection(stock: stock, expanded: expanded)
                        }
                        .frame(minHeight: 130)

                        //News Section
                        Section {
                            NewsSection(newsItemList: $detailsModel.newsList)
                        }
                    }
    //                .frame(minWidth:0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                }
                .frame(minWidth:0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .onAppear {
                    print("main", detailsModel.newsList.count)
                    print("ticker", ticker)
        //            self.detailsModel.objectWillChange.send()
        //            stock.priceGetCall()
    //                            let t = stock.ticker
                    if stock.description == "" {
                        stock.stockGetCall()
                    }
        //            stock.copy(other: detailsModel.stock)
                    stock.priceGetCall()
                    detailsModel.getNews(ticker: stock.ticker)
                }
                .onReceive(timer) { time in
                    stock.priceGetCall()
                    print(detailsModel.newsList.count)
                }
                .onDisappear {
                    self.timer.upstream.connect().cancel()
                }
                .toolbar {
                    ToolbarItem() {
                        Button(action: {
                                if user.favoriteStocksHas(ticker: stock.ticker) == false {
                                    user.favoriteStocks.append(stock)
                                    showToastAdded = true
                                } else {
                                    for i in 0...user.favoriteStocks.count-1 {
                                        if stock.ticker == user.favoriteStocks[i].ticker {
                                            user.favoriteStocks.remove(at: i)
                                            showToastRemoved = true
                                            break
                                        }
                                    }
                                }
                        }) {
                            user.favoriteStocksHas(ticker: stock.ticker) ? Image(systemName: "plus.circle.fill"): Image(systemName: "plus.circle")
                        }
                    }
                }
                .navigationBarTitle(stock.ticker)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        if showToastAdded {
                            Toast(isShowing: $showToastAdded,
                                  text: Text("Adding \(stock.ticker) to Favorites"))
                        }
                        if showToastRemoved {
                            Toast(isShowing: $showToastRemoved,
                                  text: Text("Removing \(stock.ticker) from Favorites"))
                        }
                        Spacer()
                    }
                }
                .frame(minHeight: 0, maxHeight: .infinity)
            }
        }

    }
}


struct StockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StockDetailView(stock: User().favoriteStocks[0], ticker: User().favoriteStocks[0].ticker.copy() as! String, user: User(), detailsModel: DetailsModel())
    }
}


struct PortfolioSection: View {
    @ObservedObject var stock: StockItem
    @ObservedObject var user: User
    @State var popped: Bool
    var body: some View {
        VStack {
            HStack {
                Text("Portfolio")
                    .font(.system(size:24))
//                    .fontWeight(.semibold)
                Spacer()
            }
            HStack {
                VStack(alignment: .leading) {
                    if stock.numShares == 0 {
                        Text("You have 0 shares of \(stock.ticker). \nStart trading!")
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                    }
                    else {
                        Text("Shares Owned: \(stock.numShares, specifier: "%.2f")")
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 0))
                        Text("Market Value: $\(stock.price*stock.numShares, specifier: "%.2f")")
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Button(action: {popped.toggle()}) {
                        Text("Trade")
                            .padding(EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 40))
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .sheet(isPresented: $popped) {
                                PopUpView(stock:stock, user: user, isPresented: self.$popped)
                            }
                    }
                }
            }
        }
        .padding()
    }
}

struct StatsSection: View {
    @ObservedObject var stock: StockItem
    var body: some View {
        VStack {
            HStack {
                Text("Stats")
                    .font(.system(size:24))
//                    .fontWeight(.semibold)
                Spacer()
            }
            
            let priceList = ["Current Price: ", "Open Price: ", "High: ", "Low: ", "Mid: ", "Volume: ", "Bid Price: "]
            let valList = [stock.price, stock.open, stock.high, stock.low, stock.mid, stock.volume, stock.bid]
            
            let rows: [GridItem] = [GridItem(.fixed(20)), GridItem(.fixed(20)), GridItem(.fixed(20))]
            ScrollView(.horizontal) {
                LazyHGrid(rows: rows) {
                    ForEach((0...6), id: \.self) {
                        Text("\(priceList[$0 % priceList.count])\(valList[$0 % priceList.count], specifier: "%.2f")")
                            .frame(minWidth: 200, alignment: .leading)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 5))
                    }
                }
            }
        }
        .padding()
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct AboutSection: View {
    @ObservedObject var stock: StockItem
    @State var expanded: Bool
    var body: some View {
        VStack {
            HStack {
                Text("About")
                    .font(.system(size:24))
//                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            
            
            if expanded {
                Text(stock.description)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 5, trailing: 15))
            }
            else {
                Text(stock.description)
                    .lineLimit(2)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 5, trailing: 15))
            }
            
            HStack {
                Spacer()
                Button(action: {expanded.toggle()}) {
                    if expanded {
                        Text("Show Less")
                            .font(.system(size:12))
                            .foregroundColor(.gray)
                    }
                    else {
                        Text("Show More")
                            .font(.system(size:12))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
        }
    }
}


struct NewsCell: View {
    var news: NewsItem
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(news.source)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 12))
//                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))

                    Text(news.daysAgo)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 12))
//                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    Spacer()
                }
                .frame(minWidth:0, maxWidth: .infinity)
                
                HStack {
                    Text(news.headline)
                    .fontWeight(.semibold)
//                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .lineLimit(3)
                    
                    Spacer()
                }
                .frame(minWidth:0, maxWidth: .infinity)
            }
            Spacer()
            
            KFImage(URL(string: news.imageURL) ?? URL(string: "https://www.publicdomainpictures.net/en/view-image.php?image=270609&picture=not-found-image"))
                .resizable()
                .scaledToFill()
                .frame(width:80, height:80, alignment: .center)
                .cornerRadius(10)
                .clipped()
//                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 25))
                
        }
    }
}



//main view that pops up when 'trade' button is clicked
struct PopUpView: View {
    @ObservedObject var stock: StockItem
    @ObservedObject var user: User
    @Binding var isPresented: Bool
    @State var numberOfShares = ""
    @State var buyButtonOn = false
    @State var sellButtonOn = false
    @State var showToastSharesExceed: Bool = false
    @State var showToastMoneyExceed: Bool = false
    @State var showToastSellNegative: Bool = false
    @State var showToastBuyNegative: Bool = false
    @State var showToastInvalidInput: Bool = false
    
    var body: some View {
        if buyButtonOn {
            TradeSuccess(stock:stock, numberOfShares:numberOfShares, isPresented:self.$isPresented, trade:"buy")
        }
        else if sellButtonOn {
            TradeSuccess(stock:stock, numberOfShares:numberOfShares, isPresented:self.$isPresented, trade:"sell")
        }
        else {
            VStack {
                HStack {
                    Button(action: { self.isPresented = false}) {
                        Text("X")
                            .padding(EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 40))
                            .foregroundColor(.black)
                            .cornerRadius(24)
                    }
                    Spacer()
                }
                
                Text("Trade \(stock.stockName) shares")
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                VStack {
                    Spacer()
                    
                    VStack {
                        HStack {
                            let binding = Binding<String>(get: {
                                self.numberOfShares
                            }, set: {
                                self.numberOfShares = $0
                            })
                            
                            TextField("0", text: binding,
                                      onCommit: {
                                        
                                      })
                                .keyboardType(.numberPad)
                                .foregroundColor(.black)
                                .font(.system(size: 100))
                            
                            if (Float(self.numberOfShares) ?? 0.0) == 1 {
                                Text("Share")
                                .foregroundColor(.black)
                                .font(.system(size: 40))
                            }
                            else {
                                Text("Shares")
                                    .foregroundColor(.black)
                                    .font(.system(size: 40))
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Text("x $\(stock.price, specifier: "%.2f")/share = $\(stock.price*(Float(numberOfShares) ?? 0.0), specifier: "%.2f")")
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text("\(user.money, specifier:"%.2f") available to buy \(stock.ticker)")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    
                }
            }
            ZStack {
                HStack {
                    Button(action: {
                        
                        var found = false
                        if user.portfolioStocks.count > 0 {
                            for i in 0...user.portfolioStocks.count-1 {
                                if user.portfolioStocks[i].ticker == stock.ticker {
                                    found = true
                                    let fl = Float(numberOfShares) ?? -1.0
                                    if fl == -1.0 {
                                        showToastInvalidInput = true
                                    }
                                    else if fl <= 0 {
                                        showToastBuyNegative = true
                                    }
                                    else if user.money < fl*stock.price {
                                        showToastMoneyExceed = true
                                    }
                                    else {
                                        buyButtonOn = true
                                        user.updateShares(index: i, numShares: Float(numberOfShares) ?? 0.0)
                                    }
                                }
                            }
                        }
                        if !found {
                            let fl = Float(numberOfShares) ?? -1.0
                            if fl == -1.0 {
                                showToastInvalidInput = true
                            }
                            else if fl <= 0 {
                                showToastBuyNegative = true
                            }
                            else if user.money < fl*stock.price {
                                showToastMoneyExceed = true
                            }
                            else {
                                buyButtonOn = true
                                user.addShares(stock: stock, numShares: Float(numberOfShares) ?? 0.0)
                                
                            }
                        }
                    }) {
                        Text("Buy")
                            .padding(EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 40))
                            .frame(minWidth:0, maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(24)
                    }
                    .padding()
                    Spacer()
                    Button(action: {
                        if user.portfolioStocks.count > 0 {
                            for i in 0...user.portfolioStocks.count-1 {
                                if user.portfolioStocks[i].ticker == stock.ticker {
                                    let fl = Float(numberOfShares) ?? -1.0
                                    if fl == -1.0 {
                                        showToastInvalidInput = true
                                    }
                                    else if fl <= 0 {
                                        showToastSellNegative = true
                                    }
                                    else if user.portfolioStocks[i].numShares < fl {
                                        showToastSharesExceed = true
                                    }
                                    else {
                                        sellButtonOn = true
                                        user.updateShares(index: i, numShares: (-1*(Float(numberOfShares) ?? 0.0)))
                                        print("number of shares \(numberOfShares)")
                                        print(user.portfolioStocks[i].numShares)
                                        if user.portfolioStocks[i].numShares == 0 {
                                            user.portfolioStocks.remove(at: i)
                                        }
                                    }
                                }
                            }
                        }
                    }) {
                        Text("Sell")
                            .padding(EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 40))
                            .frame(minWidth:0, maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(24)
                    }
                    .padding()
                }
                if showToastInvalidInput {
                    Toast(isShowing: $showToastInvalidInput,
                          text: Text("Please enter a valid amount"))
                }
                if showToastBuyNegative {
                    Toast(isShowing: $showToastBuyNegative,
                          text: Text("Cannot buy less than 0 shares"))
                }
                if showToastSellNegative {
                    Toast(isShowing: $showToastSellNegative,
                          text: Text("Cannot sell less than 0 shares"))
                }
                if showToastSharesExceed {
                    Toast(isShowing: $showToastSharesExceed,
                          text: Text("Not enough shares to sell"))
                }
                if showToastMoneyExceed {
                    Toast(isShowing: $showToastMoneyExceed,
                          text: Text("Not enough money to buy"))
                }
            }
            .frame(height: 100)
            
        }
    }
}

//green background view with the congratulations message on successfully trading shares
struct TradeSuccess: View {
    var stock: StockItem
    var numberOfShares: String
    @Binding var isPresented: Bool
    var trade: String
    var body: some View {
        VStack {
            
            Spacer()
            
            VStack {
                Text("Congratulations!")
                    .foregroundColor(.white)
                    .font(.system(size: 38))
                    .fontWeight(.bold)

                if trade == "sell" {
                    if (Float(numberOfShares) ?? 0.0) > 1 {
                        Text("You have successfully sold \(numberOfShares) shares of \(stock.ticker)")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .frame(maxWidth: .infinity)
                    }
                    else {
                        Text("You have successfully sold \(numberOfShares) share of \(stock.ticker)")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .frame(maxWidth: .infinity)
                    }
                }
                else {
                    if (Float(numberOfShares) ?? 0.0) > 1 {
                        Text("You have successfully bought \(numberOfShares) shares of \(stock.ticker)")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .frame(maxWidth: .infinity)
                    }
                    else {
                        Text("You have successfully bought \(numberOfShares) share of \(stock.ticker)")
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            
            Spacer()
            
            Button(action: { self.isPresented = false}) {
                Text("Done")
                    .padding(EdgeInsets(top: 10, leading: 40, bottom: 10, trailing: 40))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(.green)
                    .cornerRadius(24)
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 50, trailing: 15))
            
        }
        .background(Color.green)
        .edgesIgnoringSafeArea(.bottom)
    }
}

//View that pops up with text field for inputting the number of shares to buy/sell
//struct TradePopUpView: View {
//    var stock: StockItem
//    @Binding var isPresented: Bool
//    @State var numberOfShares: String
//
//    var body: some View {
//
//    }
//}

struct NewsSection: View {
    @Binding<[NewsItem]> var newsItemList: [NewsItem]
    
    var body: some View {
        VStack {
        HStack {
            Text("News")
                .font(.system(size:24))
//                .fontWeight(.semibold)
            Spacer()
        }
        .padding()
        
        //first news item
        if newsItemList.count > 0 {
            VStack {
                Link(destination: URL(string: newsItemList[0].sourceURL)!) {
                    VStack {
                        KFImage(URL(string: newsItemList[0].imageURL)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        HStack {
                            Text(newsItemList[0].source)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 12))
//                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))

                            Text(newsItemList[0].daysAgo)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 12))
//                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                            Spacer()
                        }
                        .frame(minWidth:0, maxWidth: .infinity)

                        HStack {
                            Text(newsItemList[0].headline)
                                .foregroundColor(.black)
                                .fontWeight(.semibold)
//                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 15))
                            Spacer()
                        }
                        .frame(minWidth:0, maxWidth: .infinity)
                    }
                    .frame(minWidth:0, maxWidth: .infinity)
                    .padding()
                }
                .background(Color.white)
                .cornerRadius(15)
                .onAppear {
                    print("news section", newsItemList.count)
                }
                .contextMenu {
                    Link(destination: URL(string: newsItemList[0].sourceURL)!) {
                        Label("Open in Safari", systemImage: "safari")
                    }

                    Link(destination: URL(string:"https://twitter.com/intent/tweet?text=Check%20out%20this%20this%20link:&url=\(newsItemList[0].sourceURL)&hashtags=CSCI570StockApp")!) {
                        Label("Share on Twitter", systemImage: "square.and.arrow.up")
                    }
                }

            
                Divider()
                
                //list of other news items
                if newsItemList.count > 1 {
                    List {
                        ForEach(Array(newsItemList[1...newsItemList.count-1])) {newsItem in
                            Link(destination: URL(string: newsItem.sourceURL)!) {
                                NewsCell(news: newsItem)
                            }
                            .contextMenu {
                                Link(destination: URL(string: newsItem.sourceURL)!) {
                                    Label("Open in Safari", systemImage: "safari")
                                }
                                
                                let text = "Check%20out%20this%20link:"
                                let url = newsItem.sourceURL
                                let hashtag = "CSCI571StockApp"
                                Link(destination: URL(string: "https://twitter.com/intent/tweet?text=\(text)&url=\(url)&hashtags=\(hashtag)")!) {
                                    Label("Share on Twitter", systemImage: "square.and.arrow.up")
                                }
                            }
                        }
                    }
                    .frame(minHeight: 0, idealHeight: CGFloat(newsItemList.count-1)*95, maxHeight: .infinity)
//                    .onAppear {
//                        UITableView.appearance().isScrollEnabled = false
//                    }

                }
                
            }
//                .frame(minHeight: 0, idealHeight: CGFloat(newsItemList.count-1)*110+250, maxHeight: .infinity)

        }
    }
    }

}


//CODE TAKEN FROM https://stackoverflow.com/questions/56550135/swiftui-global-overlay-that-can-be-triggered-from-any-view
struct Toast: View {

    /// The binding that decides the appropriate drawing in the body.
    @Binding var isShowing: Bool
    /// The text to show
    let text: Text

    var body: some View {

//        GeometryReader { geometry in

//            ZStack(alignment: .center) {


                VStack {
                    self.text
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                .background(Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(20)
////                .transition(.slide)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        print(self.isShowing)

                      withAnimation {
                        self.isShowing = false
                      }
                        print(self.isShowing)

                    }
                }
                .opacity(self.isShowing ? 1 : 0)

//            }

//        }

    }
}
