

### pr stash
in .git/config:

```
[alias]
    prstash = "!f() { git fetch $1 refs/pull-requests/$2/from:$3; } ; f"
```

usage:
`git prstash origin 93 pr/jane`  check out `origin`'s PR number 93 to local branch `pr/jane`

