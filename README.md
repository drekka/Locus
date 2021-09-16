# Locus

[Quick Guide](#quick-guide)

# Intro

*Locus* is an API you can employ to help wrangle your app's settings. For a small app it's likely overkill, but for a larger app where settings are sourced from a complicated mix of hard coded values, `Settings.bundle` preferences, `UserDefaults` and local or remote configuration files, *Locus* can greatly simplify and stream line accessing them.

*Locus* provides ...

* A consistent and simple to use API for manage and retrieving settings from numerous sources including  `UserDefaults`, `Settings.bundle` preferences, local files, remote files and customised sources unique to your app.
* The ability to enforce which settings can be updated and where those updates are kept.

# Core concepts

## The Container

*Locus* is architected around a central container for managing settings. Generally you don't need to deal with the container apart from initial setup because afterwards *Locus* provides a property wrapper for easy access to settings. 

## Current value vs Default values

Every setting has two values similar to `UserDefaults` where there is a registered and current value. *Locus* provides a similar concept through a *default* and *current* values. However where *Locus* differs from `UserDefaults`  is that it's settings are not optional and therefore will always return a value.

# Quick guide

## Step 1: Register your settings in your app startup

Before a setting can be accessed it must be registered. This is where the setting's initial default value is set, and where various other attributes controlling how it is accessed are defined. In addition registering also allows *Locus* to do things like finding miss-typed setting keys. 

```swift
// Somewhere in your startup. App delegate for example.
SettingsContainer.shared.register {
    readonly(withKey: "server.timeout", default: 30.0)
    readonly(withKey: "server.retries", default: 5)
    userDefault(withKey: "server.url", releaseLocked: true)
}
```



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
(_ Key: SettingKey, storage: Storage = .readonly, releaseLocked: Bool = false, default defaultValue: Any? = nil)
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
