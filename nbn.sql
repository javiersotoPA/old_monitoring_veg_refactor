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

--select count(*) from test_old_monitoring.nbn where taxonID = 'NaN';


------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


UPDATE test_old_monitoring.nbn a SET eventdate = b.survey_date2 from test_old_monitoring.bl_survey_dates b where
a.locality = b.site AND a.datasetName = 'Baseline Survey Peatland Monitoring Dataset';

UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '07-08-2014' WHERE survey_date = '2014-08-07';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '09-09-2014' WHERE survey_date = '2014-09-09';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '18-08-2014' WHERE survey_date = '2014-08-18';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '05-08-2014' WHERE survey_date = '2014-08-05';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '23-06-2015' WHERE survey_date = '2015-06-23';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '07-07-2015' WHERE survey_date = '2015-07-07';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '14-07-2015'	 WHERE survey_date = '2015-07-14';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '11-08-2015' WHERE survey_date = '2015-08-11';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '24-08-2015'	 WHERE survey_date = '2015-08-24';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '26-08-2015' WHERE survey_date = '2015-08-26';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '28-09-2015' WHERE survey_date = '2015-09-28';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '06-10-2015' WHERE survey_date = '2015-10-06'; 
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '14-10-2015'	 WHERE survey_date = '2015-10-14';
UPDATE test_old_monitoring.bl_survey_dates SET survey_date2 = '07-10-2015' WHERE survey_date = '2015-10-07';


UPDATE test_old_monitoring.nbn SET eventdate = replace(eventdate, '/', '-');



