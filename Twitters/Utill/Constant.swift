//
//  Constant.swift
//  Twitters
//
//  Created by 이준용 on 1/2/25.
//

import UIKit
import Firebase

let DB_REF = Database.database().reference()
let USER_REF = DB_REF.child("users")

let TWEET_REF = DB_REF.child("tweets")
let USER_TWEET_REF = DB_REF.child("user-tweet")
let USER_FOLLOWING_REF = DB_REF.child("user-following")
let USER_FOLLWER_REF = DB_REF.child("user-follower")
let TWEET_REPLIES_REF = DB_REF.child("twwet-replies")
let USER_TWEET_REPLIES_REF = DB_REF.child("user-tweet-replies")
let TWEET_LIKES_REF = DB_REF.child("tweet-likes")
let USER_TWEET_LIKES_REF = DB_REF.child("user-tweet-likes")
let NOTIFICATION_REF = DB_REF.child("notifcations")


let STORAGE_REF = Storage.storage().reference()
let USER_PROFILE = STORAGE_REF.child("user-profiles")
