CREATE TABLE strings (s TEXT);

.mode line
.import input/day3 strings
.mode list

CREATE TABLE claims (id INTEGER, left INTEGER, top INTEGER, width INTEGER, height INTEGER);

-- Parse records of the form #ID @ LEFT,TOP: WIDTHxHEIGHT
INSERT INTO claims (id, left, top, width, height)
SELECT CAST(SUBSTR(s, INSTR(s, '#') + 1, INSTR(s, '@') - INSTR(s, '#') - 2) AS INTEGER) as id,
       CAST(SUBSTR(s, INSTR(s, '@') + 2, INSTR(s, ',') - INSTR(s, '@') - 2) AS INTEGER) as left,
       CAST(SUBSTR(s, INSTR(s, ',') + 1, INSTR(s, ':') - INSTR(s, ',') - 1) AS INTEGER) as top,
       CAST(SUBSTR(s, INSTR(s, ':') + 2, INSTR(s, 'x') - INSTR(s, ':') - 2) AS INTEGER) as width,
       CAST(SUBSTR(s, INSTR(s, 'x') + 1) AS INTEGER) as height
FROM strings;

-- Generate a range from 0-1000
CREATE TABLE inches (inch INTEGER);
WITH range(inch) AS (SELECT 1 UNION ALL SELECT inch+1 FROM range LIMIT 1000)
INSERT INTO inches (inch) SELECT inch FROM range;

CREATE INDEX inch_index ON inches (inch);

-- Count the points covered by more than one claim
SELECT COUNT(*) FROM (
SELECT id, x.inch as x, y.inch as y FROM claims
  JOIN inches as x JOIN inches as y
  WHERE x.inch BETWEEN claims.left AND claims.left + claims.width - 1
    AND y.inch BETWEEN claims.top AND claims.top + claims.height - 1
  GROUP BY x, y HAVING COUNT(id) > 1
);

-- Find a claim such that there is no other claim that overlaps it
SELECT id FROM claims AS a
  WHERE NOT EXISTS
    (SELECT * FROM claims AS b
      WHERE a.id <> b.id
        AND NOT (  a.left > b.left + b.width OR a.left + a.width < b.left
                 OR a.top > b.top + b.height OR a.top + a.height < b.top));
