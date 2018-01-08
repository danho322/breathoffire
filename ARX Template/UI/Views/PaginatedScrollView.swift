//
//  PaginatedScrollView.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/31/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

struct PaginatedScrollViewConstants {
    static let OutOfFocusAlphMultiplier: CGFloat = 1.25
    static let Space: CGFloat = 5
}

protocol PaginatedScrollViewDelegate {
    func scrollViewDidUpdateToIndex(scrollView: PaginatedScrollView, index: Int)
    func scrollViewDidTapView(scrollView: PaginatedScrollView, view: UIView?, index: Int)
}

class PaginatedScrollView: UIScrollView {
    
    internal var viewArray: [UIView] = []
    internal var paginatedDelegate: PaginatedScrollViewDelegate?
    
    weak var outerScrollView: UIScrollView?
    
    override var bounds: CGRect {
        didSet {
            updateSizes()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    internal func setupUI() {
        isPagingEnabled = true
        clipsToBounds = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PaginatedScrollView.handleTap))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    @objc internal func handleTap() {
        let index = currentPage()
        let view = viewArray[safe: index]
        paginatedDelegate?.scrollViewDidTapView(scrollView: self, view: view, index: index)
    }
    
    func setPageViews(pageViewArray: [UIView], delegate: PaginatedScrollViewDelegate?, outerScrollView: UIScrollView?) {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        self.outerScrollView = outerScrollView
        viewArray = pageViewArray
        paginatedDelegate = delegate
        updateSizes()
        paginatedDelegate?.scrollViewDidUpdateToIndex(scrollView: self, index: 0)
    }
    
    func appendPageView(pageView: UIView) {
        let scrollViewWidth = frame.size.width
        var x = CGFloat(viewArray.count) * (scrollViewWidth + PaginatedScrollViewConstants.Space)

        viewArray.append(pageView)
        pageView.frame = CGRect(x: x, y: 0, width: scrollViewWidth - PaginatedScrollViewConstants.Space, height: frame.size.height)
        pageView.center = CGPoint(x: pageView.center.x, y: frame.size.height / 2)
        addSubview(pageView)
        x += scrollViewWidth

        contentSize = CGSize(width: x, height: frame.size.height)
        
        handleFinishScrolling()
    }
    
    internal func updateSizes() {
        let scrollViewWidth = frame.size.width
        
        var x: CGFloat = 0
        for view in viewArray {
            view.frame = CGRect(x: x, y: 0, width: scrollViewWidth - PaginatedScrollViewConstants.Space, height: frame.size.height)
            view.center = CGPoint(x: view.center.x, y: frame.size.height / 2)
            addSubview(view)
            x += scrollViewWidth + PaginatedScrollViewConstants.Space
        }
        
        contentSize = CGSize(width: x, height: frame.size.height)
    }
    
    internal func currentPage() -> Int {
        let pageNumber = round(contentOffset.x / frame.size.width)
        let currentPage = Int(pageNumber)
        return currentPage
    }
    
    func handleFinishScrolling() {
        let currentIndex = currentPage()
        
        setContentOffset(CGPoint(x: CGFloat(currentIndex) * (frame.width + PaginatedScrollViewConstants.Space), y: 0), animated: true)
//        var index = 0
//        for view in viewArray {
//            let alpha: CGFloat = currentIndex == index ? 1 : 1 - PaginatedScrollViewConstants.OutOfFocusAlphMultiplier / 2
//            UIView.animate(withDuration: 0.4, delay: 0, options: [.allowUserInteraction], animations: {
//                view.alpha = alpha
//            }, completion: nil)
//            index += 1
//        }
        paginatedDelegate?.scrollViewDidUpdateToIndex(scrollView: self, index: currentIndex)
    }
}

extension PaginatedScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        var index = 0
//        let contentWidth = scrollView.contentSize.width
//        for view in viewArray {
//            let indexOffset = abs(scrollView.contentOffset.x - view.frame.origin.x) / contentWidth
//            view.alpha = 1 - indexOffset * PaginatedScrollViewConstants.OutOfFocusAlphMultiplier
//            index += 1
//        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        outerScrollView?.isScrollEnabled = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleFinishScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleFinishScrolling()
        }
        outerScrollView?.isScrollEnabled = true
    }
}

extension PaginatedScrollView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

