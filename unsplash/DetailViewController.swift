
import UIKit
import Kingfisher

class DetailViewController: UIViewController, UIScrollViewDelegate{

    @IBOutlet weak var activityIndicators: UIActivityIndicatorView!
    var url:String!
    var id:String?
    let imageView = UIImageView()
    
    @IBOutlet weak var scrollViewImages: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //640 × 1136
        print(url)

       
        
        // activity indicator
        self.activityIndicators.hidden = false
        self.activityIndicators.startAnimating()
        
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // Do any additional setup after loading the view.
        scrollViewImages.delegate = self
        
        self.scrollViewImages.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        //imageView.frame = scrollViewImage.bounds
        imageView.kf_showIndicatorWhenLoading = true
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        self.getImage()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    @IBAction func onBtnBackClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func rotated()
    {
        //redraw
        self.scrollViewImages.setNeedsDisplay()

    }
    
    func getImage() {
      
        
        self.imageView.kf_setImageWithURL(NSURL(string: url)!, placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(1))],  progressBlock: {(receivedSize, totalSize) -> () in
            }, completionHandler: { (image, error, cacheType, imageURL) -> () in
                print(error)
                if error == nil {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    sleep(1)
                    self.activityIndicators.stopAnimating()
                    self.activityIndicators.hidden = true
                    
                    print(image!.size)
                    
                    // 1
                    self.imageView.image = image!
                    self.scrollViewImages.addSubview(self.imageView)
                    
                    self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 10), size:image!.size)
                    self.scrollViewImages.contentSize = image!.size
                    
                    let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "scrollViewDoubleTapped:")
                    doubleTapRecognizer.numberOfTapsRequired = 2
                    doubleTapRecognizer.numberOfTouchesRequired = 1
                    self.scrollViewImages.addGestureRecognizer(doubleTapRecognizer)
                    
                    // 4
                    let scrollViewFrame = self.scrollViewImages.frame
                    let scaleWidth = scrollViewFrame.size.width / self.scrollViewImages.contentSize.width
                    let scaleHeight = scrollViewFrame.size.height / self.scrollViewImages.contentSize.height
                    let minScale = min(scaleWidth, scaleHeight);
                    self.scrollViewImages.minimumZoomScale = minScale;
                    
                    // 5
                    self.scrollViewImages.maximumZoomScale = 1.0
                    self.scrollViewImages.zoomScale = minScale
                } else {
                    let ac = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
        })
    }
    
    func scrollViewDoubleTapped(recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.locationInView(imageView)
        
        // 2
        var newZoomScale = scrollViewImages.zoomScale * 2.0
        newZoomScale = min(newZoomScale, scrollViewImages.maximumZoomScale)
        
        // 3
        let scrollViewSize = scrollViewImages.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRectMake(x, y, w, h);
        
        // 4
        scrollViewImages.zoomToRect(rectToZoomTo, animated: true)

    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollViewImages.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func imageSave(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    
    

    
  
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        self.getImage()
    }

}

