;;; jf-illuminating.el --- Simple focus mode and extras -*- lexical-binding: t -*-

;; Copyright (C) 2022  Jeremy Friesen
;; Author: Jeremy Friesen <jeremy@jeremyfriesen.com>

;; This file is NOT part of GNU Emacs.
;;; Commentary

;; Packages specifically here for helping with my coding activities.

;;; Code

;; I vascilate between yes and no; but invariably find myself stuck in a
;; recursed buffer.
(setq enable-recursive-minibuffers t)
(use-package recursion-indicator
  :straight t
  :config
  (recursion-indicator-mode))

(global-hl-line-mode)

(use-package kind-icon
  :straight t
  :after corfu
  :custom
  (kind-icon-use-icons t)
  (kind-icon-default-face 'corfu-default) ; Have background color be the same as `corfu' face background
  (kind-icon-blend-background nil)  ; Use midpoint color between foreground and background colors ("blended")?
  (kind-icon-blend-frac 0.08)

  ;; directory that defaults to the `user-emacs-directory'. Here, I change that
  ;; directory to a location appropriate to `no-littering' conventions, a
  ;; package which moves directories of other packages to sane locations.
  ;; (svg-lib-icons-dir (no-littering-expand-var-file-name "svg-lib/cache/")) ; Change cache dir
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter) ; Enable `kind-icon'

  ;; Add hook to reset cache so the icon colors match my theme
  ;; NOTE 2022-02-05: This is a hook which resets the cache whenever I switch
  ;; the theme using my custom defined command for switching themes. If I don't
  ;; do this, then the backgound color will remain the same, meaning it will not
  ;; match the background color corresponding to the current theme. Important
  ;; since I have a light theme and dark theme I switch between. This has no
  ;; function unless you use something similar
  (add-hook 'kb/themes-hooks #'(lambda () (interactive) (kind-icon-reset-cache))))

;; A simple package that does two related things really well; expands and
;; contracts the current region.  I use this all the time.
;;
;; In writing, with the cursor at point, when I expand it selects the word.
;; The next expand the sentence, then paragraph, then page.  In programming it
;; leverages sexp.
(use-package expand-region
  :straight t
  :bind (("C-=" . er/expand-region)
         ("C-+" . er/contract-region)))

;; provides column highlighting.  Useful when you start seeing too many nested
;; layers.
(use-package highlight-indent-guides
  :straight t
  :custom (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'top)
  :hook (prog-mode . highlight-indent-guides-mode))

;;  “LIN locally remaps the hl-line face to a style that is optimal for major
;;  modes where line selection is the primary mode of interaction.”  In
;;  otherwords, ~lin.el~ improves the highlighted line behavior for the
;;  competing contexts.
(use-package lin
  :straight (lin :host gitlab :repo "protesilaos/lin")
  :config (lin-global-mode 1)
  (setq lin-face 'lin-blue))

(use-package fill-column-indicator
  :straight t
  :config
  ;; :hook (prog-mode . fci-mode)
  (setq fci-rule-width 1))

(use-package yafolding :straight t)

;; A quick and useful visual queue for paranthesis.
(use-package rainbow-delimiters
  :straight t
  :hook ((fundamental-mode) . rainbow-delimiters-mode))

;; Show tilde (e.g. ~\~~) on empty trailing lines.  This is a feature ported
;; from https://en.wikipedia.org/wiki/Vi
(use-package vi-tilde-fringe
  :straight t
  :diminish 'vi-tilde-fringe-mode
  :config (global-vi-tilde-fringe-mode))

;; A little bit of visual feedback.  See https://protesilaos.com/codelog/2022-03-14-emacs-pulsar-demo/
(use-package pulsar
  :straight (pulsar :host gitlab :repo "protesilaos/pulsar")
  :hook
  (consult-after-jump . pulsar-recenter-top)
  (consult-after-jump . pulsar-reveal-entry)
  ;; integration with the built-in `imenu':
  (imenu-after-jump . pulsar-recenter-top)
  (imenu-after-jump . pulsar-reveal-entry)
  :config
  (pulsar-global-mode 1)
  (setq pulsar-face 'pulsar-magenta
	pulsar-delay 0.05)
  (defun jf/pulse (parg)
    "Pulse the current line.

  If PARG (given as universal prefix), pulse between `point' and `mark'."
    (interactive "P")
    (if (car parg)
	(pulsar--pulse nil nil (point) (mark))
      (pulsar-pulse-line)))
  :bind (("C-l" . jf/pulse)))

;; From the package commentary, “This minor mode allows functions to operate on
;; the current line if they would normally operate on a region and region is
;; currently undefined.”  I’ve used this for awhile and believe it’s not baked
;; into my assumptions regarding how I navigate Emacs.
(use-package whole-line-or-region
  :straight t
  :diminish 'whole-line-or-region-local-mode
  :config (whole-line-or-region-global-mode))

;; provides some “intelligent” treatment of parentheses.  I’ve been using this
;; for awhile, so I assume it’s baked into my memory.
(use-package smartparens :straight t)

;; This warrants a lot more work.  See https://github.com/wolray/symbol-overlay/tree/c439b73a5f9713bb3dce98986b589bb901e22130
(use-package symbol-overlay
  :straight t)

(provide 'jf-illuminating)
;;; jf-illuminating.el ends here
