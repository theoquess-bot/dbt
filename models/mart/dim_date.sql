with jours as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="to_date('" ~ var('date_debut') ~ "')",
        end_date="to_date('" ~ var('date_fin') ~ "')"
    ) }}

)

select
    date_day::date                                  as date_id,
    year(date_day)                                  as annee,
    quarter(date_day)                               as trimestre,
    'T' || quarter(date_day)                        as trimestre_libelle,
    month(date_day)                                 as mois,
    decode(month(date_day), 1,'Janvier', 2,'Février', 3,'Mars', 4,'Avril', 5,'Mai', 6,'Juin',
           7,'Juillet', 8,'Août', 9,'Septembre', 10,'Octobre', 11,'Novembre', 12,'Décembre') as mois_libelle,
    weekiso(date_day)                               as semaine_iso,
    yearofweekiso(date_day)                         as annee_iso,
    dayofweekiso(date_day)                          as jour_semaine,       -- 1 = lundi
    decode(dayofweekiso(date_day), 1,'Lundi', 2,'Mardi', 3,'Mercredi', 4,'Jeudi',
           5,'Vendredi', 6,'Samedi', 7,'Dimanche')  as jour_semaine_libelle,
    dayofweekiso(date_day) >= 6                     as est_weekend,
    day(date_day)                                   as jour
from jours
