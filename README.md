# chatapp

A group-based chat application created by Pierce Martin

## Version 2.1.2 (In Progress)

* Username max length
* Better appearance for popups
* Padding on login/register page
* FIX: Small screen/phone two back buttons on info page
* ATTEMPT FIX: Font weights too light on my phone: flutter build web --web-renderer canvaskit
* FIX: Error when creating a group on small screens

## Version 2.1.0

* FIX: Removed accidental infinite loops on calling database + optimized other calls
    1. Moved get current group's members to viewmodel. It was called inside a stateful widget, which was called on every rebuild
    2. Only call read all messages when switching into a group, switching out, logging out, closing the window. Was previously called on every chat message
        * This leaves potential for unread messages count to be inaccurate if leaving the app without going inactive (since inactive isn't always accurate)
    3. Moved getCurrentUserInfo() + setState call into initState. It was inside the InfoState build function, and kept calling setState, which called itself again...infinitely lol
    4. Moved getNumberOfNewMessages() + setState call into initState. It was inside the GroupTile build function; same problem as 3
    5. TODO: Reduce usage of getCurrentUserName by storing it in the viewmodel after calling once
    6. Forgot to set active to true when calling setActive, so it got called like 20 times lol

## Version 2.0.0 (Current)

* Don't allow users to sign in as another past user (username and password, Google auth)
* Google authentication
* Register page
* Sign in with email and password
* Force user to create a username when they sign in for the first time
* Show the list of groups you're in and be able to select between them
* Name of group above chat page
* Unify colors
* Clicking on current group shouldn't reload the messages
* Get enter key to work
* Font chosen
* Group ID copying
* Move main page appbar code to chats page
* Group renaming
* Group name max length
* Tell when a person is in the browser? Or when they go AFK?
* Show which users are active/not on the chat page
* Account renaming
* Notification bubble on groups icon when a group has new messages
* Group together messages in similar times
* Inactive timer

### Eventually planned

* Replies (using gestures? :o)
* Profile pictures & Group pictures
* Group deleting
* Reactions to chats
* Version info page
* Pin messages
* Attachments
* Dark mode switiching support
* Redesign the group's users section to have better behavior
* Group permission settings (changing name, deleting permissions)
* Notification alert

### Known issues

* Firebase permissions error on log out, not sure where it's coming from
* Setting inactive on log out didn't work once but couldn't reproduce. Happened right after first sign in
* Reading all messages on window close doesn't work
  