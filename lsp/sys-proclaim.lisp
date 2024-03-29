
(IN-PACKAGE "SYSTEM") 
(PROCLAIM
    '(FTYPE (FUNCTION (T) FIXNUM) S-DATA-SIZE THE-START S-DATA-LENGTH)) 
(PROCLAIM '(FTYPE (FUNCTION (T T) FIXNUM) THE-END)) 
(PROCLAIM '(FTYPE (FUNCTION (T T T T T T T) *) TRACE-CALL)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T) *) READ-INSPECT-COMMAND LIST-MERGE-SORT
            SHARP-S-READER)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T *) *) SORT STABLE-SORT SET-UP-FOR-DUMP-INPUT
            SLOOP::FIND-IN-ORDERED-LIST REDUCE)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T *) T) SLOOP::PARSE-LOOP-MACRO SOME SUBSETP
            SLOOP::IN-ARRAY-SLOOP-FOR MAKE-SEQUENCE UNION
            WRITE-DEBUG-SYMBOLS MISMATCH NINTERSECTION NOTANY NOTEVERY
            NSET-DIFFERENCE NSET-EXCLUSIVE-OR NUNION POSITION
            POSITION-IF POSITION-IF-NOT REMOVE REMOVE-IF REMOVE-IF-NOT
            REPLACE SEARCH SLOOP::LOOP-ADD-BINDING SET-DIFFERENCE
            SET-EXCLUSIVE-OR DELETE DELETE-IF DELETE-IF-NOT EVERY FILL
            FIND BIT-AND BIT-ANDC1 FIND-IF BIT-ANDC2 FIND-IF-NOT
            BIT-EQV BIT-IOR BIT-NAND BIT-NOR BIT-ORC1 BIT-ORC2 BIT-XOR
            INTERSECTION)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T) T) DM-VL SETF-EXPAND-1
            TYPECASE-ERROR-STRING
            SLOOP::LOOP-PARSE-ADDITIONAL-COLLECTIONS SHARP-A-READER
            DEPOSIT-FIELD DEFMACRO* DPB CHECK-TRACE-ARGS MAKE-T-TYPE
            GET-SLOT-POS CHECK-S-DATA)) 
(PROCLAIM '(FTYPE (FUNCTION (T T T T T T *) T) ENCODE-UNIVERSAL-TIME)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T T T) T) MAKE-CONSTRUCTOR MAKE-PREDICATE)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T T T T T T T T *) T) MAKE-ACCESS-FUNCTION)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T T T T T T T T T T *) T) DEFINE-STRUCTURE)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T T) T) SLOOP::FIRST-USE-SLOOP-FOR
            SLOOP::FIRST-SLOOP-FOR SETF-STRUCTURE-ACCESS CALL-TEST)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T *) T) SUBSTITUTE SUBSTITUTE-IF
            SUBSTITUTE-IF-NOT MAP NSUBSTITUTE NSUBSTITUTE-IF
            NSUBSTITUTE-IF-NOT SLOOP::LOOP-DECLARE-BINDING)) 
(PROCLAIM '(FTYPE (FUNCTION (T T T T T *) T) UNIVERSAL-ERROR-HANDLER)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T T T *) T) SLOOP::DEF-LOOP-INTERNAL MERGE)) 
(PROCLAIM '(FTYPE (FUNCTION (FIXNUM FIXNUM) FIXNUM) ROUND-UP)) 
(PROCLAIM
    '(FTYPE (FUNCTION NIL *) BREAK-MESSAGE BREAK-UNHIDE-ALL
            SIMPLE-BACKTRACE BREAK-CURRENT)) 
(PROCLAIM
    '(FTYPE (FUNCTION NIL T) SLOOP::PARSE-LOOP-FOR
            DM-TOO-MANY-ARGUMENTS DM-TOO-FEW-ARGUMENTS BREAK-HELP-HELP
            BREAK-HELP-STACK-FUNS BREAK-TAGS BREAK-VARIABLES
            INSPECT-READ-LINE INSPECT-INDENT INSPECT-INDENT-1
            SLOOP::LOOP-POP SLOOP::LOOP-UN-POP SLOOP::LOOP-PEEK
            BREAK-BLOCKS SLOOP::PARSE-LOOP1 SLOOP::PARSE-LOOP-DO
            SLOOP::PARSE-ONE-WHEN-CLAUSE BREAK-VARIABLES-VALUES
            SLOOP::PARSE-LOOP-WHEN SLOOP::PARSE-LOOP-COLLECT
            BREAK-FUNCTIONS SET-CURRENT BREAK-HELP SET-ENV TEST-ERROR
            TOP-LEVEL SLOOP::TYPE-ERROR ILLEGAL-BOA
            ALL-TRACE-DECLARATIONS STEP-READ-LINE)) 
