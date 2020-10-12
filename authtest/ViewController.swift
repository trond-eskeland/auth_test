//
//  ViewController.swift
//  authtest
//
//  Created by Trond Eskeland on 12/10/2020.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    private lazy var url = URL(string: "https://login.microsoftonline.com/3aa4a235-b6e2-48d5-9195-7fcf05b459b0/oauth2/v2.0/authorize?client_id=c39073fd-aee8-45fb-aba0-7d82725e125d&redirect_uri=https%3A%2F%2Fq97web.statoil.no%2Fsap%2Fsaml2%2Fsp%2Facs%2F560&scope=user.read+profile+openid+offline_access&nonce=002cadd0-b849-4e8b-cd76-6965251ae1b4&state=1602502687936&prompt=&response_type=code&domain_hint=organizations")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // Do any additional setup after loading the view.
        
        let request = URLRequest(url: url)
        
        webView.load(request)
        
    
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url {
            webView.getCookies(for: url.host) { data in
                print("=========================================")
                print("\(url.absoluteString)")
                print(data)
            }
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // push new screen to the navigation controller when need to open url in another "tab"
        if let url = navigationAction.request.url, navigationAction.targetFrame == nil {
            let viewController = ViewController()
            // viewController.initWebView(configuration: configuration)
            viewController.url = url
            DispatchQueue.main.async { [weak self] in
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
            return viewController.webView
        }
        return nil
    }


}

extension WKWebView {

    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }

    func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}

extension WKWebView {

    func load(urlString: String) {
        if let url = URL(string: urlString) { load(url: url) }
    }

    func load(url: URL) { load(URLRequest(url: url)) }
}
