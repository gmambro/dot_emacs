;;; init.el --- Initialization file for Emacs
;;; Commentary:
;;; Emacs Startup File --- initialization for Emacs
;;; Code:


; https://www.reddit.com/r/emacs/comments/3kqt6e/2_easy_little_known_steps_to_speed_up_emacs_start/
(setq gc-cons-threshold (* 100 1024 1024)) ;100 MB before garbage collection
(setq read-process-output-max (* 1024 1024)) ;; 1mb



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


(setq exec-path (append exec-path '( (expand-file-name  "~/.local/bin")
                                     (expand-file-name "~/.cargo/bin"))))

;;----------------------------------------------------------------------

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

;;----------------------------------------------------------------------
;; bootstrap packages and use-package
;;----------------------------------------------------------------------

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

;;----------------------------------------------------------------------

;; Company
(use-package company)
;  :after lsp-mode
;  :hook (lsp-mode . company-mode)
;  :bind (:map company-active-map
;         ("<tab>" . company-complete-selection))
;        (:map lsp-mode-map
;         ("<tab>" . company-indent-or-complete-common))
;  :custom
;  (company-minimum-prefix-length 1)
;  (company-idle-delay 0.0))
(use-package company-box
  :hook (company-mode . company-box-mode))

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
  )

;; Recentf
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
(use-package monky)
(use-package treemacs-magit)


;;----------------------------------------------------------------------
;; Languages
;;----------------------------------------------------------------------

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


;; LSP mode

(use-package lsp-mode
  :commands lsp lsp-deferred
  :hook
  ;(python-mode . lsp)
  (rust-mode . lsp-deferred)
  :init
  (setq
   lsp-keymap-prefix "\C-c l"
   lsp-enable-file-watchers nil
   lsp-enable-xref t
   lsp-prefer-capf t
   lsp-completion-enable t
   lsp-idle-delay 0.500
   )
   )
(use-package lsp-ui :init (setq  lsp-ui-doc-enable t))
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

;;----------------------------------------------------------------------
(ignore-errors
  (server-start))

;;----------------------------------------------------------------------
(ignore-errors
  (load-theme 'spacemacs-dark t))
;;(setq spacemacs-theme-org-agenda-height nil)
;;(setq spacemacs-theme-org-height nil)
;; My previous theme (load-theme 'wombat)


;;; init.el ends here
