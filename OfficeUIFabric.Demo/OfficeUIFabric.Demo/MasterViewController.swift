//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class MasterViewController: UITableViewController {
    private(set) var demoController: UIViewController?
    var demoControllerClass: UIViewController.Type? {
        didSet {
            if demoControllerClass != oldValue {
                demoController = demoControllerClass?.init()
            }
        }
    }
    var demoPlaceholder: UIViewController?

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        if tableView.indexPathForSelectedRow == nil, let demoContainer = demoController?.navigationController {
            demoContainer.viewControllers = demoPlaceholder != nil ? [demoPlaceholder!] : []
            demoControllerClass = nil
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail", let indexPath = tableView.indexPathForSelectedRow {
            let detailContainer = segue.destination as! UINavigationController

            demoControllerClass = demos[indexPath.row].controllerClass
            if let demoController = demoController {
                demoController.title = demos[indexPath.row].title
                demoController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                demoController.navigationItem.leftItemsSupplementBackButton = true

                detailContainer.viewControllers = [demoController]
            }
        }
    }

    // MARK: Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = demos[indexPath.row].title
        return cell
    }
}
