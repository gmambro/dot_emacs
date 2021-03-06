;;; init.el --- Initialization file for Emacs
;;; Commentary:
;;; Emacs Startup File --- initialization for Emacs
;;; Code:


; https://www.reddit.com/r/emacs/comments/3kqt6e/2_easy_little_known_steps_to_speed_up_emacs_start/
(setq gc-cons-threshold (* 100 1024 1024)) ;100 MB before garbage collection
(setq read-process-output-max (* 1024 1024)) ;; 1mb

(setq inhibit-splash-screen t)         ; hide welcome screen

;;----------------------------------------------------------------------
;; Paths and extra config files
;;----------------------------------------------------------------------


(push "~/.emacs.d/libs" load-path)

;; Set custom file
(setq custom-file "~/.emacs.d/custom.el")

;; (add-to-list 'load-path "~/.emacs.d/lisp/")
;; (mapc 'load (file-expand-wildcards "~/.emacs.d/init/*.el"))

;; override local stuff
(if
    (file-exists-p  "~/.emacs.d/localconfig.el")
    (load "~/.emacs.d/localconfig.el")
  )


(let (
      ( path-list  (list
                           (expand-file-name "~/.local/bin")
                           (expand-file-name "~/.cargo/bin")
                           ))
      
      )
  (setq exec-path (append exec-path path-list))
  (setenv "PATH"
          (concat (getenv "PATH") ":"
		  (mapconcat 'identity path-list ":"))
	  )
  )

                     
                     

;;----------------------------------------------------------------------

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

;; Have highlighting all the time
(global-font-lock-mode 1)

;; use spaces, not tabs for indenting
(setq-default indent-tabs-mode nil)

;; UTF8 world
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Enable/disable commands
;; TODO Review
;;(put 'downcase-region 'disabled t)
;;(put 'upcase-region 'disabled t)
;;(put 'narrow-to-region 'disabled nil)
;;(put 'eval-expression 'disabled nil)

;; Set up the visible bell instead of a beep
(setq visible-bell t)

;; want to use mouse
(xterm-mouse-mode 1)

;;keep cursor at same position when scrolling
(setq scroll-preserve-screen-position 1)

(setq show-paren-mode t)

;; view line numbers
(require 'linum)
(global-linum-mode 1)
(setq linum-format "%3d ")

;; view simpler column numbers
(column-number-mode t)

;;----------------------------------------------------------------------
;; bootstrap packages and use-package
;;----------------------------------------------------------------------

(require 'package)
(setq package-archive-priorities
   (quote
    (("org" . 15)
     ("gnu" . 10)
     ("melpa" . 5)
     ("melpa-stable" . 0)
     )))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(when (version< emacs-version "27.0") (package-initialize))
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
   (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; Auto update packages
(use-package auto-package-update
  :hook
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

;;----------------------------------------------------------------------

(global-set-key "\C-x\ \C-b" 'ibuffer)

;; Company
(use-package company
  :init
  (setq company-tooltip-align-annotations t
        company-tooltip-limit 12
        company-idle-delay 0
        company-echo-delay (if (display-graphic-p) nil 0)
        company-minimum-prefix-length 2
        company-require-match nil
        company-global-modes '(not erc-mode message-mode help-mode
                                   gud-mode eshell-mode shell-mode)
        company-backends '((company-capf)
                           (company-dabbrev-code company-keywords company-files)
                           company-dabbrev))
  )

;; Flycheck
(use-package flycheck
  :hook (prog-mode . flycheck-mode)
  )
(use-package
  flycheck-inline
  :ensure t
  :hook ('flycheck-mode-hook . #'flycheck-inline-mode)
  )

;; Ivy/Swiper
(use-package ivy
  :diminish
  :bind (
         :map ivy-minibuffer-map
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         )
  :config
  (ivy-mode 1)
  ;(setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  )
(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper))


;; Org mode
(use-package org
  :mode ("\\.org$'" . org-mode)
  :config
  (setq org-log-done 'time)
  )

;; Recentf
(global-set-key "\C-x\ \C-r" 'recentf-open-files)
(setq
 recentf-max-saved-items 500
 recentf-max-menu-items 15
 ;; disable recentf-cleanup on Emacs start, because it can cause
 ;; problems with remote files
 recentf-auto-cleanup 'never)
(recentf-mode +1)

;; Treemacs
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))


;; Which key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))


;; Yasnippet
(use-package yasnippet)


;; VCS stuff
(use-package magit)
;(use-package monky)
(use-package treemacs-magit)


;;----------------------------------------------------------------------
;; Languages
;;----------------------------------------------------------------------

;; LaTeX
(use-package tex
  :ensure auctex
  :mode
  ("\\.tex\\'" . latex-mode)
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  
  (add-hook 'LaTeX-mode-hook 'auto-fill-mode)
  (add-hook 'LaTeX-mode-hook 'flyspell-mode)
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode) 
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  ;;(setq reftex-plug-into-AUCTeX t)
)


;; Rust
(setenv "RUST_LOG" "rls=debug")
(use-package rust-mode
  :config
  (setq rust-format-on-save t)
  )
(use-package flycheck-rust
  :hook ('flycheck-mode-hook . #'flycheck-rust-setup)
  )
(use-package cargo :hook (rust-mode . cargo-minor-mode))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :hook ('markdown-mode-hook . #'outline-minor-mode)
  :init (setq markdown-command "multimarkdown"))


;; Toml
(use-package toml-mode )

;; Perl
(defalias 'perl-mode 'cperl-mode)
;; Use 4 space indents via cperl mode
(setq
 cperl-close-paren-offset -4
 cperl-continued-statement-offset 4
 cperl-indent-level 4
 cperl-indent-parens-as-block t
 cperl-tab-always-indent t)


;; Python
(use-package python )
(use-package python-mode )
(use-package python-django)
(use-package python-environment )

;; Puppet
(use-package puppet-mode  :mode "\\.pp$")

;; Template Toolkit
(use-package tt-mode
  :mode "\\.tt$")

;; YAML
(use-package yaml-mode :ensure t)

;; LSP mode

(use-package lsp-mode
  :hook
  (rust-mode . lsp)
  :commands (lsp)
  :init
  (setq
    lsp-keymap-prefix "C-c l"
    lsp-enable-xref t
    lsp-completion-enable t
    lsp-enable-snippet t
   )
)
(use-package lsp-ui
  :after lsp-mode
  :diminish
  :commands lsp-ui-mode
  :bind
  (:map lsp-ui-mode-map
        ([remap xref-find-definitions] . lsp-ui-peek-find-definitions) ; M-.
        ([remap xref-find-references] . lsp-ui-peek-find-references) ; M-?
        ("C-c u" . lsp-ui-imenu)
        ("M-i" . lsp-ui-doc-focus-frame))
  :custom
  (lsp-ui-peek-enable t)
  (lsp-ui-sideline-enable t)
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-delay 1)
  (lsp-ui-doc-header t)
  )
(use-package lsp-treemacs)


;;----------------------------------------------------------------------
(ignore-errors
  (load-theme 'spacemacs-dark t))
;;(setq spacemacs-theme-org-agenda-height nil)
;;(setq spacemacs-theme-org-height nil)
;; My previous theme (load-theme 'wombat)

;;----------------------------------------------------------------------
(when (eq system-type 'darwin)
  (global-set-key  (kbd "<end>") 'end-of-line)
  (global-set-key  (kbd "<home>") 'beginning-of-line)
  )

(setq mac-option-modifier nil)

;; Custom shortcuts
(global-set-key [(f1)]
                (lambda (s e)
                  (interactive "r")
                  (manual-entry (buffer-substring s e))
                ))
(global-set-key [(f5)] 'goto-line)

(defun run-cmd (file)
  (interactive "sCommand name: ")
  (if (not (zerop (call-process file nil "* Test *")))
      (print "error")))


;;----------------------------------------------------------------------

(ignore-errors
  (server-start))


;;; init.el ends here
