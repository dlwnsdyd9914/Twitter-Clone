//
//  Router.swift
//  Twitters
//
//  Created by 이준용 on 3/15/25.
//

import UIKit

class Router: RouterProtocol {
    func navigate(to destination: Destination, from navigationController: UINavigationController) {

    }
    
    func navigationToTweetReply(viewController: UIViewController, tweet: Tweet, userViewModel: UserViewModel) {
        let uploadTweetController = UploadTweetController(userViewModel: userViewModel)
        uploadTweetController.viewModel = .init(configuration: .reply(tweet))
        viewController.navigationController?.pushViewController(uploadTweetController, animated: true)
    }
    

}
