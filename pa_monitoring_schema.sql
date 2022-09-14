--
-- PostgreSQL database dump
--

-- Dumped from database version 12.11
-- Dumped by pg_dump version 12.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: test_old_monitoring; Type: SCHEMA; Schema: -; Owner: j_soto
--

CREATE SCHEMA test_old_monitoring;


ALTER SCHEMA test_old_monitoring OWNER TO j_soto;

--
-- Name: create_nbn_table(); Type: FUNCTION; Schema: test_old_monitoring; Owner: j_soto
--

CREATE FUNCTION test_old_monitoring.create_nbn_table() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
drop table test_old_monitoring.nbn;
create table if not exists test_old_monitoring.nbn (
occurrenceID SERIAL NOT NULL,
datasetName	text,
institutionCode text DEFAULT 'NatureScot' NOT NULL,
license	text DEFAULT 'OGL' NOT NULL,
rightsHolder text DEFAULT 'NatureScot' NOT NULL,
scientificName text,
taxonID	text,
identificationVerificationStatus text DEFAULT 'Acepted' NOT NULL,
eventDate	text,
recordedBy	text,
gridReference	text,
coordinateUncertaintyInMeters integer DEFAULT 3 NOT NULL,
locationID text,
locality	text,
basisOfRecord	text DEFAULT 'LivingSpecimen' NOT NULL,
occurrenceStatus text DEFAULT 'present' NOT NULL,
vitality text DEFAULT 'Alive' NOT NULL,
samplingProtocol text DEFAULT 'percentage cover per quadrat' NOT NULL,
organismQuantity text,
organismQuantityType text DEFAULT 'PercentCover' NOT NULL
);

GRANT UPDATE, SELECT, DELETE, INSERT ON TABLE test_old_monitoring.nbn TO data_team;

GRANT ALL ON TABLE test_old_monitoring.nbn TO j_soto;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE test_old_monitoring.nbn TO n_tierney;

INSERT INTO test_old_monitoring.nbn 
(scientificName, eventDate, recordedBy, gridReference, locality, locationID, organismQuantity)
SELECT 
scientificName, date, recordedBy, grid_reference, site, quadrat_id, percentage
FROM test_old_monitoring.bl_quadrats_all where scientificName not ilike '%percent%';

INSERT INTO test_old_monitoring.nbn 
(scientificName, eventDate, recordedBy, gridReference, locality, locationID, organismQuantity)
SELECT 
scientificName, date, recordedBy, grid_reference, site, quadrat_id, percentage
FROM test_old_monitoring.quadrats_all where scientificName not ilike '%percent%'
AND quadrat_id not in (Select quadrat_id from test_old_monitoring.bl_quadrats_all);

UPDATE test_old_monitoring.nbn a SET taxonID = b.taxonID 
FROM test_old_monitoring.taxon_ids b
WHERE LOWER(a.scientificname) = LOWER(b.scientificname);

UPDATE test_old_monitoring.nbn SET taxonID = 'Not Matched with UKSI online tool'
WHERE taxonID is null or taxonID = 'NaN';

UPDATE test_old_monitoring.nbn SET datasetName = 'Baseline Survey Peatland Monitoring Dataset' 
WHERE locationID in (Select quadrat_id from test_old_monitoring.bl_quadrats_all);

UPDATE test_old_monitoring.nbn SET datasetName = 'Quadrat Survey Peatland Monitoring Dataset' 
WHERE locationID not in (Select quadrat_id from test_old_monitoring.bl_quadrats_all);   
   
      
   
END;
$$;


ALTER FUNCTION test_old_monitoring.create_nbn_table() OWNER TO j_soto;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: quadrat_info; Type: TABLE; Schema: test_old_monitoring; Owner: j_soto
--

