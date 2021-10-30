# Intro

[![.github/workflows/swift.yml](https://github.com/drekka/Locus/actions/workflows/swift.yml/badge.svg?branch=master)](https://github.com/drekka/Locus/actions/workflows/swift.yml)

*Locus* is a useful API that helps to wrangle your app's settings. it coordinates between hard coded values, `Settings.bundle` preferences, `UserDefaults` and local or remote configuration files whilst at the same time providing a consistent API to let you get on writing the business at hand.

Essentially *Locus* provides ...

* A consistent and simple API for retrieving and updating settings regardless of where they came from.
* A set of implementations that let you source settings values from `UserDefaults`, `Settings.bundle` preferences, local files, remote files and other sources unique to your app in an easy to use manner.
* Features for defining where updates to settings are stored and whether they can be updated at all.
* A built in Combine publisher for subscribing to updates to values.
* Support for using both `String` and enum based keys for settings.
* Immediate feedback if you try and access an unknown setting, or set a value on one that's defined as read only.

# Core concepts

## The Container

*Locus* is architected around a central container for managing settings. The container is where you register settings with their default values and load default values from external sources such as remote configuration files. When accessing setting values you can use the container if you need to, but you can also access settings via a supplied property wrapper.

## Current value vs Default values

Similar to `UserDefaults` where there is a registered default and current value for any given setting, *Locus* has a *default value* and a *current value*. But unlike `UserDefaults`, *Locus* always guarantees a value for any registered setting. Either the *Default value* which can be updated with values from various sources such as `Settings.bundle` files or remote configurations, or *Current values* if your app has stored such a value. 

## Setting keys

Every setting in *Locus* has a **key**. This uniquely identifies the setting and is used when updating defaults from external sources. Keys also allow for typo to be detected by *Locus* during development. A key can be either a `String` or an implementation of `RawRepresentable` where the `RawValue` type is `String`. In other words, a string enum. It doesn't matter which you choose to use, either, or, or both, *Locus* has overrides for every function that takes a key and will know what to do.

# Quick guide

## Step 1: Register your settings in your app startup

The first thing to do is register your settings. You do this in the container, registering each setting along with various other attributes that control how it is accessed.

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

## Step 2: Add loaders to gather default values

After registering your settings you *may* need to update the default values from one or more sources such as `Settings.bundle` files, remote configuration files, etc. This is done by passing one or more implementations of `DefaultValueSource` to the container's `.read(...)` function like this:

```swift
SettingsContainer.shared.read(sources: SettingsBundleDefaultValueSource()) { error in
    // Check error here.
}
```

## Step 3: Add `@Setting` property wrappers or access the container for settings

Finally you're ready to access your settings. You can retrieve values directly from the container like this:

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
        default defaultValue: Default) where K: RawRepresentable, K.RawValue == String
```

Where:

* **`key`** - Is the setting's unique key. It can be either a `String` or a string `RawRepresentable` such as a string enum. 
* **`persistence`** - Where updated values are stored, one of:
    * **`.none`** - The setting cannot be updated. This is the default. 
    * **`.transient`** - The setting can be updated, but the updated values are not preserved when the app is killed. 
    * **`.userDefaults`** - The setting can be updated and the updated value will be stored in `UserDefaults`.
* **`releasedLocked`** - If true, indicates that the setting can be updated in Debug builds, but is read only in Release builds. 
* **`default`** - The default value for the settings. This enum is either `.local(<value>)` indicating a value stored in memory whilst the app is running, or `.userDefaults` indicating that the value is expected to be found in the registration domain of `UserDefaults`.

### Convenience functions

In addition to creating `SettingConfiguration` instances, *Locus* also offers a range of convenience functions:

#### readonly(...)

The read only functions are short cuts that produce `SettingConfiguration` instances which cannot be updated by your app.

```swift
func readonly(_ key: String, default: Any? = nil) -> SettingConfiguration
func readonly<K>(_ key: K, default: Any? = nil) -> SettingConfiguration where K: RawRepresentable, K.RawValue == String
```

#### transient(...)


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

In addition, running this source means you don't have to pass the `default:` arguments when registering because the default values will be read and set in the `UserDefaults` **registration** domain. Providing you either specify `persistence: .userDefaults` or use the `userDefaults(...)` convenience function when registering those settings.

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
