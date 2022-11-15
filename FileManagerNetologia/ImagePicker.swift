//
//  ImagePicker.swift
//  FileManagerNetologia
//
//  Created by Dima Shikhalev on 15.11.2022.
//

import UIKit

protocol imagePickerProtocol: AnyObject {
    func addImageToDocuments(_ imagePath: String)
}

final class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var picker = UIImagePickerController()
    weak var delegate: imagePickerProtocol?
    
    override init() {
        super.init()
        picker.delegate = self
    }
    
    func presentPicker(_ viewController: UIViewController) {
        viewController.present(picker, animated: true)
    }
    
    func presentAlert(_ viewController: UIViewController) {
        self.picker.present(viewController, animated: true)
    }
    
    func dismissPicker(_ viewController: UIViewController, tableView: UITableView) {
        viewController.dismiss(animated: true) {
            tableView.reloadData()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let imagePath = (info[.imageURL] as? URL)?.path() else {return}
        delegate?.addImageToDocuments(imagePath)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
