;;; hov.el --- Local minor mode to save a buffer when Emacs is idle  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Adam Porter

;; Author: Adam Porter <adam@alphapapa.net>
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

;; Hovel, v. t.  To put in a hovel; to shelter.

;;; Code:

;;;; Variables

(defvar-local hov-idle-timer nil
  "Per-buffer idle timer.")

;;;; Customization

(defgroup hov nil
  "Automatically save buffer when Emacs is idle for so many seconds."
  :group 'convenience)

(defcustom hov-idle-duration 5
  "Automatically save buffer when Emacs is idle this many seconds."
  :type 'number)

;;;; Commands

(define-minor-mode hov-mode
  "Automatically save buffer when Emacs is idle for so many seconds.
When enabled in a buffer, it will be automatically saved
according to `hov-idle-duration'."
  :lighter "Hovel"
  (if hov-mode
      (progn
        (setq-local first-change-hook (cons #'hov--run-timer first-change-hook))    
        (when (buffer-modified-p)
          (hov--run-timer)))
    ;; Disable mode.
    (setq-local first-change-hook (remq #'hov--run-timer first-change-hook))
    (when hov-idle-timer
      (cancel-timer hov-idle-timer)
      (setf hov-idle-timer nil))))

;;;; Functions

(defun hov--run-timer ()
  "Run idle timer to save current buffer."
  (setf hov-idle-timer (run-with-idle-timer
                        hov-idle-duration nil #'hov--save-buffer (current-buffer))))

(defun hov--save-buffer (buffer)
  "Save BUFFER and unset idle timer."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (save-buffer)
      (setf hov-idle-timer nil))))

;;;; Footer

(provide 'hov)

;;; hov.el ends here
