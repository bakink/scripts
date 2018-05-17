--http://www.oracle-developer.net/display.php?id=430 

--Here's a quick example borrowed from there showing how to get this in SQL using XML conversion: 

create table t (
  x date 
) partition by range (x) (
  partition p0 values less than (date'2015-01-01'),
  partition p1 values less than (date'2015-06-01'),
  partition pmax values less than (maxvalue)
);

with xml as (
  select dbms_xmlgen.getxmltype('select table_name, partition_name, high_value from user_tab_partitions where table_name = ''T''') as x
  from   dual
)
  select extractValue(rws.object_value, '/ROW/TABLE_NAME') table_name,
         extractValue(rws.object_value, '/ROW/PARTITION_NAME') partition,
         extractValue(rws.object_value, '/ROW/HIGH_VALUE') high_value
  from   xml x, 
         table(xmlsequence(extract(x.x, '/ROWSET/ROW'))) rws;

--http://www.oracle-developer.net/display.php?id=430
--https://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:9522731800346411985

with xml as (
  select dbms_xmlgen.getxmltype('select table_name, partition_name, high_value from user_tab_partitions where table_name = ''T''') as x
  from   dual
)
  select extractValue(rws.object_value, '/ROW/TABLE_NAME') table_name,
         extractValue(rws.object_value, '/ROW/PARTITION_NAME') partition,
         extractValue(rws.object_value, '/ROW/HIGH_VALUE') high_value
  from   xml x, 
         table(xmlsequence(extract(x.x, '/ROWSET/ROW'))) rws;
