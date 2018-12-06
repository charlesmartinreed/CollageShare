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
        
        view.backgroundColor = .white //AppDelegate window is default black because we constructed it in code, set the color to white at view load
        navigationItem.title = "Collage Sharing"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        //MARK:- Drop interaction setup
        view.addInteraction(UIDropInteraction(delegate: self)) //external to app
        view.addInteraction(UIDragInteraction(delegate: self)) //internal to internal
        
    }
    
    //MARK:- Sharing methods
    @objc func handleShare() {
        //we need to capture the canvas to generate the image
        
        //set the context sized to the view's entire frame, render in the context, create image from the context
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        
        //share the image view via UIActivityViewController and present it
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem //where to place the popover, basically.
        present(activityViewController, animated: true, completion: nil)
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
    
    //MARK:- Drag Interaction item removal method
    func dragInteraction(_ interaction: UIDragInteraction, willAnimateLiftWith animator: UIDragAnimating, session: UIDragSession) {
        
        //remove the image we're dragging by grabbing it from the session's dragItems, trying to cast it as a UIView and removing it from superview if possible
        session.items.forEach { (draggedItem) in
            if let touchedImageView = draggedItem.localObject as? UIView {
                touchedImageView.removeFromSuperview()
            }
        }
        
    }
    
    //MARK:- Drag cancelled
    func dragInteraction(_ interaction: UIDragInteraction, item: UIDragItem, willAnimateCancelWith animator: UIDragAnimating) {
        //put the image back onto the view controller's view if animation is cancelled
//        if let touchedImageView = item.localObject as? UIView {
//            self.view.addSubview(touchedImageView)
//        }
        self.view.addSubview(item.localObject as! UIView)
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
                    
                    //optional image styling upon drop
                    imageView.layer.borderWidth = 3
                    imageView.layer.borderColor = UIColor.gray.cgColor
                    imageView.layer.shadowRadius = 5
                    imageView.layer.shadowOpacity = 0.3
            
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

