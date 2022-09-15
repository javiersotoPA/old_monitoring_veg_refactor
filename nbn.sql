---- Create NBN table
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
basisOfRecord	text DEFAULT 'HumanObservation' NOT NULL,
occurrenceStatus text DEFAULT 'present' NOT NULL,
lifeStage text,
vitality text DEFAULT 'Alive' NOT NULL,
samplingProtocol text DEFAULT 'percentage cover per quadrat' NOT NULL,
organismQuantity text,
organismQuantityType text DEFAULT 'PercentCover' NOT NULL
);

GRANT UPDATE, SELECT, DELETE, INSERT ON TABLE test_old_monitoring.nbn TO data_team;

GRANT ALL ON TABLE test_old_monitoring.nbn TO j_soto;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE test_old_monitoring.nbn TO n_tierney;

INSERT INTO test_old_monitoring.nbn 
(scientificName, eventDate, recordedBy, gridReference, locality, locationID, organismQuantity, lifeStage, vitality,taxonID)
SELECT 
scientificName, date, recordedBy, grid_reference, site, quadrat_id, percentage,lifeStage, vitality,taxonID
FROM test_old_monitoring.bl_quadrats_all where scientificName not similar to '%percent%|%ichen%|%algae%';

INSERT INTO test_old_monitoring.nbn 
(scientificName, eventDate, recordedBy, gridReference, locality, locationID, organismQuantity, lifeStage, vitality,taxonID)
SELECT 
scientificName, date, recordedBy, grid_reference, site, quadrat_id, percentage, lifeStage, vitality,taxonID
FROM test_old_monitoring.quadrats_all where scientificName not similar to '%percent%|%ichen%|%algae%'
AND quadrat_id not in (Select quadrat_id from test_old_monitoring.bl_quadrats_all);

--UPDATE test_old_monitoring.nbn a SET taxonID = b.taxonID 
--FROM test_old_monitoring.taxon_ids b
--WHERE LOWER(a.scientificname) = LOWER(b.scientificname);

--UPDATE test_old_monitoring.nbn SET taxonID = 'Not Matched with UKSI online tool'
--WHERE taxonID is null or taxonID = 'NaN';

UPDATE test_old_monitoring.nbn SET datasetName = 'Baseline Survey Peatland Monitoring Dataset' 
WHERE locationID in (Select quadrat_id from test_old_monitoring.bl_quadrats_all);

UPDATE test_old_monitoring.nbn SET datasetName = 'Quadrat Survey Peatland Monitoring Dataset' 
WHERE locationID not in (Select quadrat_id from test_old_monitoring.bl_quadrats_all);

select distinct scientificName from test_old_monitoring.nbn where taxonID is null;

select * from test_old_monitoring.nbn;

select * from test_old_monitoring.nbn where taxonid like '%match%';

DELETE FROM test_old_monitoring.nbn WHERE scientificname = 'algae species';


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


UPDATE test_old_monitoring.bl_quadrat_info a SET date = b.eventdate from test_old_monitoring.nbn b where
a.site = b.locality;

UPDATE test_old_monitoring.quadrat_info a SET date = b.eventdate from test_old_monitoring.nbn b where
a.site = b.locality;

UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '07-08-2014' WHERE survey_date like '2014-08-07%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '09-09-2014' WHERE survey_date like '2014-09-09%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '18-08-2014' WHERE survey_date like '2014-08-18%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '05-08-2014' WHERE survey_date like '2014-08-05%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '23-06-2015' WHERE survey_date like '2015-06-23%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '07-07-2015' WHERE survey_date like '2015-07-07%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '14-07-2015'	 WHERE survey_date like '2015-07-14%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '11-08-2015' WHERE survey_date like '2015-08-11%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '24-08-2015'	 WHERE survey_date like '2015-08-24%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '26-08-2015' WHERE survey_date like '2015-08-26%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '28-09-2015' WHERE survey_date like '2015-09-28%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '06-10-2015' WHERE survey_date like '2015-10-06%'; 
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '14-10-2015'	 WHERE survey_date like '2015-10-14%';
UPDATE test_old_monitoring.baseline_survey_dates SET survey_date = '07-10-2015' WHERE survey_date like '2015-10-07%';


UPDATE test_old_monitoring.nbn SET eventdate = replace(eventdate, '/', '-');


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

