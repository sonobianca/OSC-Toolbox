//
//  ViewController.swift
//  OSC-Toolbox
//
//  Created by Blaise Bernier on 2017-07-17.
//  Copyright © 2017 Badger Studios. All rights reserved.
//

import AppKit
import OSCKit
import String_Extensions

class ViewController: NSViewController, OSCServerDelegate {
   
   @IBOutlet weak var serverIPField: NSTextField!
   @IBOutlet weak var serverPortField: NSTextField!
   @IBOutlet weak var clientIPLabel: NSTextField!
   @IBOutlet weak var clientPortField: NSTextField!
   @IBOutlet weak var promptField: NSTextField!
   @IBOutlet weak var oscLogView: NSTextView!
   @IBOutlet weak var oscLogScroller: NSScrollView!

   
   private var serverIP = "127.0.0.1"
   private var serverPort = 53700
   private var clientPort = 53701
   private var oscPrompt = ""
   
   private var oscClient: OSCClient!
   private var oscServer: OSCServer!

   override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
      
      print("Setting up OSC interface...")
      oscClient = OSCClient()
      oscServer = OSCServer()
      oscServer.delegate = self
      oscServer.listen(clientPort)
   }

   override var representedObject: Any? {
      didSet {
      // Update the view, if already loaded.
      }
   }
   
   @IBAction func sendButtonClicked(_ sender: Any) {
      let address = "udp://\(serverIP):\(serverPort)"
      if let oscMessage = parsePrompt() {
         oscClient.send(oscMessage, to: address)
         print("Address: \(address)")
         print("Message:")
         print("\(oscMessage)")
      } else {
         print("!!! Invalid OSC Message !!!")
      }
   }
   
   @IBAction func promptFieldEnterPressed(_ sender: NSTextField) {
      sendButtonClicked(self)
   }
   
   override func controlTextDidChange(_ obj: Notification) {
      let textField = obj.object as! NSTextField
      let thisIdentifier = textField.identifier
      

      if thisIdentifier == "txtServerIP" {
         serverIP = textField.stringValue
      }
      else if thisIdentifier == "txtServerPort" {
         serverPort = textField.integerValue
      }
      else if thisIdentifier == "txtPrompt" {
         oscPrompt = textField.stringValue
      }
   }
   
   ///Handle incoming OSC messages
   func handle(_ message: OSCMessage!) {
      
      print("OSC Message: \(message)")
      
      let targetPath = message.address
      let args = message.arguments
      
      let msgAsString = "Path: \"\(targetPath)\"\nArguments: \n\(args)\n\n"
      print(msgAsString)
      oscLogView.string?.append(msgAsString)
      oscLogView.scrollToEndOfDocument(self)
   }
   
   func parsePrompt() -> OSCMessage! {
      if oscPrompt.isEmpty() {
         print("Prompt is empty!  Making sure that the field does not contain whitespace...")
         promptField.cell?.title = ""
         return nil
      }
      
      print("Parsing the prompt...")
      
      var elements = oscPrompt.split(" ")
      let elementCount = elements.count
      let oscPath = elements[0]
      elements.remove(at: 0)
      
      print("- Number of tokens on the prompt")
      print("- OSC Path found: \"\(oscPath)\"")
      
      var oscParams = [Any]()
      if  elementCount > 1 {
         print("Checking for parameters...")
         
         for element in elements {
            print("Token: \"\(element)\" ", terminator: "")
            // Check for numerical values and sort out ints from floats
            if element.isNumeric() {
               if element.contains(".") {
                  print("is detected as a \'float\'")
                  oscParams.append(element.toFloat() as Any)
               } else {
                  print("is detected as an \'integer\'")
                  oscParams.append(element.toInt() as Any)
               }
            }
            else { // If not numerical, send a string for now
               print("will be sent as a \'string\'")
               oscParams.append(element as Any)
            }
         }
      }
      
      print("Parsing completed!")
      
      let oscMessage = OSCMessage(address: oscPath, arguments: oscParams)
      return oscMessage
   }
   
}