(PROCLAIM
    '(FTYPE (FUNCTION (*) *) LOC BACKTRACE SHOW-BREAK-VARIABLES
            BREAK-LOCAL BREAK-LOCALS BREAK-NEXT BREAK-PREVIOUS
            BREAK-QUIT BREAK-VS)) 
(PROCLAIM
    '(FTYPE (FUNCTION (*) T) Y-OR-N-P YES-OR-NO-P
            SLOOP::PARSE-LOOP-WITH SLOOP::PARSE-LOOP-DECLARE VECTOR
            MAKE-S-DATA DRIBBLE BREAK)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T) *) BREAK-HIDE BREAK-HIDE-PACKAGE
            FIND-DECLARATIONS SEARCH-STACK PRIN1-TO-STRING BREAK-UNHIDE
            PRINC-TO-STRING INSPECT-OBJECT BREAK-UNHIDE-PACKAGE
            BREAK-BDS BREAK-GO IHS-FNAME DESCRIBE GET-SETF-METHOD
            GET-SETF-METHOD-MULTIPLE-VALUE INSPECT)) 
(PROCLAIM '(FTYPE (FUNCTION (T :DYNAMIC-EXTENT *) T) ADJUST-ARRAY)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T *) FIXNUM) VECTOR-PUSH-EXTEND INTERNAL-COUNT
            COUNT COUNT-IF COUNT-IF-NOT INTERNAL-COUNT-IF
            INTERNAL-COUNT-IF-NOT)) 
