-- Nettoyage du texte + type de travail + séniorité normalisés.
-- Séniorité : on prend le premier signal disponible, du plus fiable au moins fiable :
--   1. mot-clé dans le titre  2. années d'XP demandées  3. mot-clé dans le résumé
with missions as (

    select
        *,
        {{ clean_text('libelle') }}                         as titre_norm,
        {{ clean_text("libelle || ' ' || coalesce(resume, '')") }} as texte_norm,
        {{ clean_text('ville', strip_parentheses=true) }} as ville_norm
    from {{ ref('stg_fm__missions') }}

),

signaux as (

    select
        *,
        case
            when {{ match_word('titre_norm', "'lead|expert|architecte|principal|director|directeur|manager|head of'") }} then 'Expert / Lead'
            when {{ match_word('titre_norm', "'senior|sr'") }}                      then 'Senior'
            when {{ match_word('titre_norm', "'confirme|experimente'") }}           then 'Confirmé'
            when {{ match_word('titre_norm', "'junior|jr|debutant'") }}             then 'Junior'
        end as seniorite_titre,

        -- « 5 ans d'expérience », « 5+ ans », « minimum 4 ans », « au moins 10 ans »
        -- (on évite « mission de 3 ans », qui est une durée, pas de l'expérience)
        coalesce(
            try_to_number(regexp_substr(texte_norm, '([0-9]{1,2}) ?\\+? ?ans (d.?experience|minimum|mini|d.?xp)', 1, 1, 'e', 1)),
            try_to_number(regexp_substr(texte_norm, '([0-9]{1,2}) ?\\+ ?ans', 1, 1, 'e', 1)),
            try_to_number(regexp_substr(texte_norm, '(minimum|au moins|min) ([0-9]{1,2}) ans', 1, 1, 'e', 2))
        ) as annees_xp_min,

        case
            when {{ match_word('texte_norm', "'lead|expert|architecte'") }} then 'Expert / Lead'
            when {{ match_word('texte_norm', "'senior|seniors'") }}         then 'Senior'
            when {{ match_word('texte_norm', "'confirme|confirmee|experimente|experimentee'") }} then 'Confirmé'
            when {{ match_word('texte_norm', "'junior|debutant'") }}        then 'Junior'
        end as seniorite_resume

    from missions

)

select
    s.mission_id,
    s.post_url,
    s.libelle,
    s.titre_norm,
    s.resume,
    s.ville,
    s.ville_norm,
    s.tjm,
    s.tjm_texte,
    s.entreprise,
    s.recruteur,
    s.recruteur_linkedin_url,
    s.is_off_market,
    s.is_client_direct,
    s.duree_texte,
    s.detected_at_utc,
    s.detected_at_paris,

    tt.libelle                                         as type_travail,

    s.annees_xp_min,
    coalesce(s.seniorite_titre, sx.libelle, s.seniorite_resume, 'Non précisé') as seniorite,
    case
        when s.seniorite_titre is not null then 'titre'
        when sx.libelle        is not null then 'annees_xp'
        when s.seniorite_resume is not null then 'resume'
        else 'aucun'
    end                                                as source_seniorite

from signaux s
left join {{ ref('ref_type_travail') }} tt
    on tt.work_mode_brut = s.work_mode_brut
left join {{ ref('ref_seniorite') }} sx
    on s.annees_xp_min between sx.annees_min and sx.annees_max