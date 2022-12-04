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

### To Do
* Name of group above chat page
* Group info page (users and their logged-in status, group ID, other metadata)
* Unify colors
* Get enter key to work
* Font on mobile browser?
* Group together messages in similar times
* Tell when a person is in the browser? Or when they go AFK?
* Replies (using gestures? :o)
* Attachments
* Notification bubble on groups icon when a group has new messages?
* Find a way to constrain the size of groups on small screen size
* Dark mode switiching support
* Notification alert
* Allow for deleting groups potentially

### Known issues
* AuthStateChanges not updating for some reason after signing out
* Scroll to bottom on new message is a little buggy? Doesn't always go all the way to the bottom
* setState() being called after widget destruction in (i think) groups.dart
* Firebase permissions error on log out, not sure where it's coming from
  
  
