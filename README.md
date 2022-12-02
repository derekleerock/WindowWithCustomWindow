# WindowWithCustomWindow

Sample project to learn how to display a UIWindow on top of all other windows and view controllers.

There are three buttons to confirm this functionality works as I want it to:
- "New Modal": Displays a new modal window on top of the main window's view controller
- "Show Window": Displays a new window on top of the existing window with a blue view; even if a modal VC is shown, this new window is still displayed on top. This window is only created one the first time the button is pressed. 
- "Hide Window": Hides the new window that was already created; if no window was created, this does nothing. 
