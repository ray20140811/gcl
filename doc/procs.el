(defun next-word ()
    (let* ((pt (point)))
      (forward-sexp)
      (buffer-substring pt (point))))


(defun get-defuns (n) (interactive "p")
  (or n (setq n 1))
  (while (>= (setq n (- n 1)) 0)
    (cond ((search-forward "F" nil t) 
    (let (f pack args lim pt def)
      (setq pt (point))
      (forward-char 1)
      (setq lim (if (search-forward "" nil t) (point) nil))
      (goto-char pt)
      (setq f (next-word))
      (next-line 1)
      (beginning-of-line)
      (setq def (next-word))
      (cond ((equal def "Macro"))
	    ((equal def "Special"))
	    (t (search-forward "package:" lim)
	      (forward-sexp -2)
	      (setq pack (next-word))
	      (search-forward "Args:" lim)
;	      (re-search-forward "\\(Args\\)\\|\\(Syntax\\):" lim)
	      (setq args (next-word))
	      (setq values  (re-search-forward "Values" lim t))
	      (other-window 1)
	      (cond ((equal def "Function")
		     (insert "(defun "  pack "::" f  args
			     (if values " (MV)" " T")
			     ")"))
		    (t (insert "(unknown " f ")")))
	      (insert ?\n)
	      (other-window 1)
	      )))))))
