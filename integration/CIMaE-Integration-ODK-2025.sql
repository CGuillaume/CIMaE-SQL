--Récupération des passages ODK 2025

-- Passages 2025 sur nouveaux sites
insert into submissions.cimae_protocole_passages (
select sub.key as data_id,  
	site_name_add as site_name, /*site_name_maj,*/
	passage_date_begin_1 passage_date, to_char(passage_time_begin_1::time, 'HH24:MI')::time passage_time_begin, to_char(passage_time_end::time, 'HH24:MI')::time passage_time_end,
	user_name_1 user_name, lower(user_mail_1) user_mail,
	passage_collective_1 passage_collective, passage_monitoring_1 passage_monitoring,
	unit_1 unit, unit_type_1 unit_type, unit_name_1 unit_name,
	water_dry, water_area, water_area_measure, 
null as water_transect_lenght,
null as water_transect_lenght_measure,
	water_depth water_depth_mean,
null as water_depth_max, water_depth_measure, water_transparency,
	wetland_feed, wetland_feed_river_width, wetland_feed_river_depth, wetland_feed_river_measure,
	wetland_outlet, wetland_outlet_width, wetland_outlet_depth, wetland_outlet_measure,
	substrate_type, substrate_percent_rock, substrate_percent_gravel, substrate_percent_sand::integer, substrate_percent_peat, substrate_percent_soil, substrate_percent_mud,
	fish,
	vegetation_tree, vegetation_type, vegetation_percent_water, vegetation_percent_bank, vegetation_percent_around,
	vegetation_belt, vegetation_belt_width, vegetation_belt_percent,
	algae, algae_percent,
	trampling, trampling_percent, trampling_type,
	path, path_localisation,
	waste, waste_localisation,
	excrement, excrement_localisation,
	protocol, amphibian_presence, odonate_presence,
null as reptile_presence,
	replace(site_comment, '\\n', chr(10)) site_comment,
	array_to_string(array_agg(img.site_image), chr(10)) site_image,
	now()::date as import_date,
	'Import manuel 2025 - Nouveau sites' as import_source,
null as	update_date,
null as	update_user,
	st_force2d(st_setsrid(st_makepoint("site_geopoint-longitude", "site_geopoint-latitude"),4326))::geometry(geometry, 4326) AS geom
from integration."cimae-protocole-2025" sub
	left join integration."cimae-protocole-2025-site_image_repeat" img on sub.key = img.parent_key
where site_name_add is not null
group by sub.id, site_name_add, site_name_maj, passage_date_begin, passage_time_begin, passage_time_end, user_name, user_mail, passage_collective, passage_monitoring,
unit, unit_type, unit_type_other, unit_name, water_dry, water_area, water_area_measure, water_depth, water_depth_measure, water_transparency,
wetland_feed, wetland_feed_river_width, wetland_feed_river_depth, wetland_feed_river_measure, wetland_outlet, wetland_outlet_width, wetland_outlet_depth, wetland_outlet_measure,
substrate_type, substrate_percent_rock, substrate_percent_gravel, substrate_percent_sand, substrate_percent_peat, substrate_percent_soil, substrate_percent_mud, fish,
vegetation_tree, vegetation_type, vegetation_percent_water, vegetation_percent_bank, vegetation_percent_around,	vegetation_belt, vegetation_belt_width, vegetation_belt_percent,
algae, algae_percent, trampling, trampling_percent, trampling_type, path, path_localisation, waste, waste_localisation, excrement, excrement_localisation,
protocol, amphibian_presence, odonate_presence, site_comment, "site_geopoint-longitude", "site_geopoint-latitude"
);

