;;; init.el --- Initialization file for Emacs
;;; Commentary:
;;; Emacs Startup File --- initialization for Emacs
;;; Code:


; https://www.reddit.com/r/emacs/comments/3kqt6e/2_easy_little_known_steps_to_speed_up_emacs_start/
(setq gc-cons-threshold (* 100 1024 1024)) ;100 MB before garbage collection
(setq read-process-output-max (* 1024 1024)) ;; 1mb

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


(setq exec-path (append exec-path '( (expand-file-name  "~/.local/bin")
                                     (expand-file-name "~/.cargo/bin"))))


;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

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

;; switch multiple buffer with typeahead using C-x b
(require 'ido)
(global-set-key (kbd "C-x C-b") 'ibuffer)

(push "/Users/gmambro/.cargo/bin" exec-path)

;; bootstrap packages and use-package
(require 'package)
(setq package-archive-priorities
   (quote
    (("org" . 15)
     ("gnu" . 10)
     ("melpa-stable" . 5)
     ("melpa" . 0))))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)
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
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  )

(use-package swiper
  :config
  (global-set-key "\C-s" 'swiper))


(use-package flycheck
  :hook (prog-mode . flycheck-mode)
  )

(use-package company
  :hook (prog-mode . company-mode)
  :config (setq company-tooltip-align-annotations t)
          (setq company-minimum-prefix-length 1))

;(use-package
;  flycheck-inline
;  :ensure t
;  :hook ('flycheck-mode-hook . #'flycheck-inline-mode)
;  )

(use-package org
  :mode ("\\.org$'" . org-mode)
  )

(use-package recentf)

(global-set-key "\C-x\ \C-r" 'recentf-open-files)
(use-package recentf
  :config
  (setq
        recentf-max-saved-items 500
        recentf-max-menu-items 15
        ;; disable recentf-cleanup on Emacs start, because it can cause
        ;; problems with remote files
        recentf-auto-cleanup 'never)
  (recentf-mode +1))

(use-package toml-mode )

(setenv "RUST_LOG" "rls=debug")
(use-package rust-mode
  :config
  (setq rust-format-on-save t)
  )
(use-package
  flycheck-rust
  :hook ('flycheck-mode-hook . #'flycheck-rust-setup)
  )
(use-package cargo
  :hook (rust-mode . cargo-minor-mode))
(use-package flycheck-rust
  :config (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package yasnippet)

(use-package lsp-mode
  :hook
  (python-mode . lsp)
  (rust-mode . lsp)
  :commands lsp
  :config
  (setq lsp-enable-file-watchers nil)
  (setq lsp-rust-clear-env-rust-log nil)
  (setq lsp-prefer-capf t)
  (setq lsp-completion-enable t)
  (setq lsp-idle-delay 0.500)
  )
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-ui  :commands lsp-ui-mode)
(use-package company-lsp :commands company)

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :hook ('markdown-mode-hook . #'outline-minor-mode)
  :init (setq markdown-command "multimarkdown"))


;; VCS stuff
(use-package magit)
(use-package monky)
(use-package treemacs-magit)

(ignore-errors
  (server-start))

(ignore-errors
  (load-theme 'spacemacs-dark t))
;;(setq spacemacs-theme-org-agenda-height nil)
;;(setq spacemacs-theme-org-height nil)
;; My previous theme (load-theme 'wombat)


;;; init.el ends here
