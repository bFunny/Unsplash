import UIKit

public enum OverlayMode{
    case None
    case Left
    case Right
}


public class OverlayView: UIView {
    
    public var overlayState:OverlayMode = OverlayMode.None

}
