-- simple_triggers_example.sql
CREATE OR REPLACE TRIGGER trg_restrict_parts_simple
BEFORE INSERT OR UPDATE OR DELETE ON PARTS
FOR EACH ROW
DECLARE
  v_restricted CHAR(1);
  v_user VARCHAR2(200) := SYS_CONTEXT('USERENV','SESSION_USER');
  v_role VARCHAR2(100);
  v_op VARCHAR2(10) := CASE WHEN INSERTING THEN 'INSERT' WHEN UPDATING THEN 'UPDATE' ELSE 'DELETE' END;
  v_row_text VARCHAR2(4000);
BEGIN
  v_restricted := audit_pkg.is_action_restricted(SYSDATE);
  BEGIN
    SELECT role INTO v_role FROM USERS WHERE UPPER(username) = UPPER(v_user) AND ROWNUM = 1;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    v_role := NULL;
  END;
  v_row_text := 'part_id='||NVL(TO_CHAR(:NEW.part_id), NVL(TO_CHAR(:OLD.part_id),'NULL'));
  IF v_restricted = 'Y' AND NVL(UPPER(v_role),'X') = 'EMPLOYEE' THEN
    audit_pkg.log_audit_autonomous(v_user, v_role, v_op, 'PARTS', v_row_text, 'N', 'DML blocked: weekday/holiday for EMPLOYEE');
    RAISE_APPLICATION_ERROR(-20070,'DML not allowed: employees cannot modify data on weekdays or holidays.');
  ELSE
    audit_pkg.log_audit_autonomous(v_user, v_role, v_op, 'PARTS', v_row_text, 'Y', 'Allowed');
  END IF;
END trg_restrict_parts_simple;
/
