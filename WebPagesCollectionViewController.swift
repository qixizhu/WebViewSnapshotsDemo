//
//  WebPagesCollectionViewController.swift
//  WebViewSnapshotsDemo
//
//  Created by 韩企 on 2020/11/5.
//

import UIKit

private let reuseIdentifier = "WebPageCollectionViewCell"

class WebPagesCollectionViewController: UICollectionViewController, UIDocumentInteractionControllerDelegate {
    
    var sourceItems: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sourceItems.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! WebPageCollectionViewCell
        
        cell.layoutIfNeeded()
        
        let image = sourceItems[indexPath.item]
        let imageSize = cell.imageView.bounds.size
        let scale = collectionView.traitCollection.displayScale
        let thumbnail = image.getThumbnail(withScale: scale, toSize: imageSize)
        
        cell.imageView.image = thumbnail
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = sourceItems[indexPath.item]
        guard let imageData = selectedImage.pngData() else { return }
        let tmpPath = NSTemporaryDirectory() as NSString
        let path = tmpPath.appendingPathComponent("Image_\(indexPath.item).png")
        let url = URL(fileURLWithPath: path)
        try? imageData.write(to: url)
        
        let document = UIDocumentInteractionController(url: url)
        document.delegate = self
        document.presentPreview(animated: true)
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: UIDocumentInteractionControllerDelegate
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

}
