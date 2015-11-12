//
//  ViewController.swift
//  TinderCardsSwift
//
//  Created by Eugene Andreyev on 4/23/15.
//  Copyright (c) 2015 Eugene Andreyev. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import pop

private var numberOfCards: UInt = 5

class ThemeList {
    var id:String!
    var keyword:String?
    var smallUrl:String?
    var fullsizeUrl:String?
    var width:Int?
    var height:Int?
    var color:String!
    var downloads:Int!
    var likes:Int!
}
class ViewController: UIViewController, KolodaViewDataSource, KolodaViewDelegate {
    
    @IBOutlet weak var kolodaView: KolodaView!
    let Url : String = "https://api.unsplash.com/photos/"
    let key : String = "29a307bccd8555abb09dcd36bbc3e014bad09e75e18c18ae369eb338b2a01f4a"
    
    let perPage:String = "5"
    var themeLists:[ThemeList] = []
    var page:Int = 1
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.kolodaView.dataSource = self
        self.kolodaView.delegate = self
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        self.setBackground(page)
    }
    
    
    
    func setBackground(page: Int) {
        var jsonData:JSON?
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        Alamofire.request(.GET, self.Url, parameters: ["client_id":self.key, "per_page":self.perPage, "page": page])
            .responseJSON(completionHandler: { req, _, result in
                print(req)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if result.value != nil {
                    jsonData = JSON(result.value!)
                    for (_, subJson):(String, JSON) in jsonData! {
                        let themeList:ThemeList = ThemeList()
                        
                        themeList.id = subJson["id"].stringValue
                        themeList.width = subJson["width"].intValue
                        themeList.height = subJson["height"].intValue
                        themeList.smallUrl = subJson["urls"]["small"].stringValue
                         self.themeLists.append(themeList)
         
                    }
                    
                    self.kolodaView.reloadData()
                    
                    
                }
            })
       
        
    }
    
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }
    
    @IBAction func undoButtonTapped() {
       kolodaView?.revertAction()
    }
    
    //MARK: KolodaViewDataSource
    func kolodaNumberOfCards(koloda: KolodaView) -> UInt {
        print(self.themeLists.count)
        return UInt(self.themeLists.count)
    }
    
    func kolodaViewForCardAtIndex(koloda: KolodaView, index: UInt) -> UIView {
        let images = UIImageView()
        if self.themeLists.count != 0 {
        
        if let backgroundUrl = self.themeLists[Int(index)].smallUrl {
            images.frame=CGRect(x: 10, y: 10, width: 100, height: 100)
            images.kf_setImageWithURL(NSURL(string: backgroundUrl)!, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(0.2))], completionHandler: { action in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
            print("kolodaNumberOfCards")
            
        }
        }
    
        
        return images
    }
    func kolodaViewForCardOverlayAtIndex(koloda: KolodaView, index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView",
            owner: self, options: nil)[0] as? OverlayView
    }
    
    //MARK: KolodaViewDelegate
    
    func kolodaDidSwipedCardAtIndex(koloda: KolodaView, index: UInt, direction: SwipeResultDirection) {
    //Example: loading more cards
//        if index >= 3 {
//            numberOfCards = 6
//            kolodaView.reloadData()
//        }
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
    //Example: reloading
        kolodaView.resetCurrentCardNumber()
    }
    
    func kolodaDidSelectCardAtIndex(koloda: KolodaView, index: UInt) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://yalantis.com/")!)
    }
    
    func kolodaShouldApplyAppearAnimation(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldTransparentizeNextCard(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaBackgroundCardAnimation(koloda: KolodaView) -> POPPropertyAnimation? {
        return nil
    }

}

