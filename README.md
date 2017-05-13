# Prototyper

[![CI Status](http://img.shields.io/travis/grafele/Prototyper.svg?style=flat)](https://travis-ci.org/grafele/Prototyper)
[![Version](https://img.shields.io/cocoapods/v/Prototyper.svg?style=flat)](http://cocoapods.org/pods/Prototyper)
[![License](https://img.shields.io/cocoapods/l/Prototyper.svg?style=flat)](http://cocoapods.org/pods/Prototyper)
[![Platform](https://img.shields.io/cocoapods/p/Prototyper.svg?style=flat)](http://cocoapods.org/pods/Prototyper)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

To use the Prototyper framework you need an account for the [Prototyper online service](https://prototyper-bruegge.in.tum.de). Create a new prototype and download the container file for the prototype you want to inlude in your app.

## Installation

1. Integrate Prototyper Cocoapod

    ```swift
    pod 'Prototyper'
    ```

    To guarantee that you can configure prototypes directly in Interface Builder add the following lines at the end of your Podfile:

    ```swift
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.new_shell_script_build_phase.shell_script = "mkdir -p $PODS_CONFIGURATION_BUILD_DIR/#{target.name}"
            target.build_configurations.each do |config|
                config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
            end
        end
    end
    ```

2. Add App transport security exception for localhost:

    ```xml
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>localhost</key>
            <dict>
                <key>NSTemporaryExceptionAllowsInsecureHTTPSLoads</key>
                <false/>           
                <key>NSIncludesSubdomains</key>
                <true/>
                <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSTemporaryExceptionMinimumTLSVersion</key>
                <string>1.0</string>
                <key>NSTemporaryExceptionRequiresForwardSecrecy</key>
                <false/>
            </dict>
        </dict>
    </dict>
    ```

3. Add container zip file to project
4. Create ViewController for every prototype page you want to show and make it a subclass of PrototypeViewController (Don’t forget to import Prototyper module)

    ```swift
    import Prototyper
    ```

5. Load prototype in view controller. In viewDidLoad for example:

    ```swift
    self.loadPrototypePage("PAGE_ID")
    ```

6. Optional: Preload prototype (e.g. in AppDelegate)

    ```swift
    PrototypeController.sharedInstance.preloadPrototypes(nil)
    ```

## Author

Stefan Kofler, grafele@gmail.com

## License

Prototyper is available under the MIT license. See the LICENSE file for more info.
