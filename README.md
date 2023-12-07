# Submarine UI

A user interface for steering and communication wirelessly with a soon to be built RC submarine.

## Getting Started

This project was written in VScode using Manjaro OS.

To set up Flutter for the same configuration follow the following instructions:

- Follow [this link](https://dev.to/awais/configure-flutter-development-environment-on-manjaro-arch-linux-4a0a) to install and set up android-sdk and flutter.
*Installing the Andoid emulator is not required.*

- Java runtime deps:

```pacman -S jdk17-openjdk jre17-openjdk jre17-openjdk-headless```

- Linux toolchain deps:

```pacman -S clang cmake ninja pkg-config```.

- Add a chromium based browser:

```export CHROME_EXECUTABLE={path_to_browser}```

- To configure Flutter for vscode simply install the flutter extension from the VScode extension manager.

- To make sure everything is done correctly, open the VScode command palette View -> Command Palette (<kbd>Ctrl+Shift+P</kbd>).
Then search for *doctor* and run the flutter doctor. Android studio is not installed by this setup.
Alteratively, use the terminal to execute ```flutter doctor -v```

To start your project, follow [this link](https://docs.flutter.dev/get-started/test-drive?tab=vscode).

