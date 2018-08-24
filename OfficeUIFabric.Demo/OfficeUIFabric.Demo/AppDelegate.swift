//
//  Copyright © 2018 Microsoft Corporation. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
        let splitViewController = window!.rootViewController as! UISplitViewController
        let masterContainer = splitViewController.viewControllers.first as! UINavigationController
        let masterController = masterContainer.topViewController as! MasterViewController
        let detailContainer = splitViewController.viewControllers.last as! UINavigationController
        let detailController = detailContainer.topViewController!

        masterController.demoPlaceholder = detailController
        detailController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self

        return true
    }

    // MARK: Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // Return true to indicate that we don't care about DetailViewController - it will be removed
        return (secondaryViewController as? UINavigationController)?.topViewController is DetailViewController
    }
}
