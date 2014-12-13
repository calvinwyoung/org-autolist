## Summary

**org-autolist** aims to make editing org-mode lists more similar to editing lists in non-programming editors like Google Docs, MS Word, and OS X Notes.

## Setup

```el
(require 'org-autolist)
(add-hook 'org-mode-hook (lambda () (org-autolist-mode)))
```

## Usage

When editing lists with org-autolist-mode enabled, pressing the "Return" key will insert a new list item automatically. This works for both bullet points and checkboxes, so there's no need to think about which key combination to use (i.e., `M-<return>` vs. `M-S-<return>`). Additionally, pressing "Backspace" at the beginning of a list item deletes the bullet point (or checkbox), and moves the cursor to the end of the previous line.

The easiest way to illustrate this functionality is with a few examples. Here, we'll use the `|` character to indicate the cursor position. 

### Inserting list items

Suppose we start with this list:

```
- one
- two
  - apple|
```

Pressing "Return" once will result in the following:

```
- one
- two
  - apple
  - |
```

Pressing "Return" again will result in:

```
- one
- two
  - apple
- |
```

And pressing "Return" one last time will result in:

```
- one
- two
  - apple
|
```

### Deleting list items

Now, suppose we start with:

```
- [ ] one
- [ ] two
  - [ ] apple
  - [ ] |
```

Pressing "Backspace" will produce:

```
- [ ] one
- [ ] two
  - [ ] apple|
```

Similarly, if we instead start from here:

```
- [ ] one
- [ ] two
  - [ ] |apple
```

Then pressing "Backspace" will produce:

```
- [ ] one
- [ ] two|apple
```

## Feedback

If you find a bug, or have a suggestion for an improvement, then feel free to submit an issue or pull request!
