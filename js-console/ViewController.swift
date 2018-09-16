//
//  ViewController.swift
//  js-console
//
//  Created by Anton Vronskii on 2018/09/16.
//  Copyright © 2018 Anton Vronskii. All rights reserved.
//

import UIKit
import JavaScriptCore

class ViewController: UIViewController {
  @IBOutlet var codeEditor: UITextView!
  @IBOutlet var console: UITextView!
  private var jsContext: JSContext!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    codeEditor.becomeFirstResponder()
  }
  
  private func newJSContext() -> JSContext {
    jsContext = JSContext()!
    jsContext.exceptionHandler = exceptionHandler
    jsContext.evaluateScript("var console = { log: function(message) { _consoleLog(message) } }")
    let consoleLog: @convention(block) (String) -> Void = { [unowned self] message in
      print("CONSOLE: " + message)
      self.console.text = self.console.text + "\n" + message
    }
    jsContext.setObject(unsafeBitCast(consoleLog, to: AnyObject.self), forKeyedSubscript: "_consoleLog" as (NSCopying & NSObjectProtocol)!)
    return jsContext
  }
  
  @IBAction func runJS() {
    let js = codeEditor.text
    let jsContext = newJSContext()
    jsContext.evaluateScript(js)
  }
  
  func exceptionHandler(jsContext: JSContext?, jsValue: JSValue?) {
    var errorMessage = "ERROR: "
    if let error = jsValue {
      errorMessage += error.toString()
    } else {
      errorMessage += "unknown"
    }
    self.console.text += "\n" + errorMessage
  }
  
  @IBAction func clearConsole() {
    console.text = ""
  }
}

// Shortcuts support
extension ViewController {
  override var canBecomeFirstResponder: Bool {
    return true
  }
  
  override var keyCommands: [UIKeyCommand]? {
    return [
      UIKeyCommand(input: "R", modifierFlags: .command, action: #selector(runJS), discoverabilityTitle: "Run script"),
      UIKeyCommand(input: "K", modifierFlags: .command, action: #selector(clearConsole), discoverabilityTitle: "Clear console")
    ]
  }
}
