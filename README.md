# Intro

*Locus* is an API you can employ to help wrangle your app's settings. For a small app it's likely overkill, but for a larger app where settings are sourced from a complicated mix of hard coded values, `Settings.bundle` preferences, `UserDefaults` and local or remote configuration files, *Locus* can greatly simplify and stream line accessing them.

*Locus* provides ...

* A consistent and simple to use API for manage and retrieving settings from numerous sources including  `UserDefaults`, `Settings.bundle` preferences, local files, remote files and customised sources unique to your app.
* The ability to enforce which settings can be updated and where those updates are kept.
* A way to ensure you can detect missing or miss-typed setting keys.

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
enum SettingKey: String {
    case serverTimeout = "server.timeout"
    case serverUrl = "server.url"
}

SettingsContainer.shared.register {
    readonly(SettingKey.serverTimeout, default: 30.0)
    readonly("server.retries", default: 5)
    userDefault(SettingKey.serverUrl, releaseLocked: true)
}
```

As you can see the API can take setting keys as either `String` values or `RawRepresentable` string values. You'll also notice that the `server.url` setting does not have a efault value. That's because it's getting values from `UserDefaults` and will source it's default from a preference in the app's `Setting.bundle` file.  

## Step 2: Add loaders to gather default values

After registering your settings you need to update the default values from various sources you may have. These can be `Settings.bundle` files, remote configuration files, etc.  

```swift
SettingsContainer.shared.read(sources: SettingsBundleDefaultValueSource()) { error in
    // Check error here.
    }
```

## Step 3: Add the `@Setting` property wrappers to your properties

Finally you need to add code to retrieve the values where er your app needs them. You can retrieve values directly from the container, but the simplest methods is to use the supplied property wrapper.

```swift
class SomeClass {

    @Setting(SettingKey.serverTimeout)
    var timeout: Double

    @Setting(SettingKey.serverUrl)
    var serverUrl: URL

    // ...
}
```

# Setting keys

With all the functions for accessing settings, *Locus* expects the setting's key as the main argument. This key can be either a `String` or a `RawRepresentable` where the `RawValue` type is `String`. In other words, a string enum.

# Registering settings

Settings are registered with the container by calling the `.register(...)` function. It's defined as a Swift 5 [result builder](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630) so registering settings is pretty easy. Here's a sample showing a variety of styles:

```swift
SettingsContainer.shared.register {
    SettingConfiguration(SettingKey.serverUrl, default: "http://localhost")
    SettingConfiguration("server.delay", storage: .userDefaults, default: 1.0)
    transient("server.maxRetries", default: 5, releaseLocked: true)
    userDefault("pageSize", default: 20)
}
``` 

## `SettingConfiguration`

All registrations are ultimately done with instances of `SettingConfiguration`. If you want to create them explicitly the default initialiser looks like this:

```swift
public convenience init<K>(_ key: K,
                           storage: Storage = .readonly,
                           releaseLocked: Bool = false,
                           default defaultValue: Any? = nil) where K: RawRepresentable, K.RawValue == String
```

Arguments:

* **`key`** - The settings unique key. This is used to identify it and also when dealing with settings sourced from `UserDefaults`. It can be either a `String` or a string `RawRepresentable` such as a string enum. 
* **`storage`** - One of:
    * **`.readonly`** - The setting cannot be updated. This is the default. 
    * **`.transient`** - The setting can be updated, but the updated values are not preserved when the app is killed. 
    * **`.userDefaults`** - The setting can be updated and the updated value will be stored in `UserDefaults`.
* **`releasedLocked`** - If true, indicates that the setting can be updated in Debug builds, but is read only in Release builds. 
* **`default`** - The default value for the settings. 

## Convenience functions

In addition to directky creating `SettingConfiguration` instances, *Locus* offers a range of convenience functions to help:

```swift
func readonly(_ key: String, default: Any? = nil) -> SettingConfiguration
func readonly<K>(_ key: K, default: Any? = nil) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String
```

Produce readonly configurations where a setting can only be read but never updated. The exception being `DefaultValueSource` instances passed to the container's `.read(...)` function which update the default value for a setting.

```swift
func transient(_ key: String, releaseLocked: Bool = false, default: Any? = nil) -> SettingConfiguration
func transient<K>(_ key: K, releaseLocked: Bool = false, default: Any? = nil) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String
```

Produce transient configurations. Ie. for a setting that can be updated, but where the updated value is not permanently stored. 

```swift
func userDefault(_ key: String, releaseLocked: Bool = false, default: Any? = nil) -> SettingConfiguration
func userDefault<K>(_ key: K, releaseLocked: Bool = false, default: Any? = nil) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String
```

Produce user defaults configurations. That is settings that can be updated and will store changes in `UserDefaults`. Note that all settings can read values from user defaults, but this is the only one that can write to them.

# The `@Setting` property wrapper

This property wrapper is the simplest way to connect your code to the settings container. It looks like this:

```swift
class SomeClass {

    @Setting(SettingKey.serverTimeout)
    var timeout: Double

