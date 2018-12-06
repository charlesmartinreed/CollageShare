//
//  ViewController.swift
//  CollageShare
//
//  Created by Charles Martin Reed on 12/5/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDropInteractionDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //MARK:- Drop interaction setup
        view.addInteraction(UIDropInteraction(delegate: self))
    }
    
    //MARK:- Drop delegate methods
    
    
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
                    imageView.frame = CGRect(x: 0, y: 0, width: draggedImage.size.width, height: draggedImage.size.height)
                    self.view.addSubview(imageView)
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

