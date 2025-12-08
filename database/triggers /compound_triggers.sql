-- compound_triggers.sql
-- MAINTENANCE_RECORDS compound trigger
CREATE OR REPLACE TRIGGER trg_restrict_dml_maintenance
FOR INSERT OR UPDATE OR DELETE ON MAINTENANCE_RECORDS
COMPOUND TRIGGER
  g_restricted CHAR(1);

  BEFORE STATEMENT IS
  BEGIN
    g_restricted := audit_pkg.is_action_restricted(SYSDATE);
  EXCEPTION WHEN OTHERS THEN
    g_restricted := 'N';
  END BEFORE STATEMENT;

  BEFORE EACH ROW IS
    v_user VARCHAR2(200) := SYS_CONTEXT('USERENV','SESSION_USER');
    v_role VARCHAR2(100);
    v_op   VARCHAR2(10) := CASE WHEN INSERTING THEN 'INSERT' WHEN UPDATING THEN 'UPDATE' ELSE 'DELETE' END;
    v_row_text VARCHAR2(4000);
  BEGIN
    BEGIN
      SELECT role INTO v_role FROM USERS WHERE UPPER(username) = UPPER(v_user) AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      v_role := NULL;
    END;

    v_row_text := 'maintenance_id=' || NVL(TO_CHAR(:NEW.maintenance_id), NVL(TO_CHAR(:OLD.maintenance_id), 'NULL'));

    IF g_restricted = 'Y' AND NVL(UPPER(v_role), 'X') = 'EMPLOYEE' THEN
      audit_pkg.log_audit_autonomous(v_user, v_role, v_op, 'MAINTENANCE_RECORDS', v_row_text, 'N', 'DML blocked: weekday/holiday for EMPLOYEE');
      RAISE_APPLICATION_ERROR(-20070, 'DML not allowed: employees cannot modify data on weekdays or holidays.');
    ELSE
      audit_pkg.log_audit_autonomous(v_user, v_role, v_op, 'MAINTENANCE_RECORDS', v_row_text, 'Y', 'Allowed');
    END IF;
  END BEFORE EACH ROW;

END trg_restrict_dml_maintenance;
/

-- PARTS compound trigger (same pattern)
CREATE OR REPLACE TRIGGER trg_restrict_dml_parts
FOR INSERT OR UPDATE OR DELETE ON PARTS
COMPOUND TRIGGER
  g_restricted CHAR(1);

  BEFORE STATEMENT IS
  BEGIN g_restricted := audit_pkg.is_action_restricted(SYSDATE); END BEFORE STATEMENT;

  BEFORE EACH ROW IS
    v_user VARCHAR2(200) := SYS_CONTEXT('USERENV','SESSION_USER');
    v_role VARCHAR2(100);
    v_op   VARCHAR2(10) := CASE WHEN INSERTING THEN 'INSERT' WHEN UPDATING THEN 'UPDATE' ELSE 'DELETE' END;
    v_row_text VARCHAR2(4000);
  BEGIN
    BEGIN SELECT role INTO v_role FROM USERS WHERE UPPER(username) = UPPER(v_user) AND ROWNUM = 1; EXCEPTION WHEN NO_DATA_FOUND THEN v_role := NULL; END;
    v_row_text := 'part_id='||NVL(TO_CHAR(:NEW.part_id),NVL(TO_CHAR(:OLD.part_id),'NULL'));
    IF g_restricted='Y' AND NVL(UPPER(v_role),'X')='EMPLOYEE' THEN
      audit_pkg.log_audit_autonomous(v_user, v_role, v_op, 'PARTS', v_row_text, 'N', 'DML blocked: weekday/holiday for EMPLOYEE');
      RAISE_APPLICATION_ERROR(-20070,'DML not allowed: employees cannot modify data on weekdays or holidays.');
    ELSE
      audit_pkg.log_audit_autonomous(v_user, v_role, v_op, 'PARTS', v_row_text, 'Y', 'Allowed');
    END IF;
  END BEFORE EACH ROW;

END trg_restrict_dml_parts;
/

-- TRIPS compound trigger (same pattern)
CREATE OR REPLACE TRIGGER trg_restrict_dml_trips
FOR INSERT OR UPDATE OR DELETE ON TRIPS
COMPOUND TRIGGER
  g_restricted CHAR(1);
  BEFORE STATEMENT IS
  BEGIN g_restricted := audit_pkg.is_action_restricted(SYSDATE); END BEFORE STATEMENT;
  BEFORE EACH ROW IS
    v_user VARCHAR2(200) := SYS_CONTEXT('USERENV','SESSION_USER');
    v_role VARCHAR2(100);
    v_op   VARCHAR2(10) := CASE WHEN INSERTING THEN 'INSERT' WHEN UPDATING THEN 'UPDATE' ELSE 'DELETE' END;
    v_row_text VARCHAR2(4000);
  BEGIN
    BEGIN SELECT role INTO v_role FROM USERS WHERE UPPER(username) = UPPER(v_user) AND ROWNUM=1; EXCEPTION WHEN NO_DATA_FOUND THEN v_role:=NULL; END;
    v_row_text := 'trip_id='||NVL(TO_CHAR(:NEW.trip_id),NVL(TO_CHAR(:OLD.trip_id),'NULL'));
    IF g_restricted='Y' AND NVL(UPPER(v_role),'X')='EMPLOYEE' THEN
      audit_pkg.log_audit_autonomous(v_user, v_role, v_op, 'TRIPS', v_row_text, 'N', 'DML blocked: weekday/holiday for EMPLOYEE');
      RAISE_APPLICATION_ERROR(-20070,'DML not allowed: employees cannot modify data on weekdays or holidays.');
    ELSE
      audit_pkg.log_audit_autonomous(v_user, v_role, v_op, 'TRIPS', v_row_text, 'Y', 'Allowed');
    END IF;
  END BEFORE EACH ROW;
END trg_restrict_dml_trips;
/
