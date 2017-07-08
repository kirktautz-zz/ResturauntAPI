//
//  ReviewItem.swift
//  ResturauntAPI
//
//  Created by Kirk Tautz on 7/7/17.
//
//

import Foundation

public struct ReviewItem {
    
    public let reviewId: String
    public let userId: String
    public let reviewTitle: String
    public let reviewContent: String
    public let postDate: Date
    public let rating: Int
    public let parentItem: String
    
    public init(reviewId: String, userId: String, reviewTitle: String, reviewContent: String, postDate: Date, rating: Int, parentItem: String) {
        
        self.reviewId = reviewId
        self.userId = userId
        self.reviewTitle = reviewTitle
        self.reviewContent = reviewContent
        self.rating = rating
        self.postDate = postDate
        self.parentItem = parentItem
    }
}

extension ReviewItem: DictionaryConvertable {
    func toDict() -> JSONDictionary {
        var item = JSONDictionary()
        
        item["id"] = self.reviewId
        item["title"] = self.reviewTitle
        item["content"] = self.reviewContent
        item["user"] = self.userId
        item["date"] = self.postDate
        item["rating"] = self.rating
        item["parent"] = self.parentItem
        
        return item
    }
}

extension ReviewItem: Equatable {
    public static func == (lhs:ReviewItem, rhs:ReviewItem) -> Bool {
        return lhs.reviewId == rhs.reviewId && lhs.userId == rhs.userId && lhs.reviewTitle == rhs.reviewTitle && lhs.reviewContent == rhs.reviewContent && lhs.postDate == rhs.postDate && lhs.rating == rhs.rating && lhs.parentItem == rhs.parentItem
    }
}