Select * from test_old_monitoring.nbn where scientificname ilike '%dead%';
Select * from test_old_monitoring.nbn where scientificname ilike '%canopy%';
Select * from test_old_monitoring.nbn where scientificname ilike '%seedling%';
Select * from test_old_monitoring.nbn where scientificname ilike '%sapling%';


ALTER TABLE test_old_monitoring.quadrat_vegetation add column taxonid text;
ALTER TABLE test_old_monitoring.bl_quadrat_vegetation add column taxonid text;

UPDATE test_old_monitoring.bl_quadrat_vegetation a SET lifeStage = 'canopy' where veg_sp ilike '%canopy%';
UPDATE test_old_monitoring.bl_quadrat_vegetation a SET lifeStage = 'seedling' where veg_sp ilike '%seedling%';
UPDATE test_old_monitoring.bl_quadrat_vegetation a SET lifeStage = 'sapling' where veg_sp ilike '%sapling%';

UPDATE test_old_monitoring.quadrat_vegetation a SET lifeStage = 'canopy' where veg_sp ilike '%canopy%';
UPDATE test_old_monitoring.quadrat_vegetation a SET lifeStage = 'seedling' where veg_sp ilike '%seedling%';
UPDATE test_old_monitoring.quadrat_vegetation a SET lifeStage = 'sapling' where veg_sp ilike '%sapling%';


ALTER TABLE test_old_monitoring.quadrat_vegetation add column vitality text;
ALTER TABLE test_old_monitoring.bl_quadrat_vegetation add column vitality text;

UPDATE test_old_monitoring.bl_quadrat_vegetation a SET vitality = 'Dead' where veg_sp ilike '%dead%';
UPDATE test_old_monitoring.bl_quadrat_vegetation a SET vitality = 'Alive' where veg_sp not ilike '%dead%';

UPDATE test_old_monitoring.quadrat_vegetation a SET vitality = 'Dead' where veg_sp ilike '%dead%';
UPDATE test_old_monitoring.quadrat_vegetation a SET vitality = 'Alive' where veg_sp not ilike '%dead%';

SELECT veg_sp, vitality from test_old_monitoring.bl_quadrat_vegetation where veg_sp not ilike '%dead%';



------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

UPDATE test_old_monitoring.quadrat_vegetation a SET scientificname = REPLACE(scientificname, ' sapling', '');
UPDATE test_old_monitoring.quadrat_vegetation a SET scientificname = REPLACE(scientificname, ' dead', '');
UPDATE test_old_monitoring.quadrat_vegetation a SET scientificname = REPLACE(scientificname, ' seedling', '');
UPDATE test_old_monitoring.quadrat_vegetation a SET scientificname = REPLACE(scientificname, ' canopy', '');


UPDATE test_old_monitoring.bl_quadrat_vegetation a SET scientificname = REPLACE(scientificname, ' sapling', '');
UPDATE test_old_monitoring.bl_quadrat_vegetation a SET scientificname = REPLACE(scientificname, ' dead', '');
UPDATE test_old_monitoring.bl_quadrat_vegetation a SET scientificname = REPLACE(scientificname, ' seedling', '');
UPDATE test_old_monitoring.bl_quadrat_vegetation a SET scientificname = REPLACE(scientificname, ' canopy', '');

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

UPDATE test_old_monitoring.bl_quadrat_vegetation a SET scientificname = REPLACE(scientificname, 'cladonia crustose', 'cladonia');
UPDATE test_old_monitoring.bl_quadrat_vegetation a SET scientificname = REPLACE(scientificname, 'cladonia species crustose', 'cladonia');

UPDATE test_old_monitoring.quadrat_vegetation a SET scientificname = REPLACE(scientificname, 'cladonia crustose', 'cladonia');
UPDATE test_old_monitoring.quadrat_vegetation a SET scientificname = REPLACE(scientificname, 'cladonia species crustose', 'cladonia');


------------------------------------------------------------------------------------
-----------------------------------REFACOTRING TAXONIDs TABLE-----------------------
------------------------------------------------------------------------------------

ALTER TABLE test_old_monitoring.taxon_ids add column scientificname_refactor text;

UPDATE test_old_monitoring.taxon_ids a SET scientificname_refactor = scientificname;
UPDATE test_old_monitoring.taxon_ids a SET scientificname_refactor = REPLACE(scientificname_refactor, ' sapling', '');
UPDATE test_old_monitoring.taxon_ids a SET scientificname_refactor = REPLACE(scientificname_refactor, ' dead', '');
UPDATE test_old_monitoring.taxon_ids a SET scientificname_refactor = REPLACE(scientificname_refactor, ' seedling', '');
UPDATE test_old_monitoring.taxon_ids a SET scientificname_refactor = REPLACE(scientificname_refactor, ' canopy', '');

