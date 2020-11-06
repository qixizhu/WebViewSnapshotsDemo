//
//  UIImage+Extension.swift
//  WebViewSnapshotsDemo
//
//  Created by 韩企 on 2020/11/6.
//

import UIKit

extension UIImage {
    func getThumbnail(withScale scale: CGFloat, toSize newSize: CGSize) -> UIImage? {
        let scaleSize = CGSize(width: newSize.width * scale, height: newSize.height * scale)
        let oldSize = size
        var rect = CGRect.zero
        if scaleSize.width / scaleSize.height > oldSize.width / oldSize.height {
            rect.size.width = scaleSize.height * oldSize.width / oldSize.height
            rect.size.height = scaleSize.height
            rect.origin.x = (scaleSize.width - rect.size.width) / 2
            rect.origin.y = 0
        } else {
            rect.size.width = scaleSize.width
            rect.size.height = scaleSize.width * oldSize.height / oldSize.width
            rect.origin.x = 0
            rect.origin.y = (scaleSize.height - rect.size.height) / 2
        }
        
        UIGraphicsBeginImageContext(scaleSize)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(UIColor.clear.cgColor)
        UIRectFill(CGRect(origin: .zero, size: scaleSize))
        draw(in: rect)
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
