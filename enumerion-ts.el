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
    ((check) @font-lock-builtin-face)

    :language enumerion
    :override t
    :feature type
    ((nat) @font-lock-type-face
     (fin) @font-lock-type-face
     (finite) @font-lock-type-face
     (enum) @font-lock-type-face
     (prod) @font-lock-type-face
     )

    :language enumerion
    :override t
    :feature keyword
    ((lambda) @font-lock-keyword-face)

    :language enumerion
    :override t
    :feature delimiter
    ((colon) @font-lock-delimiter-face
     (comma) @font-lock-delimiter-face)

    :language enumerion
    :override t
    :feature operator
    ((arrow) @font-lock-operator-face
     (darrow) @font-lock-delimiter-face)
    
    :language enumerion
    :override t
    :feature bracket
    ((lparen) @font-lock-bracket-face
     (rparen) @font-lock-bracket-face)
    
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
                (numeral)
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
