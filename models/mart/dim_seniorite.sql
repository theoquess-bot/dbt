select
    {{ dbt_utils.generate_surrogate_key(['libelle']) }} as seniorite_id,
    libelle                                             as seniorite,
    ordre                                               as seniorite_ordre
from {{ ref('ref_seniorite') }}
