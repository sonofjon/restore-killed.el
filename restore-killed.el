;;; restore-killed.el --- Restore killed buffers and files -*- lexical-binding: t; -*-
;;
;; Author: Andreas Jonsson <ajdev8@gmail.com>
;; Maintainer: Andreas Jonsson <ajdev8@gmail.com>
;; URL: https://github.com/sonofjon/restore-killed.el
;; Version: 0.1
;; Package-Requires: ((emacs "26.1"))
;; Keywords: convenience
;;
;;; Commentary:
;;
;; Utilities to restore killed file buffers and non-file buffers.
;;
;; This package provides commands to undo killing buffers by maintaining a
;; list of recently killed files and non-file buffers.  You can restore the
;; most recently killed buffer/file or select from a list.
;;
;; For file buffers, only the file path is stored.  For non-file buffers
;; (e.g., scratch buffers, temporary buffers), the buffer name and contents
;; are stored up to a configurable size limit.
;;
;; Provides:
;;  - restore-killed-mode (minor mode to enable tracking)
;;  - restore-killed-file
;;  - restore-killed-file-select
;;  - restore-killed-buffer
;;  - restore-killed-buffer-select
;;
;; Usage:
;;
;;   (use-package restore-killed
;;     :load-path "/path/to/restore-killed"
;;     :config
;;     ;; Enable the minor mode to track killed buffers
;;     (restore-killed-mode 1))
;;
;;; Code:

(defgroup restore-killed nil
  "Restore killed buffers and files."
  :group 'convenience
  :prefix "restore-killed-")

;;; Undo for killed file buffers

(defvar restore-killed-file-list nil
  "List of recently killed files.")

(defcustom restore-killed-file-max 10
  "Maximum number of killed files to store."
  :type 'integer
  :group 'restore-killed)

(defun restore-killed--file-save ()
  "Save the file path of the current buffer to `restore-killed-file-list'.
Only save content if the buffer is associated with a filename."
  (when buffer-file-name
    (push buffer-file-name restore-killed-file-list)
    (when (> (length restore-killed-file-list) restore-killed-file-max)
      (setq restore-killed-file-list
            (cl-subseq restore-killed-file-list
                       0 restore-killed-file-max)))))

;;;###autoload
(defun restore-killed-file ()
  "Restore the most recently killed file, if one exists."
  (interactive)
  (when restore-killed-file-list
    (find-file (pop restore-killed-file-list))))

;;;###autoload
(defun restore-killed-file-select ()
  "Pick a file to restore from files killed during this session."
  (interactive)
  (if restore-killed-file-list
      (let ((file (completing-read "Restore killed file: "
                                   restore-killed-file-list
                                   nil nil nil nil
                                   (car restore-killed-file-list))))
        (when file
          (setq restore-killed-file-list
                (cl-delete file restore-killed-file-list :test #'equal))
          (find-file file)))
    (user-error "No recently-killed files to reopen")))

;;; Undo for killed non-file buffers

(defvar restore-killed-buffer-list nil
  "List of recently killed non-file buffers.
Each element is a cons cell (buffer-name . buffer-contents).")

(defcustom restore-killed-buffer-max-size 10000
  "Maximum size of non-file buffer (in characters) to store."
  :type 'integer
  :group 'restore-killed)

(defcustom restore-killed-buffer-max 10
  "Maximum number of killed non-file buffers to store."
  :type 'integer
  :group 'restore-killed)

(defun restore-killed--buffer-save ()
  "Save buffer name and content to `restore-killed-buffer-list'.
Only save content if the buffer is not associated with a filename."
  (unless buffer-file-name
    (when (<= (buffer-size) restore-killed-buffer-max-size)
      (push (cons (buffer-name) (buffer-string))
            restore-killed-buffer-list)
      (when (> (length restore-killed-buffer-list)
               restore-killed-buffer-max)
        (setq restore-killed-buffer-list
              (cl-subseq restore-killed-buffer-list
                         0 restore-killed-buffer-max))))))

;;;###autoload
(defun restore-killed-buffer ()
  "Restore the most recently killed non-file buffer, if one exists.
Note, this does not include window properties etc."
  (interactive)
  (if (null restore-killed-buffer-list)
      (user-error "No recently killed non-file buffer to reopen")
    (let* ((buffer-entry (pop restore-killed-buffer-list))
           (buffername (car buffer-entry))
           (contents (cdr buffer-entry)))
      (switch-to-buffer (get-buffer-create buffername))
      (insert contents))))

;;;###autoload
(defun restore-killed-buffer-select ()
  "Pick a buffer to restore from non-file buffers killed during this session."
  (interactive)
  (if restore-killed-buffer-list
      (let* ((buffer-names (mapcar #'car
                                   restore-killed-buffer-list))
             (buffername (completing-read "Restore killed buffer: "
                                          buffer-names
                                          nil nil nil nil
                                          (car buffer-names))))
        (when buffername
          (let ((buffer-entry (assoc buffername
                                     restore-killed-buffer-list)))
            (when buffer-entry
              (setq restore-killed-buffer-list
                    (cl-delete buffer-entry
                               restore-killed-buffer-list
                               :test #'equal))
              (switch-to-buffer (get-buffer-create (car buffer-entry)))
              (insert (cdr buffer-entry))))))
    (user-error "No recently-killed non-file buffers to reopen")))

;;; Minor mode

;;;###autoload
(define-minor-mode restore-killed-mode
  "Toggle restore-killed mode.
When enabled, track killed buffers and files so they can be restored
later using `restore-killed-file' and `restore-killed-buffer' commands."
  :global t
  :lighter " RK"
  :group 'restore-killed
  (if restore-killed-mode
      (progn
        (add-hook 'kill-buffer-hook #'restore-killed--file-save)
        (add-hook 'kill-buffer-hook #'restore-killed--buffer-save))
    (remove-hook 'kill-buffer-hook #'restore-killed--file-save)
    (remove-hook 'kill-buffer-hook #'restore-killed--buffer-save)))

(provide 'restore-killed)
;;; restore-killed.el ends here