UPDATE test_old_monitoring.quadrat_vegetation a SET taxonid = b.taxonid FROM test_old_monitoring.taxon_ids b
WHERE LOWER(a.scientificname) = LOWER(b.scientificname_refactor) AND b.taxonid != 'Not Matched with UKSI online tool';

SELECT * FROM test_old_monitoring.quadrat_vegetation;
SELECT * FROM test_old_monitoring.taxon_ids;

UPDATE test_old_monitoring.bl_quadrat_vegetation a SET taxonid = b.taxonid FROM test_old_monitoring.taxon_ids b
WHERE LOWER(a.scientificname) = LOWER(b.scientificname_refactor) AND b.taxonid != 'Not Matched with UKSI online tool';

SELECT distinct(veg_sp), scientificname from test_old_monitoring.bl_quadrat_vegetation WHERE taxonID = 'Not Matched with UKSI online tool';

SELECT distinct(veg_sp), scientificname from test_old_monitoring.quadrat_vegetation WHERE taxonID = 'Not Matched with UKSI online tool';

SELECT * FROM test_old_monitoring.bl_quadrat_vegetation;
SELECT * FROM test_old_monitoring.taxon_ids_view;

DROP view test_old_monitoring.taxon_ids_view;

SELECT REPLACE(scientificname, ' ', '_') FROM test_old_monitoring.taxon_ids where scientificname SIMILAR TO '%dead%|%canopy%|%seedling%|%sapling%';

UPDATE  SET 

INSERT INTO test_old_monitoring.taxon_ids (scientificname, taxonid, scientificname_refactor)
 VALUES ('Cladonia_species', 'NHMSYS0001477591', 'Cladonia')
 
 
 --------------------------------------------------------------------
 
 -----------------------VIEWS -----------------------------------

 --------------------------------------------------------------------

-- View: test_old_monitoring.bl_quadrats_all

DROP VIEW test_old_monitoring.bl_quadrats_all;

CREATE OR REPLACE VIEW test_old_monitoring.bl_quadrats_all
 AS
 SELECT a.scientificname,
    a.percentage,
	a.taxonID,
	a.vitality,
	a.lifeStage,
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
    get_grid_ref_from_geom(b.geom) AS grid_reference,
    b.quadrat_size_m,
    b.avg_canopy_height_cm,
    b.dung_presence,
    b.brash_stumps,
    b.quadrat_id,
    b.survey_dates,
    b.geom
   FROM test_old_monitoring.bl_quadrat_vegetation a
     LEFT JOIN test_old_monitoring.bl_quadrat_info b ON a.quadrat_id::text = b.quadrat_id::text
  WHERE a.percentage > 0::double precision AND b.x::text <> 'NaN'::text;

ALTER TABLE test_old_monitoring.bl_quadrats_all
    OWNER TO j_soto;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE test_old_monitoring.bl_quadrats_all TO n_tierney;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE test_old_monitoring.bl_quadrats_all TO data_team;
GRANT ALL ON TABLE test_old_monitoring.bl_quadrats_all TO j_soto;

------------

-- View: test_old_monitoring.quadrats_all

DROP VIEW test_old_monitoring.quadrats_all;

CREATE OR REPLACE VIEW test_old_monitoring.quadrats_all
 AS
 SELECT a.veg_sp,
    a.percentage,
		a.taxonID,
	a.vitality,
	a.lifeStage,
	    a.scientificname,
    b.quadrat_uuid,
    b.recordedby,
    b.date,
    b.site,
    b.bog_type,
    b.area,
    b.quadrat,
    b.x,
    b.y,
    get_grid_ref_from_geom(b.geom) AS grid_reference,
    b.quadrat_size_m,
    b.avg_canopy_height_cm,
    b.dung_presence,
    b.cause_damaged_peat,
    b.main_calluna_growth_stage,
    b.constraints,
    b.notes,
    b.quadrat_id
   FROM test_old_monitoring.quadrat_vegetation a
     LEFT JOIN test_old_monitoring.quadrat_info b ON a.quadrat_id::text = b.quadrat_id::text
  WHERE a.percentage > 0::double precision AND b.x::text <> 'NaN'::text;

