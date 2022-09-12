# Intro

[![.github/workflows/swift.yml](https://github.com/drekka/Locus/actions/workflows/swift.yml/badge.svg?branch=master)](https://github.com/drekka/Locus/actions/workflows/swift.yml)

*Locus* is a an API designed to address a common problem. Managing an app's settings from multiple sources such as hard coded values, `Settings.bundle` preferences, `UserDefaults` and local or remote configuration files. A problem that often crops up in enterprise apps where developers coming and going can result in multiple inconsistent and often Byzantine implementations.

*Locus* is designed to address these issues by providing ...

* A consistent and simple API for retrieving and updating settings from multiple sources.
* Detection of miss-typed setting keys. 
* Support for settings stored in `UserDefaults`, `Settings.bundle` preferences, local files, remote files and custom locations.
* Combine publishing of setting updates.
* The ability to use either `String` or enum keys.
* A `@Setting` property wrapper for easy access.

# Core concepts

## The Container

*Locus* uses a central container for managing settings. This container is where default values are set, and where updates from external sources such as remote configuration files are processed. 

Settings can be accessed directly from the container or via a supplied `@Setting` property wrapper.

All settings in the app must be registered in the container before they can be accessed. This is to ensure that every setting has a *default value* and to also allow *Locus* to detect invalid keys.

## Current value vs Default values

Similar to how `UserDefaults` has the concept of registered defaults, *Locus* has a *default value* as well as *current value* for any given setting. However unlike `UserDefaults` where settings return optionals, *Locus* guarantees a value. In other words, if there is no *current value*, it returns the *default value* set during registration. 

## Setting keys

Every setting has a **key** to uniquely identify it to the container. A key can be either a `String` or an implementation of `RawRepresentable` where the `RawValue` type is `String`. In other words, a string enum. It doesn't matter which you choose to use, either, or, or both, *Locus* has overrides for every function so that it will know what to do.

However I do recommend using enums.

# Quick guide

## Step 1: Register your settings in your app startup

First we need to register settings with the container. At a minimum this requires the setting's **Key** and a default value.

```swift
// Enum based keys.
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

You'll notice that `server.url` in the above example does not have a default value. That's is because in our example, `server.url` is using a default value sourced from the app's `Settings.bundle`. Only keys set by the `userDefaults(...)` function and which have default values in the `Settings.bundle` can skip setting a default here. _Lots more on registering settings below._

## Step 2: Read in default values

After registering settings in the container you *may* want to update their default values using one or more sources such as `Settings.bundle` files or files stored on a remote server. This is done via types that implement `DefaultValueSource` and typically you would call them like this:

```swift
let settingsBundle = SettingsBundleDefaultValueSource()
SettingsContainer.shared.read(sources: settingsBundle) { error in
    // Check error here.
}
```

## Step 3: Access your settings

At this point your settings are all ready to go. You can retrieve values directly from the container like this:

```swift
let url: URL = SettingsContainer.shared[SettingKey.serverUrl]
```

or use the provided property wrapper like this:

```swift
class SomeClass {

    @Setting(SettingKey.serverUrl)
    var serverUrl: URL

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

### SettingConfiguration

All registrations are ultimately done with instances of `SettingConfiguration`. If you want to create them explicitly (as the first two in the above example do) there are two default initialisers you can use:

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

* **`key`** - Is the setting's unique key. It's the only difference between the two functions and can be either a `String` or a string `RawRepresentable` (string enum). 
* **`persistence`** - Whether the app can update the *current value* for the setting and where that value is stored:
    * **`.none`** - The setting cannot have a *current value* set. This is the default. Note that this does not effect the updating of the setting's *default value*.
    * **`.transient`** - The setting can have a *current value* set, but it's _"transient"_ in that it's only stored in memory and not preserved when the app is shutdown. 
    * **`.userDefaults`** - The setting can have a *current value* set. That value will be set in `UserDefaults` and thus will be the *current value* from that point onwards.
* **`releasedLocked`** - If true, indicates that the setting can have a *current value* set in Debug builds, but not in Release builds. This is to support settings which are basically read only, but need to be changed for testing purposes.
* **`default`** - This is the initial _default_ value for the settings. It must be one of
  * **`.local(<value>)`** - A value stored in memory whilst the app is running.
  * **`.userDefaults`** - The *default value* is expected to be sourced from the registered defaults domain in `UserDefaults`. It is expected that if settings of this type are registered, then the `SettingBundleDefaultValueSource` is used to load defaults into the registered defaults domain.

### Convenience functions

Creating the `SettingConfiguration`s manually is the most expressive form of registration, however there are quite a few common types of settings so *Locus* also offers a range of convenience functions:

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

As mentioned, once your settings are registered you can then run a variety of **`DefaultValueSource`** instances to set or update their default values. A source can be anything - preferences in a `Settings.bundle`, locally stored files, remotely stored files, or anything else you can think of. Because sources such as remotely stored files are inherently asynchronous to access, all the sources are executed in a separate background thread. 

For example, setting up to read default values from a `Settings.bundle` and then a remote file might look something like this:

```swift
let settingsBundleSource = SettingsBundleDefaultValueSource()

let url = URL(string: "https://appserver.com/configuration/config.json")!
let remoteConfig = JSONDefaultValueSource(url: url) { json in
    if let json = json as [String: Any?], 
       let serverURL = json["url"] as? String {
        return ["serverUrl": serverURL]
    } 
    return [:]
}

// Now read the updates
SettingsContainer.shared.read(sources: settingsBundleSource, remoteConfig) { error in
    // Check error and respond as necessary.
}
```

*Note: Locus executes each source sequentially on a background thread. This is a deliberate choice to ensure that the sources store their new values in the order you specify.**

Now lets take a look at the supplied sources.

### SettingsBundleDefaultValueSource

Probably the most commonly used default value source. It's pre-programmed to scan the `Settings.bundle` file in your app, read any preferences it finds and register them in the `UserDefaults` registration domain. By default it starts with the `Root.plist` file and contains logic to also drill into child panes if any are present. 

#### URLDefaultValueSource

`URLDefaultValueSource` is a semi-complete source designed for accessing a file (local or remote) and passing it's contents to a `mapper` function for processing. You will need to supply the mapper. For example:

```swift
let fileUrl = URL(string: "https://appserver.com/configuration/config.yaml") 
Let headers = [
              "Content-Type": "yaml",
              "auth": "security-token" 
              ]
let remoteConfigSource = URLDefaultValueSource(url: url,
                                               headers: headers) { data in
    let yaml = ... // Convert data to a dictionary here
    var defaults: [String: Any] = [:] 
    if url = yaml["server-url"] {
        defaults[SettingKey.serverUrl.rawValue] = url
    } 
    return defaults
}
```

`URLDefaultValueSource` takes these arguments:

* **`url`** - A url that refers to the file to be read. Can be a local file, a file within a bundle, a remote file or any other form of valid URL.
* **`headers`** - An optional dictionary of HTTP headers to add to the request.
* **`mapper`** - A closure that will be used to read the returned `Data` and set the new default values. It's passed data read from the url and expected to return a `[String: Any]` dictionary or throw an error. 

#### JSONDefaultValueSource

`JSONDefaultValueSource` is an extension of `URLDefaultValueSource` that does one extra thing. It assumes the data read from the URL will be valid JSON and deserialises it before calling the mapper.

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

If you have a source that doesn't match any of the pre-built classes you can just roll your own. All you have to do is implement `DefaultValueSource`. The source for `URLDefaultValueSource` is a good example of doing this.

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

The only argument is the key of the setting.

### Settings via the container

`@Setting(...)` property wrappers aren't always convenient to user. So if you want to access a setting in a situation where the property wrapper is not suitable you can talk to the container directly. Here's some examples:

```swift
let timeout: Double = SettingsContainer.shared[SettingKey.serverTimeout]
let serverUrl = SettingsContainer.shared["server.url"] as URL
```

# Combine

*Locus* is [Swift Combine](https://developer.apple.com/documentation/combine) friendly and can provide settings updates through the `defaultValueUpdates` property. You can use it like this:

```swift
let cancellable = SettingsContainer.shared.defaultValueUpdates
                      .filter { $0.key == "key_im_interested_in" }
                      .sink { update in
                      // do something with the (key: String, value: Any) tuple receieved.
}
```  
