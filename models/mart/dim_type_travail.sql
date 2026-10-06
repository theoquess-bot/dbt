select
    {{ dbt_utils.generate_surrogate_key(['libelle']) }} as type_travail_id,
    libelle                                             as type_travail,
    ordre                                               as type_travail_ordre
from {{ ref('ref_type_travail') }}
