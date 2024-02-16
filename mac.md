
* key repeating vim plugin of intellij pycharm dbeaver
  
```defaults write -g ApplePressAndHoldEnabled -bool false```

It seems that Mac wants to support accent characters by holding the key.

ref: https://intellij-support.jetbrains.com/hc/en-us/community/posts/206845385-FYI-for-Lion-users-who-use-IdeaVIM

You can type `defaults write com.jetbrains.` in the terminal and then hit the tab to auto-complete. 

e.g. `defaults write com.jetbrains.intellij ApplePressAndHoldEnabled -bool false`

