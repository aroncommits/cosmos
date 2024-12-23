;;; sh-completion.el --- Emacs IQ -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(provide 'sh-completion)

(leaf vertico
  :url "https://github.com/minad/vertico/"
  :doc "Show minibuffer candidates vertically."
  :ensure t
  :bind (:vertico-map
         ("C-j" . vertico-next)
         ("C-k" . vertico-previous)
         ("C-f" . vertico-exit)
         ("C-d" . vertico-directory-enter))
  :custom
  (vertico-cycle . t)
  :init
  (vertico-mode)
  :config
  (require 'vertico-directory))

(leaf marginalia
  :doc "Add marginalia annotations to Vertico minibuffer."
  :url "https://github.com/minad/marginalia"
  :ensure t
  :after vertico
  :bind
  (:minibuffer-local-map
   ("\C-q" . marginalia-cycle))
  :init
  (marginalia-mode))

(leaf orderless
  :doc "Find with space-separated terms."
  :url "https://github.com/oantolin/orderless"
  :ensure t
  :after vertico
  :custom
  (completion-styles . '(orderless basic))
  (completion-category-overrides . '((file (styles partial-completion))))
  )

(defun sh/corfu-exit ()
  "Exit corfu and go back to meow normal mode."
  (interactive)
  (corfu-quit)
  (meow-normal-mode))

(leaf corfu
  :doc "Completion Overlay Region Functions for Emacs"
  :url "https://github.com/minad/corfu/"
  :ensure t
  :custom
  (corfu-cycle . t)                 ;; Enable cycling for `corfu-next/previous'
  (corfu-auto . t)                  ;; Enable auto completion)
  (corfu-auto-prefix . 2)           ;; Show auto-completion after typing two letters
  (corfu-auto-delay . 0.0)          ;; Show auto-completion immeditately
  (corfu-echo-documentation . 0.25) ;; Show documentation after 0.25 sec
  :bind (:corfu-map
         ("C-j" . corfu-next)
         ("C-k" . corfu-previous)
         ("<escape>" . sh/corfu-exit)
         )
  :hook
  (corfu-mode-hook . corfu-popupinfo-mode)
  :init
  (global-corfu-mode)
  :config
  (eldoc-add-command #'corfu-insert)

  (when (> emacs-major-version 29)
    (setq text-mode-ispell-word-completion nil))
  )

(leaf corfu-terminal
  :doc "Corfu popup in terminal."
  :url "https://codeberg.org/akib/emacs-corfu-terminal"
  :straight (corfu-terminal :host codeberg
                            :repo "akib/emacs-corfu-terminal")
  :disabled t
  :if (display-graphic-p)
  :after corfu
  :config
  (corfu-terminal-mode +1))

;; TODO set hydra for emoji completion
(leaf cape
  :doc "Completion at point functions for Emacs"
  :url "https://github.com/minad/cape"
  :ensure t
  :hook
    (eshell-mode-hook . (lambda ()
                        (setq-local corfu-quit-at-boundary t
                                    corfu-quit-no-match t
                                    corfu-auto :if-nil)
                        (corfu-mode 1)))
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  :config
  ;; Silence the pcomplete capf, no errors or messages!
  ;; Important for corfu
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)

  ;; Ensure that pcomplete doesn't write into the buffer
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify)
  )

(leaf copilot
  :doc "Intelligent auto-completion for Emacs"
  :url "https://github.com/zerolfx/copilot.el"
  :straight (copilot :host github :repo "zerolfx/copilot.el" :files ("*.el" "dist"))
  :custom
  (copilot-max-char . 1000000)   ;; https://github.com/zerolfx/copilot.el/issues/175
  (copilot-indent-offset-warning-disable . t) ;; https://github.com/copilot-emacs/copilot.el/issues/249#issuecomment-1921157985
  :bind
  ((:prog-mode-map
    :package prog-mode
    ("C-c C-p" . copilot-mode))
   (:copilot-mode-map
   ("C-<return>" . copilot-accept-completion)
   ("C-;" . copilot-accept-completion-by-word))))

(leaf copilot-chat
  :doc "ChatGPT completion for Copilot"
  :url "https://github.com/chep/copilot-chat.el"
  :ensure t
  :config
  (add-hook 'git-commit-setup-hook 'copilot-chat-insert-commit-message))

(leaf consult
  :doc "Consulting completing-read"
  :url "https://github.com/minad/consult"
  :straight (consult :host github :repo "minad/consult")
  :bind
  ("C-s" . 'consult-line)
  ("M-y" . 'consult-yank-pop)
  ("C-x F". 'consult-recent-file)
  (:minibuffer-local-map
   ("C-r" . consult-history))
  :custom
  (xref-show-xrefs-function . #'consult-xref)
  (xref-show-definitions-function . #'consult-xref)
  )

(leaf consult-ag
  :doc "Consult integration for ag"
  :url "https://github.com/yadex205/consult-ag"
  :ensure t)

;; TODO learn me
(leaf embark
  :doc "Conveniently act on minibuffer candidates."
  :url "https://github.com/oantolin/embark"
  :ensure t
  :bind
  ("C-," . embark-act)
  ([remap describe-bindings] . embark-bindings)
  :custom
  (prefix-help-command . #'embark-prefix-help-command))

(leaf embark-consult
  :doc "Consult integration for Embark"
  :url "https://github.com/oantolin/embark/blob/master/embark-consult.el"
  :ensure t
  :after (embark consult)
  )

(leaf shell-maker
  :doc "comint-based generic package used for making concrete shells"
  :url "https://github.com/xenodium/chatgpt-shell"
  :ensure t
  )

(leaf chatgpt-shell
  :doc "ChatGPT and DALL-E Emacs shells + Org babel"
  :url "https://github.com/xenodium/chatgpt-shell"
  :custom
  (chatgpt-shell-openai-key . (lambda ()
        (auth-source-pick-first-password :host "api.openai.com")))
  (chatgpt-shell-streaming . t)
  (chatgpt-shell-model-version . "gpt-3.5-turbo")
  (chatgpt-shell-request-timeout . 300000))

(leaf tempel
  :doc "Simple templates for Emacs"
  :url "https://github.com/minad/tempel"
  :ensure t
  :custom
  (tempel-trigger-prefix . "<")
  :bind
  (("M-+" . tempel-complete)
   ("M-*" . tempel-insert)
   (:tempel-map
    ("C-c C-c" . tempel-done)
    ("<tab>" . tempel-next)
    ("<backtab>" . tempel-previous)))
  :init
  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-complete
                      completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf))

(leaf tempel-collection
  :doc "Collection tempel templates"
  :url "https://github.com/Crandel/tempel-collection"
  :ensure t
  :after tempel)

;;; sh-completion.el ends here
