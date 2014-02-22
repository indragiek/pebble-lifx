## pebble-lifx
### Pebble controller for LIFX bulbs

![PebbleLIFX](https://raw.github.com/indragiek/pebble-lifx/master/images/ios-icon.png)

This project won 1st place at the UAlberta CompE Club Hackathon 2014. [Presentation slides](https://speakerdeck.com/indragiek/pebble-plus-lifx-compe-club-2014-hackathon-project).

### Getting Started

Connect your server, iOS device, and LIFX bulb to the same WiFi network.

#### Node.js

* Install [node.js](http://nodejs.org/) if necessary.
* Start the node.js server:

```
$ cd server
$ node server.js
```
#### iOS App

![PebbleLIFX iOS App](https://raw.github.com/indragiek/pebble-lifx/master/images/ios-screen.png)

* Install [Xcode](https://itunes.apple.com/ca/app/xcode/id497799835?mt=12) if necessary. You will also need an [iOS Developer Program Membership](https://developer.apple.com/programs/ios/) to run the app on your device.
* Clone the submodules necessary to build the iOS app:

```
$ git submodule update --init --recursive
```

* Open `ios/PebbleLIFX/PebbleLIFX.xcodeproj` in Xcode, build and install the app on your iOS device.
* Open the app and tap the Settings button to set the IP address of the node.js server. The port is always **3000** (can be changed by editing `server/server.js`). **BUG:** *The bulbs list does not reload after switching the server, so you need to kill and restart the app.*
* The bulbs should appear in the Bulbs section in the iOS app. You can turn a bulb on and off using the power button and switch colors using the colors list (or tap the **+** button on the top right to add your own colors).

#### Pebble App

![PebbleLIFX Pebble Bulbs List](https://raw.github.com/indragiek/pebble-lifx/master/images/pebble1.png)
![PebbleLIFX Pebble Colors List](https://raw.github.com/indragiek/pebble-lifx/master/images/pebble2.png)

* Download and install the [Pebble SDK 2.0](https://developer.getpebble.com/2/)
* Open the Pebble app on your iOS device, tap "Developer" in the sidebar, and turn on the server. Note the IP address.
* Run the following commands:

```
$ cd pebble/lifx
$ pebble build
$ pebble install --phone IP_ADDRESS_OF_YOUR_PHONE
```
* The lifx app should now be installed on your Pebble and it should list the bulbs shown in the iOS app. Long click select on a bulb to turn it on/off, or select a bulb and view the color list. Choose a color using the select button to switch the color on the bulb. **BUG**: *Only loads one custom color from the iOS app, does not load any default colors (buffer overflow?)*

### Known Issues

* There's no way to manually refresh the list of bulbs on iOS (changing the server address requires a restart of the iOS app to show the bulbs)
* Pebble app does not load anything more than 1 custom color, does not load any default colors at all. It seems like its a problem with the AppMessage read buffer overflowing.
