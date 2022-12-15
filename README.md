# chatapp

A group-based chat application created by Pierce Martin

## Version 2.0.0

### Completed
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

### To Do
* Version info page
* Username max length
* Group together messages in similar times
* Profile pictures & Group pictures
* Replies (using gestures? :o)
* Group deleting
* Pin messages
* Attachments
* Notification bubble on groups icon when a group has new messages?
* Find a way to constrain the size of groups on small screen size
* Dark mode switiching support
* Notification alert

### Known issues
* Group name overflows if long enough on the right screen size
* AuthStateChanges not updating for some reason after signing out
* Scroll to bottom on new message is a little buggy? Doesn't always go all the way to the bottom
* setState() being called after widget destruction in (i think) groups.dart
* Firebase permissions error on log out, not sure where it's coming from
* (fixed?) setState() called after dispose when in smaller view 
* Unhandled Google errors
  
