//
//  SettingsViewController.swift
//  FileManagerNetologia
//
//  Created by Dima Shikhalev on 18.11.2022.
//

import UIKit
protocol ActionProtocol: AnyObject {
    func sort()
    func changePass()
}

class SettingsViewController: UIViewController {
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Sort files", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private lazy var changePasswordButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Change password", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: ActionProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setConstrainsts()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(sortButton)
        view.addSubview(changePasswordButton)
        
        sortButton.addTarget(self, action: #selector(sorting), for: .touchUpInside)
        changePasswordButton.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
    }
    
    private func setConstrainsts() {
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            sortButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sortButton.widthAnchor.constraint(equalToConstant: 150),
            
            changePasswordButton.topAnchor.constraint(equalTo: sortButton.bottomAnchor, constant: 50),
            changePasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            changePasswordButton.widthAnchor.constraint(equalToConstant: 150),
        ])
    }
    
    @objc private func sorting() {
        delegate?.sort()
    }
    
    @objc private func changePassword() {
        delegate?.changePass()
    }

}
