-- Voir avec Thibault s'il peut nous retrouver les localisations

/*
--1-creation de la table passage 
--2-integration des passages 2021-2022 Passage 1 & 2
--3-integration des passages 2025 add script2
--4-integration des passages 2025 maj avec les entités 
--5-integration des passages 2026 add
--5-integration des passages 2026 en récupérant la geom des précedents ?
6-faire les fonctions trigger d''intégration auto pour les passages
trigger sur les dates maj
*/

drop table submissions.cimae_protocole_passages;
CREATE TABLE submissions.cimae_protocole_passages (
	data_id text NULL,
	site_name text NULL,
	passage_date date NULL,
	passage_time_begin time NULL,
	passage_time_end time NULL,
	user_name text NULL,
	user_mail text NULL,
	passage_collective text NULL,
	passage_monitoring text NULL,
	unit text NULL,
	unit_type text NULL,
	unit_name text NULL,
	water_dry text NULL,
	water_area int NULL,
	water_area_measure text NULL,
	water_transect_length real NULL,
	water_transect_length_measure text NULL,
	water_depth_mean real NULL,
	water_depth_max real NULL,
	water_depth_measure text NULL,
	water_transparency text NULL,
	wetland_feed text NULL,
	wetland_feed_river_width real NULL,
	wetland_feed_river_depth real NULL,
	wetland_feed_river_measure text NULL,
	wetland_outlet text NULL,
	wetland_outlet_width real NULL,
	wetland_outlet_depth real NULL,
	wetland_outlet_measure text NULL,
	substrate_type text NULL,
	substrate_percent_rock int NULL,
	substrate_percent_gravel int NULL,
	substrate_percent_sand int NULL,
	substrate_percent_peat int NULL,
	substrate_percent_soil int NULL,
	substrate_percent_mud int NULL,
	fish text NULL,
	vegetation_tree text NULL,
	vegetation_type text NULL,
	vegetation_percent_water int NULL,
	vegetation_percent_bank int NULL,
	vegetation_percent_around int NULL,
	vegetation_belt text NULL,
	vegetation_belt_width real NULL,
	vegetation_belt_percent int NULL,
	algae text NULL,
	algae_percent int NULL,
	trampling text NULL,
	trampling_percent int NULL,
	trampling_type text NULL,
	"path" text NULL,
	path_localisation text NULL,
	waste text NULL,
	waste_localisation text NULL,
	excrement text NULL,
	excrement_localisation text NULL,
	protocol text NULL,
	amphibian_presence text NULL,
	odonate_presence text NULL,
	reptile_presence text NULL,
	site_comment text NULL,
	site_image text NULL,
	import_date date NULL,
	import_source text NULL,
	update_date date NULL,
	update_user text NULL,
	geom public.geometry(point, 4326) NULL,
	CONSTRAINT cimae_protocole_passages_pkey PRIMARY KEY (data_id)
);

