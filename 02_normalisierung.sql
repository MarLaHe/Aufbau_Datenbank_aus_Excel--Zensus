-----referenztabellen kreis, land, geschlecht, zeitpunkt
--kreis erstellen
CREATE TABLE kreis (
    region_id VARCHAR PRIMARY KEY,
    regionalebene VARCHAR, 
    region_name VARCHAR
);

INSERT INTO kreis (region_id, regionalebene, region_name)
SELECT DISTINCT  _rs, regionalebene, name
FROM raw_schulform;

--land, kreis , bund eintragen
ALTER TABLE kreis
ADD COLUMN kreis_id VARCHAR,
ADD COLUMN kreis_name VARCHAR,
ADD COLUMN land_id VARCHAR,
ADD COLUMN land_name VARCHAR;

UPDATE kreis
SET 
    kreis_id = CASE 
                  WHEN regionalebene = 'stadtkreis/kreisfreie stadt/landkreis' THEN region_id
                  ELSE NULL 
                END,
    kreis_name = CASE 
                   WHEN regionalebene = 'stadtkreis/kreisfreie stadt/landkreis' THEN region_name
                   ELSE NULL 
                 END;

--mapping für land_id
UPDATE kreis
SET land_id = LEFT(kreis_id::TEXT, 2)
WHERE land_id IS NULL AND kreis_id IS NOT NULL;

-- und land_name eintragen
WITH land_name_mapping AS (
    SELECT '01' AS land_id, 'schleswig-holstein' AS land_name
    UNION ALL
    SELECT '02', 'hamburg'
    UNION ALL
    SELECT '03', 'niedersachsen'
    UNION ALL
    SELECT '04', 'bremen'
    UNION ALL
    SELECT '05', 'nordrhein-westfalen'
    UNION ALL
    SELECT '06', 'hessen'
    UNION ALL
    SELECT '07', 'rheinland-pfalz'
    UNION ALL
    SELECT '08', 'baden-württemberg'
    UNION ALL
    SELECT '09', 'bayern'
    UNION ALL
    SELECT '10', 'saarland'
    UNION ALL
    SELECT '11', 'berlin'
    UNION ALL
    SELECT '12', 'brandenburg'
    UNION ALL
    SELECT '13', 'mecklenburg-vorpommern'
    UNION ALL
    SELECT '14', 'sachsen'
    UNION ALL
    SELECT '15', 'sachsen-anhalt'
    UNION ALL
    SELECT '16', 'thüringen'
)
UPDATE kreis
SET land_name = mapping.land_name
FROM land_name_mapping mapping
WHERE kreis.land_id = mapping.land_id
AND (kreis.land_name IS NULL OR kreis.land_name = '');

SELECT * from kreis;

-- neue Tabelle land
CREATE TABLE land (
    land_id VARCHAR(2) PRIMARY KEY,
    land_name VARCHAR(50)
);

INSERT INTO land (land_id, land_name)
SELECT DISTINCT land_id, land_name
FROM kreis
WHERE land_id IS NOT NULL AND land_name IS NOT NULL;

-- aufräumen
ALTER TABLE kreis
DROP COLUMN region_id,
DROP COLUMN regionalebene,
DROP COLUMN land_name,
DROP COLUMN region_name;

--Null values entfernen
DELETE FROM kreis
WHERE kreis_id IS NULL;

-- Primär- und Fremdschlüssel hinzufügen
ALTER TABLE kreis
ADD PRIMARY KEY (kreis_id),
ADD CONSTRAINT fk_land
FOREIGN KEY (land_id) REFERENCES land (land_id);

select * from kreis

--geschlecht erstellen
CREATE TABLE geschlecht (
    geschlecht_id SERIAL PRIMARY KEY,
    geschlecht_typ VARCHAR NOT NULL UNIQUE
    );

INSERT INTO geschlecht (geschlecht_typ)
SELECT DISTINCT  "geschlecht"
FROM raw_schulform;


