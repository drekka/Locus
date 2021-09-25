//
//  Created by Derek Clarkson on 26/8/21.
//

import UIKit
import UsefulThings

public enum SettingsBundleError: LocalizedError {

    case plistNotFound(String)
    case invalidPlist(String)
    case castFailure(String)
    case duplicateKey(String)

    public var errorDescription: String? {
        switch self {
        case .plistNotFound(let name):
            return "Plist not found \(name)"
        case .invalidPlist(let name):
            return "The content of \(name) isn't a valid plist definition."
        case .castFailure(let message):
            return "Cast failure \(message)"
        case .duplicateKey(let name):
            return "Key '\(name)' exists in more than one set of preferences."
        }
    }
}

public class SettingsBundleDefaultValueSource: DefaultValueSource {

    private let parentBundle: Bundle
    private let settingsBundleName: String
    private let rootPlistFileName: String

    typealias AnyPreference = (key: String, defaultValue: Any)
    typealias Preference<T> = (key: String, defaultValue: T)

    public init(parentBundle: Bundle = Bundle.main,
                settingsBundleName: String = "Settings",
                rootPlistFileName: String = "Root") {
        self.parentBundle = parentBundle
        self.settingsBundleName = settingsBundleName
        self.rootPlistFileName = rootPlistFileName
    }

    public func readDefaults() async throws -> [String: Any] {

        guard let settingsBundleURL = parentBundle.url(forResource: settingsBundleName, withExtension: "bundle"),
              let settingsBundle = Bundle(url: settingsBundleURL) else {
            return [:]
        }

        // Reduce the preferences into a dictionary.
        return try readDefaults(fromPlist: rootPlistFileName, inBundle: settingsBundle).reduce([:]) { results, nextDefault in
            return try results.merging([nextDefault.key: nextDefault.defaultValue]) { _, _ in throw SettingsBundleError.duplicateKey(nextDefault.key) }
        }
    }

    private func readDefaults(fromPlist plistName: String, inBundle bundle: Bundle) throws -> [AnyPreference] {

        log.debug("🧩 SettingsBundleDefaultsSource: Reading \(plistName).plist")
        guard let preferences = try contentsOf(preferencesPlist: plistName, inBundle: bundle)["PreferenceSpecifiers"] as? [[String: Any]] else {
            return []
        }

        return try preferences.flatMap { preferenceData -> [AnyPreference] in

            // Recurse into child panes.
            if preferenceData["Type"] as? String == "PSChildPaneSpecifier", let file = preferenceData["File"] as? String {
                return try readDefaults(fromPlist: file, inBundle: bundle)
            }

            guard let preference = try readDefaultValue(from: preferenceData, in: plistName) else {
                return []
            }
            return [preference]
        }
    }

    private func contentsOf(preferencesPlist plistName: String, inBundle bundle: Bundle) throws -> [String: Any] {

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

    private func readDefaultValue(from preference: [String: Any], in plistName: String) throws -> AnyPreference? {

        guard let type = preference["Type"] as? String,
              let key = preference["Key"] as? String,
              let value = preference["DefaultValue"] else {
            return nil
        }

        func preferenceWith<T>(_ value: Any) throws -> Preference<T> {
            guard let value = cast(value) as T? else {
                throw SettingsBundleError.castFailure("Cannot cast value for Settings preference '\(key)' in \(plistName).plist to a \(T.self)")
            }
            log.debug("🧩 SettingsBundleDefaultsSource: \(plistName).plist (\(type)) \(key) -> \(String(describing: value))")
            return (key: key, defaultValue: value)
        }

        switch type {

        case "PSToggleSwitchSpecifier":
            return try preferenceWith(value) as Preference<Bool>

        case "PSSliderSpecifier":
            return try preferenceWith(value) as Preference<Double>

        case "PSMultiValueSpecifier":
            return try preferenceWith(value) as Preference<String>

        case "PSRadioGroupSpecifier":
            return try preferenceWith(value) as Preference<String>

        case "PSTextFieldSpecifier":
            return try preferenceWith(value) as Preference<String>

        default:
            return nil
        }
    }
}
