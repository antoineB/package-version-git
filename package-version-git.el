;;; package-version-git.el --- Save every iteration of package updates into git commits  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Antoine Brand

;; Author: Antoine Brand
;; Keywords: 

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(defcustom package-version-git-executable
  (if (featurep 'magit)
      magit-git-executable
    "git")
  "Git executable."
  :version "26.2"
  :type 'string
  :group 'package-version-git)

(defun package-version-git--execute-cmd (cmd)
  (call-process-shell-command
   (concat "cd " package-user-dir "; " package-version-git-executable " " cmd)))

(defun package-version-git--init ()
  "Coerce the `package-user-dir' into a git repository."
  ;; TODO: récupérer que le code d'erreur n'est pas zero
  (when (not (equal 0 (package-version-git--execute-cmd "show HEAD")))
    (message (concat "git init in " package-user-dir))
    (package-version-git--execute-cmd "init")))

(defadvice package-menu--perform-transaction (after package-version-git-package-menu--perform-transaction-after activate)
  "Save every update into a git commit."
  (if (not (equal 0 (call-process-shell-command (concat package-version-git-executable " --version"))))
      (message (concat package-version-git-executable " not found"))
    (package-version-git--init)
    (package-version-git--execute-cmd "add *")
    (package-version-git--execute-cmd "add -u")

    (let ((commit-message (with-temp-buffer
                            (insert (format-time-string "%FT%T%z") "\n")
                            (dolist (pkg install-list)
                              (cond ((package-desc-p pkg)
                                     (insert "I " (if (symbolp (package-desc-name pkg)) (symbol-name (package-desc-name pkg)) (package-desc-name pkg)) "\n"))
                                    ((symbolp pkg) (insert "I " (symbol-name pkg) "\n"))
                                    ((char-or-string-p pkg) (insert "I " pkg "\n"))))
                            (dolist (pkg delete-list)
                              (cond ((package-desc-p pkg)
                                     (insert "D " (if (symbolp (package-desc-name pkg)) (symbol-name (package-desc-name pkg)) (package-desc-name pkg)) "\n"))
                                    ((symbolp pkg) (insert "D " (symbol-name pkg) "\n"))
                                    ((char-or-string-p pkg) (insert "D " pkg "\n"))))
                            (buffer-string))))
      (package-version-git--execute-cmd (concat "commit -m \"" commit-message "\"")))))


(provide 'package-version-git)
;;; package-version-git.el ends here