--zeitpunkt erstellen
CREATE TABLE zeitpunkt (
    zeitpunkt_id SERIAL PRIMARY KEY,
    berichtszeitpunkt BIGINT UNIQUE
    );

INSERT INTO zeitpunkt ( berichtszeitpunkt)
SELECT DISTINCT  berichtszeitpunkt
FROM raw_schulform;


-----referenztabellen zu allen raw_tabellen
--alter_typ erstellen
CREATE TABLE alter_typ (
    alter_id SERIAL PRIMARY KEY,
    alter_typ VARCHAR NOT NULL UNIQUE,
    einheit VARCHAR
    );

INSERT INTO alter_typ (alter_typ, einheit)
SELECT DISTINCT  subtyp, einheit
FROM raw_alter;

--berufsabschluss erstellen
CREATE TABLE berufsabschluss_typ (
    berufsabschluss_id SERIAL PRIMARY KEY,
    berufsabschluss_typ VARCHAR NOT NULL UNIQUE,
    einheit VARCHAR
    );

INSERT INTO berufsabschluss_typ (berufsabschluss_typ, einheit)
SELECT DISTINCT  subtyp, einheit
FROM raw_berufsabschluss;

--berufsgruppe erstellen
CREATE TABLE berufsgruppe_typ (
    berufsgruppe_id SERIAL PRIMARY KEY,
    berufsgruppe_typ VARCHAR NOT NULL UNIQUE,
    einheit VARCHAR
    );

INSERT INTO berufsgruppe_typ(berufsgruppe_typ, einheit)
SELECT DISTINCT  subtyp, einheit
FROM raw_berufsgruppe;


--erwerbsstatus erstellen
CREATE TABLE erwerbsstatus_typ (
    erwerbsstatus_id SERIAL PRIMARY KEY,
    erwerbsstatus_typ VARCHAR NOT NULL UNIQUE,
    einheit VARCHAR
    );

INSERT INTO erwerbsstatus_typ (erwerbsstatus_typ, einheit)
SELECT DISTINCT  subtyp, einheit
FROM raw_erwerbsstatus;

--et_berufsabschluss erstellen
CREATE TABLE et_berufsabschluss_typ (
    et_berufsabschluss_id SERIAL PRIMARY KEY,
    et_berufsabschluss_typ VARCHAR NOT NULL UNIQUE,
    einheit VARCHAR
    );

INSERT INTO et_berufsabschluss_typ(et_berufsabschluss_typ, einheit)
SELECT DISTINCT  subtyp, einheit
FROM raw_et_berufsabschluss;

--klassenstufe erstellen
CREATE TABLE klassenstufe_typ (
    klassenstufe_id SERIAL PRIMARY KEY,
    klassenstufe_typ VARCHAR NOT NULL UNIQUE,
    einheit VARCHAR
    );

INSERT INTO klassenstufe_typ (klassenstufe_typ, einheit)
SELECT DISTINCT  subtyp, einheit
FROM raw_klassenstufe;

--schulabschluss erstellen
CREATE TABLE schulabschluss_typ (
    schulabschluss_id SERIAL PRIMARY KEY,
    schulabschluss_typ VARCHAR NOT NULL UNIQUE,
    einheit VARCHAR
    );

INSERT INTO schulabschluss_typ (schulabschluss_typ, einheit)
SELECT DISTINCT  subtyp, einheit
FROM raw_schulabschluss;

--schulform erstellen
CREATE TABLE schulform_typ (
    schulform_id SERIAL PRIMARY KEY,
    schulform_typ VARCHAR NOT NULL UNIQUE,
    einheit VARCHAR
);

INSERT INTO schulform_typ (schulform_typ, einheit)
SELECT DISTINCT  subtyp, einheit
FROM raw_schulform;

