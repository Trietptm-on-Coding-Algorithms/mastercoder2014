WITH t1 AS
  (SELECT DateFrom,
          row_number() over(
                            ORDER BY id) rn
   FROM SickLeave
   WHERE DateFrom NOT IN
       (SELECT DATEADD(d, 1,DateTo)
        FROM SickLeave
        WHERE DATENAME(dw,DateTo) != 'Friday'
        UNION SELECT DATEADD(d, 3,DateTo)
        FROM SickLeave
        WHERE DATENAME(dw,DateTo) = 'Friday')),
     t2 AS
  (SELECT DateTo,
          row_number() over (
                             ORDER BY id) rn
   FROM SickLeave
   WHERE DateTo IN
       (SELECT DateTo
        FROM SickLeave
        WHERE DATENAME(dw,DateTo) != 'Friday'
          AND DATEADD(d, 1,DateTo) NOT IN
            (SELECT DateFrom
             FROM SickLeave)
        UNION SELECT DateTo
        FROM SickLeave
        WHERE DATENAME(dw,DateTo) = 'Friday'
          AND DATEADD(d, 3,DateTo) NOT IN
            (SELECT DateFrom
             FROM SickLeave)))
SELECT t1.DateFrom,
       t2.DateTo,
       DATEDIFF(d,t1.DateFrom,t2.DateTo) + 1 AS 'DAYS',
       CASE
           WHEN ((DATEPART(dw,t2.DateTo)) - (DATEPART(dw,t1.DateFrom)) < 0
                 AND (DATEDIFF(d,t1.DateFrom,t2.DateTo) + 1)%7 > 0)
           THEN (DATEDIFF(d,t1.DateFrom,t2.DateTo) + 1)/7 * 5 + (DATEDIFF(d,t1.DateFrom,t2.DateTo) + 1)%7 - 2
           ELSE (DATEDIFF(d,t1.DateFrom,t2.DateTo) + 1)/7 * 5 + (DATEDIFF(d,t1.DateFrom,t2.DateTo) + 1)%7
       END AS 'WorkingDays'
FROM t1
INNER JOIN t2 ON t1.rn = t2.rn
ORDER BY t1.DateFrom;