-- Passages 2025 sur anciens sites (entity)
insert into submissions.cimae_protocole_passages (
select sub.key as data_id,  
	/*site_name_add,*/ entity.label site_name,
	passage_date_begin_1 passage_date, to_char(passage_time_begin_1::time, 'HH24:MI')::time passage_time_begin, to_char(passage_time_end::time, 'HH24:MI')::time passage_time_end,
	user_name_1 user_name, lower(user_mail_1) user_mail,
	passage_collective_1 passage_collective, passage_monitoring_1 passage_monitoring,
	unit_1 unit, unit_type_1 unit_type, unit_name_1 unit_name,
	water_dry, water_area, water_area_measure, 
null as water_transect_lenght,
null as water_transect_lenght_measure,
	water_depth water_depth_mean,
null as water_depth_max, water_depth_measure, water_transparency,
	wetland_feed, wetland_feed_river_width, wetland_feed_river_depth, wetland_feed_river_measure,
	wetland_outlet, wetland_outlet_width, wetland_outlet_depth, wetland_outlet_measure,
	substrate_type, substrate_percent_rock, substrate_percent_gravel, substrate_percent_sand::integer, substrate_percent_peat, substrate_percent_soil, substrate_percent_mud,
	fish,
	vegetation_tree, vegetation_type, vegetation_percent_water, vegetation_percent_bank, vegetation_percent_around,
	vegetation_belt, vegetation_belt_width, vegetation_belt_percent,
	algae, algae_percent,
	trampling, trampling_percent, trampling_type,
	path, path_localisation,
	waste, waste_localisation,
	excrement, excrement_localisation,
	protocol, amphibian_presence, odonate_presence,
null as reptile_presence,
	replace(site_comment, '\\n', chr(10)) site_comment,
	array_to_string(array_agg(img.site_image), chr(10)) site_image,
	now()::date as import_date,
	'Import manuel 2025 - Sites existants' as import_source,
null as	update_date,
null as	update_user,
	st_force2d(st_setsrid(st_makepoint(split_part(entity.geometry, ' ', 2)::float, split_part(entity.geometry, ' ', 1)::float),4326))::geometry(geometry, 4326) AS geom
from integration."cimae-protocole-2025" sub
	left join integration."cimae-protocole-2025-site_image_repeat" img on sub.key = img.parent_key
	left join integration."cimae-protocole-2025_sites_entity" entity on sub.site_name_maj = entity.__id
where site_name_maj is not null
group by sub.id, site_name_add, site_name_maj, entity.label, passage_date_begin, passage_time_begin, passage_time_end, user_name, user_mail, passage_collective, passage_monitoring,
sub.unit, unit_type, unit_type_other, unit_name, water_dry, water_area, water_area_measure, water_depth, water_depth_measure, water_transparency,
wetland_feed, wetland_feed_river_width, wetland_feed_river_depth, wetland_feed_river_measure, wetland_outlet, wetland_outlet_width, wetland_outlet_depth, wetland_outlet_measure,
substrate_type, substrate_percent_rock, substrate_percent_gravel, substrate_percent_sand, substrate_percent_peat, substrate_percent_soil, substrate_percent_mud, fish,
vegetation_tree, vegetation_type, vegetation_percent_water, vegetation_percent_bank, vegetation_percent_around,	vegetation_belt, vegetation_belt_width, vegetation_belt_percent,
algae, algae_percent, trampling, trampling_percent, trampling_type, path, path_localisation, waste, waste_localisation, excrement, excrement_localisation,
protocol, amphibian_presence, odonate_presence, site_comment, entity.geometry
);

-- List amphibian
select amp.data_id, amp."__Submissions-id" submission_id, sub.passage_date_begin date,
	sub.amphibian_expertise expertise, sub.amphibian_authorisation authorisation, coalesce(sub.amphibian_net, 'no') net, coalesce(sub.amphibian_net_count, '0')::int net_count,
	replace(amphibian_species_label, '*', '') species, amphibian_species cd_ref,
	amphibian_egg_identification egg_identification,
	case when amphibian_egg::int = 0 then 'exact' else amphibian_egg_estimate end egg_estimate, amphibian_egg::int egg,
	case when amphibian_larva::int = 0 then 'exact' else amphibian_larva_estimate end larva_estimate, amphibian_larva::int larva,
	case when amphibian_juvenile::int = 0 then 'exact' else amphibian_juvenile_estimate end juvenile_estimate, amphibian_juvenile::int juvenile,
	case when amphibian_adult::int = 0 then 'exact' else amphibian_adult_estimate end adult_estimate, amphibian_adult::int adult,
	case when amphibian_female::int = 0 then 'exact' else amphibian_female_estimate end female_estimate, amphibian_female::int female,
	amphibian_count::int count,
	coalesce(amphibian_dead, '0')::int dead,
	amphibian_reproduction reproduction
from odk_central."cimae-protocole_submissions_data" sub
	join odk_central."cimae-protocole_repeat_amphibian_data" amp on sub."__id" = amp."__Submissions-id"
where amphibian_species is not null

