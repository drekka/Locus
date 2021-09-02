# Locus

[Quick Guide](#quick-guide)

# Intro

An app's settings can come from a variety of sources:

* Hard coded values
* Preferences in a `Settings.bundle/Root.plist` file.
* `UserDefaults`
* Local configuration files
* Remote configuration files

A lot of apps have at least two of these and it's often surprising just how much code it can take to manage them. Especially when dealing with remote configurations or there's been several developers in the code with competing ideas on how settings should be handled.

Locus is designed to take the pain out of managing settings. It ...

* Provides a consistent and simple API for manage and retrieving settings regardless of where they come from.
* Automatically manage `UserDefaults` and the registration of default values listed in your app's `Settings.bundle/Root.plist` file, plus any child panes it references.
* Manage the ability of your app to update a setting and where those updated values are stored.
* Reads remote and local configuration files to source default values and notifies your app when they've been updated.
* Observe changes in `UserDefaults`.

# Core concepts

## The Container

*Locus* is architected around a central container. Generally you don't need to deal with the container apart from initial setup. Afterwards a provided property wrapper takes over to handle things. However you can also use the container directly if you wish. 

## Current value vs Default values

An important point to remember is that every setting has two values. Similar to the way `UserDefaults` manages values, *Locus* has a *default* and *current* value. Where *Locus* differs from `UserDefaults`  is that it regards settings as non-optional and therefore always guarantees a value for every setting. When it needs a value to return, if checks to for a current value set by the app, and if that's `nil` returns the default value.

# Quick guide

## Step 1: Register your settings in your app startup

```swift
// Somewhere in your startup. App delegate for example.
SettingsContainer.shared.register {
    readonly(withKey: "server.timeout", default: 30.0)
    userDefault(withKey: "server.url")
}
```

Settings must be registered so *Locus* can provide default values, lint for miss-typed or  missing keys, and also controlling whether settings can be updated or not.

## Step 2: Add loaders to gather default values

```swift
SettingsContainer.shared.read(sources: SettingsBundleDefaultValueSource())
```

Here's were you let *Locus* know where it can obtain default values. Settings bundles, remote files, that sort of thing.

## Step 3: Add the `@Setting` property wrappers to your properties

```swift
class SomeClass {

    @Setting("server.timeout")
    var timeout: Double

    @Setting("server.url")
    var serverUrl: URL

    // ...

}
```

Finally you add `@Setting(...)` property wrappers wherever you need to access a value. 

# Registering settings

Settings are registered with the container by calling the `.register(...)` function and passing it one or more  `SettingConfiguration` items. You can create them manually or use the `setting(...)` global function *Locus* also provides. `.register(...)` is defined as a Swift 5 [result builder](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630) and combining all of these features:

```swift
SettingsContainer.shared.register {
    SettingConfiguration("server.url", default: "http://localhost")
    SettingConfiguration("server.delay", storage: .userDefaults, default: 1.0)
    setting("server.maxRetries", default: 5)
    userDefault("pageSize", default: 20)
}
``` 

The argument signature for `SettingConfiguration(...)` and `setting(...)` is:

```swift
(_ key: String, storage: Storage = .readonly, releaseLocked: Bool = false, default defaultValue: Any? = nil)
```

Where:

* **`key`** - The settings unique key. This is used to identify it and also as the key for settings which are sourced from `UserDefaults`. 
* **`storage`** - One of:
    * **`readonly`** - The setting cannot be updated. 
    * **`transient`** - The setting can be updated, but the new value will be forgotten when the app is restarted. 
    * **`userDefaults`** - The setting can be updated and the new value will be stored in `UserDefaults`.
* **`releasedLocked`** - Indicates that the setting can be updated in Debug builds, but is read only in Release builds. 
* **`default`** - The default value for the settings. 


# Accessing settings

There are two ways to access your settings.

# The `@Setting` property wrapper

The property wrapper is the simplest way to connect your code with managed settings. It takes the following arguments:

* **``** - 
* **``** - 
* **``** - 
* **``** - 
