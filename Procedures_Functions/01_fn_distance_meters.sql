-- Creates the haversine distance in meters between two coordinates.
CREATE OR REPLACE FUNCTION fn_distance_meters(
    p_latitude_1 numeric,
    p_longitude_1 numeric,
    p_latitude_2 numeric,
    p_longitude_2 numeric
)
RETURNS numeric
LANGUAGE sql
IMMUTABLE
AS $$
    SELECT ROUND((
        6371000 * 2 * asin(least(1.0, sqrt(
            power(sin(radians((p_latitude_2 - p_latitude_1)::float8 / 2)), 2)
            + cos(radians(p_latitude_1::float8)) * cos(radians(p_latitude_2::float8))
                * power(sin(radians((p_longitude_2 - p_longitude_1)::float8 / 2)), 2)
        )))
    )::numeric, 2);
$$;
