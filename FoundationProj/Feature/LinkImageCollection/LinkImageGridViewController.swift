//
//  LinkImageGridViewController.swift
//  FoundationProj
//
//  Created by baedy on 2020/06/04.
//  Copyright (c) 2020 baedy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import SnapKit
import Then
import NSObject_Rx

class LinkImageGridViewController: UIBaseViewController, ViewModelProtocol {
    typealias ViewModel = LinkImageGridViewModel
    
    // MARK: - ViewModelProtocol
    var viewModel: ViewModel!
    
    // MARK: - Properties
    let requestTrigger = PublishRelay<Void>()
    let selectedIndexPath = BehaviorRelay<IndexPath?>(value: nil)
    
    weak var zoomIndexDelegate: ZoomAnimatorForIndexDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupLayout()
        bindingViewModel()
        
        requestTrigger.accept(())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = nil
    }
    
    // MARK: - Binding
    func bindingViewModel() {
        subView.collectionView.rx.itemSelected.asObservable().bind(to: self.selectedIndexPath).disposed(by: rx.disposeBag)
        
        let modelIndex = selectedIndexPath.compactMap{
            $0?.item
        }
        
        let res = viewModel.transform(req: ViewModel.Input(imageRequestTrigger: requestTrigger.asObservable(), modelSelect: modelIndex.asObservable()))
        
        subView.setupDI(observable: res.imageList)
    }
    
    // MARK: - View
    let subView = LinkImageGridView()
    
    func setupLayout() {
        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Methods
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.subView.collectionView.collectionViewLayout.invalidateLayout()
    }

}

extension LinkImageGridViewController : ZoomAnimatorDelegate {
    
    func zoominRefereneceView(for zoomAnimator: ZoomAnimator) -> UIView? {
        return nil
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        //Get the array of visible cells in the collectionView
        let visibleCells = self.subView.collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(selectedIndexPath) {
            
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            self.subView.collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.subView.collectionView.reloadItems(at: visibleCells)
            self.subView.collectionView.layoutIfNeeded()
            
            //Guard against nil values
            guard let guardedCell = (self.subView.collectionView.cellForItem(at: selectedIndexPath) as? LinkImageCell) else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        else {
            
            //Guard against nil return values
            guard let guardedCell = self.subView.collectionView.cellForItem(at: selectedIndexPath) as? LinkImageCell else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the
    //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        
        //Get the currently visible cells from the collectionView
        let visibleCells = self.subView.collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(selectedIndexPath) {
            
            //Scroll the collectionView to the cell that is currently offscreen
            self.subView.collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.subView.collectionView.reloadItems(at: visibleCells)
            self.subView.collectionView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.subView.collectionView.cellForItem(at: selectedIndexPath) as? LinkImageCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
            return guardedCell.frame
        }
            //Otherwise the cell should be visible
        else {
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.subView.collectionView.cellForItem(at: selectedIndexPath) as? LinkImageCell), let factorImageSize =  guardedCell.imageView.image?.size  else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            let ratio = factorImageSize.width / factorImageSize.height
            
            if ratio > 1{
                // width long
                let imageHeight = guardedCell.frame.height
                let halfHeight = imageHeight / 2
                let imageWidth = imageHeight * ratio
                let halfWidth = imageWidth / 2
                                
                let rect = CGRect.init(x: guardedCell.frame.midX - halfWidth, y: guardedCell.frame.midY - halfHeight, width: imageWidth, height: imageHeight)
                
                return rect
                
            }else {
                // height long
                let heightRatio = factorImageSize.height / factorImageSize.width
                let imageWidth = guardedCell.frame.width
                let halfWidth = imageWidth / 2
                let imageHeight = imageWidth * heightRatio
                let halfHeight = imageHeight / 2
                
                let rect = CGRect.init(x: guardedCell.frame.midX - halfWidth, y: guardedCell.frame.midY - halfHeight, width: imageWidth, height: imageHeight)
                
                return rect
                
            }
        
            
//            let imageSize = ratio > 1 ? CGSize(width: factorImageSize.width, height: contentScaleFactor * factorImageSize.height) : CGSize(width: guardedCell.imageView * factorImageSize.width, height: guardedCell.imageView.contentScaleFactor * factorImageSize.height)
//
//            //The cell was found successfully
//            let rect = CGRect.init(x: guardedCell.frame.minX - (imageSize.width / 2), y: guardedCell.frame.minY - (imageSize.height / 2), width: imageSize.width, height: imageSize.height)
//
//            return rect//guardedCell.frame
        }
    }
    
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        
        //        guard let index = zoomIndexDelegate?.transitionIndexPath() else { return }
        let indexPath = IndexPath(item: zoomAnimator.currentIndex, section: 0)
        
        let cell = self.subView.collectionView.cellForItem(at: indexPath) as! LinkImageCell
        
        let cellFrame = self.subView.collectionView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < self.subView.collectionView.contentInset.top {
            self.subView.collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.view.frame.height - self.subView.collectionView.contentInset.bottom {
            self.subView.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        //        guard let index = zoomIndexDelegate?.transitionIndexPath() else { return nil }
        let indexPath = IndexPath(item: zoomAnimator.currentIndex, section: 0)
        
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: indexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        //        guard let index = zoomIndexDelegate?.transitionIndexPath() else { return .zero }
        let indexPath = IndexPath(item: zoomAnimator.currentIndex, section: 0)
        
        self.view.layoutIfNeeded()
        self.subView.collectionView.layoutIfNeeded()
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: indexPath)
        
        let cellFrame = self.subView.collectionView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < self.subView.collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: self.subView.collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (self.subView.collectionView.contentInset.top - cellFrame.minY))
        }
        
        return cellFrame
    }
    
}

