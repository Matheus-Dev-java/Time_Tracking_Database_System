-- Creates the count of minutes worked between 22:00 and 05:00.
CREATE OR REPLACE FUNCTION fn_night_minutes(p_start timestamp, p_end timestamp)
RETURNS integer
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT COALESCE(SUM(GREATEST(0, (EXTRACT(EPOCH FROM (
               LEAST(p_end, d + INTERVAL '29 hours') - GREATEST(p_start, d + INTERVAL '22 hours')
           )) / 60)::integer)), 0)::integer
      FROM generate_series((p_start::date - 1)::timestamp, p_end::date::timestamp, INTERVAL '1 day') AS d;
$$;
