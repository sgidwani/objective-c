# PubNub 4.0b1 for iOS 7+

## Changes from 3.x
* 4.0 is a non-bw compatible REWRITE with 96% less lines of code than our 3.x!
* Removed support for iOS 6 and earlier
* Removed support for JSONKit
* Removed custom connection, request, logging, and reachability logic, replacing with NSURLSession, DDLog, and AFNetworking libraries
* Simplified serialization/deserialization threading logic
* Removed support for blocking, syncronous calls (all calls are now async)
* Simplified usability by enforcing completion block pattern -- client no longer supports Singleton, Delegate, Observer, Notifications response patterns
* Replaced configuration class with setter configuration pattern
* Consolidated instance method names
 
## Known issues and TODOs in beta1:

* Needs better handling for invalid API keys (right now fails with undefined error)
* Client should not allow duplicate channel names in subscribe field
*Not all status field attributes are being populated at Status emission time for all operations (will address via TDD)
* Ability to turn logging completely off
* Make libz.dylib added to project automatically at pod install time
* Verify HTTP pipelining behavior
* Prevent suspended dispatch queue instability when released if it contains unexecuted blocks
* Audit larger methods -- refactor into smaller where possible
* Revising Result/Status model for a more consistent behavior across all completion blocks and listener blocks, for error and non-errors
* Provide additional examples in Tutorial App
* Implement a generic status catch for non 200/403 responses
* Constantize / Objectize result.data keys
* Provide Swift Bridge and associated docs
* Provide standalone framework and static library versions of lib
* Move testing from separate 'PubNubTests' project and into actual framework project
* Add automated integration testing
* Approach >= 80% automated test code coverage as we approach final beta

## Installing the Source

* Create a new project in Xcode as you would normally.
* Close XCode
* Open a terminal window, and cd into your project directory.
* Create a Podfile. This can be done by running
```
touch Podfile
```

* Open your Podfile.
* Populate it with:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'
pod 'AFNetworking', '~> 2.5'
pod 'CocoaLumberjack'
pod 'PubNub', :path => '/Users/gcohen/clients/objective-c'
```

* Be sure the path argument in the Podfile is pointing to the [parent directory](https://github.com/pubnub/objective-c/tree/4.0b1) the [PubNub source directory](https://github.com/pubnub/objective-c/tree/4.0b1/PubNub) lives in.

* Run:
 ```
 pod install
 ```

* Open the MyApp.xcworkspace that was created with XCode. (Don't open the project! Be sure to open the workspace ... This will be the file you use to write your app.)

You should now have a skeleton PubNub project.

## Hello World

* Open the workspace
* Select myApp in the folder view
* Under **Build Phases**, under **Link Binary with Libraries**, add ```libz.dylib``` with status of required
* Open AppDelegate.m
* Just after ```#import``` add the PubNub import:
 
```objective-c
#import "PubNub.h"
```
* Within the AppDelegate interface, make AppDelegate conform to the PNObjectEventListener protocol, and define a client property. When you are finished, it should look like this:

```objective-c
@interface AppDelegate () <PNObjectEventListener>
@property(nonatomic, strong) PubNub *client;
@end
```

* Make your application:didFinishLaunchingWithOptions look like this:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.client = [PubNub clientWithPublishKey:@"demo" andSubscribeKey:@"demo"];
    [self.client addListeners:@[self]];

    [self.client subscribeToChannels:@[@"myChannel"] withPresence:NO andCompletion:^(PNStatus *status) {
        
        if (!status.isError) {
            NSLog(@"^^^^ Subscribe request succeeded at timetoken %@.", status.currentTimetoken);
            
            [self.client publish:@"I'm here!" toChannel:@"myChannel"
                  withCompletion:^(PNStatus *status) {
                      if (!status.isError) {
                          NSLog(@"Message sent at TT: %@", status.data[@"tt"]);
                      } else {
                          // analyze the status object for next steps -- See Tutorial1 for in-depth examples
                      }
                  }];
            
        } else {
            NSLog(@"^^^^ Subscribe request did not succeed. All subscribe operations will autoretry when possible.");
            // analyze the status object for next steps -- See Tutorial1 for in-depth examples
        }
    }];
    

    return YES;
}
```

* Add a message listener method to your AppDelegate.m:

```objective-c
- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message withStatus:(PNStatus *)status {
    
    if (status) {
        // analyze the status object for next steps -- See Tutorial1 for in-depth examples
    } else if (message) {
        NSLog(@"Received message: %@", message.data);
    }
}
```

* If you have a [web console running](http://www.pubnub.com/console/?channel=myChannel&origin=d.pubnub.com&sub=demo&pub=demo), you can receive the hello world messages sent from your iOS app, as well as send messages from the web console, and see them appear in the didReceiveMessage listener!

Run the app, and watch it work!

## New in 4.0 -- Result and Status Event Objects

In 4.0, we introduce the concept of Status and Result events. For every PubNub operation you call, you will be returned either a Result, or a Status, but not both.

Status objects inherit from Result objects, so both contain common information like raw request, raw response, HTTP response code information, etc.

On the Result object, if you dig deeper into the data attribute, you can get information specific to the request. 

For example, when you make a history call, when the call is successful, you would receive a history Result object containing (within the data attribute) the messages, start, and end timetokens. 

If there was an error, such as a PAM error, you would receive instead a Status object. Status.category explains the type of Status (PAM, Timeout, Acknowledgement info, Connection Status (Connect, Reconnect, Disconnect), etc), Status.isError describes the severity of the Status (whether its merely informational and can be safely ignored without consequence, or whether the operation of your  application is affected).

In Beta1, [we provide Tutorial1](https://github.com/pubnub/objective-c/tree/4.0/demo/iOS/Tutorial1) as a generic reference on how to set config options, make Pub, Sub, and History calls (with and without PAM), and handle the various Status and Result events that may arise from them.  

As we approach final beta, Tutorial1 demo app will increase in breadth, and also be accompanied by more detailed tutorials. 

If you have questions about how the Result and Status objects work in the meantime, feel free to contact support@pubnub.com and cc: geremy@pubnub.com, and we'll be happy to assist.
