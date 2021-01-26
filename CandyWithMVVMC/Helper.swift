//
//  Helper.swift
//  HelloCoordinator
//
//  Created by William on 2018/12/25.
//  Copyright © 2018 William. All rights reserved.
//

import UIKit


extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)
        
        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".")[1]
        
        // load our storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // instantiate a view controller with that identifier, and force cast as the type that was requested
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}

//extension String {
//    func isEmptyOrWhitespace() -> Bool {
//
//        // Check empty string
//        if self.isEmpty {
//            return true
//        }
//        // Trim and check empty string
//        return (self.trimmingCharacters(in: .whitespacesAndNewlines) == "")
//    }
//}

extension Optional where Wrapped == String {
    func isEmptyOrWhitespace() -> Bool {
        // Check nil
        guard let this = self else { return true }
        
        // Check empty string
        if this.isEmpty {
            return true
        }
        // Trim and check empty string
        return (this.trimmingCharacters(in: .whitespacesAndNewlines) == "")
    }
}

@available(iOS 13.0, tvOS 13.0, *)
open class GenericDiffableDataSource<SectionIdentifierType, ItemIdentifierType>: UITableViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>
    where SectionIdentifierType : Hashable, ItemIdentifierType : Hashable {
    
    public typealias SectionTitleProvider = (UITableView, SectionIdentifierType) -> String?
    
    open var sectionTitleProvider: SectionTitleProvider?
    open var useSectionIndex: Bool = false
    
    open override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard useSectionIndex, let sectionTitleProvider = sectionTitleProvider else { return nil }
        return snapshot().sectionIdentifiers.compactMap { sectionTitleProvider(tableView, $0) }
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = "\(self.snapshot().sectionIdentifiers[section])"
        return title
    }

    open override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard useSectionIndex else { return 0 }
        return snapshot().sectionIdentifiers.firstIndex(where: { sectionTitleProvider?(tableView, $0) == title }) ?? 0
    }
}
