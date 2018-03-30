--https://orastory.wordpress.com/2012/07/12/plan_hash_value-and-internal-temporary-table-names/
select sn.snap_id
,      sn.end_interval_time
,      st.module
,      st.sql_id
,      st.plan_hash_value
,      (select extractvalue(xmltype(other_xml),'other_xml/info[@type="plan_hash_2"]')
        from   dba_hist_sql_plan hp
        where  hp.sql_id          = st.sql_id
        and    hp.plan_hash_value = st.plan_hash_value
        and    hp.other_xml is not null) plan_hash_2
,      rows_processed_delta rws
,      executions_delta     execs
,      elapsed_time_delta   elp
,      cpu_time_delta       cpu
,      buffer_gets_delta    gets
,      iowait_delta         io
from   dba_hist_snapshot sn
,      dba_hist_sqlstat  st
where  st.snap_id            = sn.snap_id
and    st.sql_id             = '&sql_id'
and    st.elapsed_time_delta > 0
order by sn.snap_id desc; 
