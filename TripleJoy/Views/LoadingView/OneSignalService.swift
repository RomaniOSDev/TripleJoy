//
//  OneSignalService.swift
//  TripleJoy
//
//  Created by Jack Foster on 24.10.2025.
//

import Foundation
import OneSignalFramework
import Combine
import AppsFlyerLib

@MainActor
final class OneSignalService: ObservableObject {

    static let shared = OneSignalService()
    private var isInitialized = false
    private let appsFlyerId = AppsFlyerLib.shared().getAppsFlyerUID()

    private init() {}

    // MARK: - Initialize OneSignal when needed
    func initializeIfNeeded() {
        guard !isInitialized else { return }

        OneSignal.initialize("b5a9b955-eef8-4954-928c-05cdfd93d5cb", withLaunchOptions: nil)
        OneSignal.login(appsFlyerId)
        // Указываем, что пуши требуют разрешения пользователя
        OneSignal.Notifications.clearAll()

        isInitialized = true
        print("✅ OneSignal initialized")
    }

    // MARK: - Request permission (новый API)
        func requestPermission() {
            OneSignal.Notifications.requestPermission({ accepted in
                print("🔔 Push permission granted: \(accepted)")
            }, fallbackToSettings: true)
        }

        // MARK: - Get current OneSignal ID
        func getOneSignalID() -> String? {
            return OneSignal.User.onesignalId
        }

}