CREATE TABLE test_old_monitoring.quadrat_info (
    quadrat_uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    date character varying(50),
    site character varying(50),
    bog_type character varying(50),
    area character varying(50),
    quadrat character varying(50),
    x character varying(50),
    y character varying(50),
    quadrat_size_m character varying(50),
    avg_canopy_height_cm double precision,
    dung_presence character varying(50),
    cause_damaged_peat character varying(50),
    main_calluna_growth_stage character varying(50),
    constraints text,
    notes text,
    quadrat_id character varying(150),
    survey_year text,
    geom public.geometry(Point,27700),
    recordedby text DEFAULT 'Haycock and Jay Associates'::text NOT NULL,
    taxonid text DEFAULT 'Not Matched'::text NOT NULL
);


ALTER TABLE test_old_monitoring.quadrat_info OWNER TO j_soto;

--
-- Name: quadrat_vegetation; Type: TABLE; Schema: test_old_monitoring; Owner: j_soto
--

CREATE TABLE test_old_monitoring.quadrat_vegetation (
    quadrat_uuid character varying(150),
    quadrat_id character varying(150),
    veg_sp character varying(150),
    percentage double precision,
    scientificname text DEFAULT 'Not Matched'::text NOT NULL
);


ALTER TABLE test_old_monitoring.quadrat_vegetation OWNER TO j_soto;

--
-- Name: bl_quadrat_info; Type: TABLE; Schema: test_old_monitoring; Owner: j_soto
--

CREATE TABLE test_old_monitoring.bl_quadrat_info (
    quadrat_uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    date character varying(50),
    site character varying(50),
    bog_type character varying(50),
    area character varying(50),
    nvc_community_paa_report character varying(150),
    survey_restoration_stage character varying(50),
    restoration_year character varying(50),
    treatment character varying(50),
    treatment_specific character varying(150),
    paa_description character varying(150),
    unique_id character varying(50),
    quadrat character varying(50),
    x character varying(50),
    y character varying(50),
    quadrat_size_m character varying(50),
    avg_canopy_height_cm double precision,
    dung_presence character varying(50),
    brash_stumps character varying(50),
    quadrat_id character varying(150),
    survey_dates date,
    geom public.geometry(Point,27700),
    recordedby text DEFAULT 'Penny Anderson Associates'::text NOT NULL,
    taxonid text DEFAULT 'Not Matched'::text NOT NULL
);


ALTER TABLE test_old_monitoring.bl_quadrat_info OWNER TO j_soto;

--
-- Name: bl_quadrat_vegetation; Type: TABLE; Schema: test_old_monitoring; Owner: j_soto
--

CREATE TABLE test_old_monitoring.bl_quadrat_vegetation (
    quadrat_uuid character varying(150),
    quadrat_id character varying(150),
    veg_sp character varying(150),
    percentage double precision,
    scientificname text DEFAULT 'Not Matched'::text NOT NULL
);


ALTER TABLE test_old_monitoring.bl_quadrat_vegetation OWNER TO j_soto;

--
-- Name: bl_quadrats_all; Type: VIEW; Schema: test_old_monitoring; Owner: j_soto
--

CREATE VIEW test_old_monitoring.bl_quadrats_all AS
 SELECT a.scientificname,
    a.percentage,
    b.quadrat_uuid,
    b.date,
    b.site,
    b.bog_type,
    b.area,
    b.recordedby,
    b.nvc_community_paa_report,
    b.survey_restoration_stage,
    b.restoration_year,
    b.treatment,
    b.treatment_specific,
    b.paa_description,
    b.unique_id,
    b.quadrat,
    b.x,
    b.y,
    public.get_grid_ref_from_geom(b.geom) AS grid_reference,
    b.quadrat_size_m,
    b.avg_canopy_height_cm,
    b.dung_presence,
    b.brash_stumps,
    b.quadrat_id,
    b.survey_dates,
    b.geom
   FROM (test_old_monitoring.bl_quadrat_vegetation a
     LEFT JOIN test_old_monitoring.bl_quadrat_info b ON (((a.quadrat_id)::text = (b.quadrat_id)::text)))
  WHERE ((a.percentage > (0)::double precision) AND ((b.x)::text <> 'NaN'::text));


ALTER TABLE test_old_monitoring.bl_quadrats_all OWNER TO j_soto;

