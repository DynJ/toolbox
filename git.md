

### pr stash
in .git/config:

```
[alias]
    prstash = "!f() { git fetch $1 refs/pull-requests/$2/from:$3; } ; f"
```

usage:
`git prstash origin 93 pr/jane`  check out `origin`'s PR number 93 to local branch `pr/jane`



### oh-my-zsh slow, but only for certain Git repo

```
git config --add oh-my-zsh.hide-status 1 <=== you may not need it
git config --add oh-my-zsh.hide-dirty 1
```

