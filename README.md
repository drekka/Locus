# Intro

[![.github/workflows/swift.yml](https://github.com/drekka/Locus/actions/workflows/swift.yml/badge.svg?branch=master)](https://github.com/drekka/Locus/actions/workflows/swift.yml)

*Locus* is a an API designed to address a common problem encountered in many apps. How to manage the app's settings and coordinate between hard coded values, `Settings.bundle` preferences, `UserDefaults` and local or remote configuration files. A problem often made worse on enterprise apps where developers coming and going often implement a number of inconsistent implementations that can sometimes be quite Byzantine to understand. 

*Locus* is designed to address these issues by providing ...

* A consistent and simple API for retrieving and updating settings regardless of their source.
* Detection of miss-typed setting keys and updates to settings which should not occur. 
* A set of base implementations for reading settings from `UserDefaults`, `Settings.bundle` preferences, local files, remote files and other locations that your app may need.
* A Combine publisher for subscribing to updates.
* The ability to use either `String` or enum keys.
* A `@Setting` property wrapper for easy access.

# Core concepts

## The Container

*Locus* uses a central container for managing settings. This container is where you register settings, set default values and update them from external sources such as remote configuration files. You can use this container to access settings, or use the supplied `@Setting` property wrapper.

## Current value vs Default values

Similar to how `UserDefaults` has a registered default for a setting which is overridden by a user set current value, *Locus* has a *default value* and a *current value*. But unlike `UserDefaults` where settings can return optionals, *Locus* guarantees a value for every setting. If there is no *current value* for a setting, *Locus* will return the value set during registration, or the updated default set from an external sources such as the app's `Settings.bundle`, a remote configuration, or some other source.

## Setting keys

Every setting has a **key** to uniquely identify it to the container. A key can be either a `String` or an implementation of `RawRepresentable` where the `RawValue` type is `String`. In other words, a string enum. It doesn't matter which you choose to use, either, or, or both, *Locus* has overrides for every function so that it will know what to do.

# Quick guide

## Step 1: Register your settings in your app startup

The first thing to do is register the settings you need. This is done with the container where you register each setting with it's attributes and initial default value.

```swift
// Somewhere in your startup. App delegate for example.

// Enum based keys if you prefer them.
enum SettingKey: String {
    case serverTimeout = "server.timeout"
    case serverUrl = "server.url"
}

SettingsContainer.shared.register {
    readonly(SettingKey.serverTimeout, default: .userDefaults)
    readonly("server.retries", default: .local(5))
    userDefault(SettingKey.serverUrl)
}
```

As you can see the API can take setting keys as either `String` values or `RawRepresentable` string values. You'll also notice that the example `server.url` setting does not have a default value. That's because settings which have defaults loaded from `Setting.bundle` preferences don't need to specify a default when registering. Lots more on registering settings below.

## Step 2: Add loaders to set default values

After registering settings in the container you *may* want to update their default values using one or more sources such as `Settings.bundle` files, remote configuration files, etc via types that implement `DefaultValueSource` like this:

```swift
let settingsBundle = SettingsBundleDefaultValueSource()
SettingsContainer.shared.read(sources: settingsBundle) { error in
    // Check error here.
}
```

## Step 3: Access your settings

You can retrieve values directly from the container like this:

```swift
let url: URL = SettingsContainer.shared[SettingKey.serverUrl]
```
or... use the provided property wrapper like this:

```swift
class SomeClass {

    @Setting(SettingKey.serverUrl)
    var serverUrl: URL

    // ...
}
```

# The details

## Registering settings

Settings are registered by calling the container's `.register(...)` function. It's defined as a Swift 5 [result builder](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630) so registering settings is pretty easy.

```swift
SettingsContainer.shared.register {
    SettingConfiguration(SettingKey.serverUrl, default: .local("http://localhost"))
    SettingConfiguration("server.delay", persistence: .userDefaults, default: .local(1.0))
    transient("server.maxRetries", releaseLocked: true, default: .local(5))
    userDefault("pageSize")
}
``` 

### `SettingConfiguration`

All registrations are ultimately done with instances of `SettingConfiguration`. If you want to create them explicitly there are two default initialisers to choose from:

```swift
init(_ key: String,
     persistence: Persistence = .none,
     releaseLocked: Bool = false,
     default defaultValue: Default)

init<K>(_ key: K,
        persistence: Persistence = .none,
        releaseLocked: Bool = false,
        default defaultValue: Default) 
        where K: RawRepresentable, K.RawValue == String
```

Where:

* **`key`** - Is the setting's unique key. It's the only difference between the two functions and can be either a `String` or a string `RawRepresentable` such as a string enum. 
* **`persistence`** - If the app can set a *current value* for the setting and that value is stored:
    * **`.none`** - The setting cannot have a *current value* set. This is the default. Note that this does not effect the updating of the setting's *default value*.
    * **`.transient`** - The setting can have a *current value* set, but its transient in that it's only stored in memory and not preserved when the app is killed. 
    * **`.userDefaults`** - The setting can have a *current value* set. That value will be set in `UserDefaults` and thus will be the *current value* if the app is restarted.
* **`releasedLocked`** - If true, indicates that the setting can have a *current value* set in Debug builds, but not in Release builds. 
* **`default`** - This is the default value for the settings that will be returned if not other *default* or *current* value is set. It must be one ofL
  * **`.local(<value>)`** - A value stored in memory whilst the app is running.
  * **`.userDefaults`** - The *default value* is expected to be registered in `UserDefaults`. Possibly by the `SettingBundleDefaultValueSource`.

### Convenience functions

Creating the `SettingConfiguration`s manually is the most expressive form of registration,however *Locus* also offers a range of convenience functions for common types of registrations:

#### readonly(...)

These functions produce settings which cannot be updated by your app.

```swift
func readonly(_ key: String, default: Any? = nil) -> SettingConfiguration
func readonly<K>(_ key: K, default: Any? = nil) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String
```

#### transient(...)

These function produce settings which are transient in nature.

```swift
func transient(_ key: String, releaseLocked: Bool = false, default: Any? = nil) -> SettingConfiguration
func transient<K>(_ key: K, releaseLocked: Bool = false, default: Any? = nil) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String
```

#### userDefaults(...)

These functions produce settings backed by `UserDefaults`.

```swift
func userDefault(_ key: String, releaseLocked: Bool = false, default: Any? = nil) -> SettingConfiguration
func userDefault<K>(_ key: K, releaseLocked: Bool = false, default: Any? = nil) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String
```

## Loading default values

As mentioned above, once your settings are registered you can then run a variety of **`DefaultValueSource`** instances to set their default values. A source can be anything - preferences in a `Settings.bundle`, locally stored files, remotely stored files, or anything else you can think of. Because sources such as remotely stored files are inherently asynchronous to access, all the sources are executed in a separate background thread. 

For example, loading default values from a `Settings.bundle` and then a remote file might look something like this:

```swift
let settingsBundleSource = SettingsBundleDefaultValueSource()

let fileUrl = URL(string: "https://appserver.com/configuration/config.json") 
let remoteConfig = JSONDefaultValueSource(url: url) { json in
    if let json = json as [String: Any?] {
        return ["serverUrl": url]
    } 
    return [:]
}

SettingsContainer.shared.read(sources: settingsBundleSource, remoteConfig) { error in
    // Check error and respond as necessary.
}
```

*Note: Locus executes each source sequentially on a background thread. This is a deliberate choice to ensure that the sources get to update the settings in the order you specify and also so that it can be triggered during app startup with out imposing any unnecessary delay.**

### `SettingsBundleDefaultValueSource`

Probably the most commonly used default value source. It's pre-programmed to scan the `Settings.bundle` file in your app, read any preferences it finds and set their defaults as the settings default by registering them in the `UserDefaults` registration domain. By default it starts with the `Root.plist` file and drills down into child panes if it sees any. 

#### `URLDefaultValueSource`

`URLDefaultValueSource` is a semi-complete source designed to access files on either a remote file server or local file system. Basically if you can refer to a file via a `URL` you can access it with this source. 

It reads the `url` and passes the data to a `mapper` function. You will need to supply this as only your app knows how to interpret the data. For example:

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

`URLDefaultValueSource` takes these arguments:

* **`url`** - A url that refers to the file to be read. Can be a local file, a file within a bundle, a remote file or any other form of valid URL.
* **`headers`** - An optional dictionary of HTTP headers to add to the request.
* **`mapper`** - A closure that will be used to read the returned `Data` and set the new default values. It's passed data read from the url and expected to return a `[String: Any]` dictionary or throw an error. 

#### `JSONDefaultValueSource`

`JSONDefaultValueSource` is an extension of `URLDefaultValueSource` that does one extra thing. It assumes the data read from the URL will be valid JSON and deserialises before calling the mapper.

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

The only argument is the key of the setting you want to connect to.

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
