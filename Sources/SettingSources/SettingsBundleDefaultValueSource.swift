//
//  Created by Derek Clarkson on 26/8/21.
//

import Combine
import UIKit

public enum SettingsBundleError: LocalizedError {
    case plistNotFound(String)
    case invalidPlist(String)
    case castFailure(String)
    
    public var errorDescription: String? {
        switch self {
        case .plistNotFound(let name):
            return "Plist not found \(name)"
        case .invalidPlist(let name):
            return "The content of \(name) isn't a valid plist definition."
        case .castFailure(let message):
            return "Cast failure \(message)"
        }

    }
}

public class SettingsBundleDefaultValueSource: DefaultValueSource {

    private let parentBundle: Bundle
    private let settingsBundleName: String
    private let rootPlistFileName: String

    public init(parentBundle: Bundle = Bundle.main,
                settingsBundleName: String = "Settings",
                rootPlistFileName: String = "Root") {
        self.parentBundle = parentBundle
        self.settingsBundleName = settingsBundleName
        self.rootPlistFileName = rootPlistFileName
    }

    override public func readDefaults(_ defaults: Defaultable) {

        guard let settingsBundleURL = parentBundle.url(forResource: settingsBundleName, withExtension: "bundle"),
              let settingsBundle = Bundle(url: settingsBundleURL) else {
            defaults.complete()
            return
        }

        do {
            try readDefaults(fromPlist: rootPlistFileName, inBundle: settingsBundle, defaults: defaults)
            defaults.complete()
        } catch {
            log.debug("🧩 SettingsBundleDefaultsSource: Error: \(error.localizedDescription)")
            defaults.fail(withError: error)
        }
    }

    private func readDefaults(fromPlist plistName: String, inBundle bundle: Bundle, defaults: Defaultable) throws {

        log.debug("🧩 SettingsBundleDefaultsSource: Reading \(plistName).plist")
        let plist = try contentsOf(preferencesPlist: plistName, inBundle: bundle, defaults: defaults)["PreferenceSpecifiers"] as? [[String: Any]]

        // Process the plist data.
        try plist?.forEach { preference in

            // Recurse for child panes.
            if preference["Type"] as? String == "PSChildPaneSpecifier", let file = preference["File"] as? String {
                try readDefaults(fromPlist: file, inBundle: bundle, defaults: defaults)
                return
            }

            try readDefaultValue(from: preference, in: plistName, defaults: defaults)
        }
    }

    private func contentsOf(preferencesPlist plistName: String, inBundle bundle: Bundle, defaults _: Defaultable) throws -> [String: Any] {

        guard let plistUrl = bundle.url(forResource: plistName, withExtension: "plist") else {
            throw SettingsBundleError.plistNotFound(plistName + ".plist")
        }

        // Fail if we cannot read it.
        let data = try Data(contentsOf: plistUrl)
        guard let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            throw SettingsBundleError.invalidPlist(plistName + ".plist")
        }
        return plist
    }

    private func readDefaultValue(from preference: [String: Any], in plistName: String, defaults: Defaultable) throws {

        guard let type = preference["Type"] as? String,
              let key = preference["Key"] as? String,
              let value = preference["DefaultValue"] else {
            return
        }

        func send<T>(_ value: Any, as _: T.Type) throws {
            guard let value = value as? T else {
                throw SettingsBundleError.castFailure("Cannot cast value for Settings preference '\(key)' in \(plistName).plist to a \(T.self)")
            }
            log.debug("🧩 SettingsBundleDefaultsSource: \(plistName).plist (\(type)) \(key) -> \(String(describing: value))")
            defaults.setDefault(value, forKey: key)
        }

        switch type {

        case "PSToggleSwitchSpecifier":
            try send(value, as: Bool.self)

        case "PSSliderSpecifier":
            try send(value, as: Double.self)

        case "PSMultiValueSpecifier":
            try send(value, as: String.self)

        case "PSRadioGroupSpecifier":
            try send(value, as: String.self)

        case "PSTextFieldSpecifier":
            try send(value, as: String.self)

        default:
            return
        }
    }
}
