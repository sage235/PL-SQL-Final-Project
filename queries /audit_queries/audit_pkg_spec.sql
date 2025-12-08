-- _audit_pkg_spec.sql

CREATE OR REPLACE PACKAGE audit_pkg IS
  FUNCTION is_action_restricted(p_when IN DATE) RETURN CHAR;
  PROCEDURE log_audit_autonomous(
    p_username    IN VARCHAR2,
    p_user_role   IN VARCHAR2,
    p_operation   IN VARCHAR2,
    p_object_name IN VARCHAR2,
    p_row_id_text IN VARCHAR2,
    p_allowed_flg IN CHAR,
    p_reason      IN VARCHAR2
  );
END audit_pkg;
/
