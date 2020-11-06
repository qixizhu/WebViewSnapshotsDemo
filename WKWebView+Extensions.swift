//
//  WKWebView+Extensions.swift
//  WebViewSnapshotsDemo
//
//  Created by 韩企 on 2020/11/5.
//

import WebKit

extension WKWebView {
    /// 截取所有快照
    /// - Parameters:
    ///   - aspectRatio: 截取的图片高宽比，height/width
    ///   - nextPageOffset: 设置下一页的前`nextPageOffset`个像素重复上一页的后`nextPageOffset`个像素
    ///   - cancelHandler: 可以返回`true`，随时结束生成图片
    func takeAllSnapshots(with aspectRatio: CGFloat, nextPageOffset: CGFloat = 0.0, cancelHandler: @escaping () -> Bool, completionHandler: @escaping  (_ snapshotImages: [UIImage]) -> Void) {
        let origalOffset = scrollView.contentOffset
        
        // snapshotView 覆盖在 webView 之上
        guard let snapShotView = snapshotView(afterScreenUpdates: true) else {
            completionHandler([])
            return
        }
        snapShotView.frame = CGRect(origin: frame.origin, size: snapShotView.bounds.size)
        superview?.insertSubview(snapShotView, aboveSubview: self)
        
        /// 设置初始截取区域
        let snapshotConfiguration = WKSnapshotConfiguration()
        snapshotConfiguration.rect = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: bounds.width * aspectRatio))
        
        // 获得最终可截取图片的数量
        let pageCount = numberOfPages(with: aspectRatio, nextPageOffset: nextPageOffset)
        
        capture(nextPageOffset: nextPageOffset, numberOfPages: pageCount, configuration: snapshotConfiguration, cancelHandler: cancelHandler) { [weak self] (snapshotImages) in
            guard let `self` = self else {
                completionHandler([])
                return
            }
            `self`.scrollView .setContentOffset(origalOffset, animated: false)
            snapShotView.removeFromSuperview()
            completionHandler(snapshotImages)
        }
    }
    
    /// 获取最终可截取图片的数量
    /// - Parameters:
    ///   - aspectRatio: 高宽比
    ///   - nextPageOffset: 设置下一页的前10个像素重复上一页的后nextPageOffset个像素
    /// - Returns: page count
    private func numberOfPages(with aspectRatio: CGFloat, nextPageOffset: CGFloat = 0.0) -> Int {
        let totalHeight = scrollView.contentSize.height
        let scrollHeight = scrollView.frame.width * aspectRatio - nextPageOffset
        
        var offset: CGFloat = 0.0
        var pageCount = 1
        
        while true {
            let newOffset = offset + scrollHeight
            if newOffset < totalHeight {
                pageCount += 1
                offset = newOffset
            } else {
                break;
            }
        }
        
        return pageCount
    }
    
    private func capture(withStartPage index: Int = 1, offset: CGPoint = .zero, nextPageOffset: CGFloat = 0.0, numberOfPages maxIndex: Int, configuration: WKSnapshotConfiguration, capturedImages: [UIImage] = [], cancelHandler: @escaping () -> Bool, completionHandler: @escaping (_ snapshotImages: [UIImage]) -> Void) {
        guard !cancelHandler() else {
            completionHandler(capturedImages)
            return
        }
        
        var tempCaptruedImages = capturedImages
        let pageHeight = configuration.rect.height
        
        let deadline = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.takeSnapshot(with: configuration) { [weak self] (imageOpt, error) in
                guard let `self` = self else {
                    completionHandler([])
                    return
                }
                
                if let image = imageOpt {
                    tempCaptruedImages.append(image)
                }
                if index < maxIndex {
                    let nextOffset = CGPoint(x: offset.x, y: offset.y + pageHeight - nextPageOffset)
                    configuration.rect = CGRect(origin: CGPoint(x: 0, y: nextOffset.y), size: configuration.rect.size)
                    `self`.capture(withStartPage: index + 1, offset: nextOffset, nextPageOffset: nextPageOffset, numberOfPages: maxIndex, configuration: configuration, capturedImages: tempCaptruedImages, cancelHandler: cancelHandler, completionHandler: completionHandler)
                } else {
                    completionHandler(tempCaptruedImages)
                }
            }
        }
    }
    
}
