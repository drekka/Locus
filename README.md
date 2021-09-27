# Intro

[![.github/workflows/swift.yml](https://github.com/drekka/Locus/actions/workflows/swift.yml/badge.svg?branch=master)](https://github.com/drekka/Locus/actions/workflows/swift.yml)

*Locus* is an API that can help you wrangle your app's settings. Whether hard coded values, `Settings.bundle` preferences, `UserDefaults` and local or remote configuration files, *Locus* can help you mange them by providing a simple API that lets you get on with the business at hand.

*Locus* provides ...

* A consistently simple API for retrieving settings regardless of where they came from.
* Multiple classes for sourcing values from  `UserDefaults`, `Settings.bundle` preferences, local files, remote files and other sources unique to your app.
* The ability to enforce rules about where and when settings can be updated.
* Built in linting of setting keys to help avoid typos.

# Core concepts

## The Container

*Locus* is architected around a central container for managing settings. Generally you don't need to deal with the container apart from initial setup because from there on *Locus* provides a property wrapper for easy access to settings. 

## Current value vs Default values

Every setting has two values. Similar to `UserDefaults` where there is a registered value and current value, *Locus* provides *default values* and *current values*. *Default values* are those initially setup, then overlaid with values from various sources as they are read. *Current values* are any settings which can be updated, either externally or internally. Application preferences accessed through `UserDefaults` are a good example of those.

*Note: *Locus* differs from `UserDefaults`  in that settings always have a value and it's API does not return optionals.*

## Setting keys

Every setting in *Locus* has a **key**. This is facilitate matching settings from various sources and to also allow for typos. These keys are passed to every function that works with settings and can be either a `String` or an implementation of `RawRepresentable` where the `RawValue` type is `String`. In other words, a string enum. It doesn't matter which, *Locus* will know what to do.

# Quick guide

## Step 1: Register your settings in your app startup

Before a setting can be accessed it must be registered. This is where the setting's initial default value is set, and where various other attributes controlling how it is accessed are defined. Registering also allows *Locus* to find miss-typed setting keys which it highlights to the developer by triggering a `fatalError(...)` the moment it notices a typo. 

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

As you can see the API can take setting keys as either `String` values or `RawRepresentable` string values. You'll also notice that the example `server.url` setting does not have a default value. That's because settings which have defaults loaded from `Setting.bundle` preferences don't need to specify a default when registering.

## Step 2: Add loaders to gather default values

After registering your settings you need to update the default values from various sources you may have such as `Settings.bundle` files, remote configuration files, etc. This is done through passing one or more implementations of `DefaultValueSource` to the container's `.read(...)` function like this:

```swift
SettingsContainer.shared.read(sources: SettingsBundleDefaultValueSource()) { error in
    // Check error here.
    }
```

## Step 3: Add `@Setting` property wrappers to your properties

Finally you need to access the values of your settings in the rest of your app. You can retrieve values directly from the container, but the simplest methods is to use the supplied property wrapper:

```swift
class SomeClass {

    @Setting(SettingKey.serverTimeout)
    var timeout: Double

    @Setting(SettingKey.serverUrl)
    var serverUrl: URL

    // ...
}
```

# The details

## Registering settings

Settings are registered by calling the container's `.register(...)` function. It's defined as a Swift 5 [result builder](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630) so registering settings is pretty easy:

```swift
SettingsContainer.shared.register {
    SettingConfiguration(SettingKey.serverUrl, default: "http://localhost")
    SettingConfiguration("server.delay", storage: .userDefaults, default: 1.0)
    transient("server.maxRetries", default: 5, releaseLocked: true)
    userDefault("pageSize", default: 20)
}
``` 

### `SettingConfiguration`

All registrations are ultimately done with instances of `SettingConfiguration`. If you want to create them explicitly there are two default initialisers to choose from:

```swift
init(_ key: String,
     storage: Storage = .readonly,
     releaseLocked: Bool = false,
     default defaultValue: Any? = nil)

init<K>(_ key: K,
        storage: Storage = .readonly,
        releaseLocked: Bool = false,
        default defaultValue: Any? = nil) where K: RawRepresentable, K.RawValue == String
```

Where:

* **`key`** - Is the setting's unique key. It can be either a `String` or a string `RawRepresentable` such as a string enum. 
* **`storage`** - Where updated values are stored, one of:
    * **`.readonly`** - The setting cannot be updated. This is the default. 
    * **`.transient`** - The setting can be updated, but the updated values are not preserved when the app is killed. 
    * **`.userDefaults`** - The setting can be updated and the updated value will be stored in `UserDefaults`.
* **`releasedLocked`** - If true, indicates that the setting can be updated in Debug builds, but is read only in Release builds. 
* **`default`** - The default value for the settings. 

### Convenience functions

In addition to creating `SettingConfiguration` instances, *Locus* also offers a range of convenience functions:

```swift
func readonly(_ key: String, default: Any? = nil) -> SettingConfiguration
func readonly<K>(_ key: K, default: Any? = nil) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String
```

Produce readonly configurations where a setting can only be read but never updated. 

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


## Loading default values

As mentioned above, once your settings are registered you can then run a variety of **`DefaultValueSource`** instances to set their default values. A source can be anything - preferences in a `Settings.bundle`, local files, remote files, or anything else you can think of. Because sources such as remotely stored files are inherently asynchronous to access, all the sources are executed in a separate background thread managed by Swift 5.5's `async`/`await` feature. Executing a number of sources will look something like this:

```swift
let settingsBundleSource = SettingsBundleDefaultValueSource()

let fileUrl = URL(string: "https://appserver.com/configuration/config.json") 
Let headers = [
              "Content-Type": "json",
              "auth": "security-token" 
              ]
let remoteConfig = JSONDefaultValueSource(url: url,
                                          headers: headers) { json in
    if let json = json as [String: Any?] {
        If let url = json["server-url"] {
            return [
	            "serverUrl": url
            ]
        }
    } 
}

SettingsContainer.shared.read(sources: settingsBundleSource, remoteConfig) { error in
    // Check error and respond as necessary.
}
```

*Note: Locus executes each source one after the other on a background thread. This serves two purposes, one is to allow this to be done during your app's startup without imposing an unnecessary delay, and the second is to ensure that the sources update your settings in the order you specify. So for example, you can define defaults in a setting bundle preferences file, and then have them updated by a remotely stored configuration file.**

### `SettingsBundleDefaultValueSource`

Probably the most commonly used source. **`SettingsBundleDefaultValueSource`** is pre-programmed to scan the `Settings.bundle` file in your app and read any preferences it finds, Using it looks like this:

```swift
SettingsContainer.shared.read(sources: SettingsBundleDefaultValueSource()) { error in
    // Check error here.
}
```

It's coded to look for preferences in the `Root.plist` file and drill down into child panes if there are any. 

In addition, running this source means you don't have to pass the `default:` arguments when registering because the default values will be read and set in the `UserDefaults` **registration** domain. Providing you either specify `storage: .userDefaults` or use the `userDefaults(...)` convenience function when registering those settings.

#### `URLDefaultValueSource`

`URLDefaultValueSource` is a semi-complete source designed to access files on a remote server or on the local file system. Basically if you can refer to a file via a `URL` you can access it with this source. It reads the default values through the `url` argument and passes them to the `mapper` argument. You will need to supply this as only you know the layout of the data being read:

```swift
let fileUrl = URL(string: "https://appserver.com/configuration/config.yaml") 
Let headers = [
              "Content-Type": "yaml",
              "auth": "security-token" 
              ]
let remoteConfig = URLDefaultValueSource(url: url,
                                         headers: headers) { data in
    let yaml = ... // Convert data to a dictionary here
    var defaults: [String: Any] = [:] 
    if url = yaml["server-url"] {
        defaults[SettingKey.serverUrl] = url
    } 
    return defaults
}
```

* **`url`** - A url that refers to the file to be read. Can be a local file, a file within a bundle, a remote file or any other form of valid URL.
* **`headers`** - An optional dictionary of HTTP headers to add to the request.
* **`mapper`** - A closure that will be used to read the returned `Data` and set the new default values. It's passed data read from the url and expected to return a `[String: Any]` dictionary or throw an error. 

#### `JSONDefaultValueSource`

`JSONDefaultValueSource` is an extension of `URLDefaultValueSource` that really only has one change, and that is that it assumes the data coming back from the URL will be valid JSON and will serialise that data into a valid JSON object before calling the mapper.

```swift
let fileUrl = URL(string: "https://appserver.com/configuration/config.json") 
Let headers = [
              "Content-Type": "json",
              "auth": "security-token" 
              ]
let remoteConfig = JSONDefaultValueSource(url: url,
                                          headers: headers) { json in
    var defaults: [String: Any] = [:] 
    if let json = json as [String: Any?] {
        if let url = json["server-url"] {
            defaults[SettingKey.serverUrl] = url
        }
    }
    return defaults
}
```

#### Rolling your own

If you have a source of default values that doesn't match one of the pre-built class you can just roll your own. All you have to do is implement `DefaultValueSource`. The source for `URLDefaultValueSource` is a good example of doing this.

## The `@Setting` property wrapper

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

### Settings via the container

`@Setting(...)` property wrappers access settings by talking directly to the container and you can do this as well if you want to access a setting in a situation where the property wrapper is not suitable. Here's some examples:

```swift
let timeout: Double = SettingsContainer.shared[SettingKey.serverTimeout]
let serverUrl = SettingsContainer.shared["server.url"] as URL
```

# Combine

*Locus* is [Swift Combine](https://developer.apple.com/documentation/combine) friend with a publisher being made available through the `defaultValueUpdates`. So if you want to receive updates via a combine you can use it like this:

```swift
let cancellable = SettingsContainer.shared.defaultValueUpdates
                      .filter { $0.key == "key_im_interested_in" }
                      .sink { update in
                      // do something with the (key: String, value: Any) tuple receieved.
}
```  
