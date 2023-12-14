# Submarine UI

A user interface for sockets based communcation with a RC Submarine.

## Setup

This project is built on Arch Linux using the Flutter framework.

Install Flutter, OpenJDK, and Android SDK
```bash
yay -S flutter
doas pacman -S jre17-openjdk
yay -S android-sdk android-sdk-platform-tools android-sdk-build-tools
yay -S android-platform
```

Configure licenses for Flutter
```bash
flutter doctor --android-licenses
```
and check the installation
```bash
flutter doctor
```

If Flutter complains about dubious ownership, run the provided command:
```bash
git config --global --add safe.directory /opt/flutter
```

Flutter might also complain about a missing Chrome executable, 
this can be fixed with one of:
```bash
ln -s $(which $BROWSER_OF_CHOICE) /usr/bin/google-chrome  # or a seemingly more unreliable fix
export CHROME_EXECUTABLE=$BROWSER_OF_CHOICE  # can also be added .bashrc
```

Rerun the Flutter doctor:
```bash
flutter doctor -v  # Android Studio might not be installed
```

### Test

Create and run a new Flutter project
```bash
flutter create hello_world
cd hello_world
flutter run
```

## Running the Application

Get application dependencies
```bash
flutter pub get
```

Start the app
```bash
flutter run
```

### Inside the Application

Firstly you need to connect to the submarine server.

Go to the settings page and click `Connect`, this should provide a list if available IPs. 

Click the corresponding IP and the application automatically tries to connect to it 
through the configured port, which can be changed by `Set Port`.

If the correct IP doesn't show up, try clicking `Stop Scan` (if one is running) 
and then `Start Scan`.

If the application finds a device with the correct port open, it sends a handshake and waits for
its response, if this fails try configuring the `Set Handshake Recv` and `Set Handshake Send`.

When the application is connected, it automatically sends the state of the steering controls 
to the submarine making it possible to wirelessly steer the submarine.

