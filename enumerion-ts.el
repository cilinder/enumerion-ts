;;; enumerion-ts.el --- enumerion tree-sitter mode  -*- coding: utf-8; lexical-binding:t -*-

;; Author: Jure Taslak <jure.taslak@fmf.uni-lj.si>
;; Maintainer: Jure Taslak <jure.taslak@fmf.uni-lj.si>
;; Created: 14 October 2023
;; Version: 1.0.8
;; Package-Requires: ((emacs "29.1"))
;; Keywords: enumerion tree-sitter
;; Homepage: https://github.com/cilinder/enumerion-ts

;; This file is *NOT* part of GNU Emacs.

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
;; Major mode for editing Enumerion files based on tree-sitter.
;; Also provides repl mode for Enumerion. To use it set `enumerion-repl-send-region`
;; to the value of the Enumerion executable.

;;; Installation:
;;
;; TODO

;;; Usage:
;;
;; TODO

;;; Code:


(defvar enumerion-ts-font-lock-rules
  '(:language
    enumerion
    :override t
    :feature comment
    ((comment) @font-lock-comment-face)

    :language enumerion
    :override t
    :feature toplevel
    ((load) @font-lock-keyword-face
     (definition) @font-lock-keyword-face
     (check) @font-lock-keyword-face
     (enumerate) @font-lock-keyword-face
     (eval) @font-lock-keyword-face
     (axiom) @font-lock-keyword-face
     (clear) @font-lock-keyword-face)

    :language enumerion
    :override t
    :feature type
    ((nat) @font-lock-type-face
     (fin) @font-lock-type-face
     (prop) @font-lock-type-face
     (finite) @font-lock-type-face
     (theory_type) @font-lock-type-face
     (enum) @font-lock-type-face
     (prod) @font-lock-type-face
     (exists) @font-lock-type-face
     (forall) @font-lock-type-face
     (theory) @font-lock-type-face
     (structure) @font-lock-type-face
     (variant) @font-lock-type-face)

    :language enumerion
    :override t
    :feature keyword
    ((fun) @font-lock-keyword-face
     (match) @font-lock-keyword-face
     (with_keyword) @font-lock-keyword-face
     (size) @font-lock-keyword-face
     (begin) @font-lock-keyword-face
     (end) @font-lock-keyword-face)

    :language enumerion
    :override t
    :feature constant
    ((true_const) @font-lock-constant-face
     (false_const) @font-lock-constant-face)

    :language enumerion
    :override t
    :feature backtick
    ((backtick) @font-lock-delimiter-face)

    :language enumerion
    :override t
    :feature delimiter
    ((colon) @font-lock-delimiter-face
     (comma) @font-lock-delimiter-face
     (coloneq) @font-lock-delimiter-face
     (vbar) @font-lock-delimiter-face
     (period) @font-lock-delimiter-face)

    :language enumerion
    :feature operator
    ((arrow) @font-lock-operator-face
     (darrow) @font-lock-delimiter-face
     (lor) @font-lock-delimiter-face
     (land) @font-lock-delimiter-face
     (neg) @font-lock-delimiter-face
     (lt) @font-lock-delimiter-face
     (leq) @font-lock-delimiter-face
     (equal) @font-lock-delimiter-face
     (plus) @font-lock-delimiter-face
     (minus) @font-lock-delimiter-face
     (times) @font-lock-delimiter-face
     (divide) @font-lock-delimiter-face
     (pow) @font-lock-delimiter-face)
    
    :language enumerion
    :override t
    :feature bracket
    ((lparen) @font-lock-bracket-face
     (rparen) @font-lock-bracket-face
     (lbrace) @font-lock-bracket-face
     (rbrace) @font-lock-bracket-face)
    
    :language enumerion
    :override t
    :feature numeral
    ((numeral) @font-lock-number-face)
    )
  )

