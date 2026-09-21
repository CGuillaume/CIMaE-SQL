-- Récupération des données depuis la dernière soumission
-- Tache cron - Exécution 01h20 et 13h20 = 20 1,13 * * * psql -h localhost -p 7432 -U postgres -f /home/gcostes/plpyodk/get_cimae_macroinv.sql -d cimae

CREATE MATERIALIZED VIEW IF NOT EXISTS odk_central."cimae-macroinv_last_submission_date" AS 
	SELECT max("submissionDate")::text AS last_submission_date
	FROM odk_central."cimae-macroinv_submissions_data";

REFRESH MATERIALIZED VIEW odk_central."cimae-macroinv_last_submission_date";

SELECT plpyodk.odk_central_to_pg(
	16,		-- the project id, 
	'cimae-macroinv'::text,		-- form ID
	'odk_central'::text,		-- schema where to create tables and store data
	concat('__system/submissionDate ge ',last_submission_date),		-- the filter "clause" used in the API call ex. '__system/submissionDate ge 2023-04-01'. Empty string ('') will get all the datas. 
	'site_geopoint'::text		-- (geo)columns to ignore in json transformation to database attributes (geojson fields of GeoWidgets)
)
FROM odk_central."cimae-macroinv_last_submission_date";

/*
CREATE TABLE submissions.cimae_macroinv (
	data_id text NOT NULL,
	sampling_date date NULL,
	sampling_time time NULL,
	sampling_number text NULL,
	sampling_type text NULL,
	mosquito_presence text NULL,
	user_name text NULL,
	user_mail text NULL,
	geom public.geometry(point, 4326) NULL,
	CONSTRAINT cimae_macroinv_pkey PRIMARY KEY (data_id)
);
*/

/*
CREATE OR REPLACE FUNCTION submissions.insert_cimae_macroinv()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO submissions.cimae_macroinv (
        data_id,
		sampling_date,
		sampling_time,
		sampling_number,
		sampling_type,
		mosquito_presence,
		user_name,
		user_mail,
		geom
    )
    VALUES (
        NEW.data_id,
        NEW.sampling_date::date,
        to_char(NEW.sampling_time::time, 'HH24:MI')::time,
		lpad(NEW.sampling_number,3,'0'),
        NEW.sampling_type,
        NEW.mosquito_presence,
        NEW.user_name,
		lower(NEW.user_mail),
        st_force2d(st_geomfromgeojson(replace(COALESCE(NEW.site_geopoint), '\', '')))::geometry(point, 4326)
    );
    
    RETURN NEW;
END;
$function$
;
*/

/*
create trigger insert_cimae_macroinv after
insert
    on
    odk_central."cimae-macroinv_submissions_data" for each row execute function submissions.insert_cimae_macroinv();
*/
