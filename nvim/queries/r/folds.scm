;; ~/.config/nvim/queries/r/folds.scm
;; Define foldable regions in R

;; Fold functions
((function_definition) @fold)
((call) @fold)

;; Fold control structures
((if_statement) @fold)
((for_statement) @fold)
((while_statement) @fold)
((repeat_statement) @fold)
