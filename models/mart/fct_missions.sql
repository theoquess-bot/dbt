-- Fait mission, grain : 1 post. Version minimale (étape 1) :
-- recruteur, entreprise, secteur, métiers et stacks arrivent à l'étape suivante.
with m as (

    select * from {{ ref('int_missions_normalisees') }}

),

loc as (

    select
        m.mission_id,
        coalesce(r.ville, m.ville, 'Non précisé') as ville,
        coalesce(r.region, 'Non précisé')         as region,
        coalesce(r.pays, 'Non précisé')           as pays
    from m
    left join {{ ref('ref_ville_region') }} r
        on r.ville_norm = m.ville_norm

)

select
    m.mission_id,
    m.post_url,
    m.libelle,

    -- clés
    m.detected_at_paris::date                                                  as date_id,
    {{ dbt_utils.generate_surrogate_key(['loc.ville', 'loc.region', 'loc.pays']) }} as localisation_id,
    {{ dbt_utils.generate_surrogate_key(['m.type_travail']) }}                 as type_travail_id,
    {{ dbt_utils.generate_surrogate_key(['m.seniorite']) }}                    as seniorite_id,

    -- mesures / attributs
    m.tjm,
    m.annees_xp_min,
    m.is_off_market,
    m.is_client_direct,
    iff(m.is_off_market, 1, 0)                                                 as is_off_market_int,     -- AVERAGE => %
    iff(m.is_client_direct, 1, 0)                                              as is_client_direct_int,
    hour(m.detected_at_paris)                                                  as heure_publication,
    m.source_seniorite,

    -- temporaire, remplacés par des dimensions à l'étape suivante
    m.recruteur,
    m.entreprise,

    m.detected_at_utc

from m
join loc on loc.mission_id = m.mission_id