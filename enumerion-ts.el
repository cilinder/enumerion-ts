;;; enumerion-ts.el --- enumerion tree-sitter mode  -*- coding: utf-8; lexical-binding:t -*-

;; Author: Jure Taslak <jure.taslak@fmf.uni-lj.si>
;; Maintainer: Jure Taslak <jure.taslak@fmf.uni-lj.si>
;; Created: 14 October 2023
;; Version: 1.0.2
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
;; Major mode for editing Enumerion files based on tree-sitter

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
    ((load) @font-lock-builtin-face
     (definition) @font-lock-builtin-face
     (check) @font-lock-builtin-face
     (compile) @font-lock-builtin-face
     (eval) @font-lock-builtin-face
     (axiom) @font-lock-builtin-face
     (clear) @font-lock-builtin-face)

    :language enumerion
    :override t
    :feature type
    ((nat) @font-lock-type-face
     (fin) @font-lock-type-face
     (finite) @font-lock-type-face
     (enum) @font-lock-type-face
     (prod) @font-lock-type-face
     (exists) @font-lock-type-face
     (forall) @font-lock-type-face
     (stream) @font-lock-type-face
     (structure) @font-lock-type-face
     (variant) @font-lock-type-face
     )

    :language enumerion
    :override t
    :feature keyword
    ((lambda) @font-lock-keyword-face
     (match) @font-lock-keyword-face
     (with) @font-lock-keyword-face
     (size) @font-lock-keyword-face
     (enumerate) @font-lock-keyword-face
     (begin) @font-lock-keyword-face
     (end) @font-lock-keyword-face
     )

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
    :override t
    :feature operator
    ((arrow) @font-lock-operator-face
     (darrow) @font-lock-delimiter-face
     (lor) @font-lock-delimiter-face
     (land) @font-lock-delimiter-face
     (not) @font-lock-delimiter-face
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
    ((number) @font-lock-number-face)
    )
  )

(defun enumerion-ts-setup ()
  "Setup treesit for Enumerion-ts-mode."
  ;; Our tree-sitter setup goes here.

  (setq-local treesit-font-lock-feature-list
              '((comment toplevel)
                (type keyword)
                (numeral backtick constant)
		(delimiter bracket)))

  (setq-local treesit-font-lock-settings
              (apply #'treesit-font-lock-rules
                     enumerion-ts-font-lock-rules))

  ;; End with this
  (treesit-major-mode-setup))

  ;;;###autoload
(define-derived-mode enumerion-ts-mode prog-mode "enumerion[ts]"
  "Major mode for editing Enumerion files with tree-sitter"
  (setq-local font-lock-defaults nil)
  (when (treesit-ready-p 'enumerion)
    (treesit-parser-create 'enumerion)
    (enumerion-ts-setup)))


(provide 'enumerion-ts)

;;; enumerion-ts.el ends here