(PROCLAIM '(FTYPE (FUNCTION (T FIXNUM FIXNUM T T) T) QUICK-SORT)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T) T) SIGNUM S-DATA-PRINT-FUNCTION
            DM-KEY-NOT-ALLOWED SINH S-DATA-SLOT-DESCRIPTIONS
            SLOOP::AVERAGING-SLOOP-MACRO S-DATA-SLOT-POSITION
            SLOOP::REPEAT-SLOOP-MACRO SLOOP::SUBSTITUTE-SLOOP-BODY
            SIMPLE-ARRAY-P S-DATA-HAS-HOLES SLOOP::RETURN-SLOOP-MACRO
            NORMALIZE-TYPE S-DATA-FROZEN KNOWN-TYPE-P LOGNOT
            S-DATA-DOCUMENTATION S-DATA-CONSTRUCTORS S-DATA-OFFSET
            DM-BAD-KEY S-DATA-NAMED S-DATA-TYPE BEST-ARRAY-ELEMENT-TYPE
            TANH SLOOP::SLOOP-SLOOP-MACRO SHOW-ENVIRONMENT VECTOR-POP
            INSPECT-SYMBOL SLOOP::LOOP-COLLECT-KEYWORD-P PHASE
            INSPECT-PACKAGE INSPECT-CHARACTER INSPECT-NUMBER
            SLOOP::PARSE-NO-BODY INSPECT-CONS INSPECT-STRING
            INSPECT-VECTOR TERMINAL-INTERRUPT PROVIDE INSPECT-ARRAY
            INSPECT-STRUCTURE SLOOP::TRANSLATE-NAME
            SLOOP::LOOP-LET-BINDINGS SLOOP::PARSE-LOOP
            BREAK-BACKWARD-SEARCH-STACK ASK-FOR-FORM
            SLOOP::PARSE-LOOP-INITIALLY TYPECASE-ERROR-STRINGS BOIN-P
            BREAK-FORWARD-SEARCH-STACK 
            SLOOP::POINTER-FOR-COLLECT PRINT-IHS PRINT-FRS LEAP-YEAR-P
            FRS-KIND NUMBER-OF-DAYS-FROM-1900 IHS-VISIBLE
            IHS-COMPILED-P PRINT-SYMBOL-APROPOS BYTE-SIZE SEQTYPE CIS
            FIND-DOCUMENTATION COSH TRACE-ONE UNTRACE-ONE ABS S-DATA-P
            ACOS TRACE-ONE-PREPROCESS RATIONAL ACOSH CHECK-TRACE-SPEC
            CHECK-DECLARATIONS RESET-TRACE-DECLARATIONS
            ARRAY-DIMENSIONS ASIN ASINH FREEZE-DEFSTRUCT ATANH
            FIND-ALL-SYMBOLS S-DATA-NAME S-DATA-RAW S-DATA-INCLUDED
            ISQRT S-DATA-INCLUDES BYTE-POSITION S-DATA-STATICP)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T *) *) SET-UP-FOR-DUMP-OUTPUT PRINT-DOC
            APROPOS-DOC WRITE-TO-STRING READ-FROM-STRING
            DECODE-UNIVERSAL-TIME STEPPER APROPOS FCEILING FFLOOR
            FROUND FTRUNCATE)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T *) T) SLOOP::ADD-FROM-DATA MAKE-ARRAY
            REMOVE-DUPLICATES REQUIRE SBIT SLOOP::LOOP-ADD-TEMPS
            CONCATENATE WARN BAD-SEQ-LIMIT DELETE-DUPLICATES
            APROPOS-LIST ARRAY-IN-BOUNDS-P ARRAY-ROW-MAJOR-INDEX BIT
            BIT-NOT)) 
(PROCLAIM '(FTYPE (FUNCTION (T T) *) FIND-DOC SUBTYPEP TYPEP)) 
(PROCLAIM
    '(FTYPE (FUNCTION (T T) T) LDB-TEST LOGANDC1 SLOOP::PARSE-LOOP-MAP
            LOGANDC2 LOGNAND LOGNOR DM-V SLOOP::IN-TABLE-SLOOP-MAP
            DM-NTH SUB-INTERVAL-P LOGORC1 DM-NTH-CDR IN-INTERVAL-P
            LOGORC2 SLOOP::IN-PACKAGE-SLOOP-MAP MATCH-DIMENSIONS
            LOGTEST SUPER-GO SLOOP::=-SLOOP-FOR MASK-FIELD
            SLOOP::IN-CAREFULLY-SLOOP-FOR VECTOR-PUSH SETF-HELPER
            SLOOP::COLLATE-SLOOP-COLLECT SLOOP::IN-FRINGE-SLOOP-MAP
            SLOOP::DESETQ1 SETF-EXPAND SLOOP::L-EQUAL SUBSTRINGP
            INCREMENT-CURSOR SEQUENCE-CURSOR BREAK-CALL SLOOP::THE-TYPE
            SLOOP::MAKE-VALUE LIST-DELQ CHECK-SEQ-START-END COERCE
            DOCUMENTATION PARSE-SLOT-DESCRIPTION
            OVERWRITE-SLOT-DESCRIPTIONS SLOOP::SUM-SLOOP-COLLECT
            SLOOP::LOGXOR-SLOOP-COLLECT SLOOP::MAXIMIZE-SLOOP-COLLECT
            SLOOP::MINIMIZE-SLOOP-COLLECT SLOOP::COUNT-SLOOP-COLLECT
            SLOOP::THEREIS-SLOOP-COLLECT SLOOP::ALWAYS-SLOOP-COLLECT
            BYTE SLOOP::NEVER-SLOOP-COLLECT LDB)) 