    @Setting(SettingKey.serverUrl)
    var serverUrl: URL

    // ...
}
```

Apart from specifying the key of the setting you want to connect to there's really nothing more to it.

## Settings via the container

`@Setting(...)` property wrappers access settings by talking directly to the container and you can do this as well if you want to access a setting in a situation where the property wrapper is not suitable. Here's some examples:

```swift
let timeout: Double = SettingsContainer.shared[SettingKey.serverTimeout]
let serverUrl = SettingsContainer.shared["server.url"] as URL
```

# Default value sources

Default value sources are classes that can be used to update the default values of settings. A source can be anything, but sources such as default values in `Settings.bundle` files and remotely stored configuration are probably the most  common. Especially if you app is one that communicates with servers. Because reading sources such as remote files is inherently an asynchronous thing, default value sources as designed so they can be run on background threads, sourcing values and updating the container as they come back. 

To read these sources you need to create one or more instances of `DefaultValueSource` and pass them to the `SettingContainer.shared.read(sources:...)` function. 

### `SettingsBundleDefaultValueSource`

*Locus* come with one source ready to use out of the box. **`SettingsBundleDefaultValueSource`** is pre-programmed to read the `Settings.bundle` file in your app and process any preferences it finds in it, reading their default values and registering them in the `UserDefaults` **registration** domain. Using it looks like this:

```swift
SettingsContainer.shared.read(sources: SettingsBundleDefaultValueSource()) { error in
    // Check error here.
    }
```

It's coded to look for preferences in the `Root.plist` file and drill down into child panes it finds as well. 

In addition, running this source means you don't have to pass the `default:` argument when registering settings that have matching preferences because their defaults will be read by this source and set into the `UserDefaults` registration domain which all settings can access.

## Custom value sources

In addition to `SettingsBundleDefaultValueSource` *Locus* also provides two other pre-built default value sources. However they do need some additional code which will be unique to your app.

### `URLDefaultValueSource`

`URLDefaultValueSource` is written to read default values from a file referenced through a `URL`. It could be local or remote and you use this source like this:

```swift
let fileUrl = URL(string: "https://appserver.com/configuration/config.yaml") 
Let headers = [
              "Content-Type": "yaml",
              "auth": "security-token" 
              ]
let remoteConfig = URLDefaultValueSource(url: url,
                                         headers: headers) { data, container in
    let yaml = ... // Convert data to a dictionary here
    container.setDefault(yaml["server-url"], forKey: SettingKey.serverUrl)
    container.complete()
}

SettingsContainer.shared.read(sources: SettingsBundleDefaultValueSource(),
                                       remoteConfig) { error in
    // Check error here.
}
```

Arguments:

* **`url`** - A url referring to the file to be read. Can be a local file, a file within a bundle, a remote file or any other form of URL that will return a file.
* **`headers`** - An optional dictionary of HTTP headers to add to the request.
* **`mapper`** - A closure that will be used to read the returned `Data` and set the new default values. It's passed two arguments: **`data`** which is the `Data` read from the url, and `container` which is a reference to an instance of **`Defaultable`**. 

`Defaultable` provides a simple interface for updating the container:

```swift
/// Updates the default value for a setting.
func setDefault<T, K>(_ value: T, forKey key: K) where K: RawRepresentable, K.RawValue == String

/// Updates the default value for a setting.
func setDefault<T>(_ value: T, forKey key: String)

/// Tells Locus that the default value source has finished reading values.
func complete()

/// Tells Locus that the default value source has encountered an error.
func fail(withError error: Error)
```

*Note: It's important that you call either `complete()` or `fail(withError:)` after processing the data. The reason for this is that Locus processes default value sources in order and needs to know when each one is finished so it can start the next one. Doing this allows (for example) a remote file configuration to reliably override local preferences.**

## `JSONDefaultValueSource`

`JSONDefaultValueSource` is an extension of `URLDefaultValueSource` that does some additional processing on the assumption that the data returned from the url will be JSON. It's basically the same as `URLDefaultValueSource` except that the data is already decoded from `Data` to a valid JSON data structure using `JSONSerialization.dataObject(with:)`, returning a dictionary or array in the `json` value.

```swift
let fileUrl = URL(string: "https://appserver.com/configuration/config.json") 
Let headers = [
              "Content-Type": "json",
              "auth": "security-token" 
              ]
let remoteConfig = JSONDefaultValueSource(url: url,
                                          headers: headers) { json, container in
    if let json = json as [String: Any?] {
        container.setDefault(json["server-url"], forKey: SettingKey.serverUrl)
    } 
    container.complete()
}

SettingsContainer.shared.read(sources: SettingsBundleDefaultValueSource(),
                                       remoteConfig) { error in
    // Check error here.
}
```

## Rolling your own

If you have a source of default values that doesn't match one of the pre-built class you can just roll your own. All you have to do is extend the `DefaultValueSource` class and override the `readDefaults(_ container: Defaultable)` function. The source for `URLDefaultValueSource` is a good example of doing this.

