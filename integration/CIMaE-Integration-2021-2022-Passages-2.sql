-- # Intégration des données CIMaE 2021-2022

--	# Récupération des "Passages 2"
insert into submissions.cimae_protocole_passages (
select 
concat('uuid:',gen_random_uuid()) as data_id,
site as site_name,
date2::date as passage_date,
date_trunc('minute', (interval '1 day' * NULLIF(replace(heurarriv2, ',', '.'), 'NA')::numeric)::time + interval '59 seconds')::time as passage_time_begin,
date_trunc('minute', (interval '1 day' * NULLIF(replace(heurdep2,   ',', '.'), 'NA')::numeric)::time + interval '59 seconds')::time AS passage_time_end,
observateur_s2 as user_name,
null as user_mail,
null as passage_collective,
null as passage_monitoring,
null as unit,
null as unit_type,
null as unit_name,
case
	when NULLIF(replace(surfaceeau2, ',', '.'), 'NA')::numeric = 0 then 'yes'
	else 'no'
end as water_dry,
NULLIF(replace(surfaceeau2, ',', '.'), 'NA')::numeric as water_area,
'NA' as water_area_measure,
null as water_transect_lenght,
null as water_transect_lenght_measure,
NULLIF(replace(profondeur2, ',', '.'), 'NA')::numeric as water_depth_mean,
null as water_depth_max,
'NA' as water_depth_measure,
case
    when transpeau2 like 'je ne vois pas le fond' then 'no'
    when transpeau2 like 'je vois le fond mais mal' then 'bad'
    when transpeau2 like 'je vois le fond' then 'yes'
    else NULL
end as water_transparency,
case
    when alimentationsite2 like 'source' then 'source'
    when alimentationsite2 like 'cours d''eau' then 'river'
    when alimentationsite2 like 'ruissellement' then 'runoff'
    when alimentationsite2 like 'fonte' then 'melting'
    when alimentationsite2 like 'precipitations' then 'precipitation'
    when alimentationsite2 like 'nsp' then 'unknown'
    else NULL
end as wetland_feed,
NULLIF(replace(largeurmoyennecoureau2, ',', '.'), 'NA')::numeric as wetland_feed_river_width,
NULLIF(replace(profondeurmoyennecoureau2, ',', '.'), 'NA')::numeric as wetland_feed_river_depth,
'NA' as wetland_feed_river_measure,
'NA' as wetland_outlet,
case 
    when trim(largeurmoyenneexutoire2) in ('NA', 'nsp') then NULL
    else replace(largeurmoyenneexutoire2, ',', '.')::numeric
end as wetland_outlet_width,
case 
    when trim(profondeurmoyenneexutoire2) in ('NA', 'nsp') then NULL
    else replace(profondeurmoyenneexutoire2, ',', '.')::numeric
end as wetland_outlet_depth,
'NA' as wetland_outlet_measure,
concat_ws(' ',
    case when NULLIF(NULLIF("rocher/roche2", '0'), 'NA')::int > 0 then 'rock' end,
    case when NULLIF(NULLIF(gravier2, '0'), 'NA')::int > 0 then 'gravel' end,
    case when NULLIF(NULLIF(sable2, '0'), 'NA')::int > 0 then 'sand' end,
    case when NULLIF(NULLIF(tourbe2, '0'), 'NA')::int > 0 then 'peat' end,
    case when NULLIF(NULLIF(terre2, '0'), 'NA')::int > 0 then 'soil' end,
    case when NULLIF(NULLIF(vase2, '0'), 'NA')::int > 0 then 'mud' end
) as substrate_type,
	NULLIF(NULLIF("rocher/roche2", '0'), 'NA')::int as substrate_percent_rock,
	NULLIF(NULLIF(gravier2, '0'), 'NA')::int as substrate_percent_gravel,
	NULLIF(NULLIF(sable2, '0'), 'NA')::int as substrate_percent_sand,
	NULLIF(NULLIF(tourbe2, '0'), 'NA')::int as substrate_percent_peat,
	NULLIF(NULLIF(terre2, '0'), 'NA')::int as substrate_percent_soil,
	NULLIF(NULLIF(vase2, '0'), 'NA')::int as substrate_percent_mud,
case
    when prespoissons2 like 'non' then 'no'
    when prespoissons2 like 'oui' then 'yes'
    when prespoissons2 like 'nsp' then 'nsp'
    else NULL
end as fish,
null as vegetation_tree,
coalesce(NULLIF(concat_ws(' ',
    case when NULLIF(NULLIF(vegetpieceeau2::text, '0'), 'NA')::int > 0 then 'water' end,
    case when NULLIF(NULLIF(vegetberge2::text, '0'), 'NA')::int > 0 then 'bank' end,
    case when NULLIF(NULLIF(vegetenv2::text, '0'), 'NA')::int > 0 then 'around' end
), ''), 'no') as vegetation_type,
	NULLIF(NULLIF(vegetpieceeau2::text, '0'), 'NA')::int vegetation_percent_water,
	NULLIF(NULLIF(vegetberge2::text, '0'), 'NA')::int vegetation_percent_bank,
	NULLIF(NULLIF(vegetenv2::text, '0'), 'NA')::int vegetation_percent_around,
case
    when ceintveget2 like 'non' then 'no'
    when ceintveget2 like 'oui' then 'yes'
    else NULL
end as vegetation_belt,
case
	when ceintveget2 like 'non' then 0
	else NULLIF(replace(largceint2, ',', '.'), 'NA')::numeric
end as vegetation_belt_width,
case
	when tourpieceau2 like 'oui' then 100
	when ceintveget2 like 'non' then 0
	else NULLIF(replace(pourcperim2, ',', '.'), 'NA')::numeric
end as vegetation_belt_percent,
case
    when alguefil2  like 'non' then 'no'
    when alguefil2 like 'oui' then 'yes'
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
    when pietine2  = 'humaine' then 'humans'
    when pietine2  = 'animale domestique' then 'domestic'
    when pietine2  = 'animale sauvage' then 'wild'
    when pietine2  = 'nsp' then 'unknown'
    else NULL
end as trampling_type,
case
    when sentier100_2  like 'non' then 'no'
    when sentier100_2 like 'oui' then 'yes'
    else NULL
end as path,
case
    when sentier100_2 like 'oui' and sentloc  like 'non' then 'bank'
    when sentier100_2 like 'oui' and sentloc  like 'tres pres' then 'bank'
    when sentier100_2 like 'oui' and sentloc  like 'sur berges' then 'bank'
    when sentier100_2 like 'oui' and sentloc  like '<10m' then '<10m'
    when sentier100_2 like 'oui' and sentloc  like '< 10m' then '<10m'
    when sentier100_2 like 'oui' and sentloc  like 'aucun' then '<100m'
    else NULL
end as path_localisation,
case
    when dechets1_2 like 'dechets' or dechets2_2 like 'dechets' then 'yes'
    else 'no'
end as waste,
case
    when dechets1_2 like 'dechets' and locdechets1_2 like 'berges' then 'bank'
    when dechets1_2 like 'dechets' and locdechets1_2 like 'eau' then 'water'
    when dechets2_2 like 'dechets' and locdechets2_2 like 'berges' then 'bank'
    when dechets2_2 like 'dechets' and locdechets2_2 like 'eau' then 'water'
    else NULL
end as waste_localisation,
case
    when dechets1_2 like 'dejections' or dechets2_2 like 'dejections' then 'yes'
    else 'no'
end as excrement,
case
    when dechets1_2 like 'dejections' and locdechets1_2 like 'berges' then 'bank'
    when dechets1_2 like 'dejections' and locdechets1_2 like 'eau' then 'water'
    when dechets2_2 like 'dejections' and locdechets2_2 like 'berges' then 'bank'
    when dechets2_2 like 'dejections' and locdechets2_2 like 'eau' then 'water'
    else NULL
end as excrement_localisation,
null as protocol,
null as amphibian_presence,
null as odonate_presence,
null as reptile_presence,
case
    when remarques2 like 'aucun' then NULL
    when remarques2 like 'aucune' then NULL
    when remarques2 like 'NA' then NULL
    when remarques2 like 'RAS' then NULL
    else remarques2
end as site_comment,
null as site_image,
	now()::date as import_date,
	'Import manuel 2021-2022 - Deuxième passage' as import_source,
null as	update_date,
null as	update_user,
st_transform(st_setsrid(st_makepoint(x::numeric, y::numeric),2154),4326) AS geom
from integration.cimae_protocole_passages_integration a
);