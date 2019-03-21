//
//  Copyright © 2018 Microsoft Corporation. All rights reserved.
//

#if DOGFOOD
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute
import AppCenterPush
#endif
import UIKit

#if DOGFOOD
private let appCenterSecret = to_be_supplied_before_compilation
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIImage.addDarkerPrimaryColors(darkerPrimaryColorByImageName, forImagesIn: .main)

        let splitViewController = window!.rootViewController as! UISplitViewController
        let masterContainer = splitViewController.viewControllers.first as! UINavigationController
        let masterController = masterContainer.topViewController as! MasterViewController
        let detailContainer = splitViewController.viewControllers.last as! UINavigationController
        let detailController = detailContainer.topViewController!

        masterController.demoPlaceholder = detailController
        detailController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self

        #if DOGFOOD
        MSAppCenter.start(appCenterSecret, withServices: [
            MSAnalytics.self,
            MSCrashes.self,
            MSDistribute.self,
            MSPush.self
        ])
        #endif

        return true
    }

    // MARK: Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // Return true to indicate that we don't care about DetailViewController - it will be removed
        return (secondaryViewController as? UINavigationController)?.topViewController is DetailViewController
    }
}

// MARK: - Image primary colors for Darker System Colors mode

private let darkerPrimaryColorByImageName: [String: UIColor] = [
    "agenda-25x25": #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1),                 // #4D4D4D
    "attach-25x25": #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1),                 // #4D4D4D
    "day-view-25x25": #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1),               // #4D4D4D
    "flag-25x25": #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1),                   // #4D4D4D
    "mail-unread-25x25": #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1),            // #4D4D4D
    "month-view-25x25": #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1),             // #4D4D4D
    "week-view-25x25": #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)               // #4D4D4D
]
