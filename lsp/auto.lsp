(in-package 'si)
;;; Autoloaders.

;(defautoload compiler::emit-fn compiler::list-undefined-functions "cmpnew/collectfn")
(defmacro defautoload (&rest l &aux forms (module (car (last l))))
  (dolist (name (butlast l))
	  (or (fboundp name)
	      (push 
	       `(defun ,name (&rest argument-list)
		  (autoloader ',name ,module argument-list))
	       forms)))
  `(progn ,@ forms))

;; this is loaded in the unixport directory
(defun src-path (x) (string-concatenate #. (namestring (truename "../")) x))

(defun aload (module &aux *load-verbose*)
  (load  (src-path
	  (if (symbolp module)(format nil "lsp/~(~a~)"module) module))))

(defun autoloader (name module argument-list)
  ;(fmakunbound name)
  (aload module)
  (apply name argument-list))

(defmacro defautoloadmacro (name module)
  `(defmacro ,name (&rest argument-list)
     (autoloadermacro ',name ,module argument-list)))

(defun autoloadermacro (name module argument-list)
  ;(fmakunbound name)
  (aload module)
  (funcall (macro-function name) (cons name argument-list) nil))


;;; DEFAUTOLOAD definitions. for lsp directory files normally loaded.
(if (fboundp 'abs) (push :numlib *features*))
;;hack to avoid interning all the :symbols if the files are loaded..
#-numlib
(progn
(defautoload abs :numlib)
(defautoload acos :numlib)
(defautoload acosh :numlib)
(defautoload adjust-array :arraylib)
(defautoload apropos :packlib)
(defautoload apropos-list :packlib)
(defautoload array-dimensions :arraylib)
(defautoload array-in-bounds-p :arraylib)
(defautoload array-row-major-index :arraylib)
(defautoload asin :numlib)
(defautoload asinh  :numlib)
(defautoload atanh :numlib)
(defautoload best-array-element-type :arraylib)
(defautoload bit :arraylib)
(defautoload bit-and :arraylib)
(defautoload bit-andc1 :arraylib)
(defautoload bit-andc2 :arraylib)
(defautoload bit-eqv :arraylib)
(defautoload bit-ior :arraylib)
(defautoload bit-nand :arraylib)
(defautoload bit-nor :arraylib)
(defautoload bit-not :arraylib)
(defautoload bit-orc1 :arraylib)
(defautoload bit-orc2 :arraylib)
(defautoload bit-xor :arraylib)
(defautoload byte :numlib)
(defautoload byte-position :numlib)
(defautoload byte-size :numlib)
(defautoload cis :numlib)
(defautoload coerce :predlib)
(defautoload compile-file :loadcmp)
(defautoload compile :loadcmp)
(defautoload disassemble :loadcmp)
(defautoload concatenate :seq)
(defautoload cosh :numlib)
(defautoload count :seqlib)
(defautoload count-if :seqlib)
(defautoload count-if-not :seqlib)
(defautoload decode-universal-time :mislib)
(defautoload delete :seqlib)
(defautoload delete-duplicates :seqlib)
(defautoload delete-if :seqlib)
(defautoload delete-if-not  :seqlib)
(defautoload deposit-field :numlib)
(defautoload describe :describe)
(defautoload dpb :numlib)
(defautoload dribble :iolib)
(defautoload encode-universal-time :mislib)
(defautoload every :seq)
(defautoload fceiling :numlib)
(defautoload ffloor :numlib)
(defautoload fill :seqlib)
(defautoload find :seqlib)
(defautoload find-all-symbols :packlib)
(defautoload find-if :seqlib)
(defautoload find-if-not :seqlib)
(defautoload fround :numlib)
(defautoload ftruncate :numlib)
#-unix (defautoload get-decoded-time :mislib)
#+aosvs (defautoload get-universal-time :mislib)
(defautoload get-setf-method :setf)
(defautoload get-setf-method-multiple-value :setf)
(defautoload inspect :describe)
(defautoload intersection :listlib)
(defautoload isqrt :numlib)
(defautoload ldb :numlib)
(defautoload ldb-test :numlib)
(defautoload logandc1 :numlib)
(defautoload logandc2 :numlib)
(defautoload lognand :numlib)
(defautoload lognor :numlib)
(defautoload lognot :numlib)
(defautoload logorc1 :numlib)
(defautoload logorc2 :numlib)
(defautoload logtest :numlib)
(defautoload make-array :arraylib)
(defautoload make-sequence :seq)
(defautoload map :seq)
(defautoload mask-field :numlib)
(defautoload merge :seqlib)
(defautoload mismatch :seqlib)
(defautoload nintersection :listlib)
(defautoload notany :seq)
(defautoload notevery :seq)
(defautoload si::normalize-type :predlib)
(defautoload nset-difference :listlib)
(defautoload nset-exclusive-or :listlib)
(defautoload nsubstitute :seqlib)
(defautoload nsubstitute-if :seqlib)
(defautoload nsubstitute-if-not :seqlib)
(defautoload nunion :listlib)
(defautoload phase :numlib)
(defautoload position :seqlib)
(defautoload position-if :seqlib)
(defautoload position-if-not :seqlib)
(defautoload prin1-to-string :iolib)
(defautoload princ-to-string :iolib)
(defautoload rational :numlib)
(defautoload rationalize :numlib)
(defautoload read-from-string :iolib)
(defautoload reduce :seqlib)
(defautoload remove :seqlib)
(defautoload remove-duplicates :seqlib)
(defautoload remove-if :seqlib)
(defautoload remove-if-not :seqlib)
(defautoload replace :seqlib)
(defautoload sbit :arraylib)
(defautoload search :seqlib)
(defautoload set-difference :listlib)
(defautoload set-exclusive-or :listlib)
(defautoload signum :numlib)
(defautoload sinh :numlib)
(defautoload some :seq)
(defautoload sort :seqlib)
(defautoload stable-sort :seqlib)
(defautoload subsetp :listlib)
(defautoload substitute :seqlib)
(defautoload substitute-if :seqlib)
(defautoload substitute-if-not :seqlib)
(defautoload subtypep :predlib)
(defautoload tanh :numlib)
(defautoload typep :predlib)
(defautoload union :listlib)
(defautoload vector :arraylib)
(defautoload vector-pop :arraylib)
(defautoload vector-push :arraylib)
(defautoload vector-extend :arraylib)
(defautoload write-to-string :iolib)
(defautoload y-or-n-p :iolib)
(defautoload yes-or-no-p :iolib)

(set-dispatch-macro-character #\# #\a 'si::sharp-a-reader)
(set-dispatch-macro-character #\# #\A 'si::sharp-a-reader)
(defautoload si::sharp-a-reader "iolib")
(set-dispatch-macro-character #\# #\s 'si::sharp-s-reader)
(set-dispatch-macro-character #\# #\S 'si::sharp-s-reader)
(defautoload si::sharp-s-reader :iolib)


;;; DEFAUTOLOADMACRO definitions.

(defautoloadmacro assert :assert)
(defautoloadmacro ccase :assert)
(defautoloadmacro check-type :assert)
(defautoloadmacro ctypecase :assert)
(defautoloadmacro decf :setf)
(defautoloadmacro define-modify-macro :setf)
(defautoloadmacro define-setf-method :setf)
(defautoloadmacro defsetf :setf)
(defautoloadmacro defstruct :defstruct)
(defautoloadmacro si::define-structure :defstruct)
(defautoloadmacro deftype :predlib)
(defautoloadmacro do-all-symbols :packlib)
(defautoloadmacro do-external-symbols :packlib)
(defautoloadmacro do-symbols :packlib)
(defautoloadmacro ecase :assert)
(defautoloadmacro etypecase :assert)
(defautoloadmacro incf :setf)
(defautoloadmacro pop :setf)
(defautoloadmacro push :setf)
(defautoloadmacro pushnew :setf)
(defautoloadmacro remf :setf)
(defautoloadmacro rotatef :setf)
(defautoloadmacro setf :setf)
(defautoloadmacro shiftf :setf)
(defautoloadmacro step :trace)
(defautoloadmacro time :mislib)
(defautoloadmacro trace :trace)
(defautoloadmacro typecase :assert)
(defautoloadmacro untrace :trace)
(defautoloadmacro with-input-from-string :iolib)
(defautoloadmacro with-open-file :iolib)
(defautoloadmacro with-open-stream :iolib)
(defautoloadmacro with-output-to-string :iolib)
)   ;;end autoloads of normally loaded files.j
(if (find-package "COMPILER") (push :compiler *features*))
#+compiler
(defautoload compiler::emit-fn compiler::init-fn "cmpnew/collectfn")

(defautoload si::monstartup "lsp/gprof.o")
(defautoload si::set-up-profile "lsp/profile")

;; the sun has a broken ypbind business, if one wants to save.
;; So to stop users from invoking this
#+sun
(defun user-homedir-pathname ()
  (pathname (si::getenv "HOME")))

