//
//  SearchBar.swift
//  HW9_CSCI571
//
//  Created by Mehr Sethi on 11/28/20.
//
//FOLLOWING CODE IS TAKEN FROM https://github.com/Geri-Borbas/iOS.Blog.SwiftUI_Search_Bar_in_Navigation_Bar/blob/main/SwiftUI_Search_Bar_in_Navigation_Bar/SearchBar/SearchBar.swift

import SwiftUI
import SwiftyJSON

class SearchBar: NSObject, ObservableObject {
    
    @Published var text: String = ""
    @Published var stockDict: [String: StockItem] = [:]
    @Published var stockTickerList: [String] = []
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    override init() {
        super.init()
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchResultsUpdater = self
    }
}

extension SearchBar: UISearchResultsUpdating {
   
    func updateSearchResults(for searchController: UISearchController) {
        
        // Publish search bar text changes.
        let debouncer = Debouncer(delay: 0.5)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            debouncer.run(action: {
                if let searchBarText = searchController.searchBar.text {
                    self.text = searchBarText
                    if self.text.count >= 3 {
                        let urlTiingoPrice = "https://api.tiingo.com/tiingo/utilities/search?query=\(self.text)&token=53e6f1e82b9a80fc51d90ba68b9118383aaecd9f"
                        getJSON(url: urlTiingoPrice, callback: self.updateList)

                    }
                }
            })
        })
    }
    
    func updateList(json: JSON) {
        stockTickerList = []
        stockDict = [:]
        if json.count > 0 {
            for i in 0...json.count-1 {
                let item = json[i]
                stockTickerList.append(item["ticker"].string ?? "")
                print(item["ticker"].string ?? "")
                stockDict[item["ticker"].string ?? ""] = StockItem(ticker: item["ticker"].string ?? "", stockName: item["name"].string ?? "", numShares: 0, price: 0, change: 0, description: "")
            }
        }
    }
}

struct SearchBarModifier: ViewModifier {
    
    let searchBar: SearchBar
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ViewControllerResolver { viewController in
                    viewController.navigationItem.searchController = self.searchBar.searchController
                }
                    .frame(width: 0, height: 0)
            )
    }
}

extension View {
    
    func add(_ searchBar: SearchBar) -> some View {
        return self.modifier(SearchBarModifier(searchBar: searchBar))
    }
}