--stellung erstellen
CREATE TABLE stellung_typ (
    stellung_id SERIAL PRIMARY KEY,
    stellung_typ VARCHAR NOT NULL UNIQUE,
    einheit VARCHAR
    );

INSERT INTO stellung_typ (stellung_typ, einheit)
SELECT DISTINCT  subtyp, einheit
FROM raw_stellung;

--wirtschaft erstellen
CREATE TABLE wirtschaft_typ (
    wirtschaft_id SERIAL PRIMARY KEY,
    wirtschaft_typ VARCHAR NOT NULL UNIQUE,
    einheit VARCHAR
    );

INSERT INTO wirtschaft_typ(wirtschaft_typ, einheit)
SELECT DISTINCT  subtyp, einheit
FROM raw_wirtschaft;

select * from alter_typ

----sozusagen haupttabellen jeweils mit Anzahlen und Referenzen...
--schulform erstellen
CREATE TABLE schulform (
    haupt_id SERIAL PRIMARY KEY,
    kreis_id VARCHAR,
    schulform_id INT,
    geschlecht_id INT,
    zeitpunkt_id INT,
    anzahl INT,
    FOREIGN KEY (kreis_id) REFERENCES kreis(kreis_id),
    FOREIGN KEY (schulform_id) REFERENCES schulform_typ(schulform_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt(zeitpunkt_id)
);

INSERT INTO schulform (kreis_id, schulform_id, geschlecht_id, zeitpunkt_id, anzahl)
SELECT 
    raw_schulform."_rs" AS kreis_id, 
    schulform_typ.schulform_id, 
    geschlecht.geschlecht_id, 
    zeitpunkt.zeitpunkt_id, 
    raw_schulform."anzahl"
FROM 
    raw_schulform
INNER JOIN 
    kreis ON raw_schulform."_rs" = kreis.kreis_id
INNER JOIN 
    schulform_typ ON raw_schulform."subtyp" = schulform_typ.schulform_typ
INNER JOIN 
    geschlecht ON raw_schulform."geschlecht" = geschlecht.geschlecht_typ
INNER JOIN 
    zeitpunkt ON raw_schulform."berichtszeitpunkt" = zeitpunkt.berichtszeitpunkt;

select * from schulform LIMIT 20

--klassenstufe erstellen
CREATE TABLE klassenstufe (
    haupt_id SERIAL PRIMARY KEY,
    kreis_id VARCHAR,
    klassenstufe_id INT,
    geschlecht_id INT,
    zeitpunkt_id INT,
    anzahl INT,
    FOREIGN KEY (kreis_id) REFERENCES kreis(kreis_id),
    FOREIGN KEY (klassenstufe_id) REFERENCES klassenstufe_typ(klassenstufe_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt(zeitpunkt_id)
);

INSERT INTO klassenstufe (kreis_id, klassenstufe_id, geschlecht_id, zeitpunkt_id, anzahl)
SELECT 
    raw_klassenstufe."_rs" AS kreis_id, 
    klassenstufe_typ.klassenstufe_id, 
    geschlecht.geschlecht_id, 
    zeitpunkt.zeitpunkt_id, 
    raw_klassenstufe."anzahl"
FROM 
    raw_klassenstufe
INNER JOIN 
    kreis ON raw_klassenstufe."_rs" = kreis.kreis_id
INNER JOIN 
    klassenstufe_typ ON raw_klassenstufe."subtyp" = klassenstufe_typ.klassenstufe_typ
INNER JOIN 
    geschlecht ON raw_klassenstufe."geschlecht" = geschlecht.geschlecht_typ
INNER JOIN 
    zeitpunkt ON raw_klassenstufe."berichtszeitpunkt" = zeitpunkt.berichtszeitpunkt;

select * from klassenstufe LIMIT 20

-- schulabschluss erstellen
CREATE TABLE schulabschluss (
    haupt_id SERIAL PRIMARY KEY,
    kreis_id VARCHAR,
    schulabschluss_id INT,
    geschlecht_id INT,
    zeitpunkt_id INT,
    anzahl INT,
    FOREIGN KEY (kreis_id) REFERENCES kreis(kreis_id),
    FOREIGN KEY (schulabschluss_id) REFERENCES schulabschluss_typ(schulabschluss_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt(zeitpunkt_id)
);

INSERT INTO schulabschluss (kreis_id, schulabschluss_id, geschlecht_id, zeitpunkt_id, anzahl)
SELECT 
    raw_schulabschluss."_rs" AS kreis_id, 
    schulabschluss_typ.schulabschluss_id, 
    geschlecht.geschlecht_id, 
    zeitpunkt.zeitpunkt_id, 
    raw_schulabschluss."anzahl"
FROM 
    raw_schulabschluss
INNER JOIN 
    kreis ON raw_schulabschluss."_rs" = kreis.kreis_id
INNER JOIN 
    schulabschluss_typ ON raw_schulabschluss."subtyp" = schulabschluss_typ.schulabschluss_typ
INNER JOIN 
    geschlecht ON raw_schulabschluss."geschlecht" = geschlecht.geschlecht_typ
INNER JOIN 
    zeitpunkt ON raw_schulabschluss."berichtszeitpunkt" = zeitpunkt.berichtszeitpunkt;

select * from schulabschluss limit 10

--berufsabschluss
CREATE TABLE berufsabschluss (
    haupt_id SERIAL PRIMARY KEY,
    kreis_id VARCHAR,
    berufsabschluss_id INT,
    geschlecht_id INT,
    zeitpunkt_id INT,
    anzahl INT,
    FOREIGN KEY (kreis_id) REFERENCES kreis(kreis_id),
    FOREIGN KEY (berufsabschluss_id) REFERENCES berufsabschluss_typ(berufsabschluss_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt(zeitpunkt_id)
);

INSERT INTO berufsabschluss (kreis_id, berufsabschluss_id, geschlecht_id, zeitpunkt_id, anzahl)
SELECT 
    raw_berufsabschluss."_rs" AS kreis_id, 
    berufsabschluss_typ.berufsabschluss_id, 
    geschlecht.geschlecht_id, 
    zeitpunkt.zeitpunkt_id, 
    raw_berufsabschluss."anzahl"
FROM 
    raw_berufsabschluss
INNER JOIN 
    kreis ON raw_berufsabschluss."_rs" = kreis.kreis_id
INNER JOIN 
    berufsabschluss_typ ON raw_berufsabschluss."subtyp" = berufsabschluss_typ.berufsabschluss_typ
INNER JOIN 
    geschlecht ON raw_berufsabschluss."geschlecht" = geschlecht.geschlecht_typ
INNER JOIN 
    zeitpunkt ON raw_berufsabschluss."berichtszeitpunkt" = zeitpunkt.berichtszeitpunkt;


--alter erstellen
CREATE TABLE alter (
    haupt_id SERIAL PRIMARY KEY,
    kreis_id VARCHAR,
    alter_id INT,
    geschlecht_id INT,
    zeitpunkt_id INT,
    anzahl INT,
    FOREIGN KEY (kreis_id) REFERENCES kreis(kreis_id),
    FOREIGN KEY (alter_id) REFERENCES alter_typ(alter_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt(zeitpunkt_id)
);

INSERT INTO alter (kreis_id, alter_id, geschlecht_id, zeitpunkt_id, anzahl)
SELECT 
    raw_alter."_rs" AS kreis_id, 
    alter_typ.alter_id, 
    geschlecht.geschlecht_id, 
    zeitpunkt.zeitpunkt_id, 
    raw_alter."anzahl"
FROM 
    raw_alter
INNER JOIN 
    kreis ON raw_alter."_rs" = kreis.kreis_id
INNER JOIN 
    alter_typ ON raw_alter."subtyp" = alter_typ.alter_typ
INNER JOIN 
    geschlecht ON raw_alter."geschlecht" = geschlecht.geschlecht_typ
INNER JOIN 
    zeitpunkt ON raw_alter."berichtszeitpunkt" = zeitpunkt.berichtszeitpunkt;

--et_berufsabschluss erstellen
CREATE TABLE et_berufsabschluss(
    haupt_id SERIAL PRIMARY KEY,
    kreis_id VARCHAR,
    et_berufsabschluss_id INT,
    geschlecht_id INT,
    zeitpunkt_id INT,
    anzahl INT,
    FOREIGN KEY (kreis_id) REFERENCES kreis(kreis_id),
    FOREIGN KEY (et_berufsabschluss_id) REFERENCES et_berufsabschluss_typ(et_berufsabschluss_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt(zeitpunkt_id)
);

INSERT INTO et_berufsabschluss (kreis_id, et_berufsabschluss_id, geschlecht_id, zeitpunkt_id, anzahl)
SELECT 
    raw_et_berufsabschluss."_rs" AS kreis_id, 
    et_berufsabschluss_typ.et_berufsabschluss_id, 
    geschlecht.geschlecht_id, 
    zeitpunkt.zeitpunkt_id, 
    raw_et_berufsabschluss."anzahl"
FROM 
    raw_et_berufsabschluss
INNER JOIN 
    kreis ON raw_et_berufsabschluss."_rs" = kreis.kreis_id
INNER JOIN 
    et_berufsabschluss_typ ON raw_et_berufsabschluss."subtyp" = et_berufsabschluss_typ.et_berufsabschluss_typ
INNER JOIN 
    geschlecht ON raw_et_berufsabschluss."geschlecht" = geschlecht.geschlecht_typ
INNER JOIN 
    zeitpunkt ON raw_et_berufsabschluss."berichtszeitpunkt" = zeitpunkt.berichtszeitpunkt;


--berufsgruppe erstellen
CREATE TABLE berufsgruppe (
    haupt_id SERIAL PRIMARY KEY,
    kreis_id VARCHAR,
    berufsgruppe_id INT,
    geschlecht_id INT,
    zeitpunkt_id INT,
    anzahl INT,
    FOREIGN KEY (kreis_id) REFERENCES kreis(kreis_id),
    FOREIGN KEY (berufsgruppe_id) REFERENCES berufsgruppe_typ(berufsgruppe_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt(zeitpunkt_id)
);

INSERT INTO berufsgruppe (kreis_id, berufsgruppe_id, geschlecht_id, zeitpunkt_id, anzahl)
SELECT 
    raw_berufsgruppe."_rs" AS kreis_id, 
    berufsgruppe_typ.berufsgruppe_id, 
    geschlecht.geschlecht_id, 
    zeitpunkt.zeitpunkt_id, 
    raw_berufsgruppe."anzahl"
FROM 
    raw_berufsgruppe
INNER JOIN 
    kreis ON raw_berufsgruppe."_rs" = kreis.kreis_id
INNER JOIN 
    berufsgruppe_typ ON raw_berufsgruppe."subtyp" = berufsgruppe_typ.berufsgruppe_typ
INNER JOIN 
    geschlecht ON raw_berufsgruppe."geschlecht" = geschlecht.geschlecht_typ
INNER JOIN 
    zeitpunkt ON raw_berufsgruppe."berichtszeitpunkt" = zeitpunkt.berichtszeitpunkt;



--stellung erstellen
CREATE TABLE stellung (
    haupt_id SERIAL PRIMARY KEY,
    kreis_id VARCHAR,
    stellung_id INT,
    geschlecht_id INT,
    zeitpunkt_id INT,
    anzahl INT,
    FOREIGN KEY (kreis_id) REFERENCES kreis(kreis_id),
    FOREIGN KEY (stellung_id) REFERENCES stellung_typ(stellung_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt(zeitpunkt_id)
);

INSERT INTO stellung (kreis_id, stellung_id, geschlecht_id, zeitpunkt_id, anzahl)
SELECT 
    raw_stellung."_rs" AS kreis_id, 
    stellung_typ.stellung_id, 
    geschlecht.geschlecht_id, 
    zeitpunkt.zeitpunkt_id, 
    raw_stellung."anzahl"
FROM 
    raw_stellung
INNER JOIN 
    kreis ON raw_stellung."_rs" = kreis.kreis_id
INNER JOIN 
    stellung_typ ON raw_stellung."subtyp" = stellung_typ.stellung_typ
INNER JOIN 
    geschlecht ON raw_stellung."geschlecht" = geschlecht.geschlecht_typ
INNER JOIN 
    zeitpunkt ON raw_stellung."berichtszeitpunkt" = zeitpunkt.berichtszeitpunkt;


--wirtschaft erstellen
CREATE TABLE wirtschaft(
    haupt_id SERIAL PRIMARY KEY,
    kreis_id VARCHAR,
    wirtschaft_id INT,
    geschlecht_id INT,
    zeitpunkt_id INT,
    anzahl INT,
    FOREIGN KEY (kreis_id) REFERENCES kreis(kreis_id),
    FOREIGN KEY (wirtschaft_id) REFERENCES wirtschaft_typ(wirtschaft_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt(zeitpunkt_id)
);

INSERT INTO wirtschaft (kreis_id, wirtschaft_id, geschlecht_id, zeitpunkt_id, anzahl)
SELECT 
    raw_wirtschaft."_rs" AS kreis_id, 
    wirtschaft_typ.wirtschaft_id, 
    geschlecht.geschlecht_id, 
    zeitpunkt.zeitpunkt_id, 
    raw_wirtschaft."anzahl"
FROM 
    raw_wirtschaft
INNER JOIN 
    kreis ON raw_wirtschaft."_rs" = kreis.kreis_id
INNER JOIN 
    wirtschaft_typ ON raw_wirtschaft."subtyp" = wirtschaft_typ.wirtschaft_typ
INNER JOIN 
    geschlecht ON raw_wirtschaft."geschlecht" = geschlecht.geschlecht_typ
INNER JOIN 
    zeitpunkt ON raw_wirtschaft."berichtszeitpunkt" = zeitpunkt.berichtszeitpunkt;


--erwerbsstatus_erstellen
CREATE TABLE erwerbsstatus (
    haupt_id SERIAL PRIMARY KEY,
    kreis_id VARCHAR,
    erwerbsstatus_id INT,
    geschlecht_id INT,
    zeitpunkt_id INT,
    anzahl INT,
    FOREIGN KEY (kreis_id) REFERENCES kreis(kreis_id),
    FOREIGN KEY (erwerbsstatus_id) REFERENCES erwerbsstatus_typ(erwerbsstatus_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt(zeitpunkt_id)
);

INSERT INTO erwerbsstatus(kreis_id, erwerbsstatus_id, geschlecht_id, zeitpunkt_id, anzahl)
SELECT 
    raw_erwerbsstatus."_rs" AS kreis_id, 
    erwerbsstatus_typ.erwerbsstatus_id, 
    geschlecht.geschlecht_id, 
    zeitpunkt.zeitpunkt_id, 
    raw_erwerbsstatus."anzahl"
FROM 
    raw_erwerbsstatus
INNER JOIN 
    kreis ON raw_erwerbsstatus."_rs" = kreis.kreis_id
INNER JOIN 
    erwerbsstatus_typ ON raw_erwerbsstatus."subtyp" = erwerbsstatus_typ.erwerbsstatus_typ
INNER JOIN 
    geschlecht ON raw_erwerbsstatus."geschlecht" = geschlecht.geschlecht_typ
INNER JOIN 
    zeitpunkt ON raw_erwerbsstatus."berichtszeitpunkt" = zeitpunkt.berichtszeitpunkt;
    







