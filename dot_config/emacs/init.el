;;;; init.el --- Minimal startup file -*- lexical-binding: t; -*-

;; Set garbage collection thresholds for faster startup
(setq gc-cons-threshold (\* 100 1024 1024)
gc-cons-percentage 0.6)

; Set default protocol for pulling packages to SSH
(setq straight-vc-git-default-protocol 'ssh)


;; Defer garbage collection until after startup
(add-hook 'emacs-startup-hook
(lambda ()
(setq gc-cons-threshold (\* 8 1024 1024)
gc-cons-percentage 0.1)))

;; Reset default-directory to home after init (prevents defaulting to user-emacs-directory)
(add-hook 'emacs-startup-hook
(lambda ()
(setq default-directory "~/")))

;; --- Bootstrap straight.el ---
(defvar bootstrap-version)
(let ((bootstrap-file
(expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
(bootstrap-version 5))
(unless (file-exists-p bootstrap-file)
(with-current-buffer
(url-retrieve-synchronously
"https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
'silent 'inhibit-cookies)
(goto-char (point-max))
(eval-print-last-sexp)))
(load bootstrap-file nil 'nomessage))

;; --- Configure use-package ---
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq use-package-always-ensure t) ;; Ensures packages are installed by default

;; --- Load the main configuration ---
(org-babel-load-file (expand-file-name "config.org" user-emacs-directory))

;; --- Custom File ---
;; All variables set via M-x customize will be stored here, not in init.el.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
(load custom-file))

;;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-vc-selected-packages
   '((copilot :url "https://github.com/copilot-emacs/copilot.el" :branch
	      ":main"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
