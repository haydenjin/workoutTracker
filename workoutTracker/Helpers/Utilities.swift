import Foundation
import UIKit


class Utilities {
    
    static func addDoneButtonOnKeyboard(_ textField: UITextField){
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default

            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: textField, action: #selector(UITextField.resignFirstResponder))

            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()

            textField.inputAccessoryView = doneToolbar
        }
    
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleTableViewCells(_ cell:UITableViewCell) {
        
        //cell.backgroundColor = UIColor.init(red: 90/255, green: 50/255, blue: 200/255, alpha: 1)
        cell.layer.cornerRadius = 25.0
        cell.tintColor = UIColor.white
    }
    
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.backgroundColor = UIColor.init(red: 48/255, green: 40/255, blue: 140/255, alpha: 1)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        // Password must have (One character)(One uppercase character)(One special character)(Is at least 6 characters long)
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,}$")
        return passwordTest.evaluate(with: password)
    }
    
    struct Themes {
        
        static var backgroundColor:UIColor?
        static var buttonTextColor:UIColor?
        static var buttonBackgroundColor:UIColor?
        static var tableviewCellColor:UIColor?
        
        static public func tealWhite() {
            self.backgroundColor = UIColor.white
            self.buttonTextColor = UIColor.blue
            self.buttonBackgroundColor = UIColor.white
            self.tableviewCellColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
            updateDisplay()
        }

        static public func blackMint() {
            self.backgroundColor = UIColor.darkGray
            self.buttonTextColor = UIColor.white
            self.buttonBackgroundColor = UIColor.black
            self.tableviewCellColor = UIColor(red: 52, green: 235, blue: 161, alpha: 1)
            updateDisplay()
        }

        static public func updateDisplay() {
            let proxyButton = UIButton.appearance()
            proxyButton.setTitleColor(Themes.buttonTextColor, for: .normal)
            proxyButton.backgroundColor = Themes.buttonBackgroundColor

            let proxyView = UIView.appearance()
            proxyView.backgroundColor = backgroundColor
            
            let tableView = UITableViewCell.appearance()
            tableView.backgroundColor = tableviewCellColor
        }
    }

}
