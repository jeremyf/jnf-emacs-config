;;; jf-reading.el --- Simple focus mode and extras -*- lexical-binding: t -*-

;; Copyright (C) 2022  Jeremy Friesen
;; Author: Jeremy Friesen <jeremy@jeremyfriesen.com>

;; This file is NOT part of GNU Emacs.
;;; Commentary

;;; Code
(use-package doc-view
  :straight (doc-view :type built-in)
  :bind (:map doc-view-mode-map
              ("C-c g" . doc-view-goto-page)))


(use-package elfeed
  ;; An Emacs RSS reader.  I’ve used Google Reader, Feedly, Inoreader, and
  ;; Newsboat.  I wrote about
  ;; https://takeonrules.com/2020/04/12/switching-from-inoreader-to-newsboat-for-rss-reader/,
  ;; and the principles apply for Elfeed.
  :straight t
  :after org
  :hook ((elfeed-show-mode . jf/reader-visual))
  :config
  (setq-default elfeed-search-filter "@2-days-ago +unread ")
  :bind ((:map elfeed-search-mode-map
	       ("q" . jf/elfeed-save-db-and-bury))))

(defun jf/elfeed-save-db-and-bury ()
  "Wrapper to save the elfeed db to disk before burying buffer"
  ;;write to disk when quiting
  (interactive)
  (elfeed-db-save)
  (quit-window))

(defun jf/elfeed-load-db-and-open ()
  "Load the elfeed db from disk before opening"
  (interactive)
  (elfeed)
  (elfeed-update)
  (elfeed-db-load)
  (elfeed-search-update--force))
(defalias 'rss 'jf/elfeed-load-db-and-open)

;; From https://karthinks.com/blog/lazy-elfeed/
(defun elfeed-search-show-entry-pre (&optional lines)
  "Returns a function to scroll forward or back in the Elfeed
  search results, displaying entries without switching to them."
  (lambda (times)
    (interactive "p")
    (forward-line (* times (or lines 0)))
    (recenter)
    (call-interactively #'elfeed-search-show-entry)
    (select-window (previous-window))
    (unless elfeed-search-remain-on-entry (forward-line -1))))
(eval-after-load 'elfeed-search
  '(define-key elfeed-search-mode-map (kbd "n")
     (elfeed-search-show-entry-pre +1)))
(eval-after-load 'elfeed-search
  '(define-key elfeed-search-mode-map (kbd "p")
     (elfeed-search-show-entry-pre -1)))
(eval-after-load 'elfeed-search
  '(define-key elfeed-search-mode-map (kbd "M-RET")
     (elfeed-search-show-entry-pre)))
;; End https://karthinks.com/blog/lazy-elfeed/

(use-package elfeed-org
  ;; Maintaining my RSS subscriptions in `org-mode' format.
  :straight t
  :after elfeed
  :config (elfeed-org)
  (setq rmh-elfeed-org-files (list "~/git/org/elfeed.org")))

(use-package eww
  ;; A plain text browser.  Use this to see just how bad much of the web has
  ;; become.
  :straight t
  :config
  (defun shr-tag-dfn (dom)
    (shr-fontize-dom dom 'italic))

  (defun shr-tag-cite (dom)
    (shr-fontize-dom dom 'italic))

  (defun shr-tag-q (dom)
    (shr-insert (car shr-around-q-tag))
    (shr-generic dom)
    (shr-insert (cdr shr-around-q-tag)))

  (defcustom shr-around-q-tag '("“" . "”")
    "The before and after quotes.  `car' is inserted before the Q-tag and `cdr' is inserted after the Q-tag.

Alternative suggestions are: - '(\"\\\"“\" . \"\\\"\")"
    :type (cons 'string 'string))

  (defface shr-small
    '((t :height 0.8))
    "Face for <small> elements.")

  ;; Drawing inspiration from shr-tag-h1
  (defun shr-tag-small (dom)
    (shr-fontize-dom dom (when shr-use-fonts 'shr-small)))

  (defface shr-time
    '((t :inherit underline :underline (:style wave)))
    "Face for <time> elements.")

  ;; Drawing inspiration from shr-tag-abbr
  (defun shr-tag-time (dom)
    (when-let* ((datetime (or
			   (dom-attr dom 'title)
			   (dom-attr dom 'datetime)))
		(start (point)))
      (shr-generic dom)
      (shr-add-font start (point) 'shr-time)
      (add-text-properties
       start (point)
       (list
	'help-echo datetime
	'mouse-face 'highlight))))


  ;; EWW lacks a style for article
  (defun shr-tag-article (dom)
    (shr-ensure-paragraph)
    (shr-generic dom)
    (shr-ensure-paragraph))

  ;; EWW lacks a style for section; This is quite provisional
  (defun shr-tag-section (dom)
    (shr-ensure-paragraph)
    (shr-generic dom)
    (shr-ensure-paragraph))

  (setq browse-url-browser-function 'browse-url-default-macosx-browser)
  :bind (:map eww-mode-map ("U" . eww-up-url))
  :bind (("C-s-w" . browse-url-at-point))
  :hook ((eww-mode . jf/reader-visual)))

(defun jf/reader-visual ()
  "A method to turn on visual line mode and adjust text scale."
  ;; A little bit of RSS beautification.
  (text-scale-set 2)
  (turn-on-visual-line-mode))

(provide 'jf-reading)
;;; jf-reading.el ends here
