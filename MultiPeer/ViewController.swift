//
//  ViewController.swift
//  MultiPeer
//
//  Created by Maxime Moison on 7/25/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import UIKit
import MultipeerConnectivity

enum MessageDirection {
    case inbound
    case outbound
}

struct Message {
    var body:String
    var direction:MessageDirection
}


class ViewController: UIViewController {
    
    let multiPeerService = MultiPeerService()
    
    var messages:[Message] = []
    
    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        multiPeerService.delegate = self
        messageTableview.dataSource = self
        messageTableview.register(UINib(nibName: "SentCell", bundle: nil), forCellReuseIdentifier: "SentCell")
        messageTableview.register(UINib(nibName: "ReceivedCell", bundle: nil), forCellReuseIdentifier: "ReceivedCell")
        // Add an observer to check on keyboard status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }
    
    func reload() {
        messageTableview.reloadData()
        messageTableview.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: .bottom, animated: true)
    }
    
    @IBAction func textFieldDidReturn(_ sender: UITextField) {
        guard let msg = sender.text else { return }
        messages.append(Message(body: msg, direction: .outbound))
        multiPeerService.send(message: msg)
        sender.text = ""
        self.reload()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // When keyboard shows, change inset in searchTable so that nothing is under keyboard
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            messageTableview.contentInset.bottom = keyboardHeight
            messageTextField.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight+view.frame.maxY-messageTextField.frame.maxY)
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        messageTableview.contentInset.bottom = 0
        messageTextField.transform = CGAffineTransform(translationX: 0, y: 0)
    }
}

extension ViewController : MultiPeerServiceDelegate {
    func connectedDevicesChanged(manager: MultiPeerService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "\(connectedDevices.count)"
        }
    }
    
    func didReceiveMessage(manager : MultiPeerService, message: String) {
        OperationQueue.main.addOperation {
            self.messages.append(Message(body: message, direction: .inbound))
            self.reload()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let message = messages[row]
        let cell:UITableViewCell
        switch message.direction {
        case .inbound:
            let c = tableView.dequeueReusableCell(withIdentifier: "ReceivedCell", for: indexPath) as? ReceivedCell
            c?.messageBodyLabel.text = message.body
            cell = c ?? UITableViewCell()
        case .outbound:
            let c = tableView.dequeueReusableCell(withIdentifier: "SentCell", for: indexPath) as? SentCell
            c?.messageBodyLabel.text = message.body
            cell = c ?? UITableViewCell()
        }
        return cell
    }
    
    
}
