//
//  Created by Derek Clarkson on 26/8/21.
//

import Combine
import UIKit

public class SettingsBundleDefaultValueSource: BaseDefaultValueSource {

    private let parentBundle: Bundle
    private let settingBundleName: String
    private let rootPlistFileName: String
    
    public init(parentBundle: Bundle = Bundle.main,
                settingBundleName: String = "Settings",
                rootPlistFileName: String = "Root") {
        self.parentBundle = parentBundle
        self.settingBundleName = settingBundleName
        self.rootPlistFileName = rootPlistFileName
    }

    public override func read() {
        if let settingsBundleURL = parentBundle.url(forResource: settingBundleName, withExtension: "bundle"),
           let settingsBundle = Bundle(url: settingsBundleURL) {
            read(from: rootPlistFileName, inBundle: settingsBundle)
        }
        defaultValuePublisher.send(completion: .finished)
    }

    private func read(from plistName: String, inBundle bundle: Bundle) {

        guard let plistUrl = bundle.url(forResource: plistName, withExtension: "plist"),
              let data = try? Data(contentsOf: plistUrl),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            return
        }

        // Process the plist data.
        log.debug("🧩 SettingsBundleDefaultsSource: Reading \(plistName).plist")
        (plist["PreferenceSpecifiers"] as? [[String: Any]])?.forEach { preference in

            // Loop back for child panes.
            if preference["Type"] as? String == "PSChildPaneSpecifier", let file = preference["File"] as? String {
                read(from: file, inBundle: bundle)
                return
            }

            // Process the preference.
            loadDefaultValue(from: preference, in: plistName)
        }
    }

    private func loadDefaultValue(from preference: [String: Any], in plistName: String) {

        guard let type = preference["Type"] as? String,
              let key = preference["Key"] as? String,
              let value = preference["DefaultValue"] else {
            return
        }


        func send<T>(_ value: Any, as _: T.Type) {
            guard let value = value as? T else {
                fatalError("💥💥💥 Cannot cast value for Settings preference '\(key)' in \(plistName).plist to a \(T.self) 💥💥💥")
            }
            log.debug("🧩 SettingsBundleDefaultsSource: \(plistName).plist (\(type)) \(key) -> \(String(describing: value))")
            defaultValuePublisher.send((key, value))
        }

        switch type {

        case "PSToggleSwitchSpecifier":
            send(value, as: Bool.self)

        case "PSSliderSpecifier":
            send(value, as: Double.self)

        case "PSMultiValueSpecifier":
            send(value, as: String.self)

        case "PSRadioGroupSpecifier":
            send(value, as: String.self)

        case "PSTextFieldSpecifier":
            send(value, as: String.self)

        default:
            return
        }
    }
}
