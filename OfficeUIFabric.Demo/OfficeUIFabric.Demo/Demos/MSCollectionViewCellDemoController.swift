//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import OfficeUIFabric

// MARK: MSCollectionViewCellDemoController

class MSCollectionViewCellDemoController: DemoController {
    private let sections: [TableViewSampleData.Section] = TableViewSampleData.sections

    private var isInSelectionMode: Bool = false {
        didSet {
            collectionView.allowsMultipleSelection = isInSelectionMode

            for indexPath in collectionView?.indexPathsForVisibleItems ?? [] {
                if !sections[indexPath.section].allowsMultipleSelection {
                    continue
                }

                let cell = collectionView.cellForItem(at: indexPath) as! MSCollectionViewCell
                cell.cellView.setIsInSelectionMode(isInSelectionMode, animated: true)
            }

            collectionView.indexPathsForSelectedItems?.forEach {
                collectionView.deselectItem(at: $0, animated: false)
            }

            updateNavigationTitle()
            navigationItem.rightBarButtonItem?.title = isInSelectionMode ? "Done" : "Select"
        }
    }

    private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(MSCollectionViewCell.self, forCellWithReuseIdentifier: MSCollectionViewCell.identifier)
        collectionView.register(CollectionViewSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionViewSectionHeader.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = MSColors.background
        view.addSubview(collectionView)

        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChange), name: UIContentSizeCategory.didChangeNotification, object: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(barButtonTapped))
    }

    override func viewWillLayoutSubviews() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            if #available(iOS 12, *) {
                flowLayout.estimatedItemSize = CGSize(width: view.width, height: MSTableViewCell.mediumHeight)
            } else {
                // Higher value of 100 needed for proper layout on iOS 11
                flowLayout.estimatedItemSize = CGSize(width: view.width, height: 100)
            }
            flowLayout.headerReferenceSize = CGSize(width: view.width, height: CollectionViewSectionHeader.height)
        }
        super.viewWillLayoutSubviews()
    }

    @objc private func barButtonTapped(sender: UIBarButtonItem) {
        isInSelectionMode = !isInSelectionMode
    }

    @objc private func handleContentSizeCategoryDidChange() {
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func updateNavigationTitle() {
        if isInSelectionMode {
            let selectedCount = collectionView.indexPathsForSelectedItems?.count ?? 0
            navigationItem.title = selectedCount == 1 ? "1 item selected" : "\(selectedCount) items selected"
        } else {
            navigationItem.title = title
        }
    }
}

// MARK: - MSCollectionViewCellDemoController: UICollectionViewDataSource

extension MSCollectionViewCellDemoController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TableViewSampleData.Section.itemCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        let item = section.item

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MSCollectionViewCell.identifier, for: indexPath) as! MSCollectionViewCell
        cell.cellView.setup(
            title: item.title,
            subtitle: item.subtitle,
            footer: item.footer,
            customView: TableViewSampleData.createCustomView(imageName: item.image),
            customAccessoryView: section.hasAccessoryView ? TableViewSampleData.customAccessoryView : nil,
            accessoryType: TableViewSampleData.accessoryType(for: indexPath)
        )
        cell.cellView.titleNumberOfLines = section.numberOfLines
        cell.cellView.subtitleNumberOfLines = section.numberOfLines
        cell.cellView.footerNumberOfLines = section.numberOfLines
        cell.cellView.isInSelectionMode = section.allowsMultipleSelection ? isInSelectionMode : false
        cell.cellView.onAccessoryTapped = { [unowned self] in self.showAlertForDetailButtonTapped(title: item.title) }
        return cell
    }

    private func showAlertForDetailButtonTapped(title: String) {
        let alert = UIAlertController(title: "\(title) detail button was tapped", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

// MARK: - MSCollectionViewCellDemoController: UICollectionViewDelegate

extension MSCollectionViewCellDemoController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewSectionHeader.identifier, for: indexPath) as! CollectionViewSectionHeader
            header.title = sections[indexPath.section].title
            return header
        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isInSelectionMode {
            updateNavigationTitle()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isInSelectionMode {
            updateNavigationTitle()
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
