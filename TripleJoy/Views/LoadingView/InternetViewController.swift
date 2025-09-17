import UIKit
import WebKit
import OneSignalFramework

class WebviewVC: UIViewController, WKNavigationDelegate  {
    
    private let oneSignalIDChecker = OneSignalIDChecker()

    func obtainCookies() {
        let standartStorage: UserDefaults = UserDefaults.standard
        let data: Data? = standartStorage.object(forKey: "cvcvcv") as? Data
        if let cookie = data {
            let datas: NSArray? = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: cookie)
            if let cookies = datas {
                for c in cookies {
                    if let cookieObject = c as? HTTPCookie {
                        HTTPCookieStorage.shared.setCookie(cookieObject)
                    }
                }
            }
        }
    }

    lazy var firemanWebviewForTerms: WKWebView = {
        let privacyConfiguration = WKWebViewConfiguration()
        privacyConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true
        privacyConfiguration.allowsPictureInPictureMediaPlayback = true
        privacyConfiguration.allowsAirPlayForMediaPlayback = true
        privacyConfiguration.allowsInlineMediaPlayback = true
        let privacyPreferences = WKWebpagePreferences()
        privacyPreferences.preferredContentMode = .mobile
        privacyConfiguration.defaultWebpagePreferences = privacyPreferences
        let webView = WKWebView(frame: .zero, configuration: privacyConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addUI()
        obtainCookies()
        onesignalInit()
        firemanWebviewForTerms.navigationDelegate = self
    }

    init(url: URL) {
        self.termsURL = url
        print("termsURL: \(termsURL)")
        super.init(nibName: nil, bundle: nil)
    }
    let termsURL: URL
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            oneSignalIDChecker.stopCheckingOneSignalID()
        }
    
    private func onesignalInit() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            OneSignal.Notifications.requestPermission({ accepted in

            }, fallbackToSettings: true)
            
        }
    }
    
    private func addUI() {
        view.addSubview(firemanWebviewForTerms)
        firemanWebviewForTerms.load(URLRequest(url: termsURL))
        firemanWebviewForTerms.allowsBackForwardNavigationGestures = true
        
        firemanWebviewForTerms.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firemanWebviewForTerms.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            firemanWebviewForTerms.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            firemanWebviewForTerms.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            firemanWebviewForTerms.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func saveCookies() {
        let cookieJar: HTTPCookieStorage = HTTPCookieStorage.shared
        if let cookies = cookieJar.cookies {
            let data: Data? = try? NSKeyedArchiver.archivedData(withRootObject: cookies, requiringSecureCoding: false)
            if let data = data {
                let userDefaults = UserDefaults.standard
                userDefaults.set(data, forKey: "cvcvcv")
            }
        }
    }
  
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        saveCookies()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Checking web view url")
        if let url = webView.url {
            print("URL for webview: \(url)")
            print("lol kek")
            if SaveService.lastUrl == nil {
                SaveService.lastUrl = url
                print("Last url: \(String(describing: SaveService.lastUrl))")
            }
        }
    }
}

struct SaveService {
    
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: "LastUrl") }
        set { UserDefaults.standard.set(newValue, forKey: "LastUrl") }
    }
}

class OneSignalIDChecker {
    
    private var timer: Timer?
    func startCheckingOneSignalID() {
        stopCheckingOneSignalID()
        timer = Timer.scheduledTimer(
            timeInterval: 0.5,
            target: self,
            selector: #selector(printOneSignalID),
            userInfo: nil,
            repeats: true
        )
    }
    func stopCheckingOneSignalID() {
        timer?.invalidate()
        timer = nil
    }
    
    // Функция, которая будет вызываться таймером
    @objc private func printOneSignalID() {
        _ = OneSignal.User.onesignalId ?? "OneSignal ID не найден"
    }
}
