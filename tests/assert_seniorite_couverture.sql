-- Alerte si plus de 70 % des missions n'ont aucune séniorité détectée.
-- (seuil volontairement large au démarrage : peu de posts la mentionnent)
{{ config(severity='warn') }}

select
    count_if(seniorite = 'Non précisé') / nullif(count(*), 0) as taux_non_precise
from {{ ref('int_missions_normalisees') }}
having taux_non_precise > 0.70
