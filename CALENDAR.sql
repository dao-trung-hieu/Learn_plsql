select date_key,
TO_CHAR (date_key, 'YYYYMMDD') AS date_value,
TO_CHAR (date_key, 'DD/MM/YYYY') AS date_value_1,
TO_NUMBER (TO_CHAR (date_key, 'D')) AS day_of_week_number,
TO_CHAR (date_key, 'Day') AS day_of_week_desc,
TO_CHAR (date_key, 'DY') AS day_of_week_sdesc,
CASE WHEN TO_NUMBER (TO_CHAR (date_key, 'D')) IN (1, 7) THEN 1
ELSE 0
END AS weekend_flag,
TO_NUMBER (TO_CHAR (date_key, 'W')) AS week_in_month_number,
TO_NUMBER (TO_CHAR (date_key, 'WW')) AS week_in_year_number,
TO_CHAR (date_key, 'YYYY')||' WEEK '||TO_CHAR (date_key, 'WW') AS week_in_year_varchar,
TRUNC(date_key, 'w') AS week_start_date,
TRUNC(date_key, 'w') + 7 - 1/86400 AS week_end_date,
TO_NUMBER (TO_CHAR (date_key, 'IW')) AS iso_week_number,
TRUNC(date_key, 'iw') AS iso_week_start_date,
TRUNC(date_key, 'iw') + 7 - 1/86400 AS iso_week_end_date,
TO_NUMBER (TO_CHAR (date_key, 'DD')) AS day_of_month_number,
TO_CHAR (date_key, 'YYYY')||TO_CHAR (date_key, 'MM') AS month_value,
TO_CHAR (date_key, 'Month') AS month_desc,
TO_CHAR (date_key, 'MON') AS month_sdesc,
TRUNC (date_key, 'mm') AS month_start_date,
LAST_DAY (TRUNC (date_key, 'mm')) + 1 - 1/86400 AS month_end_date,
TO_NUMBER ( TO_CHAR( LAST_DAY (TRUNC (date_key, 'mm')), 'DD')) AS days_in_month,
CASE WHEN date_key = LAST_DAY (TRUNC (date_key, 'mm')) THEN 1
ELSE 0
END AS last_day_of_month_flag,
TRUNC (date_key) - TRUNC (date_key, 'Q') + 1 AS day_of_quarter_number,
to_char(date_key,'YYYY')||'-Q' || TO_CHAR (date_key, 'Q') AS quarter_value,
TO_CHAR (date_key, 'Q') AS quarter_number,
to_char(date_key,'YYYY')||'-Q' || TO_CHAR (date_key, 'Q') AS quarter_desc,
TRUNC (date_key, 'Q') AS quarter_start_date,
ADD_MONTHS (TRUNC (date_key, 'Q'), 3) - 1/86400 AS quarter_end_date,
ADD_MONTHS (TRUNC (date_key, 'Q'), 3) - TRUNC (date_key, 'Q') AS days_in_quarter,
CASE WHEN date_key = ADD_MONTHS (TRUNC (date_key, 'Q'), 3) - 1 THEN 1
ELSE 0
END AS last_day_of_quarter_flag,
case when to_char(date_key,'MM')<='06' then to_char(date_key,'YYYY')||'-'||'H1' else to_char(date_key,'YYYY')||'-'||'H2' end as half_value,
TO_NUMBER (TO_CHAR (date_key, 'DDD')) AS day_of_year_number,
TO_CHAR (date_key, 'yyyy') AS year_value,
'YR' || TO_CHAR (date_key, 'yyyy') AS year_desc,
'YR' || TO_CHAR (date_key, 'yy') AS year_sdesc,
TRUNC (date_key, 'Y') AS year_start_date,
ADD_MONTHS (TRUNC (date_key, 'Y'), 12) - 1/86400 AS year_end_date,
ADD_MONTHS (TRUNC (date_key, 'Y'), 12) - TRUNC (date_key, 'Y') AS days_in_year
from (
select (to_date('2016/01/01', 'yyyy/mm/dd') + N.n) as date_key
 from
  (SELECT ROWNUM n
   FROM   ( SELECT 1 just_a_column
         FROM   dual
         CONNECT BY LEVEL <=  to_date('2016/12/31', 'yyyy/mm/dd') - to_date('2016/01/01', 'yyyy/mm/dd') + 1
           ) T
  ) N
  where to_date('2016/01/01', 'yyyy/mm/dd') + N.n <= to_date('2016/12/31', 'yyyy/mm/dd'));