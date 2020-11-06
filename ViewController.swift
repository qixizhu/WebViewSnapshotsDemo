//
//  ViewController.swift
//  WebViewSnapshotsDemo
//
//  Created by 七夕猪 on 2020/11/5.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var previewButton: UIBarButtonItem!
    // Tip: 删除 weak 后，当设置active=false 后，不会被系统自动释放
    @IBOutlet var webViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var webViewBottomConstraint: NSLayoutConstraint!
    
    private var titleObservationToken: NSKeyValueObservation?
    private var isLoadingObservationToken: NSKeyValueObservation?
    
    private var webImages: [UIImage] = []
    private let webImagesAspectRatio: CGFloat = sqrt(2)
    
    /// 当前截取的图片过多时，会导致运行内存暴涨，从而崩溃。所以需要在内存警告时，停止截图
    private var isMemoryWarning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpObservation()
        
        guard let url = URL(string: "https://m.baidu.com/") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func setUpObservation() {
        webView.navigationDelegate = self
        
        titleObservationToken = webView.observe(\.title) { [weak self] (object, change) in
            guard let `self` = self else { return }
            `self`.title = `self`.webView.title
        }
        
        isLoadingObservationToken = webView.observe(\.isLoading) { [weak self] (object, change) in
            guard let `self` = self else { return }
            if `self`.webView.isLoading {
                `self`.indicator.startAnimating()
            } else {
                `self`.indicator.stopAnimating()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        isMemoryWarning = true
        print("didReceiveMemoryWarning")
    }
    
}

// MARK: Actions
extension ViewController {
    @IBAction func previewButtonClicked(_ sender: UIBarButtonItem) {
        webImages.removeAll()
        
        // TODO: - Show HUD.
        
        isMemoryWarning = false
        
        setWebViewLayoutFitSnapshot()
        
        webView.takeAllSnapshots(with: webImagesAspectRatio) { [weak self] () -> Bool in
            guard let `self` = self else { return true }
            return `self`.isMemoryWarning
        } completionHandler: { [weak self] (snapshotImages) in
            // TODO: - Hide HUD.
            
            guard let `self` = self else { return }
            `self`.restoreWebViewLayout()
            
            guard !`self`.isMemoryWarning else {
                // TODO: - Show Alert.
                
                `self`.previewButton.isEnabled = false
                return
            }
            
            `self`.webImages = snapshotImages
            guard !`self`.webImages.isEmpty else {
                return
            }
            `self`.performSegue(withIdentifier: "showWebPages", sender: sender)
        }

    }
}

// MARK: Web screenshots
extension ViewController {
    // 将webView高度设置为内容高度
    private func setWebViewLayoutFitSnapshot() {
        webViewBottomConstraint.isActive = false
        webViewHeightConstraint.constant = webView.scrollView.contentSize.height
        webViewHeightConstraint.isActive = true
        view.layoutIfNeeded()
    }
    
    // 将webView的布局恢复
    private func restoreWebViewLayout() {
        webViewHeightConstraint.isActive = false
        webViewBottomConstraint.isActive = true
        view.layoutIfNeeded()
    }
}

// MARK: WKNavigationDelegate
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        previewButton.isEnabled = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        previewButton.isEnabled = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        previewButton.isEnabled = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        previewButton.isEnabled = false
    }
}

// MARK: Navigation
extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebPages" {
            let webpages = segue.destination as! WebPagesCollectionViewController
            webpages.sourceItems = webImages
        }
    }
}
