//
//  UIImageView+Extensions.swift
//  Talent
//
//  Created by Aamal Holding Android on 18/06/2023.
//

import Foundation
import UIKit

extension UIImageView{
    
    func downloadImg(imgPath:String , size:CGSize, placeholder:UIImage = UIImage()){
        self.image = placeholder
        download(imagePath: imgPath, size: size)
    }
    
    func download(imagePath:String , size:CGSize) {
        self.subviews.forEach{ $0.removeFromSuperview() }
        let loading = UIActivityIndicatorView(style: .medium)
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.hidesWhenStopped = true
        addSubview(loading)
        loading.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loading.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loading.startAnimating()
        if let image = ImageCacheManager.shared.image(forKey: imagePath) {
            self.image = image
            loading.stopAnimating()
            return
        }
        guard let url = URL(string: imagePath) else {return}
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async {
                    loading.stopAnimating()
                }
                return
            }
            DispatchQueue.main.async {
                loading.stopAnimating()
                guard let img = UIImage(data: data)?.scaleImage(toSize: size) else {return}
                DispatchQueue.global().async {
                    ImageCacheManager.shared.setImage(img, forKey: imagePath)
                }
                self.image = img
            }
        }
    }
    
}

extension UIImage {
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }
}