-- Passages 2026 sur nouveaux sites
insert into submissions.cimae_protocole_passages (
select sub.data_id,  
	sub.site_name_new site_name,
	sub.passage_date_begin::date passage_date, to_char(sub.passage_time_begin::time, 'HH24:MI')::time passage_time_begin, to_char(sub.passage_time_end::time, 'HH24:MI')::time passage_time_end,
	sub.user_name, lower(sub.user_mail) user_mail,
	sub.passage_collective, sub.passage_monitoring,
	sub.unit, sub.unit_type, sub.unit_name,
	sub.water_dry, sub.water_area::int, sub.water_area_measure,
	sub.water_transect_length::real, sub.water_transect_length_measure,
	sub.water_depth_mean::real, sub.water_depth_max::real, sub.water_depth_measure, sub.water_transparency,
	sub.wetland_feed, sub.wetland_feed_river_width::real, sub.wetland_feed_river_depth::real, sub.wetland_feed_river_measure,
	sub.wetland_outlet, sub.wetland_outlet_width::real, sub.wetland_outlet_depth::real, sub.wetland_outlet_measure,
	sub.substrate_type, sub.substrate_percent_rock::int, sub.substrate_percent_gravel::int, sub.substrate_percent_sand::int, sub.substrate_percent_peat::int, sub.substrate_percent_soil::int, sub.substrate_percent_mud::int,
	sub.fish,
	sub.vegetation_tree, sub.vegetation_type, sub.vegetation_percent_water::int, sub.vegetation_percent_bank::int, sub.vegetation_percent_around::int,
	sub.vegetation_belt, sub.vegetation_belt_width::real, sub.vegetation_belt_percent::int,
	sub.algae, sub.algae_percent::int,
	sub.trampling, sub.trampling_percent::int, sub.trampling_type,
	sub.path, sub.path_localisation,
	sub.waste, sub.waste_localisation,
	sub.excrement, sub.excrement_localisation,
	sub.protocol, sub.amphibian_presence, sub.odonate_presence, sub.reptile_presence,
	replace(sub.site_comment, '\\n', chr(10)) site_comment,
	array_to_string(array_agg(concat('https://central.sicen.fr/v1/projects/16/forms/cimae-protocole/submissions/',"instanceID",'/attachments/',img.site_image)), chr(10)) site_image,
	now()::date as import_date,
	'Import manuel 2026 - Nouveau sites' as import_source,
null as	update_date,
null as	update_user,	
	st_force2d(st_geomfromgeojson(replace(COALESCE(sub.site_geopoint),'\','')))::geometry(point, 4326) AS geom
from odk_central."cimae-protocole_submissions_data" sub
	left join odk_central."cimae-protocole_site_image_repeat_data" img on sub."__id" = img."__Submissions-id"
where sub.site_name_new is not null
group by sub.data_id, "submitterName", site_name_new, sub.passage_date_begin, sub.passage_time_begin, sub.passage_time_end, sub.user_name, sub.user_mail, sub.passage_collective, sub.passage_monitoring,
sub.unit, sub.unit_type, sub.unit_name, sub.water_dry, sub.water_area, sub.water_area_measure, sub.water_transect_length, sub.water_transect_length_measure, sub.water_depth_mean, sub.water_depth_max, sub.water_depth_measure, sub.water_transparency,
sub.wetland_feed, sub.wetland_feed_river_width, sub.wetland_feed_river_depth, sub.wetland_feed_river_measure, sub.wetland_outlet, sub.wetland_outlet_width, sub.wetland_outlet_depth, sub.wetland_outlet_measure,
sub.substrate_type, sub.substrate_percent_rock, sub.substrate_percent_gravel, sub.substrate_percent_sand, sub.substrate_percent_peat, sub.substrate_percent_soil, sub.substrate_percent_mud, sub.fish,
sub.vegetation_tree, sub.vegetation_type, sub.vegetation_percent_water, sub.vegetation_percent_bank, sub.vegetation_percent_around,	sub.vegetation_belt, sub.vegetation_belt_width, sub.vegetation_belt_percent,
sub.algae, sub.algae_percent, sub.trampling, sub.trampling_percent, sub.trampling_type, sub.path, sub.path_localisation, sub.waste, sub.waste_localisation, sub.excrement, sub.excrement_localisation,
sub.protocol, sub.amphibian_presence, sub.odonate_presence, sub.reptile_presence, sub.site_comment, sub.site_geopoint
);


-- Passages 2026 sur sites cimae existants
insert into submissions.cimae_protocole_passages (
select sub.data_id,  
	sub.site_name,
	sub.passage_date_begin::date passage_date, to_char(sub.passage_time_begin::time, 'HH24:MI')::time passage_time_begin, to_char(sub.passage_time_end::time, 'HH24:MI')::time passage_time_end,
	sub.user_name, lower(sub.user_mail) user_mail,
	sub.passage_collective, sub.passage_monitoring,
	sub.unit, sub.unit_type, sub.unit_name,
	sub.water_dry, sub.water_area::int, sub.water_area_measure,
	sub.water_transect_length::real, sub.water_transect_length_measure,
	sub.water_depth_mean::real, sub.water_depth_max::real, sub.water_depth_measure, sub.water_transparency,
	sub.wetland_feed, sub.wetland_feed_river_width::real, sub.wetland_feed_river_depth::real, sub.wetland_feed_river_measure,
	sub.wetland_outlet, sub.wetland_outlet_width::real, sub.wetland_outlet_depth::real, sub.wetland_outlet_measure,
	sub.substrate_type, sub.substrate_percent_rock::int, sub.substrate_percent_gravel::int, sub.substrate_percent_sand::int, sub.substrate_percent_peat::int, sub.substrate_percent_soil::int, sub.substrate_percent_mud::int,
	sub.fish,
	sub.vegetation_tree, sub.vegetation_type, sub.vegetation_percent_water::int, sub.vegetation_percent_bank::int, sub.vegetation_percent_around::int,
	sub.vegetation_belt, sub.vegetation_belt_width::real, sub.vegetation_belt_percent::int,
	sub.algae, sub.algae_percent::int,
	sub.trampling, sub.trampling_percent::int, sub.trampling_type,
	sub.path, sub.path_localisation,
	sub.waste, sub.waste_localisation,
	sub.excrement, sub.excrement_localisation,
	sub.protocol, sub.amphibian_presence, sub.odonate_presence, sub.reptile_presence,
	replace(sub.site_comment, '\\n', chr(10)) site_comment,
	array_to_string(array_agg(concat('https://central.sicen.fr/v1/projects/16/forms/cimae-protocole/submissions/',"instanceID",'/attachments/',img.site_image)), chr(10)) site_image,
	now()::date as import_date,
	'Import manuel 2026 - Sites existants' as import_source,
null as	update_date,
null as	update_user,
	sites.geom as geom
from odk_central."cimae-protocole_submissions_data" sub
	left join odk_central."cimae-protocole_site_image_repeat_data" img on sub."__id" = img."__Submissions-id"
	left join submissions.cimae_protocole_passages sites on sub.site_name = sites.site_name
where sub.site_name is not null
group by sub.data_id, "submitterName", site_name_new, sub.site_name, sites.site_name, sub.passage_date_begin, sub.passage_time_begin, sub.passage_time_end, sub.user_name, sub.user_mail, sub.passage_collective, sub.passage_monitoring,
sub.unit, sub.unit_type, sub.unit_name, sub.water_dry, sub.water_area, sub.water_area_measure, sub.water_transect_length, sub.water_transect_length_measure, sub.water_depth_mean, sub.water_depth_max, sub.water_depth_measure, sub.water_transparency,
sub.wetland_feed, sub.wetland_feed_river_width, sub.wetland_feed_river_depth, sub.wetland_feed_river_measure, sub.wetland_outlet, sub.wetland_outlet_width, sub.wetland_outlet_depth, sub.wetland_outlet_measure,
sub.substrate_type, sub.substrate_percent_rock, sub.substrate_percent_gravel, sub.substrate_percent_sand, sub.substrate_percent_peat, sub.substrate_percent_soil, sub.substrate_percent_mud, sub.fish,
sub.vegetation_tree, sub.vegetation_type, sub.vegetation_percent_water, sub.vegetation_percent_bank, sub.vegetation_percent_around,	sub.vegetation_belt, sub.vegetation_belt_width, sub.vegetation_belt_percent,
sub.algae, sub.algae_percent, sub.trampling, sub.trampling_percent, sub.trampling_type, sub.path, sub.path_localisation, sub.waste, sub.waste_localisation, sub.excrement, sub.excrement_localisation,
sub.protocol, sub.amphibian_presence, sub.odonate_presence, sub.reptile_presence, sub.site_comment, sites.geom
);

-- nb de passages par sites
select site_name, count(*) nb
from submissions.cimae_protocole_passages
where passage_date >= '2026-05-01'
group by site_name
order by 2 asc, 1 desc;

-- CIMaE_TV_09_ber_M1 - 3 passages
update submissions.cimae_protocole_passages set geom = t.geom
from (select geom from submissions.cimae_protocole_passages where data_id = 'uuid:d18889a3-04b3-484d-82a0-9af44a73f278') as t
where data_id = 'uuid:a9b10952-4e99-4156-8ce2-9e21e782b5e3'

-- CIMaE_TV_09_ber_M2 - 3 passages
update submissions.cimae_protocole_passages set geom = t.geom
from (select geom from submissions.cimae_protocole_passages where data_id = 'uuid:968682f8-7eb1-4fe7-b631-307435f02997') as t
where data_id = 'uuid:f23d5d51-1616-456a-9eab-942e22ed35d0'

-- CIMaE_TV_09_ber_M3 - 3 passages
update submissions.cimae_protocole_passages set geom = t.geom
from (select geom from submissions.cimae_protocole_passages where data_id = 'uuid:a61a1e3d-0142-44ca-bfe0-e68c7e241722') as t
where data_id = 'uuid:ac8aad2a-7798-4f04-b68d-cd7cb857fe95'

-- CIMaE_LT_06_01 - Doublon de nom 
update submissions.cimae_protocole_passages set site_name = 'CIMaE_LT_06_02'
where data_id = 'uuid:3ed18fcb-b2b7-4570-b0e8-15e572c098b9'

-- Changement de nom de sites + geom pour avoir des geom identiques
update submissions.cimae_protocole_passages set site_name = 'CIMaEPNM_CA_1_1' where site_name =  'CIMaE_LT_04_04';
update submissions.cimae_protocole_passages set geom = t.geom
from (select geom from submissions.cimae_protocole_passages where data_id = 'uuid:78779965-0f40-43af-9d66-90f7085ab8da') as t
where data_id = 'uuid:d5756d2f-24bb-48c4-aced-2f2bdab61df2';

update submissions.cimae_protocole_passages set site_name = 'CIMaEPNM_CA_1_2' where site_name =  'CIMaE_LT_04_05';
update submissions.cimae_protocole_passages set geom = t.geom
from (select geom from submissions.cimae_protocole_passages where data_id = 'uuid:a42cb534-c9e6-44b0-9d50-c6f90bccd50f') as t
where data_id = 'uuid:26a0cb56-f6d0-4ba7-a8f9-fef8dd218afd';

update submissions.cimae_protocole_passages set site_name = 'CIMaEPNM_CA_1_3' where site_name =  'CIMaE_LT_04_06';
update submissions.cimae_protocole_passages set geom = t.geom
from (select geom from submissions.cimae_protocole_passages where data_id = 'uuid:08b8aff0-3d12-4446-845a-2e66e99ce45a') as t
where data_id = 'uuid:9ddd6573-9a1a-446e-bd1d-80644f0b5edb';

update submissions.cimae_protocole_passages set site_name = 'CIMaEPNM_CA_1_4' where site_name =  'CIMaE_LT_04_07';
update submissions.cimae_protocole_passages set geom = t.geom
from (select geom from submissions.cimae_protocole_passages where data_id = 'uuid:f6d6d653-9011-4b34-b90e-bc3c3e2835de') as t
where data_id = 'uuid:057d6ebd-67eb-468e-a6f8-7b88c57dc6ab';

-- Corrections geom
select * from submissions.cimae_protocole_passages where data_id = 'uuid:c6a9bba5-30ca-4d1d-a4d2-1b3c276546e5';
update submissions.cimae_protocole_passages set geom = st_setsrid(st_makepoint(6.7111,45.65305),4326) where data_id = 'uuid:c6a9bba5-30ca-4d1d-a4d2-1b3c276546e5';
