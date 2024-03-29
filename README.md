# chatapp

A group-based chat application created by Pierce Martin

## Version 2.2.0 (Current)

* BUG FIXED: Constant redraws when the scroll button is showing
* Replies to messages
* Reactions to messages
* Switched to Roboto font because it can overflow properly

## Version 2.1.3

* Correct gaps between messages sent by different other users
* Updated timestamp showing for messages > 3 min apart instead of > 5
* BUG FIXED: New account has a displayName but when sending a message, the sender is empty
* BUG FIXED: Creating groups on mobile breaks the UI
  * Added null checks to numMessagesReadStream in groups.dart to ensure no errors; seems to still read correctly

## Version 2.1.2

* Username max length
* Better appearance for popups
* Padding on login/register page
* BUG FIXED: Small screen/phone two back buttons on info page
* ATTEMPT FIX: Font weights too light on my phone: flutter build web --web-renderer canvaskit
* BUG FIXED: Error when creating a group on small screens

## Version 2.1.0

* FIX: Removed accidental infinite loops on calling database + optimized other calls
    1. Moved get current group's members to viewmodel. It was called inside a stateful widget, which was called on every rebuild
    2. Only call read all messages when switching into a group, switching out, logging out, closing the window. Was previously called on every chat message
        * This leaves potential for unread messages count to be inaccurate if leaving the app without going inactive (since inactive isn't always accurate)
    3. Moved getCurrentUserInfo() + setState call into initState. It was inside the InfoState build function, and kept calling setState, which called itself again...infinitely lol
    4. Moved getNumberOfNewMessages() + setState call into initState. It was inside the GroupTile build function; same problem as 3
    5. TODO: Reduce usage of getCurrentUserName by storing it in the viewmodel after calling once
    6. Forgot to set active to true when calling setActive, so it got called like 20 times lol

## Version 2.0.0

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

* TODO: Clean up message page (separate things into widgets)
* Reply via swipe
* Alerts for group creation, group renaming, joining group
* Profile pictures & Group pictures
* Group deleting
* Version info page
* Pin messages
* Attachments
* Dark mode switiching support
* Redesign the group's users section to have better behavior
* Group permission settings (changing name, deleting permissions)
* Notification alert
* Emoji keyboard, specifically for desktop

### Known issues

* Firebase permissions error on log out, not sure where it's coming from
* Setting inactive on log out didn't work once but couldn't reproduce. Happened right after first sign in
* Reading all messages on window close doesn't work
* Possible to create an account without creating database info, need a backup for this case
* (Can't seem to replicate outside of deployed version) New messages not right in some circumstances
  