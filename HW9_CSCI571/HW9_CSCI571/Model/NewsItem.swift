//
//  NewsItem.swift
//  HW9_CSCI571
//
//  Created by Mehr Sethi on 11/28/20.
//

import Foundation

struct NewsItem: Identifiable {
    var id = UUID()
    var headline: String
    var source: String
    var publishDate: String
    var imageURL: String
    var sourceURL: String
    var daysAgo: String
}


//let newsItemListSample = [
//    NewsItem(headline: "Insert some headline here that's kinda long", source: "Business Insider", publishDate: "Gonna keep this as 6 days ago for now", imageURL: "...", sourceURL: "https://www.google.com"),
//    NewsItem(headline: "Insert some headline here that's kinda long", source: "Business Insider", publishDate: "Gonna keep this as 6 days ago for now", imageURL: "...", sourceURL: "https://www.google.com"),
//    NewsItem(headline: "Insert some headline here that's kinda long", source: "Business Insider", publishDate: "Gonna keep this as 6 days ago for now", imageURL: "...", sourceURL: "https://www.google.com")
//]
