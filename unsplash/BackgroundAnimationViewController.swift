import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import pop
private let numberOfCards: UInt = 5
private let frameAnimationSpringBounciness:CGFloat = 9
private let frameAnimationSpringSpeed:CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent:CGFloat = 0.1

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


class BackgroundAnimationViewController: UIViewController, KolodaViewDataSource, KolodaViewDelegate {

    @IBOutlet weak var kolodaView: CustomKolodaView!
    let Url : String = "https://api.unsplash.com/photos/"
    let key : String = "29a307bccd8555abb09dcd36bbc3e014bad09e75e18c18ae369eb338b2a01f4a"
    
    var perPage:String = "5"
    var themeLists:[ThemeList] = []
    var nowLists:[ThemeList] = []
    var page:Int = 1
    var isFirst:Bool=true
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.dataSource = self
        kolodaView.delegate = self
        self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.getImageData(page)
    }
    
    func getImageData(page: Int) {
        print("getImageData")
         self.themeLists=[]
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
                    if self.isFirst {
                        self.isFirst=false
                        self.perPage="10"
                        self.nowLists=self.themeLists
                        self.kolodaView.reloadData()
                    
                    }
                    
                    
                    
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
        print(self.nowLists.count)
       
        return UInt(self.nowLists.count)
    }
    
    func kolodaViewForCardAtIndex(koloda: KolodaView, index: UInt) -> UIView {
        print(index)
        if index == 3 {
            print(kolodaDidSwipedCardAtIndex)
            getImageData(++page)
        }
        let images = UIImageView()
        if self.nowLists.count != 0 {
            print(index)
            if let backgroundUrl = self.nowLists[Int(index)].smallUrl {
                images.frame=CGRect(x: 0, y: 0, width: CGRectGetWidth(self.view.frame) - 20, height: CGRectGetWidth(self.view.frame) - 20)
                images.kf_setImageWithURL(NSURL(string: backgroundUrl)!, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(0.2))], completionHandler: { action in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
                
                
            }
        }
        
        
        return images
    }
    
    func kolodaViewForCardOverlayAtIndex(koloda: KolodaView, index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CustomOverlayView",
            owner: self, options: nil)[0] as? OverlayView
    }
    
    //MARK: KolodaViewDelegate
    
    func kolodaDidSwipedCardAtIndex(koloda: KolodaView, index: UInt, direction: SwipeResultDirection) {
     
        
        
    }
    
    func kolodaDidRunOutOfCards(koloda: KolodaView) {
        print(kolodaDidRunOutOfCards)
        //Example: reloading
        self.nowLists=[]
        self.nowLists=self.themeLists
        kolodaView.resetCurrentCardNumber()
       
        
    }
    
    func kolodaDidSelectCardAtIndex(koloda: KolodaView, index: UInt) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc2:DetailViewController = storyboard.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        vc2.url = self.nowLists[Int(index)].smallUrl
        self.presentViewController(vc2, animated: true, completion: nil)
    
    }
    
    func kolodaShouldApplyAppearAnimation(koloda: KolodaView) -> Bool {
        return true
    }
    
    func kolodaShouldMoveBackgroundCard(koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaShouldTransparentizeNextCard(koloda: KolodaView) -> Bool {
        return false
    }
    
    func kolodaBackgroundCardAnimation(koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation.springBounciness = frameAnimationSpringBounciness
        animation.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}