ALTER TABLE test_old_monitoring.quadrats_all
    OWNER TO j_soto;

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE test_old_monitoring.quadrats_all TO n_tierney;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE test_old_monitoring.quadrats_all TO data_team;
GRANT ALL ON TABLE test_old_monitoring.quadrats_all TO j_soto;

-------------------------------------------------------------


SELECT distinct scientificname from test_old_monitoring.nbn where taxonID is null or taxonID = 'Not Matched with UKSI online tool';


select * from test_old_monitoring.quadrats_all where lifeStage is not null;

 ALTER TABLE test_old_monitoring.taxon_ids ADD COLUMN id SERIAL PRIMARY KEY;

insert into test_old_monitoring.taxon_ids (scientificname, scientificname_refactor, taxonid)
VALUES
('chamerion angustifolium', 'chamerion angustifolium',	'NBNSYS0000003598'),
('calliergon cuspidatum', 'calliergon cuspidatum',	'NHMSYS0000309529'),
('dryopteris felix mas', 'dryopteris filix-mas',	'NBNSYS0000004640'),
('sphagnum magellanicum', 'sphagnum magellanicum',	'NHMSYS0021239440'),
('dactylorhiza fuschii', 'dactylorhiza fuchsii',	'NHMSYS0000457901'),
('salix cinerea', 'salix cinerea',	'NBNSYS0000003871'),
('algae species', 'algae species',	'Not Matched with UKSI online tool'),
('deschampsia flexuosa', 'deschampsia flexuosa',	'NBNSYS0000002623'),
('cladonia rangiforms', 'cladonia rangiforms',	'NBNSYS0000018401'),
('agrostis canina', 'agrostis canina',	'NBNSYS0000102171'),
('carex curta', 'carex curta',	'NBNSYS0000002484'),
('sphagnum squarrosum papillosum', 'sphagnum squarrosum',	'NBNSYS0000036072'),
('huperzia selago', 'huperzia selago',	'NHMSYS0000459776'),
('sphagnum recurvum', 'sphagnum recurvum',	'NBNSYS0000036101'),
('vaccinium microcarpum', 'vaccinium microcarpum',	'NBNSYS0000003919'),
('sphagnum capillifolium', 'sphagnum capillifolium',	'NBNSYS0000036080');


DELETE FROM test_old_monitoring.taxon_ids WHERE scientificname IS NULL;
DELETE FROM test_old_monitoring.taxon_ids WHERE taxonid IS NULL;
DELETE FROM test_old_monitoring.taxon_ids WHERE scientificname_refactor IS NULL;


UPDATE test_old_monitoring.bl_quadrat_vegetation a SET scientificname = REPLACE(scientificname, 'dryopteris felix mas', 'dryopteris filix-mas');
UPDATE test_old_monitoring.bl_quadrat_vegetation a SET scientificname = REPLACE(scientificname, 'dactylorhiza fuschii', 'dactylorhiza fuchsii');
UPDATE test_old_monitoring.bl_quadrat_vegetation a SET scientificname = REPLACE(scientificname, 'sphagnum squarrosum papillosum', 'sphagnum squarrosum');


UPDATE test_old_monitoring.quadrat_vegetation a SET scientificname = REPLACE(scientificname, 'dryopteris felix mas', 'dryopteris filix-mas');
UPDATE test_old_monitoring.quadrat_vegetation a SET scientificname = REPLACE(scientificname, 'dactylorhiza fuschii', 'dactylorhiza fuchsii');
UPDATE test_old_monitoring.quadrat_vegetation a SET scientificname = REPLACE(scientificname, 'sphagnum squarrosum papillosum', 'sphagnum squarrosum');


-------------------------------

select distinct(locality), eventdate
from test_old_monitoring.nbn
order by locality;


select distinct(site), date
from test_old_monitoring.quadrat_info
order by site;


select distinct(site), date, 
from test_old_monitoring.bl_quadrat_info
order by site;


select *  from test_old_monitoring.nbn
where locality = 'Carsegowan';



create table test_old_monitoring.baseline_survey_dates 
(site text,	survey_date text)

--------------------------------------

select * from test_old_monitoring.bl_quadrat_info where date like'202';

UPDATE test_old_monitoring.bl_quadrat_info a SET date = b.survey_date FROM test_old_monitoring.baseline_survey_dates b
WHERE a.site = b.site;