-- List odonate
with t as (
select odo.data_id, odo."__Submissions-id" submission_id, sub.passage_date_begin date,
	sub.odonate_expertise expertise, coalesce(sub.odonate_net, 'no') net, coalesce(sub.odonate_net_count, '0')::int net_count,
	replace(odonate_species_label, '*', '') species, odonate_species cd_ref,
	odonate_larva_identification larva_identification,
	case 
		when odonate_larva::int = 0 then 'exact'
		else odonate_larva_estimate
	end larva_estimate, 
	case
		when odonate_larva_estimate is not null then coalesce(odonate_larva, '0')::int
		else odonate_larva::int
	end larva,
	case 
		when odonate_exuvie::int = 0 then 'exact'
		when odonate_exuvie is null then 'exact'
		else odonate_exuvie_estimate
	end exuvie_estimate, coalesce(odonate_exuvie, '0')::int exuvie,
	case 
		when odonate_immature::int = 0 then 'exact'
		when odonate_immature is null then 'exact'
		else odonate_immature_estimate
	end immature_estimate, coalesce(odonate_immature, '0')::int immature,
	case when odonate_adult::int = 0 then 'exact' else odonate_adult_estimate end adult_estimate, odonate_adult::int adult,
	case when odonate_female::int = 0 then 'exact' else odonate_female_estimate end female_estimate, odonate_female::int female,
	odonate_count::int count,
	coalesce(odonate_dead, '0')::int dead,
	odonate_behavior behavior,
case 
	when odonate_photo is not null then  concat('https://central.sicen.fr/v1/projects/16/forms/cimae-protocole/submissions/',"instanceID",'/attachments/',img.odonate_photo)
	else null
end as odonate_photo
from odk_central."cimae-protocole_submissions_data" sub
	join odk_central."cimae-protocole_repeat_odonate_data" odo on sub."__id" = odo."__Submissions-id"
	left join odk_central."cimae-protocole_odonate_photo_repeat_data" img on odo."__id" = img."__Submissions-group_odonate-group_odonate_1-repeat_odonate-id"
where odonate_species is not null
)
select data_id, submission_id, "date", expertise, net, net_count, species, cd_ref, larva_identification, larva_estimate, larva, exuvie_estimate, exuvie,
	immature_estimate, immature, adult_estimate, adult, female_estimate, female, count, dead, behavior,
	array_to_string(array_agg(odonate_photo), chr(10)) odonate_photo
from t 
group by data_id, submission_id, "date", expertise, net, net_count, species, cd_ref, larva_identification, larva_estimate, larva, exuvie_estimate, exuvie,
	immature_estimate, immature, adult_estimate, adult, female_estimate, female, count, dead, behavior


-- List macrophyte 
select qua.data_id, qua."__Submissions-id" submission_id, sub.passage_date_begin date,
	sub.macrophyte_expertise expertise,
	qua.quadrat_index::int, 'no' grapple, qua.quadrat_percent_ground::int percent_ground,
	replace(sp.macrophyte_current_species, '*', '') species, sp.macrophyte_current_species_number::int number, sp.macrophyte_current_species_abundance::int abundance,
	st_force2d(st_geomfromgeojson(replace(COALESCE(qua.quadrat_geopoint),'\','')))::geometry(geometry, 4326) AS geom
from odk_central."cimae-protocole_submissions_data" sub
	join odk_central."cimae-protocole_repeat_macrophyte_quadrat_data" qua on sub."__id" = qua."__Submissions-id"
	join odk_central."cimae-protocole_repeat_macrophyte_abundance_data" sp on qua."__id" = sp."__Submissions-group_macrophyte_1-repeat_macrophyte_quadrat-id"
union 
select qua.data_id, qua."__Submissions-id" submission_id, sub.passage_date_begin date,
	sub.macrophyte_expertise expertise,
	qua.quadrat_index::int, 'yes' grapple, qua.quadrat_percent_ground::int percent_ground,
	replace(macrophyte_grapple_current_species, '*', '') species, gsp.macrophyte_grapple_current_species_number::int number, gsp.macrophyte_grapple_current_species_abundance::int abundance,
	st_force2d(st_geomfromgeojson(replace(COALESCE(qua.quadrat_geopoint),'\','')))::geometry(geometry, 4326) AS geom
from odk_central."cimae-protocole_submissions_data" sub
	join odk_central."cimae-protocole_repeat_macrophyte_quadrat_data" qua on sub."__id" = qua."__Submissions-id"
	join odk_central."cimae-protocole_repeat_macrophyte_grapple_abundance_data" gsp on qua."__id" = gsp."__Submissions-group_macrophyte_1-repeat_macrophyte_quadrat-id"
union
select qua.data_id, qua."__Submissions-id" submission_id, sub.passage_date_begin date,
	sub.macrophyte_expertise expertise,
	qua.quadrat_index::int, 'no' grapple, qua.quadrat_percent_ground::int percent_ground,
	replace(sp.macrophyte_current_species, '*', '') species, sp.macrophyte_current_species_number::int number, sp.macrophyte_current_species_abundance::int abundance,
	st_force2d(st_geomfromgeojson(replace(COALESCE(qua.quadrat_geopoint),'\','')))::geometry(geometry, 4326) AS geom
from odk_central."cimae-protocole_submissions_data" sub
	join odk_central."cimae-protocole_repeat_macrophyte_quadrat_data" qua on sub."__id" = qua."__Submissions-id"
	left join odk_central."cimae-protocole_repeat_macrophyte_abundance_data" sp on qua."__id" = sp."__Submissions-group_macrophyte_1-repeat_macrophyte_quadrat-id"
where qua.quadrat_percent_ground = '100'


	
