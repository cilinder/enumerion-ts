;;; enumerion-ts.el --- enumerion tree-sitter mode  -*- coding: utf-8; lexical-binding:t -*-

;; Author: Jure Taslak <jure.taslak@fmf.uni-lj.si>
;; Maintainer: Jure Taslak <jure.taslak@fmf.uni-lj.si>
;; Created: 14 October 2023
;; Version: 1.0.6
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
