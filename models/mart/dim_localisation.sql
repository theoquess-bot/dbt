-- 1 ligne par (ville, région, pays) rencontrée + un membre « Non précisé ».
with villes as (

    select distinct
        coalesce(r.ville, m.ville, 'Non précisé')  as ville,
        coalesce(r.region, 'Non précisé')         as region,
        coalesce(r.pays, 'Non précisé')           as pays,
        r.ville_norm is not null or m.ville is null as est_referencee
    from {{ ref('int_missions_normalisees') }} m
    left join {{ ref('ref_ville_region') }} r
        on r.ville_norm = m.ville_norm

    union

    select 'Non précisé', 'Non précisé', 'Non précisé', true

)

select
    {{ dbt_utils.generate_surrogate_key(['ville', 'region', 'pays']) }} as localisation_id,
    ville,
    region,
    pays,
    est_referencee   -- false = ville absente de ref_ville_region : à ajouter au seed
from villes
