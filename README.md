# Pin

Pin is a tiny iPhone app with Home Screen and Lock Screen widgets for one-tap audio notes.

## What it does

- Choose a destination folder in the app, such as your iCloud Drive `Pens` folder.
- Tap the app button to start recording.
- Tap again to stop and save an `.m4a` file into the selected folder.
- Add the `Pin` widget to the Home Screen or Lock Screen and tap it to open the app via `pin://toggle`, which starts or stops recording.

## iOS constraint

Widgets cannot directly run a long-lived microphone recording session. The widget is intentionally a deep-link toggle: tapping it opens the app, and the app performs the recording.

## Setup

1. Open `PensRecorder.xcodeproj` in Xcode.
2. Select the `PensRecorder` app target.
3. In Signing & Capabilities, choose your Apple Developer team.
4. Build and run on your iPhone.
5. In the app, tap `Choose Folder` and select your iCloud Drive `Pens` folder.
6. Add the `Pin` widget to your Home Screen or Lock Screen.
