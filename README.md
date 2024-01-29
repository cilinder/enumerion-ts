# enumerion-ts

Emacs major mode for [Enumerion](taslak.si/Enumerion-docs) based on [tree-sitter](https://tree-sitter.github.io).

For an introduction on how to use tree-sitter in emacs see [here](https://www.masteringemacs.org/article/how-to-get-started-tree-sitter).

## Requirements:
- An emacs version 29.1+ built with tree-sitter support

## Install

### Install tree-sitter grammar

First you need to install the tree-sitter grammar for Enumerion.
Add this to your emacs config
```elisp
(setq treesit-language-source-alist
	'((enumerion "git@github.com:cilinder/tree-sitter-enumerion.git")))
```

Then install the tree-sitter grammar via `M-x treesit-install-language-grammar`,
type `enumerion` and press `RET`.

### Install major mode

You can install the major mode in emacs with
```elisp
(package-vc-install "https://github.com/cilinder/enumerion-ts")
```

Then add the following to your config
```
(require 'enumerion-ts)
```

or if you use [use-package](https://github.com/jwiegley/use-package)
```elisp
(use-package enumerion-ts)
```

Activate with `M-x enumerion-ts-mode`.

To set the mode to automatically activate with Enumerion files add this to your config

```elisp
(setq auto-mode-alist
	(append '(("\\.enum$" . enumerion-ts-mode))
		auto-mode-alist))
```


## Update

To update the package you can use the command `package-vc-upgrade` in emacs and select `enumerion-ts`.

To update the language grammar, use the command `treesit-install-language-grammar` and select `enumerion`.
