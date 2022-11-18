//
//  VerificationViewController.swift
//  FileManagerNetologia
//
//  Created by Dima Shikhalev on 17.11.2022.
//

import UIKit
import KeychainAccess

protocol FileVCDelegate: AnyObject {
    func addImage()
}

enum State: String, Codable {
    case notAuthorized = "notAuthorized"
    case registration = "registration"
    case authorized = "authorized"
}

class VerificationViewController: UIViewController {
    
    private var state: String {
        get {
            guard let state = UserDefaults.standard.string(forKey: "state") else { return State.notAuthorized.rawValue }
            return state
        } set {
            UserDefaults.standard.set("\(newValue)", forKey: "state")
        }
    }
    private lazy var passwordTF = UITextField()
    private var enterPassword: UIButton = {
        let button = UIButton()
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        return button
    }()
    private var resetPassword: UIButton = {
        let button = UIButton()
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.setTitle("Reset password", for: .normal)
        return button
    }()

    weak var delegate: FileVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(passwordTF)
        view.addSubview(enterPassword)
        view.addSubview(resetPassword)
        
        passwordTF.translatesAutoresizingMaskIntoConstraints = false
        enterPassword.translatesAutoresizingMaskIntoConstraints = false
        resetPassword.translatesAutoresizingMaskIntoConstraints = false
        
        passwordTF.backgroundColor = .lightGray
        passwordTF.layer.borderWidth = 2
        passwordTF.layer.cornerRadius = 10
        passwordTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        passwordTF.leftViewMode = .always
        
        enterPassword.addTarget(self, action: #selector(enterPass), for: .touchUpInside)
        resetPassword.addTarget(self, action: #selector(resetPasswordAction), for: .touchUpInside)


        setState(statevalue: state)
        
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            passwordTF.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            passwordTF.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTF.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3),
            passwordTF.heightAnchor.constraint(equalTo: passwordTF.widthAnchor, multiplier: 1/4),

            enterPassword.topAnchor.constraint(equalTo: passwordTF.bottomAnchor,constant: 50),
            enterPassword.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enterPassword.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/5),
            
            resetPassword.topAnchor.constraint(equalTo: enterPassword.bottomAnchor, constant: 50),
            resetPassword.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetPassword.widthAnchor.constraint(equalTo: enterPassword.widthAnchor)
        ])
    }
    
    private func setState(statevalue: String) {
        switch statevalue {
        case "notAuthorized":
            passwordTF.text = nil
            enterPassword.setTitle("Create password", for: .normal)
        case "registration":
            passwordTF.text = nil
            enterPassword.setTitle("Repeat password", for: .normal)
        case "authorized":
            passwordTF.text = nil
            enterPassword.setTitle("Enter password", for: .normal)
        default: break
        }
    }

    @objc private func enterPass() {
        
        guard let pass = passwordTF.text, pass.count >= 4 else { return }
        
        switch state {
        case "notAuthorized":
            try? Keychain().set(pass, key: "password")
            state = "registration"
            setState(statevalue: state)
        case "registration":
            let enterPass = try? Keychain().get("password")
            if pass == enterPass {
                state = "authorized"
                pushTabbarVC()
                setState(statevalue: state)
            } else {
                state = "notAuthorized"
                setState(statevalue: state)
                presentAlert()
            }
        case "authorized":
            let enterPass = try? Keychain().get("password")
            if pass == enterPass {
                setState(statevalue: state)
                pushTabbarVC()
            } else {
                presentAlert()
            }
        default: break
        }
    }
    
    @objc private func resetPasswordAction() {
        UserDefaults.standard.removeObject(forKey: "state")
        setState(statevalue: state)
    }
    
    private func presentAlert() {
        let alertController = UIAlertController(title: "Oops", message: "incorrect password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ooops", style: .default) { [weak self] _ in
            self?.passwordTF.text = nil
        }
        alertController.addAction(action)
        
        navigationController?.present(alertController, animated: true)
    }
    
    private func pushTabbarVC() {
        let tabbarVC = UITabBarController()
        
        let fileVC = FileViewController()
        fileVC.tabBarItem = UITabBarItem(title: "Files", image: UIImage(systemName: "folder"), tag: 0)
        
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 1)
        
        tabbarVC.viewControllers = [fileVC, settingsVC]
        delegate = fileVC
        settingsVC.delegate = fileVC
        tabbarVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImage))
        navigationController?.pushViewController(tabbarVC, animated: true)
    }
    
    @objc private func addImage() {
        delegate?.addImage()
    }
}
