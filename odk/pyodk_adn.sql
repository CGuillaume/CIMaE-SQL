/* 
##	Récupération des données ODK 	##
##	Formulaire ADN					##
*/

-- Utilisation de pl-pyODK : https://github.com/mathieubossaert/pl-pyodk/blob/main/README_FR.md

-- 1-Récupération des données sur la base de données locale

CREATE EXTENSION plpython3u;
CREATE OR REPLACE PROCEDURAL LANGUAGE plpython3u;

-- A éxécuter une première fois sans date de début pour initialiser les tables de récupération des soumissions dans le schéma odk_central
SELECT plpyodk.odk_central_to_pg(
	16,						-- the project id, 
	'cimae-adn'::text,		-- form ID
	'odk_central'::text,	-- schema where to create tables and store data
	''::text,				-- the filter "clause" used in the API call ex. '__system/submissionDate ge 2023-04-01'. Empty string ('') will get all the datas. 
	'site_geopoint'::text	-- (geo)columns to ignore in json transformation to database attributes (geojson fields of GeoWidgets)
);

-- 2-Récupération des données à partir de la dernière soumission (automatisation)
	-- Créer une tache cron qui appelle le SQL suivant :
	-- Exécution 01h10 et 13h10 = 10 1,13 * * * psql -h localhost -p 7432 -U postgres -f /home/gcostes/plpyodk/get_cimae_adn.sql -d cimae
	
	-- Création d'une vue matérialisée pour récupérer la date de dernière soumission
CREATE MATERIALIZED VIEW IF NOT EXISTS odk_central."cimae-adn_last_submission_date" AS 
	SELECT max("submissionDate")::text AS last_submission_date
	FROM odk_central."cimae-adn_submissions_data";
	
REFRESH MATERIALIZED VIEW odk_central."cimae-adn_last_submission_date";
	
	-- Appel à pl-pyODK à partir de la dernière date de soumission
SELECT plpyodk.odk_central_to_pg(
	16,																-- the project id, 
	'cimae-adn'::text,												-- form ID
	'odk_central'::text,											-- schema where to create tables and store data
	concat('__system/submissionDate ge ',last_submission_date),		-- the filter "clause" used in the API call ex. '__system/submissionDate ge 2023-04-01'. Empty string ('') will get all the datas. 
	'site_geopoint'::text											-- (geo)columns to ignore in json transformation to database attributes (geojson fields of GeoWidgets)
)
FROM odk_central."cimae-adn_last_submission_date";					-- materialized view with last submission date

-- 3-Mise en forme des données et écriture dans une table pour l'utilisation des données
	-- Création d'une table vierge pour acceuillir les données
CREATE TABLE submissions.cimae_adn (
	data_id text NOT NULL,
	sampling_date date NULL,
	sampling_time time NULL,
	sampling_number text NULL,
	sampling_type text NULL,
	user_name text NULL,
	user_mail text NULL,
	geom public.geometry(point, 4326) NULL,
	CONSTRAINT cimae_adn_pkey PRIMARY KEY (data_id)
);	
	
	-- Fonction d'insert des données (pour construire la fonction suivante)
insert into submissions.cimae_adn (
select data_id, sampling_date::date, to_char(sampling_time::time, 'HH24:MI')::time, lpad(sampling_number,3,'0'), sampling_type, user_name, lower(user_mail),
        st_force2d(st_geomfromgeojson(replace(COALESCE(site_geopoint), '\', '')))::geometry(point, 4326)
from odk_central."cimae-suivi_submissions_data" a
);

	-- Création d'une fonction de mise en forme des données
CREATE OR REPLACE FUNCTION submissions.insert_cimae_adn()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO submissions.cimae_adn (
        data_id,
		sampling_date,
		sampling_time,
		sampling_number,
		sampling_type,
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
        NEW.user_name,
		lower(NEW.user_mail),
        st_force2d(st_geomfromgeojson(replace(COALESCE(NEW.site_geopoint), '\', '')))::geometry(point, 4326)
    );
    
    RETURN NEW;
END;
$function$
;

	-- Création du trigger pour lancer la fonction à chaque nouvelle donnée
CREATE TRIGGER insert_cimae_adn
AFTER INSERT ON odk_central."cimae-adn_submissions_data"
FOR EACH ROW
EXECUTE FUNCTION submissions.insert_cimae_adn();

	-- Pour supprimer le trigger si nécessaire :
-- DROP TRIGGER IF EXISTS insert_cimae_adn ON odk_central."cimae-adn_submissions_data";
-- DROP FUNCTION IF EXISTS submissions.insert_cimae_adn();