--
-- Name: bl_survey_dates; Type: TABLE; Schema: test_old_monitoring; Owner: j_soto
--

CREATE TABLE test_old_monitoring.bl_survey_dates (
    survey_date date,
    site text,
    survey_date2 text
);


ALTER TABLE test_old_monitoring.bl_survey_dates OWNER TO j_soto;

--
-- Name: nbn; Type: TABLE; Schema: test_old_monitoring; Owner: j_soto
--

CREATE TABLE test_old_monitoring.nbn (
    occurrenceid integer NOT NULL,
    datasetname text,
    institutioncode text DEFAULT 'NatureScot'::text NOT NULL,
    license text DEFAULT 'OGL'::text NOT NULL,
    rightsholder text DEFAULT 'NatureScot'::text NOT NULL,
    scientificname text,
    taxonid text,
    identificationverificationstatus text DEFAULT 'Acepted'::text NOT NULL,
    eventdate text,
    recordedby text,
    gridreference text,
    coordinateuncertaintyinmeters integer DEFAULT 3 NOT NULL,
    locationid text,
    locality text,
    basisofrecord text DEFAULT 'LivingSpecimen'::text NOT NULL,
    occurrencestatus text DEFAULT 'present'::text NOT NULL,
    vitality text DEFAULT 'Alive'::text NOT NULL,
    samplingprotocol text DEFAULT 'percentage cover per quadrat'::text NOT NULL,
    organismquantity text,
    organismquantitytype text DEFAULT 'PercentCover'::text NOT NULL
);


ALTER TABLE test_old_monitoring.nbn OWNER TO j_soto;

--
-- Name: nbn_occurrenceid_seq; Type: SEQUENCE; Schema: test_old_monitoring; Owner: j_soto
--

CREATE SEQUENCE test_old_monitoring.nbn_occurrenceid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE test_old_monitoring.nbn_occurrenceid_seq OWNER TO j_soto;

--
-- Name: nbn_occurrenceid_seq; Type: SEQUENCE OWNED BY; Schema: test_old_monitoring; Owner: j_soto
--

ALTER SEQUENCE test_old_monitoring.nbn_occurrenceid_seq OWNED BY test_old_monitoring.nbn.occurrenceid;


--
-- Name: quadrats_all; Type: VIEW; Schema: test_old_monitoring; Owner: j_soto
--

CREATE VIEW test_old_monitoring.quadrats_all AS
 SELECT a.veg_sp,
    a.percentage,
    b.quadrat_uuid,
    b.recordedby,
    b.date,
    b.site,
    b.bog_type,
    b.area,
    b.quadrat,
    b.x,
    b.y,
    public.get_grid_ref_from_geom(b.geom) AS grid_reference,
    b.quadrat_size_m,
    b.avg_canopy_height_cm,
    b.dung_presence,
    b.cause_damaged_peat,
    b.main_calluna_growth_stage,
    b.constraints,
    a.scientificname,
    b.notes,
    b.quadrat_id
   FROM (test_old_monitoring.quadrat_vegetation a
     LEFT JOIN test_old_monitoring.quadrat_info b ON (((a.quadrat_id)::text = (b.quadrat_id)::text)))
  WHERE ((a.percentage > (0)::double precision) AND ((b.x)::text <> 'NaN'::text));


ALTER TABLE test_old_monitoring.quadrats_all OWNER TO j_soto;

--
-- Name: taxon_ids; Type: TABLE; Schema: test_old_monitoring; Owner: j_soto
--

CREATE TABLE test_old_monitoring.taxon_ids (
    scientificname text,
    taxonid text
);


ALTER TABLE test_old_monitoring.taxon_ids OWNER TO j_soto;

--
-- Name: nbn occurrenceid; Type: DEFAULT; Schema: test_old_monitoring; Owner: j_soto
--

ALTER TABLE ONLY test_old_monitoring.nbn ALTER COLUMN occurrenceid SET DEFAULT nextval('test_old_monitoring.nbn_occurrenceid_seq'::regclass);


