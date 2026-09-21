-- Récupération des données depuis la dernière soumission
-- Tache cron - Exécution 01h25 et 13h25 = 25 1,13 * * * psql -h localhost -p 7432 -U postgres -f /home/gcostes/plpyodk/get_cimae_suivi_trient.sql -d cimae

CREATE MATERIALIZED VIEW IF NOT EXISTS odk_central."cimae-suivi-trient_last_submission_date" AS 
	SELECT max("submissionDate")::text AS last_submission_date
	FROM odk_central."cimae-suivi-trient_submissions_data";

REFRESH MATERIALIZED VIEW odk_central."cimae-suivi-trient_last_submission_date";

SELECT plpyodk.odk_central_to_pg(
	16,		-- the project id, 
	'cimae-suivi-trient'::text,		-- form ID
	'odk_central'::text,		-- schema where to create tables and store data
	concat('__system/submissionDate ge ',last_submission_date),		-- the filter "clause" used in the API call ex. '__system/submissionDate ge 2023-04-01'. Empty string ('') will get all the datas. 
	'site_geopoint'::text		-- (geo)columns to ignore in json transformation to database attributes (geojson fields of GeoWidgets)
)
FROM odk_central."cimae-suivi-trient_last_submission_date";

/*
create table submissions.cimae_suivi_trient (
	data_id text not NULL,
	passage_date date,
	passage_time time,
	water_presence text,
	water_percent int,
	water_type text,
	water_transparency text,
	wetland_feed text,
	wetland_pressure text,
	amphibian_presence text,
	amphibian_stage text,
	amphibian_egg int,
	user_name text,
	user_mail text,
	site_image text,
	geom geometry(point, 4326),
	CONSTRAINT cimae_suivi_trient_pkey PRIMARY KEY (data_id)
);
*/

/*
-- Création de la fonction trigger
CREATE OR REPLACE FUNCTION submissions.insert_cimae_suivi_trient()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO submissions.cimae_suivi_trient (
        data_id,
        passage_date,
        passage_time,
        water_presence,
		water_percent,
		water_type,
		water_transparency,
		wetland_feed,
		wetland_pressure,
		amphibian_presence,
		amphibian_stage,
		amphibian_egg,
        user_name,
        user_mail,
        site_image,
        geom
    )
    VALUES (
        NEW.data_id,
        NEW.passage_date::date,
        to_char(NEW.passage_time_begin::time, 'HH24:MI')::time,
        NEW.water_presence,
		NEW.water_percent::int,
		NEW.water_type,
		NEW.water_transparency,
		NEW.wetland_feed,
		NEW.wetland_pressure,
		NEW.amphibian_presence,
		NEW.amphibian_stage,
		NEW.amphibian_egg::int,
        NEW.user_name,
        lower(NEW.user_mail),
        CASE
            WHEN NEW.site_image IS NOT NULL THEN 
                concat('https://central.sicen.fr/v1/projects/16/forms/cimae-suivi-trient/submissions/',
                       NEW."instanceID",
                       '/attachments/',
                       NEW.site_image)
            ELSE NULL
        END,
        st_force2d(st_geomfromgeojson(replace(COALESCE(NEW.site_geopoint), '\', '')))::geometry(point, 4326)
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Création du trigger
CREATE TRIGGER insert_cimae_suivi_trient
AFTER INSERT ON odk_central."cimae-suivi-trient_submissions_data"
FOR EACH ROW
EXECUTE FUNCTION submissions.insert_cimae_suivi_trient();

*/