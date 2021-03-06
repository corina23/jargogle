;; -- Package management --
(require 'package)
(package-initialize)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

(defvar packages
  '(cl-lib ack-and-a-half helm helm-bibtex helm-ls-git
    ;; coding stuff
    ascope auto-complete autopair clang-format yasnippet magit
    haskell-mode python elpy jedi inf-ruby multiple-cursors flycheck
    ;; writing
    ace-jump-mode ebib markdown-mode key-chord
    ;; ui
    automargin expand-region paredit projectile helm-projectile
    popup powerline volatile-highlights yaml-mode yari
    ;;themes
    tango-plus-theme))

(require 'cl)
(defun packages-installed-p ()
  (loop for p in packages
        when (not (package-installed-p p)) do (return nil)
        finally (return t)))

(unless (packages-installed-p)
  (message "%s" "Refreshing package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  (dolist (p packages)
    (when (not (package-installed-p p))
      (package-install p))))

(dolist (p packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; -- imports --
(require 'ace-jump-mode)
(require 'ascope)
(require 'auto-complete)
(require 'autopair)
(require 'automargin)
(require 'ebib)
(require 'elpy)
(require 'expand-region)
(require 'flycheck)
(require 'key-chord)
(require 'kmacro)
(require 'multiple-cursors)
(require 'popup)
(require 'powerline)
(require 'projectile)
(require 'volatile-highlights)
(require 'yasnippet)

;; -- UI, Editing --
(powerline-default-theme)
(autopair-global-mode)

(desktop-save-mode 1)
(global-hl-line-mode 1)
(global-flycheck-mode 1)
(ido-mode 1)
(load-theme 'tango-plus t)

(menu-bar-mode -1)
(setq column-number-mode t)
(setq indent-tabs-mode nil
      tab-width 2
      whitespace-style '(face tabs trailing lines-tail))
(show-paren-mode 1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)
(volatile-highlights-mode t)
(pending-delete-mode t)
(key-chord-mode 1)
(set-default 'cursor-type 'bar)
(blink-cursor-mode 0)
(savehist-mode 1)
(defalias 'yes-or-no-p 'y-or-n-p)

;; -- Coding --
(define-key global-map (kbd "RET") 'newline-and-indent) ; Auto indent on enter
(setq next-line-add-newlines t)                         ; Add new lines at end of buffer
(setq gdb-many-windows t)
(setq yas/root-directory '("~/.yasnippet-snippets"))
(mapc 'yas/load-directory yas/root-directory)
(yas-global-mode 1)
(global-auto-complete-mode 1)
(setq compilation-scroll-output 'first-error)

;; --- Python IDE ---
(elpy-enable)
(add-hook 'python-mode-hook 'jedi:setup)
(add-hook 'python-mode-hook 'projectile-on)
(setq jedi:setup-keys t)                      ; optional
(setq jedi:complete-on-dot t)                 ; optional

;; -- Backups --
(setq backup-directory-alist `(("." . "~/.emacs-bkp"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;; -- Hooks --
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'text-mode-hook 'auto-fill-mode)
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'text-mode-hook 'flyspell-buffer)
(setq auto-mode-alist (cons '("\\.lara$" . javascript-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.maxj$" . java-mode) auto-mode-alist))

;; Hide Compilation buffer if everything went OK
(defun bury-compile-buffer-if-successful (buffer string)
  "Bury a compilation buffer if succeeded without warnings "
  (if (and
       (string-match "compilation" (buffer-name buffer))
       (string-match "finished" string)
       (not
        (with-current-buffer buffer
          (search-forward "warning" nil t))))
      (run-with-timer 1 nil
                      (lambda (buf)
                        (bury-buffer buf)
                        (switch-to-prev-buffer (get-buffer-window buf) 'kill)
                        )
                      buffer)))

(setq bury-compile-buffer 1)
(add-hook 'compilation-finish-functions 'bury-compile-buffer-if-successful)

(defun toggle-bury-compile-buffer  ()
  "Toggle burying compilation buffer on/off."
  (interactive)
  (setq bury-compile-buffer (- 1 bury-compile-buffer))
  (if (= bury-compile-buffer 0)
      (remove-hook 'compilation-finish-functions 'bury-compile-buffer-if-successful)
    (add-hook 'compilation-finish-functions 'bury-compile-buffer-if-successful)))

(defun indent-buffer ()
  "Indent buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

;; -- Treat annotations as comments --
(add-hook 'java-mode-hook
          (lambda ()
            "Treat Java 1.5 @-style annotations as comments."
            (setq c-comment-start-regexp "(@|/(/|[*][*]?))")
            (modify-syntax-entry ?@ "< b" java-mode-syntax-table)))

(setq recording-macro 0)
(defun toggle-record-macro ()
  "Toggle record macro on/off"
  (interactive)
  (setq recording-macro (- 1 recording-macro))
  (if (= recording-macro 1)
      (kmacro-start-macro 0)
    (kmacro-end-macro nil)))

(setq compilation-scroll-output 'first-error)
(defun toggle-auto-scroll-compilation-buffer ()
  "Toggle scroll compilation buffer on/off"
  (interactive)
  (if (equal compilation-scroll-output nil)
      (setq compilation-scroll-output 'first-error)
    (setq compilation-scroll-output nil )))

(defun bashrc ()
  "Open a buffer with bashrc."
  (interactive)
  (find-file "~/.bashrc"))

(defun emacsel ()
  "Open a buffer with emacs.el"
  (interactive)
  (find-file "~/.emacs.el"))

;; -- Local settings --
(setq helm-bibtex-bibliography "~/Dropbox/refdb/bibliography.bib")
(setq helm-bibtex-library-path "~/Dropbox/refdb/papers")
(setq helm-bibtex-notes-path "~/Dropbox/refdb/notes")
(setq helm-bibtex-notes-extension ".md")

;; -- Key bindings
(global-set-key [f1] 'projectile-regenerate-tags)
(global-set-key [f2] 'kmacro-call-macro)
(global-set-key [f3] 'toggle-record-macro)
(global-set-key [f5] 'compile)
(global-set-key [f7] 'ff-find-other-file)
(global-set-key [f8] 'ascope-init)
(global-set-key [f9] 'ascope-find-this-symbol)
(global-set-key [f10] 'ascope-find-global-definition)
(global-set-key [f11] 'ascope-find-functions-calling-this-function)

(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-<tab>") 'yas-expand)
(global-set-key (kbd "C-c n") 'indent-buffer)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key (kbd "C-=") 'er/expand-region)
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-c SPC") 'ace-jump-mode)

(key-chord-define-global "qq" 'query-replace)
(key-chord-define-global "$$" 'magit-status)
(key-chord-define-global ",," 'other-window)
(key-chord-define-global "bb" 'switch-to-buffer)
(key-chord-define-global "jj" 'find-file)
(key-chord-define-global "aa" 'helm-ls-git-ls)
(key-chord-define-global "zz" 'helm-etags-select)
(key-chord-define-global "ZZ" 'helm-projectile)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:background "#5f615c" :foreground "#eeeeec" :box nil))))
 '(mode-line-highlight ((t (:box nil))))
 '(mode-line-inactive ((t (:inherit mode-line :background "#888a85" :foreground "#babdb6" :box nil :weight light))))
 '(magit-diff-add ((t (:inherit diff-added :foreground "chartreuse3"))))
 '(magit-diff-del ((t (:inherit diff-removed :foreground "red"))))
 '(magit-item-highlight ((t (:inherit secondary-selection :background "white smoke")))))
