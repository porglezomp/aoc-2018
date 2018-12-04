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

CREATE TABLE points (id INTEGER, x INTEGER, y INTEGER);

-- All points
WITH inches(inch) AS (SELECT 1 UNION ALL SELECT inch+1 FROM inches LIMIT 1000)
INSERT INTO points (id, x, y)
SELECT id, x.inch as x, y.inch as y FROM claims
  JOIN inches as x JOIN inches as y
  WHERE x.inch BETWEEN claims.left AND claims.left + claims.width - 1
    AND y.inch BETWEEN claims.top AND claims.top + claims.height - 1;

CREATE INDEX points_by_id ON points (id);
CREATE INDEX points_by_loc ON points (x, y);

-- Count the points covered by more than one entry
SELECT COUNT(*) FROM (SELECT * FROM points GROUP BY x, y HAVING COUNT(id) > 1);

-- Find the id such that all points for that id are not contained in any other claim
SELECT id FROM points AS p
  WHERE NOT EXISTS
    (SELECT * FROM points AS a JOIN points AS b
      WHERE a.id <> p.id AND b.id = p.id
        AND a.x = b.x AND a.y = b.y)
  LIMIT 1;
