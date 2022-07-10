;;; salv.el --- Local minor mode to save a modified buffer when idle  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Adam Porter

;; Author: Adam Porter <adam@alphapapa.net>
;; URL: https://github.com/alphapapa/salv.el
;; Version: 0.1-pre
;; Package-Requires: ((emacs "24.3"))
;; Keywords: convenience

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

;;   Salve, v. t. & i.
;;   To save, as a ship or goods, from the perils of the sea.

;;   --Webster, 1913

;; Q: How does this package differ from other ones that automatically
;; save buffers?

;; A: Salve is a buffer-local minor mode, rather than being a global
;; mode.  It is activated in buffers the user wants to be saved,
;; rather than in all buffers (requiring the user to exclude ones that
;; aren't to be saved).  It uses per-buffer idle timers, rather than a
;; global timer.  It only runs a timer when a buffer is modified after
;; being saved, rather than constantly.

;; Because of these characteristics, it's simple and lightweight.  To
;; use, just, e.g. add `salv-mode' to a major mode hook.  Or, if you
;; only want it activated in certain conditions, write a simple lambda
;; to activate it when appropriate.  For example, the author uses:

;;   (add-hook 'org-mode-hook
;;             (lambda ()
;;               (when (file-in-directory-p (buffer-file-name) "~/org")
;;                 (salv-mode))))

;;; Code:

;;;; Variables

(defvar-local salv-idle-timer nil
  "Per-buffer idle timer.")

;;;; Customization

(defgroup salv nil
  "Automatically save buffer when Emacs is idle."
  :group 'convenience)

(defcustom salv-idle-seconds 5
  "Idle seconds before saving buffer."
  :type 'number)

;;;; Commands

;;;###autoload
(define-minor-mode salv-mode
  "Automatically save buffer when Emacs is idle.
When enabled in a buffer, it will be automatically saved
according to `salv-idle-seconds'."
  :lighter "Salve"
  (if salv-mode
      (progn
        (setq-local first-change-hook (cons #'salv--run-timer first-change-hook))
        (when (buffer-modified-p)
          (salv--run-timer)))
    ;; Disable mode.
    (setq-local first-change-hook (remq #'salv--run-timer first-change-hook))
    (when (equal first-change-hook (default-value 'first-change-hook))
      (kill-local-variable 'first-change-hook))
    (when salv-idle-timer
      (cancel-timer salv-idle-timer)
      (setf salv-idle-timer nil))))

;;;; Functions

(defun salv--run-timer ()
  "Run idle timer to save current buffer."
  (setf salv-idle-timer (run-with-idle-timer
                         salv-idle-seconds nil #'salv--save-buffer (current-buffer))))

(defun salv--save-buffer (buffer)
  "Save BUFFER and unset idle timer."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (save-buffer)
      (setf salv-idle-timer nil))))

;;;; Footer

(provide 'salv)

;;; salv.el ends here
