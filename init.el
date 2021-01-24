;;; init.el --- Initialization file for Emacs
;;; Commentary:
;;; Emacs Startup File --- initialization for Emacs
;;; Code:


(push "~/.emacs.d/libs" load-path)

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
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

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

(use-package org :ensure t
  :mode ("\\.org$'" . org-mode)
  )

(use-package recentf :ensure t)

(use-package rust-mode :ensure t)
(use-package
  flycheck-rust
  :hook ('flycheck-mode-hook . #'flycheck-rust-setup)
  :config
  (setq rust-format-on-save t)
  )
(use-package toml-mode :ensure t)
(use-package cargo
  :hook (rust-mode . cargo-minor-mode))

(use-package lsp-mode
  :hook
  (python-mode . lsp)
  :commands lsp
  :config
  (setq lsp-enable-file-watchers nil)
  (setq lsp-rust-rls-server-command (quote ("/home/gmambro/.cargo/bin/rls")))
  (setq lsp-rust-clear-env-rust-log nil)
  )

(use-package lsp-ui :ensure t :commands lsp-ui-mode)
(use-package company-lsp :ensure t :commands company)


(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :hook ('markdown-mode-hook . #'outline-minor-mode)
  :init (setq markdown-command "multimarkdown"))


;; view line numbers
(require 'linum)
(global-linum-mode 1)
(setq linum-format "%3d ")

;; view simpler column numbers
(column-number-mode t)

;; switch multiple buffer with typeahead using C-x b
(require 'ido)
(global-set-key (kbd "C-x C-b") 'ibuffer)

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)


(load-theme 'spacemacs-dark t)
;;(setq spacemacs-theme-org-agenda-height nil)
;;(setq spacemacs-theme-org-height nil)
;; My previous theme (load-theme 'wombat)

;;; init.el ends here

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(swiper spacemacs-theme ivy auto-package-update cargo markdown-mode flycheck-inline flycheck-inline-mode use-package flycheck-rust rust-mode))
 '(show-paren-mode t)
 '(tramp-default-host "devvm940.lla0")
 '(tramp-default-method "sshx")
 '(tramp-default-user "gmambro"))


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
