import UIKit
import SwiftUI
import ObjectiveC.runtime

@main
final class SkillzAppDelegate: UIResponder, UIApplicationDelegate, SkillzDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        configureCleverTapAlertPresentationIfNeeded()

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: RootView())
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    func tournamentWillBegin(_ gameParameters: [AnyHashable : Any], with matchInfo: SKZMatchInfo) {
        SkillzBridge.shared.handleTournamentWillBegin(gameParameters, matchInfo: matchInfo)
    }

    func onProgressionRoomEnter() {
        SkillzBridge.shared.handleProgressionRoomEnter()
    }

    func skillzWillExit() {
        SkillzBridge.shared.handleSkillzWillExit()
    }

    func skillzHasFinishedLaunching() {
        SkillzBridge.shared.handleSkillzHasFinishedLaunching()
    }

    func skillzWillLaunch() {
        SkillzBridge.shared.handleSkillzWillLaunch()
    }

    private func configureCleverTapAlertPresentationIfNeeded() {
        let cleverTapClassNames = [
            "CleverTap",
            "SKZCleverTapHelper",
            "SKZCleverTapGroupManager"
        ]
        let sharedInstanceSelector = NSSelectorFromString("sharedInstance")
        let alertControllerSelector = NSSelectorFromString("setUseUIAlertControllerIfAvailable:")

        for className in cleverTapClassNames {
            guard let cleverTapClass = NSClassFromString(className) else { continue }
            guard let sharedMethod = class_getClassMethod(cleverTapClass, sharedInstanceSelector) else { continue }

            typealias SharedInstanceIMP = @convention(c) (AnyClass, Selector) -> AnyObject?
            let sharedInstance = unsafeBitCast(method_getImplementation(sharedMethod), to: SharedInstanceIMP.self)
            guard let cleverTap = sharedInstance(cleverTapClass, sharedInstanceSelector) as? NSObject else { continue }
            guard cleverTap.responds(to: alertControllerSelector) else { continue }
            cleverTap.perform(alertControllerSelector, with: NSNumber(value: true))
            return
        }
    }
}
