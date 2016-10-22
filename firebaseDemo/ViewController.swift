//
//  ViewController.swift
//  firebaseDemo
//
//  Created by f0go on 10/20/16.
//  Copyright © 2016 f0go. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var myName: String = "\(Int(NSDate().timeIntervalSince1970))"
    var chats:[Message] = []
    
    var firebase: FIRDatabaseReference!
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        table.estimatedRowHeight = 280
        table.rowHeight = UITableViewAutomaticDimension
        
        firebase = FIRDatabase.database().reference()
        firebase.child("chat").observe(.childAdded, with: { (snapshot) -> Void in
            let message: [String:String] = snapshot.value as! Dictionary
            let chat = Message(text: message["message"]!, from: message["from"]!)
            self.chats.append(chat)
            self.table.reloadData()
            self.table.scrollToRow(at: IndexPath(row: self.chats.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.message.textColor = UIColor.black
        if chats[indexPath.row].from == myName {
            cell.message.textColor = UIColor.gray
        }
        cell.message.text = "\(chats[indexPath.row].from): \(chats[indexPath.row].text)"
        return cell
    }
    
    @IBAction func postMessage(_ sender: UIButton) {
        if textfield.text == "" {
            return
        }
        let data = [
            "from":myName,
            "message":textfield.text!
        ]
        firebase.child("chat").childByAutoId().updateChildValues(data)
        textfield.text = ""
    }
    
    func keyboardDidShow(notification: NSNotification) {
        let keyboardInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrameBegin: NSValue = keyboardInfo.value(forKey: "UIKeyboardBoundsUserInfoKey") as! NSValue
        let keyboardFrameBeginRect: CGRect = keyboardFrameBegin.cgRectValue
        bottomConstraint.constant = keyboardFrameBeginRect.height
    }
}

struct Message {
    var text: String
    var from: String
}
