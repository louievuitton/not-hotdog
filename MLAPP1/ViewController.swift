//
//  ViewController.swift
//  MLAPP1
//
//  Created by Steven Louie on 6/27/19.
//  Copyright © 2019 Steven Louie. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // downcast
        // this is to grab the user selected image that is stored inside this dictionary
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            // this will throw a fatal error if image cannot be converted
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Cannot convert UIImage to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    // uses CoreML model to classify the image passed
    func detect(image: CIImage) {
        
        // 1. load up model using the Inceptionv3 model
        // uses inception model to classify the image
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        // 2. create a request that ask model to classify whatever data is passed to it
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let result = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = result.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog"
                }
                else {
                    self.navigationItem.title = "Not Hotdog"
                }
            }
        }
        
        // 3. use handler to classify the image passed to it
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        // when the camera button is tapped, this will open the image picker VC that allows user to select an image
        present(imagePicker, animated: true, completion: nil)
    }
    
}

