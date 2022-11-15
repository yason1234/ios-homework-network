//
//  ViewController.swift
//  FileManagerNetologia
//
//  Created by Dima Shikhalev on 14.11.2022.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var tableView = UITableView()
    private let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    private var contentOfFile: [String] {
        do {
           return try FileManager.default.contentsOfDirectory(atPath: documentPath)
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    private lazy var imagePicker = ImagePicker()
    private lazy var rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addImage))
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
        
        navigationItem.rightBarButtonItem = rightButton
        
        imagePicker.delegate = self
    }
    
    @objc private func addImage() {
        imagePicker.presentPicker(self)
    }
}

extension ViewController {
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

//MARK: tableView delegate && dataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
   
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

extension ViewController: imagePickerProtocol {
   
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

