; 地の SQL (content) と {{ }} の式 (output) を1つの SQL として解析する。
; {% %} のタグは SQL に渡さない。
;
; 式まで除くと `where {{ f() }} and ...` が `where  and ...` になり、SQL の構文エラーで
; 周辺のキーワードに色が付かなくなるため、式は SQL 側にも渡す。
; ただし '{{ x | replace("'", "''") }}' のように ' や " が奇数個の式を渡すと、SQL の文字列が
; そこで閉じてファイルの残りが文字列扱いになるので渡さない。
; 正規表現の前半は content（{{ で始まらない）を常に通すための条件
([(content) (output)] @injection.content
 (#match? @injection.content "^(?:[^{]|\\{[^{]|\\{$)|^[^']*(?:'[^']*'[^']*)*$")
 (#match? @injection.content "^(?:[^{]|\\{[^{]|\\{$)|^[^\"]*(?:\"[^\"]*\"[^\"]*)*$")
 (#set! injection.combined)
 (#set! injection.include-children)
 (#set! injection.language "sql"))
