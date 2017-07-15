import UIKit
import Spruce

class SpruceAnimatingViewController: UIViewController {
    var animations: [StockAnimation]?
    var sortFunction: SortFunction?
    var animationView: UIView?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(prepareAnimation))
        animationView?.addGestureRecognizer(tapGesture)
    }
    
    func setup() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        prepareAnimation()
    }
    
    @objc func prepareAnimation() {
        if let animations = animations {
            animationView?.spruce.prepare(with: animations)
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(callAnimation), userInfo: nil, repeats: false)
        }
    }
    
    @objc func callAnimation() {
        guard let animations = animations, let sortFunction = sortFunction else {
            return
        }
        let animation = SpringAnimation(duration: 0.7)
        DispatchQueue.main.async {
            self.animationView?.spruce.animate(animations, animationType: animation, sortFunction: sortFunction)
        }
    }
}