--
-- Name: bl_quadrat_info bl_quadrat_info_pkey; Type: CONSTRAINT; Schema: test_old_monitoring; Owner: j_soto
--

ALTER TABLE ONLY test_old_monitoring.bl_quadrat_info
    ADD CONSTRAINT bl_quadrat_info_pkey PRIMARY KEY (quadrat_uuid);


--
-- Name: quadrat_info quadrat_info_pkey; Type: CONSTRAINT; Schema: test_old_monitoring; Owner: j_soto
--

ALTER TABLE ONLY test_old_monitoring.quadrat_info
    ADD CONSTRAINT quadrat_info_pkey PRIMARY KEY (quadrat_uuid);


--
-- Name: idx_bl_quadrat_id; Type: INDEX; Schema: test_old_monitoring; Owner: j_soto
--

CREATE INDEX idx_bl_quadrat_id ON test_old_monitoring.bl_quadrat_info USING btree (quadrat_id);


--
-- Name: idx_bl_quadrat_id_veg; Type: INDEX; Schema: test_old_monitoring; Owner: j_soto
--

CREATE INDEX idx_bl_quadrat_id_veg ON test_old_monitoring.bl_quadrat_vegetation USING btree (quadrat_id);


--
-- Name: idx_blquadrat_old_monitoring; Type: INDEX; Schema: test_old_monitoring; Owner: j_soto
--

CREATE INDEX idx_blquadrat_old_monitoring ON test_old_monitoring.bl_quadrat_info USING gist (geom);


--
-- Name: idx_quadrat_id; Type: INDEX; Schema: test_old_monitoring; Owner: j_soto
--

CREATE INDEX idx_quadrat_id ON test_old_monitoring.quadrat_info USING btree (quadrat_id);


--
-- Name: idx_quadrat_id_veg; Type: INDEX; Schema: test_old_monitoring; Owner: j_soto
--

CREATE INDEX idx_quadrat_id_veg ON test_old_monitoring.quadrat_vegetation USING btree (quadrat_id);


--
-- Name: idx_quadrat_old_monitoring; Type: INDEX; Schema: test_old_monitoring; Owner: j_soto
--

CREATE INDEX idx_quadrat_old_monitoring ON test_old_monitoring.quadrat_info USING gist (geom);


--
-- Name: SCHEMA test_old_monitoring; Type: ACL; Schema: -; Owner: j_soto
--

GRANT USAGE ON SCHEMA test_old_monitoring TO n_tierney;
GRANT USAGE ON SCHEMA test_old_monitoring TO data_team;


--
-- Name: TABLE quadrat_info; Type: ACL; Schema: test_old_monitoring; Owner: j_soto
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.quadrat_info TO data_team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.quadrat_info TO n_tierney;


--
-- Name: TABLE quadrat_vegetation; Type: ACL; Schema: test_old_monitoring; Owner: j_soto
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.quadrat_vegetation TO data_team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.quadrat_vegetation TO n_tierney;


--
-- Name: TABLE bl_quadrat_info; Type: ACL; Schema: test_old_monitoring; Owner: j_soto
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.bl_quadrat_info TO data_team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.bl_quadrat_info TO n_tierney;


--
-- Name: TABLE bl_quadrat_vegetation; Type: ACL; Schema: test_old_monitoring; Owner: j_soto
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.bl_quadrat_vegetation TO data_team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.bl_quadrat_vegetation TO n_tierney;


--
-- Name: TABLE bl_quadrats_all; Type: ACL; Schema: test_old_monitoring; Owner: j_soto
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.bl_quadrats_all TO n_tierney;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.bl_quadrats_all TO data_team;


--
-- Name: TABLE nbn; Type: ACL; Schema: test_old_monitoring; Owner: j_soto
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.nbn TO data_team;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.nbn TO n_tierney;


--
-- Name: TABLE quadrats_all; Type: ACL; Schema: test_old_monitoring; Owner: j_soto
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.quadrats_all TO n_tierney;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE test_old_monitoring.quadrats_all TO data_team;


--
-- PostgreSQL database dump complete
--

