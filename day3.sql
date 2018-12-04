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
