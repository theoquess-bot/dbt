{#- Vrai si `pattern` (regex) apparaît comme mot entier dans `col` (texte déjà nettoyé). -#}
{% macro match_word(col, pattern) %}
regexp_instr({{ col }}, '(^|[^a-z0-9])(' || {{ pattern }} || ')([^a-z0-9]|$)') > 0
{% endmacro %}
