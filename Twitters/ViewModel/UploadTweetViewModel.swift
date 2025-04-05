//
//  UploadTweetViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/25/25.
//

import UIKit

class UploadTweetViewModel {


   


    private(set) var caption: String = "" {
        didSet {
            fetchCaption?(caption)
        }
    }

    private(set) var actionButtonTitle: String = "" {
        didSet {
            onActionButtonTitleChanged?(actionButtonTitle)
        }
    }
    var shouldShowReplyLabel = false {
        didSet {
            onReplyLabelVisibilityChanged?(shouldShowReplyLabel)
        }
    }

    var replyText: String? {
        didSet {
            guard let replyText else { return }
            onReplyText?(replyText)
        }
    }

    var fetchCaption: ((String) -> Void)?
    var onTweetUploadSuccess: (() -> Void)?
    var onTweetUploadFail: ((Error) -> Void)?
    var onUploadTweetConfiguration: ((UploadTweetConfiguration) -> Void)?
    var onActionButtonTitleChanged: ((String) -> Void)?
    var onReplyLabelVisibilityChanged: ((Bool) -> Void)?
    var onReplyText: ((String) -> Void)?

    var uploadTweetConfiguration = UploadTweetConfiguration.tweet {
        didSet {
            onUploadTweetConfiguration?(uploadTweetConfiguration)
            configureationUploadTweet()
        }
    }

    init(configuration: UploadTweetConfiguration = .tweet) {
        self.uploadTweetConfiguration = configuration
        configureationUploadTweet()
    }



    func bindCaption(caption: String) {
        self.caption = caption
    }

    func uploadtweet() {
        TweetService.shared.uploadTweet(caption: caption, type: uploadTweetConfiguration) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success():
                self.onTweetUploadSuccess?()
            case .failure(let error):
                self.onTweetUploadFail?(error)
            }
        }
    }

    func configureationUploadTweet() {
        switch uploadTweetConfiguration {
        case .tweet:
            self.actionButtonTitle = "Tweet"
            self.shouldShowReplyLabel = false
        case .reply(let tweet):
            self.actionButtonTitle = "Reply"
            self.shouldShowReplyLabel = true
            self.replyText = "Replying to @\(tweet.user.userName)"
        }
    }
}
