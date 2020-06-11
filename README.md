#  Locus

_Merriam-Webster dictionary -
1a: the place where something is situated or occurs.
1b: a center of activity, attention, or concentration.
**2: the set of all points whose location is determined by stated conditions**
3: the position in a chromosome of a particular gene or allele._

_… or 4: An iOS API for managing an applications settings._

## So what is Locus… really.

Locus is an API for managing an applications settings . It was built as a response to the complexities of managing settings in larger applications. Often they're sourced from a number of places including local and remote configuration files, local user defaults and hard coded values scattered through out the code. Add in the complexities of dealing with settings required by multiple APIs and the fact that the code is typically written over a long period of time by numerous developers using differing techniques and the results can be messy, inconsistent, hard to understand and difficult to maintain.

Locus solves these problems with a simple API that lets you manage all your settings in a consistent manner whilst it deals with all the complexity. 

## Features

* Built for enterprise and larger applications.
* Central container for getting and setting all application settings.
* Auto-loading of `Root.plist` defaults.
* Readonly, writable and transient settings.
* Release locked settings which are writable for Debug builds only.
* Setting domains for grouping settings.
* Local and remote loading of configuration files.
* Reset to default functions.
* Duplicate setting detection.
* Customisable setting stores and loaders.
* Protocol driven.

# Quick guide

Although Locus is protocol driven and therefore extremely flexible in how you use it, the following is perhaps the simplest technique. I'll use a problem of defining some basic settings for accessing a server in the following examples.

## Step 1: Define the settings in a protocol

First I'll define my application's settings using a protocol like this:

```swift
protocol MyApplicationSettings {
    var serverUrl: URL { get }
    var retries: Int { get }
}
```

## Step 2: Define your setting keys

Next I need to setup the keys to unique identify the the settings. I could use plain old hard coded `String` values or statics or whatever, but it's nicer to use an enum like this:

```swift
enum MyApplicationSettingKey: String {
    case serverUrl = "server.url"
    case retries = "server.retries"
} 
```

Obviously the enum's string values are the keys.