CREATE OR REPLACE FUNCTION submissions.insert_cimae_protocole_passages()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_site_images TEXT;
    v_geom geometry(point, 4326);
    v_site_name TEXT;
BEGIN
    -- Récupération des images associées via la table repeat
    SELECT array_to_string(
        array_agg(
            concat('https://central.sicen.fr/v1/projects/16/forms/cimae-protocole/submissions/',
                   NEW."instanceID",
                   '/attachments/',
                   img.site_image)
        ),
        chr(10)
    )
    INTO v_site_images
    FROM odk_central."cimae-protocole_site_image_repeat_data" img
    WHERE img."__Submissions-id" = NEW."__id";

    -- ============================================
    -- CAS 1 : Nouveau site (site_name_new renseigné)
    -- ============================================
    IF NEW.site_name_new IS NOT NULL THEN

        v_site_name := NEW.site_name_new;
        v_geom := st_force2d(st_geomfromgeojson(replace(COALESCE(NEW.site_geopoint), '\', '')))::geometry(point, 4326);

    -- ============================================
    -- CAS 2 : Site existant (site_name renseigné)
    -- ============================================
    ELSIF NEW.site_name IS NOT NULL THEN

        v_site_name := NEW.site_name;

        -- Récupération de la géométrie depuis un passage existant sur ce site
        SELECT geom
        INTO v_geom
        FROM submissions.cimae_protocole_passages
        WHERE site_name = NEW.site_name
        LIMIT 1;

    ELSE
        -- Ni site_name_new ni site_name renseigné : on ne fait rien
        RETURN NEW;
    END IF;

    -- ============================================
    -- Insertion commune
    -- ============================================
    INSERT INTO submissions.cimae_protocole_passages (
        data_id,
        site_name,
        passage_date,
        passage_time_begin,
        passage_time_end,
        user_name,
        user_mail,
        passage_collective,
        passage_monitoring,
        unit,
        unit_type,
        unit_name,
        water_dry,
        water_area,
        water_area_measure,
        water_transect_length,
        water_transect_length_measure,
        water_depth_mean,
        water_depth_max,
        water_depth_measure,
        water_transparency,
        wetland_feed,
        wetland_feed_river_width,
        wetland_feed_river_depth,
        wetland_feed_river_measure,
        wetland_outlet,
        wetland_outlet_width,
        wetland_outlet_depth,
        wetland_outlet_measure,
        substrate_type,
        substrate_percent_rock,
        substrate_percent_gravel,
        substrate_percent_sand,
        substrate_percent_peat,
        substrate_percent_soil,
        substrate_percent_mud,
        fish,
        vegetation_tree,
        vegetation_type,
        vegetation_percent_water,
        vegetation_percent_bank,
        vegetation_percent_around,
        vegetation_belt,
        vegetation_belt_width,
        vegetation_belt_percent,
        algae,
        algae_percent,
        trampling,
        trampling_percent,
        trampling_type,
        path,
        path_localisation,
        waste,
        waste_localisation,
        excrement,
        excrement_localisation,
        protocol,
        amphibian_presence,
        odonate_presence,
        reptile_presence,
        site_comment,
        site_image,
        import_date,
        import_source,
        update_date,
        update_user,
        geom
    )
    VALUES (
        NEW.data_id,
        v_site_name,
        NEW.passage_date_begin::date,
        to_char(NEW.passage_time_begin::time, 'HH24:MI')::time,
        to_char(NEW.passage_time_end::time, 'HH24:MI')::time,
        NEW.user_name,
        lower(NEW.user_mail),
        NEW.passage_collective,
        NEW.passage_monitoring,
        NEW.unit,
        NEW.unit_type,
        NEW.unit_name,
        NEW.water_dry,
        NEW.water_area::int,
        NEW.water_area_measure,
        NEW.water_transect_length::real,
        NEW.water_transect_length_measure,
        NEW.water_depth_mean::real,
        NEW.water_depth_max::real,
        NEW.water_depth_measure,
        NEW.water_transparency,
        NEW.wetland_feed,
        NEW.wetland_feed_river_width::real,
        NEW.wetland_feed_river_depth::real,
        NEW.wetland_feed_river_measure,
        NEW.wetland_outlet,
        NEW.wetland_outlet_width::real,
        NEW.wetland_outlet_depth::real,
        NEW.wetland_outlet_measure,
        NEW.substrate_type,
        NEW.substrate_percent_rock::int,
        NEW.substrate_percent_gravel::int,
        NEW.substrate_percent_sand::int,
        NEW.substrate_percent_peat::int,
        NEW.substrate_percent_soil::int,
        NEW.substrate_percent_mud::int,
        NEW.fish,
        NEW.vegetation_tree,
        NEW.vegetation_type,
        NEW.vegetation_percent_water::int,
        NEW.vegetation_percent_bank::int,
        NEW.vegetation_percent_around::int,
        NEW.vegetation_belt,
        NEW.vegetation_belt_width::real,
        NEW.vegetation_belt_percent::int,
        NEW.algae,
        NEW.algae_percent::int,
        NEW.trampling,
        NEW.trampling_percent::int,
        NEW.trampling_type,
        NEW.path,
        NEW.path_localisation,
        NEW.waste,
        NEW.waste_localisation,
        NEW.excrement,
        NEW.excrement_localisation,
        NEW.protocol,
        NEW.amphibian_presence,
        NEW.odonate_presence,
        NEW.reptile_presence,
        replace(NEW.site_comment, '\\n', chr(10)),
        v_site_images,
        now()::date,
        CASE 
            WHEN NEW.site_name_new IS NOT NULL THEN concat('ODK - Nouveau site - ', NEW."submitterName")
            ELSE concat('ODK - Site existant - ', NEW."submitterName")
        END,
        NULL,
        NULL,
        v_geom
    );
    RETURN NEW;
END;
$function$
;

-- Création du trigger
CREATE TRIGGER insert_cimae_protocole_passages
AFTER INSERT ON odk_central."cimae-protocole_submissions_data"
FOR EACH ROW
EXECUTE FUNCTION submissions.insert_cimae_protocole_passages();

-- Pour supprimer le trigger si nécessaire :
-- DROP TRIGGER IF EXISTS insert_cimae_protocole_passages ON odk_central."cimae-protocole_submissions_data";
-- DROP FUNCTION IF EXISTS submissions.insert_cimae_protocole_passages();

-- Historisation des mises à jours
CREATE OR REPLACE FUNCTION submissions.update_user_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_date := now();
    NEW.update_user := 'Marie LAMOUILLE-HEBERT';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_date
BEFORE UPDATE ON submissions.cimae_protocole_passages
FOR EACH ROW
EXECUTE FUNCTION submissions.update_user_date();


