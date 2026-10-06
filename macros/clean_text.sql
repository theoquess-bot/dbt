{#-
  Normalise un texte libre pour le rendre comparable :
  minuscules, sans accents, tirets insécables -> tirets, sans (H/F), espaces multiples réduits.
  Le contenu entre parenthèses est conservé (il porte souvent l'XP : « (5+ ans) »).
  strip_parentheses=true le supprime (utile pour les villes : « Neuchâtel (Suisse) »).
-#}
{% macro clean_text(col, strip_parentheses=false) %}
trim(regexp_replace(
  {%- if strip_parentheses %} regexp_replace({% endif %}
    regexp_replace(
      translate(lower(coalesce({{ col }}, '')),
                'éèêëàâäîïôöùûüçœ‑–—',
                'eeeeaaaiioouuuco---'),
      '\\((h/f|f/h)\\)|h/f|f/h', ' ')
  {%- if strip_parentheses %}, '\\([^)]*\\)', ' '){% endif %},
  ' +', ' '))
{% endmacro %}