-- Récupération des données depuis la dernière soumission
-- Tache cron - Exécution 01h00 et 13h00 = 0 1,13 * * * psql -h localhost -p 7432 -U postgres -f /home/gcostes/plpyodk/get_cimae_public.sql -d cimae

CREATE MATERIALIZED VIEW IF NOT EXISTS odk_central."cimae-protocole_last_submission_date" AS 
	SELECT max("submissionDate")::text AS last_submission_date
	FROM odk_central."cimae-protocole_submissions_data";

REFRESH MATERIALIZED VIEW odk_central."cimae-protocole_last_submission_date";

SELECT plpyodk.odk_central_to_pg(
	16,		-- the project id, 
	'cimae-protocole'::text,		-- form ID
	'odk_central'::text,		-- schema where to create tables and store data
	concat('__system/submissionDate ge ',last_submission_date),		-- the filter "clause" used in the API call ex. '__system/submissionDate ge 2023-04-01'. Empty string ('') will get all the datas. 
	'site_geopoint'::text		-- (geo)columns to ignore in json transformation to database attributes (geojson fields of GeoWidgets)
)
FROM odk_central."cimae-protocole_last_submission_date";