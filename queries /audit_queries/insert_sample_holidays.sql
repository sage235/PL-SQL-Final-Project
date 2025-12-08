insert_sample_holidays.sql
  
INSERT INTO HOLIDAYS(HOLIDAY_DATE, DESCRIPTION)
VALUES (TRUNC(SYSDATE) + 7, 'Sample Holiday +7 Days');

INSERT INTO HOLIDAYS(HOLIDAY_DATE, DESCRIPTION)
VALUES (TRUNC(SYSDATE) + 21, 'Sample Holiday +21 Days');

COMMIT;
PROMPT Inserted sample holidays for testing
