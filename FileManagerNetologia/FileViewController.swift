//
//  ViewController.swift
//  FileManagerNetologia
//
//  Created by Dima Shikhalev on 14.11.2022.
//

import UIKit
import KeychainAccess

class FileViewController: UIViewController, FileVCDelegate {
    
    private lazy var tableView = UITableView()
    private let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    private var contentOfFile: [String] {
        get {
            do {
                if !isSorted {
                    return try FileManager.default.contentsOfDirectory(atPath: documentPath).sorted(by: {$0 > $1})
                } else {
                    return try FileManager.default.contentsOfDirectory(atPath: documentPath).sorted(by: {$0 < $1})
                }
            } catch {
                print(error.localizedDescription)
            }
            return []
        } set {
            
        }
    }
    private lazy var imagePicker = ImagePicker()
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private var isSorted: Bool {
        get {
            UserDefaults.standard.bool(forKey: "sorted")
        } set {
            UserDefaults.standard.set(newValue, forKey: "sorted")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        configure()
        setConstraints()
    }
    
    private func setupView() {
        view.addSubview(tableView)
        view.backgroundColor = .white
    }
    
    private func configure() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        imagePicker.delegate = self
    }
    
    @objc internal func addImage() {
        imagePicker.presentPicker(self)
    }
}

extension FileViewController {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
           // rightButton
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

//MARK: tableView delegate && dataSource
extension FileViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contentOfFile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = contentOfFile[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fullPath = documentPath + "/" + "\(contentOfFile[indexPath.row])"
            try? FileManager.default.removeItem(atPath: fullPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension FileViewController: imagePickerProtocol {
   
    func addImageToDocuments(_ imagePath: String) {
        
        let alertController = UIAlertController(title: "Image name", message: "Enter image name", preferredStyle: .alert)
        alertController.addTextField()
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            guard let text = alertController.textFields?[0].text, !text.isEmpty else { return }
            
            let toPath = self.documentPath.appending("/" + "\(text)")
            
            DispatchQueue.main.async {
                do {
                    try? FileManager.default.removeItem(atPath: toPath)
                    try FileManager.default.moveItem(atPath: imagePath, toPath: toPath)
                    self.tableView.reloadData()
                    self.imagePicker.dismissPicker(self, tableView: self.tableView)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        alertController.addAction(action)
        imagePicker.presentAlert(alertController)
    }
}

extension FileViewController: ActionProtocol {
    func sort() {
        isSorted.toggle()
        tableView.reloadData()
        }
    
    func changePass() {
        let alertController = UIAlertController(title: "Change password", message: "Enter new password", preferredStyle: .alert)
        
        alertController.addTextField()
        let action = UIAlertAction(title: "Enter", style: .default) { _ in
            guard let pass = try? Keychain().get("password") else { return }
            guard let text =  alertController.textFields?[0].text else { return }
            if text == pass {
                self.presentAlert(title: "Change password", message: "Enter password", tag: 0)
            } else {
                self.presentAlert(title: "Oops", message: "Incorrect password", tag: 1)
            }
        }
        
        alertController.addAction(action)
        
        navigationController?.present(alertController, animated: true)
    }
    
    private func presentAlert(title: String, message: String, tag: Int) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if tag == 0 {
            alertController.addTextField()

            let action = UIAlertAction(title: "Enter", style: .default) { _ in
                guard let text =  alertController.textFields?[0].text else { return }
                try? Keychain().set(text, key: "password")
            }
                alertController.addAction(action)
        } else {
            let action = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(action)
        }
        
        navigationController?.present(alertController, animated: true)
    }
}


