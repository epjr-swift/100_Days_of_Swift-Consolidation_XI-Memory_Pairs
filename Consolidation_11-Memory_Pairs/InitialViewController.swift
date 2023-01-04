//
//  InitialViewController.swift
//  Consolidation_11-Memory_Pairs
//
//  Created by Edwin Przeźwiecki Jr. on 18/12/2022.
//

import LocalAuthentication
import UIKit

extension UIView {
    func blink() {
        self.alpha = 0
        UIView.animate(withDuration: 1, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: { self.alpha = 1 })
    }
}

class InitialViewController: UIViewController {
    
    @IBOutlet var startGameButton: UIButton!
    @IBOutlet var addPairsButton: UIButton!
    
    var pairs = SavedPairs()
    
    var firstRun = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hue: 0.6, saturation: 1, brightness: 0.3, alpha: 1)
        
        startGameButton.blink()
        
        let defaults = UserDefaults.standard
        
        if let savedRunState = defaults.value(forKey: "firstRun") as? Bool {
            firstRun = savedRunState
            print(firstRun)
        }
        
        if !firstRun {
            DispatchQueue.global().async { [weak self] in
                self?.pairs.load()
                print("Second run")
                print(SavedPairs.allPairs)
            }
        } else if firstRun {
            
            if let pairsURL = Bundle.main.url(forResource: "pairs", withExtension: "txt") {
                if let pairs = try? String(contentsOf: pairsURL) {
                    let lines = pairs.components(separatedBy: "\n")
                    
                    for line in lines {
                        let components = line.components(separatedBy: ": ")
                        SavedPairs.allPairs[components[0]] = components[1]
                    }
                }
            }
            
            SavedPairs.separatedPairs += SavedPairs.allPairs.keys.map { "\($0)" }
            SavedPairs.separatedPairs += SavedPairs.allPairs.values.map { "\($0)" }
            SavedPairs.separatedPairs += [""]
            
            firstRun.toggle()
            save()
            
            pairs.save()
            print(SavedPairs.separatedPairs)
        }
    }
    
    @IBAction func startGame(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func addPairs(_ sender: Any) {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please identify yourself."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        if let viewController = self?.storyboard?.instantiateViewController(withIdentifier: "PairsTableViewController") as? PairsTableViewController {
                            self?.navigationController?.pushViewController(viewController, animated: true)
                        }
                    } else {
                        let alertController = UIAlertController(title: "Authentication failed", message: "You could not be verified. Please try again.", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        self?.present(alertController, animated: true)
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alertController, animated: true)
        }
    }
    
    func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(firstRun, forKey: "firstRun")
    }
}
