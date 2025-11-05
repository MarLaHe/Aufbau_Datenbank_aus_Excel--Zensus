--dimensionstabellen erstellen: regionalebene, einheiten; geschlecht und zeitpunkt kann verbunden werden von den normalisierten Tabellen

--regionalebene erstellen
CREATE TABLE regionalebene (
    regional_id VARCHAR PRIMARY KEY,
    kreis_name VARCHAR NOT NULL,
    land_name VARCHAR NOT NULL
);

INSERT INTO regionalebene (regional_id, kreis_name, land_name)
SELECT DISTINCT kreis.kreis_id, 
                kreis.kreis_name, 
                land.land_name
FROM kreis
INNER JOIN land ON kreis.land_id = land.land_id;

select * from regionalebene limit 10

--einheiten erstellen
CREATE TABLE einheiten (
    einheiten_id SERIAL PRIMARY KEY,
    einheit VARCHAR,
    subtyp VARCHAR
);
INSERT INTO einheiten (einheit, subtyp)
SELECT DISTINCT einheit, subtyp FROM raw_alter
UNION ALL
SELECT DISTINCT einheit, subtyp FROM raw_berufsabschluss
UNION ALL
SELECT DISTINCT einheit, subtyp FROM raw_berufsgruppe 
UNION ALL 
SELECT DISTINCT einheit, subtyp FROM raw_erwerbsstatus 
UNION ALL
SELECT DISTINCT einheit, subtyp FROM raw_et_berufsabschluss
UNION ALL 
SELECT DISTINCT einheit, subtyp FROM raw_klassenstufe 
UNION ALL
SELECT DISTINCT einheit, subtyp FROM raw_schulabschluss 
UNION ALL 
SELECT DISTINCT einheit, subtyp FROM raw_schulform 
UNION ALL 
SELECT DISTINCT einheit, subtyp FROM raw_stellung 
UNION ALL 
SELECT DISTINCT einheit, subtyp FROM raw_wirtschaft;

select * from einheiten


--Faktentabelle erstellen

CREATE TABLE zensus_fakten (
    fakten_id SERIAL PRIMARY KEY,
    zeitpunkt_id INT,
    regional_id VARCHAR,
    geschlecht_id INT,
    einheiten_id INT,
    subtyp VARCHAR,
    anzahl INT,
    FOREIGN KEY (regional_id) REFERENCES regionalebene(regional_id),
    FOREIGN KEY (zeitpunkt_id) REFERENCES zeitpunkt (zeitpunkt_id),
    FOREIGN KEY (geschlecht_id) REFERENCES geschlecht(geschlecht_id),
    FOREIGN KEY (einheiten_id) REFERENCES einheiten(einheiten_id)
);

INSERT INTO zensus_fakten (
    zeitpunkt_id, 
    regional_id, 
    geschlecht_id,
    subtyp, 
    anzahl)

SELECT 
    schulform.zeitpunkt_id,
    schulform.kreis_id,
    schulform.geschlecht_id,
    schulform_typ.schulform_typ,
    schulform.anzahl
FROM schulform
JOIN schulform_typ ON schulform.schulform_id = schulform_typ.schulform_id

UNION ALL

SELECT 
    klassenstufe.zeitpunkt_id,
    klassenstufe.kreis_id,
    klassenstufe.geschlecht_id,
    klassenstufe_typ.klassenstufe_typ,
    klassenstufe.anzahl
FROM klassenstufe
JOIN klassenstufe_typ ON klassenstufe.klassenstufe_id = klassenstufe_typ.klassenstufe_id

UNION ALL 

SELECT 
    schulabschluss.zeitpunkt_id,
    schulabschluss.kreis_id,
    schulabschluss.geschlecht_id,
    schulabschluss_typ.schulabschluss_typ,
    schulabschluss.anzahl
FROM schulabschluss
JOIN schulabschluss_typ ON schulabschluss.schulabschluss_id = schulabschluss_typ.schulabschluss_id

UNION ALL

SELECT 
    berufsabschluss.zeitpunkt_id,
    berufsabschluss.kreis_id,
    berufsabschluss.geschlecht_id,
    berufsabschluss_typ.berufsabschluss_typ,
    berufsabschluss.anzahl
FROM berufsabschluss
JOIN berufsabschluss_typ ON berufsabschluss.berufsabschluss_id = berufsabschluss_typ.berufsabschluss_id

UNION ALL 

SELECT 
    erwerbsstatus.zeitpunkt_id,
    erwerbsstatus.kreis_id,
    erwerbsstatus.geschlecht_id,
    erwerbsstatus_typ.erwerbsstatus_typ,
    erwerbsstatus.anzahl
FROM erwerbsstatus
JOIN erwerbsstatus_typ ON erwerbsstatus.erwerbsstatus_id = erwerbsstatus_typ.erwerbsstatus_id 

UNION ALL 

SELECT 
    alter.zeitpunkt_id,
    alter.kreis_id,
    alter.geschlecht_id,
    alter_typ.alter_typ,
    alter.anzahl
FROM alter
JOIN alter_typ ON alter.alter_id = alter_typ.alter_id 

UNION ALL 

SELECT 
    berufsgruppe.zeitpunkt_id,
    berufsgruppe.kreis_id,
    berufsgruppe.geschlecht_id,
    berufsgruppe_typ.berufsgruppe_typ,
    berufsgruppe.anzahl
FROM berufsgruppe
JOIN berufsgruppe_typ ON berufsgruppe.berufsgruppe_id = berufsgruppe_typ.berufsgruppe_id 

UNION ALL 

SELECT 
    et_berufsabschluss.zeitpunkt_id,
    et_berufsabschluss.kreis_id,
    et_berufsabschluss.geschlecht_id,
    et_berufsabschluss_typ.et_berufsabschluss_typ,
    et_berufsabschluss.anzahl
FROM et_berufsabschluss
JOIN et_berufsabschluss_typ ON et_berufsabschluss.et_berufsabschluss_id = et_berufsabschluss_typ.et_berufsabschluss_id 

UNION ALL 

SELECT 
    stellung.zeitpunkt_id,
    stellung.kreis_id,
    stellung.geschlecht_id,
    stellung_typ.stellung_typ,
    stellung.anzahl
FROM stellung
JOIN stellung_typ ON stellung.stellung_id = stellung_typ.stellung_id 

UNION ALL 

SELECT 
    wirtschaft.zeitpunkt_id,
    wirtschaft.kreis_id,
    wirtschaft.geschlecht_id,
    wirtschaft_typ.wirtschaft_typ,
    wirtschaft.anzahl
FROM wirtschaft
JOIN wirtschaft_typ ON wirtschaft.wirtschaft_id = wirtschaft_typ.wirtschaft_id 
;

UPDATE zensus_fakten
SET einheiten_id = einheiten.einheiten_id
FROM einheiten
WHERE einheiten.subtyp = zensus_fakten.subtyp;

ALTER TABLE zensus_fakten
DROP COLUMN subtyp;

SELECT DISTINCT e.subtyp 
FROM zensus_fakten zf
INNER JOIN einheiten e ON zf.einheiten_id = e.einheiten_id
WHERE e.einheit = 'et_berufsabschluss';



