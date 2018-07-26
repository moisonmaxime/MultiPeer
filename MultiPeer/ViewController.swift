//
//  ViewController.swift
//  MultiPeer
//
//  Created by Maxime Moison on 7/25/18.
//  Copyright © 2018 Maxime Moison. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let multiPeerService = MultiPeerService()

    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var broadcastLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        multiPeerService.delegate = self
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

    @IBAction func textFieldDidReturn(_ sender: UITextField) {
        guard let msg = sender.text else { return }
        multiPeerService.send(message: msg)
        sender.text = ""
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // When keyboard shows, change inset in searchTable so that nothing is under keyboard
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            messageTextField.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
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
            self.broadcastLabel.text = message
        }
    }
}
