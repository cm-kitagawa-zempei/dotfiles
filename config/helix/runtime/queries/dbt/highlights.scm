; tree-sitter-twig のノードに対するハイライト。
; Helix では後に書いたパターンが優先されるため、汎用的なものを先に書く
(comment) @comment
["embedded_begin" "embedded_end"] @punctuation.special
"keyword" @keyword
["not" "with" "divisible by" "same as"] @keyword.operator
"operator" @operator
"=" @operator
["(" ")" "[" "]" "{" "}"] @punctuation.bracket
["," "." ":"] @punctuation.delimiter
(identifier) @variable
(variable) @variable
(property) @variable.other.member
(function) @function
(parameter) @variable.parameter
(string) @string
(interpolated_string) @string
(number) @constant.numeric
(boolean) @constant.builtin.boolean
(null) @constant.builtin
; Jinja の名前付き引数 f(key=value) のキーは string ノードとして解析される
(named_argument key: (string) @variable.parameter)
