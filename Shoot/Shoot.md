Shoot'nShare
==============
You want to shoot cool photos and share them with friends using Dropbox.

## Install
All our project require [CocoaPods](http://cocoapods.org/) for dependency management;

**Before**, you can run the apps, you need to run the following command:

    pod install

After that you just need to open the ```Shoot.xcworkspace``` file in XCode and you're all set.

## Dropbox setup
### Create app
To get started with your Dropbox App, open the [Dropbox App Console](https://www.dropbox.com/developers/apps). Sign in if you have a Dropbox account, or create a free Dropbox account. Choose the **Create App** option. You’ll be presented with a series of questions – provide the following responses:

* Dropbox API app
* Files and Datastore
* All File Types

Finally, choose a name for your app, whatever you want, it just has to be unique. Once you've created you app, you will have a App key and App secret.

### Authorize Shoot'nShare app

In AGAppDelegate, replace APP_KEY/APP_SECRET by you provide app key/app secret.

    #warning Set appKey from dropbox
    NSString* appKey = @"APP_KEY";
    #warning set appSecret from dropbox
    NSString* appSecret = @"APP_SECRET";

In Shoot-Info.plist

	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>db-APP_KEY</string>
			</array>
		</dict>
	</array>

## UI Fow 
When you start the application you need to link your app with dropbox. Click on 'Link to Dropbox' and enter your credentials. 

Once linked, you can shoot a photo and then upload it to dropbox. You can also browse existing photos, pick one and upload it to Dropbox.

## How does it work?
### Dropbox authentication: an overview

### upload file


