//
//  SafariTabsVC.swift
//  MyHenFarm2
//
//  Created by Роман Главацкий on 08.10.2025.
//

import SafariServices
import WebKit

final class SafariTabsVC: UIViewController {

    private let startURL: URL

    init(url: URL) {
        self.startURL = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        clearSafariCacheThenOpen()
    }

    private func clearSafariCacheThenOpen() {
        let dataStore = WKWebsiteDataStore.default()
        let types = WKWebsiteDataStore.allWebsiteDataTypes()

        dataStore.fetchDataRecords(ofTypes: types) { records in
            dataStore.removeData(ofTypes: types, for: records) {
                print("🧹 Cookies и кеш очищены перед открытием Safari.")
                DispatchQueue.main.async {
                    self.openInSafari()
                }
            }
        }
    }

    private func openInSafari() {
        let safariVC = SFSafariViewController(url: startURL)
        safariVC.preferredControlTintColor = .systemBlue
        safariVC.dismissButtonStyle = .close
        present(safariVC, animated: true)
    }
}

struct SaveService {
    
    static var lastUrl: URL? {
        get { UserDefaults.standard.url(forKey: "LastUrl") }
        set { UserDefaults.standard.set(newValue, forKey: "LastUrl") }
    }
}
