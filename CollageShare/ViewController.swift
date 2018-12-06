//
//  ViewController.swift
//  CollageShare
//
//  Created by Charles Martin Reed on 12/5/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDropInteractionDelegate, UIDragInteractionDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //MARK:- Drop interaction setup
        view.addInteraction(UIDropInteraction(delegate: self)) //external to app
        view.addInteraction(UIDragInteraction(delegate: self)) //internal to internal
        
    }
    //MARK:- Drag delegate method
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        //get item location
        let touchedPoint = session.location(in: self.view)
        
        //hitTest returns the view that was being touched
        if let touchedImageView = self.view.hitTest(touchedPoint, with: nil) as? UIImageView {
            
            //image is interactable because we enable touch interation when capturing the image during drop session
            if let touchedImage = touchedImageView.image {
                let itemProvider = NSItemProvider(object: touchedImage) //try to get the item from item provider
                let dragItem = UIDragItem(itemProvider: itemProvider)
                
                //localObject allows you to associate a custom object with the drag item, local to this app only
                dragItem.localObject = touchedImageView
                
                return [dragItem]
            }
            
        }
        
        return []
    }
    
    //MARK:- Drag Interaction preview method
    func dragInteraction(_ interaction: UIDragInteraction, previewForLifting item: UIDragItem, session: UIDragSession) -> UITargetedDragPreview? {
        
        //get the view out of the image that you're draging.
        return UITargetedDragPreview(view: item.localObject as! UIView)
    }
    
    //MARK:- Drop delegate method
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        //get the image by looking in the session's items array
        for dragItem in session.items {
            dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (obj, err) in
                if let err = err {
                    print("Failed to load our dragged item", err)
                    return
                }
                
                //assuming no error, grab the obj from the itemProvider and cast it as an UIImage
                guard let draggedImage = obj as? UIImage else { return }
                
                DispatchQueue.main.async {
                    //updating the UI needs to be done on the main thread, of course
                    let imageView = UIImageView(image: draggedImage)
                    imageView.isUserInteractionEnabled = true
                    imageView.frame = CGRect(x: 0, y: 0, width: draggedImage.size.width, height: draggedImage.size.height)
                    self.view.addSubview(imageView)
                    
                    //making a location call on a session allows you to place an obj precisely where the user intended
                    let centerPoint = session.location(in: self.view)
                    imageView.center = centerPoint //places the image center where your finger was
                }
            }
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        //update what session does between drag and drop
        return UIDropProposal(operation: .copy) //vs. move, whereas move would be used to take from one app and move to another
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) ///allows us to drag images into app by allowing the item provider to create an object of UIImage
    }
    
   


}

