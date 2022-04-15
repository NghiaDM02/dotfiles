;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

(setq doom-font (font-spec :family "Jetbrains Mono" :size 22)
     doom-variable-pitch-font (font-spec :family "Jetbrains Mono" :size 22))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(add-hook 'window-setup-hook 'toggle-frame-maximized t)

(setq company-idle-delay 0.2)
(setq company-tooltip-minimum-width 60)
(setq company-tooltip-maximum-width 60)
(setq company-tooltip-limit 12)
(setq company-minimum-prefix-length 1)
(setq company-tooltip-align-annotations t)
(setq flycheck-display-errors-delay 0.1)

(use-package java
  :ensure nil
  :after lsp-java
  :bind (:map java-mode-map ("C-c i" . lsp-java-add-import)))

(require 'company-tabnine)
(add-to-list 'company-backends #'company-tabnine)

;; workaround for company-transformers
(setq company-tabnine--disable-next-transform nil)
(defun my-company--transform-candidates (func &rest args)
  (if (not company-tabnine--disable-next-transform)
      (apply func args)
    (setq company-tabnine--disable-next-transform nil)
    (car args)))

(defun my-company-tabnine (func &rest args)
  (when (eq (car args) 'candidates)
    (setq company-tabnine--disable-next-transform t))
  (apply func args))

(advice-add #'company--transform-candidates :around #'my-company--transform-candidates)
(advice-add #'company-tabnine :around #'my-company-tabnine)
(after! company
  (setq +lsp-company-backends '(company-tabnine :separate company-capf company-yasnippet))
  (setq company-show-numbers t)
  (setq company-idle-delay 0)
)
(setq +lsp-company-backends '(company-capf company-yasnippet company-dabbrev company-dabbrev-code company-tabnine))
(setq-hook! 'rustic-mode-hook +lsp-company-backends '(company-capf company-yasnippet company-dabbrev company-dabbrev-code company-tabnine))

;; dap-mode
(use-package dap-mode
  :ensure t
  :after (lsp-mode)
  :functions dap-hydra/nil
  :config
  (require 'dap-java)
  :bind (:map lsp-mode-map
         ("<f5>" . dap-debug)
         ("M-<f5>" . dap-hydra))
  :hook ((dap-mode . dap-ui-mode)
    (dap-session-created . (lambda (&_rest) (dap-hydra)))
    (dap-terminated . (lambda (&_rest) (dap-hydra/nil)))))

(use-package dap-java :ensure nil)

(use-package lsp-java
:ensure t
:config (add-hook 'java-mode-hook 'lsp))

(use-package projectile
  :defer t
  :config
  (setq projectile-completion-system 'ivy
        projectile-enable-caching t
        projectile-use-git-grep t
        projectile-globally-ignored-file-suffixes '(".elc" ".class" ".pyc" ".o")
        projectile-ignored-projects '("~/" "/tmp")
        projectile-kill-buffers-filter 'kill-only-files
        projectile-files-cache-expire 604800 ; expire after a week
        projectile-sort-order 'recentf
        projectile-switch-project-action 'projectile-dired)
  (projectile-global-mode)
  :bind (("C-x b" . projectile-switch-to-buffer)))

;; idee config
(use-package projectile
  :config
  (setq projectile-sort-order 'recentf)
  (setq projectile-indexing-method 'hybrid)
  (setq projectile-completion-system 'ivy)
  (setq projectile-mode-line-prefix " ")
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "C-c p") #'projectile-command-map))

(setq lsp-auto-guess-root t)

;; Lsp-ui
(use-package lsp-ui
  :commands lsp-ui-mode
  :custom-face
  (lsp-ui-doc-background ((t (:background nil))))
  :config
  (with-eval-after-load 'evil
    (add-hook 'buffer-list-update-hook
              #'(lambda ()
                  (when (bound-and-true-p lsp-ui-mode)
                    (define-key evil-motion-state-local-map (kbd "K")
                      #'(lambda () (interactive) (lsp-ui-doc-glance) (ian/pulse-line)))))))
  (custom-set-faces '(lsp-ui-sideline-global ((t (:italic t)))))
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-doc-use-childframe t)
  (setq lsp-ui-doc-position 'at-point)
  (setq lsp-ui-doc-include-signature t)
  (setq lsp-ui-doc-border (face-foreground 'default))
  (setq lsp-ui-sideline-show-code-actions nil)
  (setq lsp-ui-peek-always-show t)
  (setq lsp-ui-sideline-delay 0.05))
