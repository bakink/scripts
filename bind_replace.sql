undefine sql_id
accept sql_id prompt "SQL_ID......: "
set serveroutput on
declare
 v_sql_id varchar2(13):=trim('&&sql_id');
 TYPE varchar2_array IS VARRAY(1000) of varchar2(32767);
 v_sql_fulltext varchar2_array := varchar2_array();
 j number:=1;
begin

 v_sql_fulltext.extend(1000);

 for i in
 (
  select substr(sql_fulltext,1,32767) vc_sql_fulltext from gv$sql where sql_id=v_sql_id
 )
 loop
  v_sql_fulltext(j):=i.vc_sql_fulltext;
  j:=j+1;
 end loop;

 for i in
 (
 SELECT name,
       NVL (
           DECODE (
               SUBSTR (datatype_string, 1, 4),
               'NUMB', value_string,
               'VARC', '''' || replace(value_string,'''','''''') || '''',
               'NVAR', '''' || replace(value_string,'''','''''') || '''',
               'CHAR', '''' || replace(value_string,'''','''''') || '''',
               'DATE',    'to_date('''
                       || value_string
                       || ''',''MM/DD/YY HH24:MI:SS'')',
               ''),
           'NULL')
           AS "VALUE"
  FROM gv$sql_bind_capture
 WHERE     sql_id = v_sql_id
       AND child_address =
               (SELECT child_address
                  FROM (SELECT child_address
                          FROM gv$sql
                         WHERE sql_id = v_sql_id
                        ORDER BY elapsed_time / (executions + 1) DESC)
                 WHERE ROWNUM = 1)
GROUP BY name,
         DECODE (
             SUBSTR (datatype_string, 1, 4),
             'NUMB', value_string,
             'VARC', '''' || replace(value_string,'''','''''') || '''',
             'NVAR', '''' || replace(value_string,'''','''''') || '''',
             'CHAR', '''' || replace(value_string,'''','''''') || '''',
             'DATE',    'to_date('''
                     || value_string
                     || ''',''MM/DD/YY HH24:MI:SS'')',
             '')
--  order by to_number(replace(name,substr(name,1,2),'')) desc
--  order by to_number(REGEXP_REPLACE(name, '[^0-9]', '')) desc
ORDER BY name DESC
 )
 loop
  for j IN 1 .. v_sql_fulltext.COUNT
  LOOP
   v_sql_fulltext(j):=replace(replace(upper(v_sql_fulltext(j)), ':"'||substr(upper(i.name),2)||'"', i.value),upper(i.name), i.value);
  END LOOP;
 end loop;

 dbms_output.put_line(v_sql_fulltext(1));
-- for j IN 1 .. v_sql_fulltext.COUNT
-- LOOP
--  dbms_output.put_line(v_sql_fulltext(j));
-- END LOOP;
end;
/
undefine sql_id
