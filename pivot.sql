DO $$
Declare concept text;
Declare valtype text;
Declare type_name text;
Declare query text;
Declare table_name text;
Declare id integer;
Declare char_val text;
Declare num_val numeric(18,5);
Declare usedid text;
Declare currentid text;
Declare sex text;
Declare year integer;
Declare startdate timestamp without time zone;
Declare pid integer;
BEGIN
query := '';
usedid := '';
table_name := 'new_table';
for concept, valtype in 
	select distinct on (concept_cd) concept_cd, valtype_cd 
	from observation_fact
loop
CASE
    WHEN 'T'=valtype 
    THEN 
	type_name := ' text';
    ELSE 
	type_name := ' numeric(18,5)';
END case;
query := query || '"' || concept || '"' || type_name || ',';
end loop;
query := 'CREATE TABLE ' || table_name || '( id integer, pid integer, birth_year integer, sex text, ' || query || '@);';
query := regexp_replace(query, ',@', '');
execute format('DROP TABLE IF EXISTS ' || table_name);
execute format(query);
table_name := 'new_table';
for id, pid, startdate, concept, valtype, char_val, num_val, year, sex in 
	select observation_fact.encounter_num, observation_fact.patient_num, observation_fact.start_date, observation_fact.concept_cd, observation_fact.valtype_cd, observation_fact.tval_char, observation_fact.nval_num, 2000, patient_dimension.sex_cd  
	from observation_fact, patient_dimension where observation_fact.patient_num=patient_dimension.patient_num
loop
currentid := ',' || id || ',';
--raise notice 'CurrentID = %', currentid;
CASE
    WHEN 'T'=valtype 
    THEN 
	IF coalesce(TRIM(char_val), '') <> '' and char_val is not null then
		if ( usedid ~ currentid) then
		execute format('update ' || table_name  || ' set ' || '"' || concept || '" = ''' ||  char_val || ''' where id = ' || id );
		else
--	raise notice 'Value: %', 'insert into ' || table_name  || '( id, ' || '"' || concept || '"' || ') VALUES (' || id || ',''' ||  char_val || ''')';
		execute format('insert into ' || table_name  || '( id, pid, birth_year, sex, ' || '"' || concept || '"' || ') VALUES (' || id || ',' || pid || ',' || year || ',''' || sex || ''',''' ||  char_val || ''')');
		usedid := usedid || ',' || id || ',';
		end if;
	end if;
    ELSE 
	if num_val is not null then
		if ( usedid ~ currentid) then
		execute format('update ' || table_name  || ' set ' || '"' || concept || '" = ' ||  num_val || ' where id = ' || id );
		else
--	raise notice 'Value: %', 'insert into ' || table_name  || '( id, ' || '"' || concept || '"' || ') VALUES (' || id || ')';
		execute format('insert into ' || table_name  || '( id, pid, birth_year, sex, ' || '"' || concept || '"' || ') VALUES (' || id || ',' || pid || ',' || year || ',''' || sex || ''',' ||  num_val || ')');
		usedid := usedid || ',' || id ||',';
		end if;
	end if;
END case;
end loop;
-- by ucommenting/commenting one of these two lines the result is either stored in a CSV or in a table
COPY (Select * From new_table) To '/opt/target/NiguardaFlat.csv' With CSV DELIMITER ',' HEADER;
execute format('DROP TABLE IF EXISTS ' || table_name);
end;$$
