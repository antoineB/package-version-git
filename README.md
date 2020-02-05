To use this package :

```emacslisp
(require 'package-version-git)
```

Configure <code>package-version-git-executable</code> if your git installation is non standard.

Then every time you install/update/delete a package a commit in <code>~/.emacs.d/elpa</code> will be added.