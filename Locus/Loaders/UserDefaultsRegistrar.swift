//
//  UserDefaultsRegistrar.swift
//  Locus
//
//  Created by Derek Clarkson on 13/6/20.
//  Copyright © 2020 Derek Clarkson. All rights reserved.
//

import UIKit

typealias PlistPreference = (file: String, key: String, value: Any)

struct UserDefaultsRegistrar {

    func register(bundle: Bundle = Bundle.main,
                  settingsBundleName: String = "Settings",
                  rootPlistName: String = "Root",
                  using: (PlistPreference) -> PlistPreference? = { $0 }) {

        guard let settingsUrl = bundle.url(forResource: settingsBundleName, withExtension: "bundle"),
            let settings = Bundle(url: settingsUrl) else {
                return
        }

        locusLog("Registering preferences from %@.plist in %@.bundle...", rootPlistName, settingsBundleName)
        let preferences = defaults(plist: rootPlistName, inBundle: settings, using: using)
        locusLog("Found preferences:")
        preferences.sorted { $0.key < $1.key }.forEach { locusLog("    • %@.plist, %@: %@", $0.file, $0.key, String(describing: $0.value)) }
        UserDefaults.standard.register(defaults: [String: Any](uniqueKeysWithValues: preferences.map { ($0.key, $0.value) }))
    }

    private func defaults(plist: String, inBundle bundle: Bundle, using: (PlistPreference) -> PlistPreference?) -> [PlistPreference] {

        guard let plistUrl = bundle.url(forResource: plist, withExtension: "plist"),
            let data = try? Data(contentsOf: plistUrl),
            let pl = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let preferences = pl["PreferenceSpecifiers"] as? [[String: Any]] else {
            return []
        }

        return preferences.reduce(into: [PlistPreference]()) { result, preference in

            // Recurse into child panes.
            if preference["Type"] as? String == "PSChildPaneSpecifier", let file = preference["File"] as? String {
                locusLog("Found child pane %@ with preferences", file)
                result.append(contentsOf: defaults(plist: file, inBundle: bundle, using: using))
                return
            }

            // Add the default if present.
            if let key = preference["Key"] as? String,
                let defaultValue = preference["DefaultValue"],
                let finalPreference = using((file: plist, key: key, value: defaultValue)) {

                // Check for duplicates
                if let duplicate = result.first(where: { $0.key == finalPreference.key }) {
                    locusFatalError("Found duplicate key '" + finalPreference.key + "' in plists " + plist + ".plist and " + duplicate.file + ".plist")
                }

                result.append(finalPreference)
            }
        }
    }
}
