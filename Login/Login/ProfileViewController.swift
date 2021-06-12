//
//  ProfileViewController.swift
//  Login
//
//  Created by Arturo Iván Chávez Gómez on 11/06/21.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var uploadImageView: UIImageView!
    
    var imageID: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        uploadImageView.layer.cornerRadius = uploadImageView.frame.height / 2
        uploadImageView.clipsToBounds = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(clickImage))
        
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        uploadImageView.addGestureRecognizer(gesture)
        uploadImageView.isUserInteractionEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "return" {
            let obj = segue.destination as! MainViewController
            obj.id = imageID
        }
    }
    
    @objc func clickImage(gesture: UITapGestureRecognizer){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        guard let image = uploadImageView.image, let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        let nameImage = UUID().uuidString
        
        let referenceImage = Storage.storage()
            .reference()
            .child("messages")
            .child(nameImage)
        
        referenceImage.putData(imageData, metadata: nil) { (metaData, error) in
            if let err = error {
                print("Error al subir imagen \(err.localizedDescription)")
            }
            
            referenceImage.downloadURL { (url, error) in
                if let err = error {
                    print("Error al subir imagen \(err.localizedDescription)")
                }
                
                guard let url = url else {
                    print("Error al crear la URL de la imagen")
                    return
                }
                
                let referenceData = Firestore.firestore().collection("messages").document()
                
                let documentID = referenceData.documentID
                
                self.imageID = documentID
                    
                let urlString = url.absoluteString
                
                let sendData = ["id": documentID, "url": urlString]
                
                referenceData.setData(sendData) { (error) in
                    if let err = error {
                        print("Error al mandar datos de imagen \(err.localizedDescription)")
                        return
                    } else {
                        print("Se guardó correctamente en FS")
                    }
                    
                }
            }
        }
        
        performSegue(withIdentifier: "return", sender: self)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            uploadImageView.image = imageSelected
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
