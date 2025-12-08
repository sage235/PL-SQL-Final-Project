-- audit_pkg_body.sql
CREATE OR REPLACE PACKAGE BODY audit_pkg IS

  PROCEDURE log_audit_autonomous(
    p_username    IN VARCHAR2,
    p_user_role   IN VARCHAR2,
    p_operation   IN VARCHAR2,
    p_object_name IN VARCHAR2,
    p_row_id_text IN VARCHAR2,
    p_allowed_flg IN CHAR,
    p_reason      IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO AUDIT_DML_LOG(
      USERNAME, USER_ROLE, OPERATION, OBJECT_NAME, ROW_ID_TEXT, ALLOWED_FLG, REASON
    ) VALUES (
      p_username, p_user_role, p_operation, p_object_name, p_row_id_text, p_allowed_flg, p_reason
    );
    COMMIT;
  EXCEPTION WHEN OTHERS THEN
    NULL; -- keep logger silent (avoid cascading failures)
  END log_audit_autonomous;

  FUNCTION get_user_role(p_db_username IN VARCHAR2) RETURN VARCHAR2 IS
    v_role VARCHAR2(100);
  BEGIN
    SELECT role INTO v_role
      FROM USERS
     WHERE UPPER(username) = UPPER(p_db_username)
       AND ROWNUM = 1;
    RETURN v_role;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END get_user_role;

  FUNCTION is_action_restricted(p_when IN DATE) RETURN CHAR IS
    v_user VARCHAR2(200) := SYS_CONTEXT('USERENV','SESSION_USER');
    v_role VARCHAR2(100);
    v_day_index NUMBER;
    v_is_holiday NUMBER;
  BEGIN
    v_role := get_user_role(v_user);

    IF v_role IS NULL OR UPPER(v_role) != 'EMPLOYEE' THEN
      RETURN 'N';
    END IF;

    -- ISO weekday index: TRUNC(p_when) - TRUNC(p_when, 'IW')
    v_day_index := TRUNC(p_when) - TRUNC(p_when, 'IW');

    -- Monday..Friday => 0..4 -> restricted
    IF v_day_index BETWEEN 0 AND 4 THEN
      RETURN 'Y';
    END IF;

    BEGIN
      SELECT 1 INTO v_is_holiday
        FROM HOLIDAYS h
       WHERE h.HOLIDAY_DATE = TRUNC(p_when)
         AND h.HOLIDAY_DATE BETWEEN TRUNC(SYSDATE) AND TRUNC(ADD_MONTHS(SYSDATE,1))
         AND ROWNUM = 1;
      RETURN 'Y';
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN 'N';
    END;
  EXCEPTION WHEN OTHERS THEN
    RETURN 'N'; -- fail open to avoid accidental full lockout
  END is_action_restricted;

END audit_pkg;
/
