-- # Intégration des données CIMaE 2021-2022

--	# Récupération des "Passages 1"
insert into submissions.cimae_protocole_passages (
select 
gen_random_uuid() as data_id,
site as site_name,
date::date as passage_date,
date_trunc('minute', (interval '1 day' * NULLIF(replace(heurarriv, ',', '.'), 'NA')::numeric)::time + interval '59 seconds')::time as passage_time_begin,
date_trunc('minute', (interval '1 day' * NULLIF(replace(heurdep,   ',', '.'), 'NA')::numeric)::time + interval '59 seconds')::time AS passage_time_end,
observateur_s as user_name,
null as user_mail,
null as passage_collective,
null as passage_monitoring,
null as unit,
null as unit_type,
null as unit_name,
case
	when NULLIF(replace(surfaceeau, ',', '.'), 'NA')::numeric = 0 then 'yes'
	else 'no'
end as water_dry,
NULLIF(replace(surfaceeau, ',', '.'), 'NA')::numeric as water_area,
case
    when mesuresurf like '%pied%' then 'eye'
    when mesuresurf in ('GPS', 'gps') then 'gps'
    when mesuresurf = 'carte/SIG' then 'map'
    ELSE NULL
end as water_area_measure,
null as water_transect_lenght,
null as water_transect_lenght_measure,
NULLIF(replace(profondeur, ',', '.'), 'NA')::numeric as water_depth_mean,
null as water_depth_max,
case
    when mesureprof like 'il' then 'eye'
    when mesureprof like '%metre%' then 'meter'
    else NULL
end as water_depth_measure,
case
    when transpeau like 'je ne vois pas le fond' then 'no'
    when transpeau like 'je vois le fond mais mal' then 'bad'
    when transpeau like 'je vois le fond' then 'yes'
    else NULL
end as water_transparency,
case
    when alimentationsite like 'source' then 'source'
    when alimentationsite like 'cours d''eau' then 'river'
    when alimentationsite like 'ruissellement' then 'runoff'
    when alimentationsite like 'fonte' then 'melting'
    when alimentationsite like 'precipitations' then 'precipitation'
    when alimentationsite like 'nsp' then 'unknown'
    else NULL
end as wetland_feed,
NULLIF(replace(largeurmoyennecoureau, ',', '.'), 'NA')::numeric as wetland_feed_river_width,
NULLIF(replace(profondeurmoyennecoureau, ',', '.'), 'NA')::numeric as wetland_feed_river_depth,
case
    when mesurecourseau like 'il' then 'eye'
    when mesurecourseau like '%metre%' then 'meter'
    else NULL
end as wetland_feed_river_measure,
case
    when exutoirevisible like 'non' then 'no'
    when exutoirevisible like 'oui' then 'yes'
    else NULL
end as wetland_outlet,
case 
    when trim(largeurmoyenneexutoire) in ('NA', 'nsp') then NULL
    else replace(largeurmoyenneexutoire, ',', '.')::numeric
end as wetland_outlet_width,
case 
    when trim(profondeurmoyenneexutoire) in ('NA', 'nsp') then NULL
    else replace(profondeurmoyenneexutoire, ',', '.')::numeric
end as wetland_outlet_depth,
case
    when mesureexutoire like 'il' then 'eye'
    when mesureexutoire like '%metre%' then 'meter'
    else NULL
end as wetland_outlet_measure,
concat_ws(' ',
    case when NULLIF(NULLIF("rocher/roche1", '0'), 'NA')::int > 0 then 'rock' end,
    case when NULLIF(NULLIF(gravier1, '0'), 'NA')::int > 0 then 'gravel' end,
    case when NULLIF(NULLIF(sable_1, '0'), 'NA')::int > 0 then 'sand' end,
    case when NULLIF(NULLIF(tourbe1, '0'), 'NA')::int > 0 then 'peat' end,
    case when NULLIF(NULLIF(terre1, '0'), 'NA')::int > 0 then 'soil' end,
    case when NULLIF(NULLIF(vase1, '0'), 'NA')::int > 0 then 'mud' end
) as substrate_type,
	NULLIF(NULLIF("rocher/roche1", '0'), 'NA')::int as substrate_percent_rock,
	NULLIF(NULLIF(gravier1, '0'), 'NA')::int as substrate_percent_gravel,
	NULLIF(NULLIF(sable_1, '0'), 'NA')::int as substrate_percent_sand,
	NULLIF(NULLIF(tourbe1, '0'), 'NA')::int as substrate_percent_peat,
	NULLIF(NULLIF(terre1, '0'), 'NA')::int as substrate_percent_soil,
	NULLIF(NULLIF(vase1, '0'), 'NA')::int as substrate_percent_mud,
case
    when prespoissons like 'non' then 'no'
    when prespoissons like 'oui' then 'yes'
    when prespoissons like 'nsp' then 'nsp'
    else NULL
end as fish,
null as vegetation_tree,
coalesce(NULLIF(concat_ws(' ',
    case when NULLIF(NULLIF(vegetpieceeau, '0'), 'NA')::int > 0 then 'water' end,
    case when NULLIF(NULLIF(vegetberge, '0'), 'NA')::int > 0 then 'bank' end,
    case when NULLIF(NULLIF(vegetenv, '0'), 'NA')::int > 0 then 'around' end
), ''), 'no') as vegetation_type,
	NULLIF(NULLIF(vegetpieceeau, '0'), 'NA')::int vegetation_percent_water,
	NULLIF(NULLIF(vegetberge, '0'), 'NA')::int vegetation_percent_bank,
	NULLIF(NULLIF(vegetenv, '0'), 'NA')::int vegetation_percent_around,
case
    when ceintveget like 'non' then 'no'
    when ceintveget like 'oui' then 'yes'
    else NULL
end as vegetation_belt,
case
	when ceintveget like 'non' then 0
	else NULLIF(replace(largceint, ',', '.'), 'NA')::numeric
end as vegetation_belt_width,
case
	when tourpieceau like 'oui' then 100
	when ceintveget like 'non' then 0
	else NULLIF(replace(pourcperim, ',', '.'), 'NA')::numeric
end as vegetation_belt_percent,
case
    when alguefil  like 'non' then 'no'
    when alguefil like 'oui' then 'yes'
    else NULL
end as algae,
null as algae_percent,
case
    when pietine  = '0' then 'no'
    when pietine  = 'nsp' then 'yes'
    else 'yes'
end as trampling,
NULLIF(NULLIF(pourcbergedegrad2::text, '0'), 'NA')::int trampling_percent,
case
    when pietine  = 'humaine' then 'humans'
    when pietine  = 'animale domestique' then 'domestic'
    when pietine  = 'animale sauvage' then 'wild'
    when pietine  = 'nsp' then 'unknown'
    else NULL
end as trampling_type,
case
    when sentier100  like 'non' then 'no'
    when sentier100 like 'oui' then 'yes'
    else NULL
end as path,
case
    when sentier100 like 'oui' and sentloc  like 'non' then 'bank'
    when sentier100 like 'oui' and sentloc  like 'tres pres' then 'bank'
    when sentier100 like 'oui' and sentloc  like 'sur berges' then 'bank'
    when sentier100 like 'oui' and sentloc  like '<10m' then '<10m'
    when sentier100 like 'oui' and sentloc  like '< 10m' then '<10m'
    when sentier100 like 'oui' and sentloc  like 'aucun' then '<100m'
    else NULL
end as path_localisation,
case
    when dechets1 like 'dechets' or dechets2 like 'dechets' then 'yes'
    else 'no'
end as waste,
case
    when dechets1 like 'dechets' and locdechets1 like 'berges' then 'bank'
    when dechets1 like 'dechets' and locdechets1 like 'eau' then 'water'
    when dechets2 like 'dechets' and locdechets2 like 'berges' then 'bank'
    when dechets2 like 'dechets' and locdechets2 like 'eau' then 'water'
    else NULL
end as waste_localisation,
case
    when dechets1 like 'dejections' or dechets2 like 'dejections' then 'yes'
    else 'no'
end as excrement,
case
    when dechets1 like 'dejections' and locdechets1 like 'berges' then 'bank'
    when dechets1 like 'dejections' and locdechets1 like 'eau' then 'water'
    when dechets2 like 'dejections' and locdechets2 like 'berges' then 'bank'
    when dechets2 like 'dejections' and locdechets2 like 'eau' then 'water'
    else NULL
end as excrement_localisation,
null as protocol,
null as amphibian_presence,
null as odonate_presence,
null as reptile_presence,
case
    when remarques like 'aucun' then NULL
    when remarques like 'aucune' then NULL
    when remarques like 'NA' then NULL
    when remarques like 'RAS' then NULL
    else remarques
end as site_comment,
null as site_image,
	now()::date as import_date,
	'Import manuel 2021-2022 - Premier passage' as import_source,
null as	update_date,
null as	update_user,
st_transform(st_setsrid(st_makepoint(x::numeric, y::numeric),2154),4326) AS geom
from integration.cimae_protocole_passages_integration a
);
