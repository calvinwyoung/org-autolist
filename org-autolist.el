;;; org-autolist.el --- Improved list management in org-mode

;; Copyright (C) 2014 Calvin Young

;; Author: Calvin Young
;; Keywords: lists, checklists, org-mode
;; Homepage: https://github.com/calvinwyoung/org-autolist
;; Version: 0.1

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; `org-autolist` makes org-mode lists behave more like lists in non-programming
;; editors such as Google Docs, MS Word, and OS X Notes.
;;
;; When editing a list item, pressing "Return" will insert a new list item
;; automatically. This works for both bullet points and checkboxes, so there's
;; no need to think about whether to use `M-<return>` or `M-S-<return>`. Similarly,
;; pressing "Backspace" at the beginning of a list item deletes the bullet /
;; checkbox, and moves the cursor to the end of the previous line.

;;; Usage:

;; To enable org-autolist mode in the current buffer:
;;
;;   (org-autolist-mode)
;;
;; To enable it whenever you open an org file, add this to your init.el:
;;
;;   (add-hook 'org-mode-hook (lambda () (org-autolist-mode)))

;;; Code:
(require 'org)
(require 'org-element)

(defun org-autolist-beginning-of-item-after-bullet ()
  "Returns the position before the first character after the
bullet of the current list item"
  (org-element-property :contents-begin (org-element-at-point)))

(defadvice org-return (around org-autolist-return)
  "Wraps the org-return function to allow the Return key to
automatically insert new list items.

- Pressing Return at the end of a list item inserts a new list item.
- Pressing Return at the end of a checkbox inserts a new checkbox.
- Pressing return at the beginning of an empty list or checkbox item
  outdents the item, or clears it if it's already at the outermost
  indentation level."
  ;; We should only invoke our custom logic if we're in a list item.
  (if (org-at-item-p)
      ;; If we're at the beginning of an empty list item, then try to outdent
      ;; it. If it can't be outdented (b/c it's already at the outermost
      ;; indentation level), then delete it.
      (if (and (eolp)
               (<= (point) (org-autolist-beginning-of-item-after-bullet)))
          (condition-case nil
              (call-interactively 'org-outdent-item)
            ('error (delete-region (line-beginning-position)
                                   (line-end-position))))

        ;; Now we can insert a new list item. Insert a checkbox if we're on a
        ;; checkbox item, otherwise let org-mode figure it out.
        (if (org-at-item-checkbox-p)
            (org-insert-todo-heading nil)
          (org-meta-return)))
    ad-do-it))

(defadvice org-delete-backward-char (around org-autolist-delete-backward-char)
  "Wraps the org-delete-backward-char function to allow the Backspace
key to automatically delete list prefixes.

- Pressing backspace at the beginning of a list item deletes it and
  moves the cursor to the previous line.
- If the previous line is blank, then delete the previous line, and
  move the current list item up one line."
  ;; We should only invoke our custom logic if we're at the beginning of a list
  ;; item right after the bullet character.
  (if (and (org-at-item-p)
           (<= (point) (org-autolist-beginning-of-item-after-bullet)))
      ;; If the previous line is empty, then just delete the previous line (i.e.,
      ;; shift the list up by one line).
      (if (org-previous-line-empty-p)
          (delete-region (line-beginning-position)
                         (save-excursion (forward-line -1)
                                         (line-beginning-position)))

        ;; Otherwise we should delete to the end of the previous line.
        (progn
          ;; If we're not already at the end of a line, then we should move to
          ;; the point after the bullet. This handles the case when the cursor
          ;; is in the middle of a checkbox.
          (if (not (eolp))
              (goto-char (org-autolist-beginning-of-item-after-bullet)))

          ;; For most lines, we want to delete from bullet point to the end of
          ;; the previous line. But if we're on the first line in the buffer,
          ;; then we should just delete the bullet point.
          (if (= 1 (line-number-at-pos))
              (delete-region (point) (line-beginning-position))
            (delete-region (point) (save-excursion (forward-line -1)
                                                   (line-end-position))))))
    ad-do-it))

;;;###autoload
(define-minor-mode org-autolist-mode
  "Enables improved list management in org-mode."
  nil nil nil
  (cond
   ;; If enabling org-autolist-mode, then add our advice functions.
   (org-autolist-mode
    (message "Enabling auto-list-mode!")
    (ad-activate 'org-return)
    (ad-activate 'org-delete-backward-char))
   ;; Be sure to clean up after ourselves when org-autolist-mode gets disabled.
   (t
    (message "Disabling auto-list-mode!")
    (ad-deactivate 'org-return)
    (ad-deactivate 'org-delete-backward-char))))

(provide 'org-autolist)
;;; org-autolist.el ends here
