//
//  Extension.swift
//  Twitters
//
//  Created by 이준용 on 11/14/24.
//

import UIKit
import Firebase


extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, paddingTop: CGFloat, paddingLeading: CGFloat, paddingTrailing: CGFloat, paddingBottom: CGFloat, width: CGFloat, height: CGFloat, centerX: NSLayoutXAxisAnchor?, centerY: NSLayoutYAxisAnchor?) {

        self.translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }

        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: paddingLeading).isActive = true
        }

        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -paddingTrailing).isActive = true
        }

        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }

        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }

        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        if let centerX = centerX {
            self.centerXAnchor.constraint(equalTo: centerX).isActive = true
        }

        if let centerY = centerY {
            self.centerYAnchor.constraint(equalTo: centerY).isActive = true
        }
    }

    func setSize(width: CGFloat = 0, height: CGFloat = 0) {
           translatesAutoresizingMaskIntoConstraints = false

           if width > 0 {
               widthAnchor.constraint(equalToConstant: width).isActive = true
           }

           if height > 0 {
               heightAnchor.constraint(equalToConstant: height).isActive = true
           }
       }
}


extension UIImage {
    static let feedImage = #imageLiteral(resourceName: "home_unselected")
    static let searchImage = #imageLiteral(resourceName: "search_unselected")
    static let notificationImage = #imageLiteral(resourceName: "like_unselected")
    static let emailImage = #imageLiteral(resourceName: "mail")
    static let twiiterImage = #imageLiteral(resourceName: "TwitterLogo")
    static let newTweetImage = #imageLiteral(resourceName: "new_tweet")
    static let passwordImage = #imageLiteral(resourceName: "ic_lock_outline_white_2x")
    static let addProfileImage = #imageLiteral(resourceName: "plus_photo")
    static let nameFieldImage = #imageLiteral(resourceName: "ic_person_outline_white_2x")
    static let commentImage = #imageLiteral(resourceName: "comment")
    static let retweetImage = #imageLiteral(resourceName: "retweet")
    static let shareImage = #imageLiteral(resourceName: "share")
    static let likeImage = UIImage(named: "like")
    static let backImage = #imageLiteral(resourceName: "baseline_arrow_back_white_24dp")
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }

    static let twitterBlue = UIColor.rgb(red: 29, green: 161, blue: 242)

    static let buttonColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    static let enabledColor = UIColor.white
}

extension UIViewController {
     func navigationBarSetting() {
        let apperance = UINavigationBarAppearance()
        self.navigationController?.navigationBar.scrollEdgeAppearance = apperance
    }
}


protocol Attributed {
    func attributedTitleSetting(main MainTitle: String, sub Subtitle: String, font: UIFont, textColor: UIColor) -> NSAttributedString
}

extension UIButton: Attributed {
    func attributedTitleSetting(main MainTitle: String, sub Subtitle: String, font: UIFont, textColor: UIColor) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: MainTitle, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : textColor])
        attributedTitle.append(NSAttributedString(string: Subtitle, attributes: [NSAttributedString.Key.font : font, NSAttributedString.Key.foregroundColor : textColor]))
        return attributedTitle
    }

    func applyAttributedTitle(main: String, sub: String, font: UIFont, textColor: UIColor) {
        let attributedTitle = attributedTitleSetting(main: main, sub: sub, font: font, textColor: textColor)
        self.setAttributedTitle(attributedTitle, for: .normal)
    }
}

extension FilterOption {
    var cacheKey: String {
        switch self {
        case .tweets: return "selectedTweet"
        case .replies: return "selectedTweetReplies"
        case .likes: return "selectedTweetLikes"
        }
    }

    func fullKey(uid: String) -> NSString {
        return "\(self.cacheKey)_\(uid)" as NSString
    }
}
