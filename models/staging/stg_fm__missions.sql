-- 1 ligne = 1 post LinkedIn. Typage + renommage uniquement, aucune règle métier.
with source as (

    select * from {{ source('freelance_mention', 'freelance_missions') }}

)

select
    coalesce(raw_payload:id::string, md5(post_url))         as mission_id,
    post_url,
    raw_payload:title::string                               as libelle,
    raw_payload:summary::string                             as resume,
    nullif(trim(raw_payload:city::string), '')              as ville,
    coalesce(nullif(raw_payload:work_mode::string, ''), 'unknown') as work_mode_brut,
    raw_payload:tjm_amount::number(6,0)                     as tjm,
    raw_payload:tjm::string                                 as tjm_texte,
    raw_payload:company::string                             as entreprise,
    raw_payload:poster_name::string                         as recruteur,
    raw_payload:poster_linkedin::string                     as recruteur_linkedin_url,
    raw_payload:is_off_market::boolean                      as is_off_market,
    raw_payload:is_direct_client::boolean                   as is_client_direct,
    raw_payload:duration::string                            as duree_texte,
    to_timestamp_ntz(replace(raw_payload:detected_at::string, 'Z', '')) as detected_at_utc,
    convert_timezone('UTC', 'Europe/Paris',
        to_timestamp_ntz(replace(raw_payload:detected_at::string, 'Z', '')))  as detected_at_paris,
    ingested_at

from source
