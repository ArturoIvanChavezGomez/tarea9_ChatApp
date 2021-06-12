//
//  MainViewController.swift
//  Login
//
//  Created by Arturo Iván Chávez Gómez on 10/06/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn

class MainViewController: UIViewController {
    
    var chats = [Message]()
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var chatsTableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    var imageChat: UIImage?
    
    var id: String?
    
    override func viewWillAppear(_ animated: Bool) {
        chatsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "MessageTableViewCell", bundle: nil)
        chatsTableView.register(nib, forCellReuseIdentifier: "cellMessage")
        navigationItem.hidesBackButton = true
        loadMessages()
        
        if let email = Auth.auth().currentUser?.email {
            let defaults = UserDefaults.standard
            defaults.set(email, forKey: "email")
            defaults.synchronize()
        }
    }
    
    func loadMessages() {
        db.collection("messages").order(by: "created").addSnapshotListener() { (querySnapshot, err) in
            
            self.chats = []
            
            if let e = err {
                print("Error al obtener los chats: \(e.localizedDescription)")
            } else {
                if let documentsSnapShot = querySnapshot?.documents {
                    for document in documentsSnapShot {
                        print("\(document.data())")
                        let data = document.data()
                        guard let senderFS = data["sender"] as? String else { return }
                        guard let bodyFS = data["body"] as? String else { return }
                        
                        let newMessage = Message(sender: senderFS, body: bodyFS)
                        
                        self.chats.append(newMessage)
                        
                        DispatchQueue.main.async {
                            self.chatsTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendButton(_ sender: UIButton) {
        
        if let body = messageTextField.text, let sender = Auth.auth().currentUser?.email {
            db.collection("messages").addDocument(data: ["sender": sender, "body": body, "created": Date().timeIntervalSince1970]) {
                (error) in
                if let e = error {
                    print("Error al guardar \(e.localizedDescription)")
                } else {
                    self.messageTextField.text = ""
                    self.chatsTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        GIDSignIn.sharedInstance()?.signOut()
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.synchronize()
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = chatsTableView.dequeueReusableCell(withIdentifier: "cellMessage", for: indexPath) as! MessageTableViewCell
        
        let query = Firestore.firestore().collection("messages").whereField("id", isEqualTo: "1J5f4eQwDuhBpgRZtN1g")
                query.getDocuments { (snapshot, error) in
                    if let err = error {
                        print("Error al descargar imagen: \(err.localizedDescription)")
                    }
                    guard let snapshot = snapshot,
                          let data = snapshot.documents.first?.data(),
                          let urlString = data["url"] as? String,
                          let url = URL(string: urlString)
                    else { return }
                    
                           DispatchQueue.global().async { [weak self] in
                               if let data = try? Data(contentsOf: url) {
                                   if let image = UIImage(data: data) {
                                       DispatchQueue.main.async {
                                        self?.imageChat = image
                                       }
                                   }
                               }
                           }
                }
        var string = chats[indexPath.row].sender
        if let index = string.firstIndex(of: "@") {
            let firstPart = string.prefix(upTo: index)
            cell.senderLabel.text = String(firstPart)
        }
        cell.profileImageView.image = imageChat
        cell.messageLabel.text = chats[indexPath.row].body
        return cell
    }
    
}
