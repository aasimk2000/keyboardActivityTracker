# keyboardActivityTracker
Mac menubar app to monitor daily keystrokes and trends

Simple menubar app that uses [NSEvent global monitoring](https://developer.apple.com/documentation/appkit/nsevent/1535472-addglobalmonitorforevents) to track number of keystrokes.
This data is stored is persisted in a Core Data database.

Daily keystrokes and total keystrokes are displayed in a menubar NSView along with a activity progress wheel tracking how many keystrokes to daily goal.
