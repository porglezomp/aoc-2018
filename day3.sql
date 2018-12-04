CREATE TABLE strings(str TEXT);

.mode line
.import input/day3 strings
.mode list

CREATE TABLE claims (id INTEGER, left INTEGER, top INTEGER, width INTEGER, height INTEGER);

INSERT INTO claims (id, left, top, width, height)
SELECT CAST(SUBSTR(str, INSTR(str, '#') + 1, INSTR(str, '@') - INSTR(str, '#') - 2) AS INTEGER) as id,
       CAST(SUBSTR(str, INSTR(str, '@') + 2, INSTR(str, ',') - INSTR(str, '@') - 2) AS INTEGER) as left,
       CAST(SUBSTR(str, INSTR(str, ',') + 1, INSTR(str, ':') - INSTR(str, ',') - 1) AS INTEGER) as top,
       CAST(SUBSTR(str, INSTR(str, ':') + 2, INSTR(str, 'x') - INSTR(str, ':') - 2) AS INTEGER) as width,
       CAST(SUBSTR(str, INSTR(str, 'x') + 1) AS INTEGER) as height
FROM strings;

SELECT COUNT(*) FROM (
WITH inches(inch) AS (SELECT 1 UNION ALL SELECT inch+1 FROM inches LIMIT 1000)
SELECT * FROM claims
  JOIN inches as x JOIN inches as y
  WHERE x.inch BETWEEN claims.left AND claims.left + claims.width - 1
    AND y.inch BETWEEN claims.top AND claims.top + claims.height - 1
  GROUP BY x.inch, y.inch
  HAVING COUNT(id) > 1
);