(defun enumerion-ts-setup ()
  "Setup treesit for Enumerion-ts-mode."
  ;; Our tree-sitter setup goes here.

  (setq-local treesit-font-lock-feature-list
              '((comment toplevel)
                (type keyword)
                (numeral backtick constant operator)
		(delimiter bracket)))

  (setq-local treesit-font-lock-settings
              (apply #'treesit-font-lock-rules
                     enumerion-ts-font-lock-rules))
  ;; Set up indentation rules for enumerion
  (setq-local treesit-simple-indent-rules
	    `((enumerion
	       ((parent-is "source_file") parent-bol 0)
	       ((match "rbrace" "structure_expr" nil nil nil) grand-parent 0)
	       ((match "lbrace" "structure_expr" nil nil nil) grand-parent 0)
	       ((parent-is "structure_expr") parent 2)
		(no-node parent 0))))

  (defvar enumerion-ts-mode-map
    (let ((map (make-sparse-keymap)))
    ;; example definition
    (define-key map "\t" 'completion-at-point)
    (define-key map "\C-c\C-p" #'enumerion-repl)
    (define-key map "\C-c\C-r" #'enumerion-repl-send-region)
    (define-key map "\C-c\C-s" #'enumerion-repl-send-string)
    (define-key map "\C-c\C-e" #'enumerion-repl-send-statement)
    map)
    "Basic mode map for `enumerion-repl'.")

(defvar-local enumerion-ts--overlays (make-hash-table :test #'eq))
  
(defun enumerion-ts--find-overlay-at-point (point)
  "Find any overlay in tsm/-overlays containing POINT."
  (seq-find (lambda (o) (gethash o enumerion-ts--overlays)) (overlays-at point)))

(defun enumerion-ts--overlay-at-node (node)
  "Create overlay of NODE and add to `enumerion-ts--overlays'"
  (let ((overlay (make-overlay (treesit-node-start node) (treesit-node-end node))))
    (overlay-put overlay 'face 'lazy-highlight)
    (overlay-put overlay 'evaporate t)
    (overlay-put overlay 'node node)
    ; Emacs documentation says integer must be nonnegative, but -1 seems to work...
    ; (i.e. puts it below multiple-cursors region overlay)
    (overlay-put overlay 'priority '(nil . -1))
    (puthash overlay overlay enumerion-ts--overlays)
    overlay))

(defun enumerion-ts--overlay-at-point (point)
  "Get overlay at POINT, or make one and add to `enumerion-ts--overlays' if it does not exist."
  (or (enumerion-ts--find-overlay-at-point point)
      (enumerion-ts--overlay-at-node (treesit-node-on point point))))

(defun enumerion-ts-node-parent (point)
  "Select parent of indicated node at POINT."
  (interactive "d")
  (let* ((overlay (enumerion-ts--overlay-at-point point))
         (node (overlay-get overlay 'node))
         (next (treesit-node-parent node)))
    (when next
      (overlay-put overlay 'node next)
      (move-overlay overlay (treesit-node-start next) (treesit-node-end next)))))

  ;;;###autoload
(define-derived-mode enumerion-ts-mode prog-mode "enumerion[ts]"
  "Major mode for editing Enumerion files with tree-sitter"
  (setq-local font-lock-defaults nil)
  (when (treesit-ready-p 'enumerion)
    (treesit-parser-create 'enumerion)
    (enumerion-ts-setup)))

;;; ######################################################
;;; End of treesitter things.
;;; Begnning of Enumerion REPL things.
;;; ######################################################

(defcustom enumerion-repl-file-path "enumerion.exe"
  "Path to the program used by `enumerion-repl'")

(defvar enumerion-repl-cli-arguments '()
  "Commandline arguments to pass to `enumerion-repl'.")

(defvar enumerion-repl-mode-map
  (let ((map (nconc (make-sparse-keymap) comint-mode-map)))
    ;; example definition
    (define-key map "\t" 'completion-at-point)
    map)
  "Basic mode map for `enumerion-repl'.")

;; (defvar enumerion-repl-prompt-regexp "^\\(?:\\[[^@]+@[^@]+\\]\\)"
;;   "Prompt for `enumerion-repl'.")

(defvar enumerion-repl-prompt-regexp "#"
  "Prompt for `enumerion-repl'.")


(defvar enumerion-repl-buffer-name "*Enumerion*"
  "Name of the buffer to use for the `enumerion-repl' comint instance.")

(defun enumerion-repl ()
  "Run an inferior instance of `enumerion' inside Emacs."
  (interactive)
  (let* ((enumerion-program enumerion-repl-file-path)
         (buffer (get-buffer-create enumerion-repl-buffer-name))
         (proc-alive (comint-check-proc buffer))
         (process (get-buffer-process buffer)))
    ;; if the process is dead then re-create the process and reset the
    ;; mode.
    (unless proc-alive
      (with-current-buffer buffer
        (apply 'make-comint-in-buffer "Enumerion" buffer
               enumerion-program nil enumerion-repl-cli-arguments)
        (enumerion-repl-mode)))
    ;; Regardless, provided we have a valid buffer, we pop to it.
    (when buffer
      (pop-to-buffer buffer))))

(defun enumerion--initialize ()
  "Helper function to initialize Enumerion."
  (setq comint-process-echoes t)
  (setq comint-use-prompt-regexp t))

(define-derived-mode enumerion-repl-mode comint-mode "Enumerion"
  "Major mode for `enumerion'.

\\<enumerion-repl-mode-map>"
  ;; this sets up the prompt so it matches things like: [foo@bar]
  (setq comint-prompt-regexp enumerion-repl-prompt-regexp)
  ;; this makes it read only; a contentious subject as some prefer the
  ;; buffer to be overwritable.
  (setq comint-prompt-read-only t)
  ;; this makes it so commands like M-{ and M-} work.
  (set (make-local-variable 'paragraph-separate) "\\'")
  (set (make-local-variable 'font-lock-defaults) '(enumerion-font-lock-keywords t))
  (set (make-local-variable 'paragraph-start) enumerion-repl-prompt-regexp))

(add-hook 'enumerion-repl-mode-hook 'enumerion--initialize)

(defconst enumerion-keywords
  '("check" "def" "eval" "enumerate" "load")
  "List of keywords to highlight in `enumerion-font-lock-keywords'.")

(defvar enumerion-font-lock-keywords
  (list
   ;; highlight all the reserved commands.
   `(,(concat "\\_<" (regexp-opt enumerion-keywords) "\\_>") . font-lock-keyword-face))
  "Additional expressions to highlight in `enumerion-mode'.")

(defun enumerion-repl-get-process-name (dedicated)
  "Calculate the appropriate process name for inferior Enumerion process.
If DEDICATED is nil, this is simply `enumerion-repl-buffer-name'.
If DEDICATED is `buffer' or `project', append the current buffer
name respectively the current project name."
  (pcase dedicated
    ('nil enumerion-repl-buffer-name)
    ('project
     (if-let ((proj (and (featurep 'project)
                         (project-current))))
         (format "%s[%s]" enumerion-repl-buffer-name (file-name-nondirectory
                                                    (directory-file-name
                                                     (project-root proj))))
       enumerion-repl-buffer-name))
    (_ (format "%s[%s]" enumerion-repl-buffer-name (buffer-name)))))

(defun enumerion-repl-get-buffer ()
  "Return inferior Enumerion buffer for current buffer.
If current buffer is in `enumerion-repl-mode', return it."
  (if (derived-mode-p 'enumerion-repl-mode)
      (current-buffer)
    (seq-some
     (lambda (dedicated)
       (let* ((proc-name (enumerion-repl-get-process-name dedicated)))
         (when (comint-check-proc proc-name)
           proc-name)))
     '(buffer project nil))))

(defun enumerion-repl-get-process ()
  "Return inferior Enumerion process for current buffer."
  (get-buffer-process (enumerion-repl-get-buffer)))

(defun enumerion-repl-get-process-or-error (&optional interactivep)
  "Return inferior Enumerion process for current buffer or signal error.
When argument INTERACTIVEP is non-nil, use `user-error' instead
of `error' with a user-friendly message."
  (or (enumerion-repl-get-process)
      (if interactivep
          (user-error
           (substitute-command-keys
            "Start an Enumerion process first with \\`M-x enumerion-repl' or `%s'")
           ;; Get the binding.
           (key-description
            (where-is-internal
             #'enumerion-repl overriding-local-map t)))
        (error "No inferior Enumerion process running"))))

(defun enumerion-repl--save-temp-file (string)
  (let* ((temporary-file-directory
          (if (file-remote-p default-directory)
              (concat (file-remote-p default-directory) "/tmp")
            temporary-file-directory))
         (temp-file-name (make-temp-file "py"))
         (coding-system-for-write (enumerion-info-encoding)))
    (with-temp-file temp-file-name
      (if (bufferp string)
          (insert-buffer-substring string)
        (insert string))
      (delete-trailing-whitespace))
    temp-file-name))

(defun enumerion-repl-send-string (string &optional process msg)
  "Send STRING to inferior Enumerion PROCESS.
When optional argument MSG is non-nil, forces display of a
user-friendly message if there's no process running; defaults to
t when called interactively."
  (interactive
   (list (read-string "Enumerion command: ") nil t))
  (let ((process (or process (enumerion-repl-get-process-or-error msg)))
        (code (concat string "\n")))
    (unless enumerion-repl-output-filter-in-progress
      (with-current-buffer (process-buffer process)
        (save-excursion
          (goto-char (process-mark process))
          (insert-before-markers "\n"))))
    (if (or (null (process-tty-name process))
            (<= (string-bytes code)
                (or (bound-and-true-p comint-max-line-length)
                    1024))) ;; For Emacs < 28
        (comint-send-string process code)
      (error "error sending string to inferior Enumerion process"))))

(defun enumerion-repl-send-region (start end &optional send-main msg
                                       no-cookie)
  "Send the region delimited by START and END to inferior Enumerion process.
When optional argument MSG is non-nil, forces display of a
user-friendly message if there's no process running; defaults to
t when called interactively.  The substring to be sent is
retrieved using `enumerion-shell-buffer-substring'."
  (interactive
   (list (region-beginning) (region-end) current-prefix-arg t))
  (let* ((string (buffer-substring start end))
         (process (enumerion-repl-get-process-or-error msg))
         (original-string (buffer-substring-no-properties start end)))
    (message "Sent: %s..." (substring original-string 0 (min 20 (length original-string))))
    ;; Recalculate positions to avoid landing on the wrong line if
    ;; lines have been removed/added.
    (with-current-buffer (process-buffer process)
      (insert string)
      (comint-send-input))
        (deactivate-mark)))

  ;; (treesit-node-type (treesit-node-parent (treesit-node-parent (treesit-node-parent (treesit-node-at (point))))))

(defun enumerion-ts-find-toplevel ()
  "Find the toplevel ancestor of the current node at point."
  (setq current-node (treesit-node-at (point)))
  (if (treesit-node-p current-node)
      (progn
	(while (not (equal (treesit-node-type current-node) "toplevel"))
	  (setq current-node (treesit-node-parent current-node))
	  )
	current-node
	)
    (error "Error: no node found at point")))
  
(defun enumerion-repl-send-statement ()
  "Send the current toplevel statement that point is on to an inferior Enumerion process."
  (interactive)
   (let* ((node (enumerion-ts-find-toplevel))
	  (string (treesit-node-text node t))
	  (process (enumerion-repl-get-process-or-error)))
   (with-current-buffer (process-buffer process)
     (insert string)
     (comint-send-input))))

(defvar enumerion-repl-output-filter-in-progress nil)
(defvar enumerion-repl-output-filter-buffer nil)

(defun enumerion-info-encoding ()
  "Return encoding for file.
default to utf-8."
  ;; If no encoding is defined, then it's safe to use UTF-8.
  'utf-8)

;; End with this
(treesit-major-mode-setup))

(provide 'enumerion-ts)

;;; enumerion-ts.el ends here
