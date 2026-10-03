-- Find the FIPS code for York County from the table, then calculate the county's annual growth rate of median household income by comparing the median income in the current year with the previous year. If there is one year missing, say null, report the county name as "name", current year as "year", income in current year as "current_value", income in the previous year as "previous_value", and growth rate as "growth_rate"
WITH
  "york_fips" AS (
  SELECT
    "n"."fips",
    "n"."name"
  FROM
    "name" AS "n"
  WHERE
    "n"."name" = 'York County'
  GROUP BY
    "n"."fips",
    "n"."name"),
  "york_income" AS (
  SELECT
    "y"."name",
    "i"."year",
    "i"."income"
  FROM
    "income" AS "i"
  JOIN
    "york_fips" AS "y"
  ON
    "i"."fips" = "y"."fips"
  WHERE
    "i"."income" IS NOT NULL),
  "lagged_income" AS (
  SELECT
    "yi"."name",
    "yi"."year",
    "yi"."income" AS "current_value",
    LAG("yi"."income", 1) OVER (ORDER BY "yi"."year" ASC NULLS LAST ) AS "previous_value",
    LAG("yi"."year", 1) OVER (ORDER BY "yi"."year" ASC NULLS LAST ) AS "prev_year"
  FROM
    "york_income" AS "yi")
SELECT
  "li"."name",
  "li"."year",
  "li"."current_value",
  CASE
    WHEN "li"."prev_year" = "li"."year" - 1 THEN "li"."previous_value"
    ELSE NULL
END
  AS "previous_value",
  CASE
    WHEN "li"."prev_year" = "li"."year" - 1 AND "li"."previous_value" IS NOT NULL AND "li"."previous_value" <> 0 THEN (CAST("li"."current_value" AS DOUBLE PRECISION) - CAST("li"."previous_value" AS DOUBLE PRECISION)) / CAST("li"."previous_value" AS DOUBLE PRECISION)
    ELSE NULL
END
  AS "growth_rate"
FROM
  "lagged_income" AS "li"
ORDER BY
  "li"."year" ASC
NULLS LAST
  ;

-- Find the FIPS code for York County from the table, then calculate the county's annual growth rate of population by comparing the population in the current year with the previous year. If there is one year missing, say null, report the county name as "name", current year as "year", income in current year as "current_value", income in the previous year as "previous_value", and growth rate as "growth_rate"
SELECT
  "t1"."fips" AS "fips",
  "t1"."year" AS "year",
  "t2"."income" AS "previous_value",
  "t1"."income" AS "current_value",
  CASE
    WHEN "t2"."income" IS NULL THEN NULL
    WHEN "t2"."income" = 0 THEN NULL
    ELSE (("t1"."income" - "t2"."income")::double precision / "t2"."income"::double precision)
END
  AS "growth_rate"
FROM
  "income" AS "t1"
INNER JOIN
  "name" AS "n"
ON
  "t1"."fips" = "n"."fips"
LEFT JOIN
  "income" AS "t2"
ON
  "t1"."fips" = "t2"."fips"
  AND "t1"."year" = "t2"."year" + 1
WHERE
  "n"."name" = 'York County'
ORDER BY
  "year" ASC
NULLS LAST

-- Find the FIPS code for York County from the table, then calculate the county's median income per person by comparing the median income value with the population value for each year that data is available. If there is one year missing, say null, report the county FIPS, the current year, population in the current year as "current_population", median income in the current year as "current_income", and the income per person
SELECT
  "t_inc"."fips" AS "fips",
  "t_inc"."year" AS "year",
  "t_pop"."population" AS "current_population",
  "t_inc"."income" AS "current_income",
  CAST("t_inc"."income" AS DOUBLE PRECISION) / CAST("t_pop"."population" AS DOUBLE PRECISION) AS "income_per_person"
FROM
  "name" AS "n"
INNER JOIN
  "income" AS "t_inc"
ON
  "n"."fips" = "t_inc"."fips"
INNER JOIN
  "population" AS "t_pop"
ON
  "t_inc"."fips" = "t_pop"."fips"
  AND "t_inc"."year" = "t_pop"."year"
WHERE
  "n"."name" = 'York County'
  AND "t_inc"."fips" IS NOT NULL
  AND "t_inc"."year" IS NOT NULL
  AND "t_pop"."population" IS NOT NULL
  AND "t_inc"."income" IS NOT NULL
ORDER BY
  "t_inc"."year" ASC
NULLS LAST
