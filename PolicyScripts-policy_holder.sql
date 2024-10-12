BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema  => 'INSURANCE',
    object_name    => 'policy_holder',
    policy_name    => 'policy_holder_select_policy',
    function_schema=> 'INSURANCE',
    policy_function=> 'policy_holder_vpd_function',
    statement_types=> 'SELECT, INSERT, UPDATE'
  );

  DBMS_RLS.ADD_POLICY(
    object_schema  => 'INSURANCE',
    object_name    => 'auto_policy',
    policy_name    => 'auto_policy_select_policy',
    function_schema=> 'INSURANCE',
    policy_function=> 'policy_holder_vpd_function',
    statement_types=> 'SELECT'
  );

  DBMS_RLS.ADD_POLICY(
    object_schema  => 'INSURANCE',
    object_name    => 'claim',
    policy_name    => 'claim_select_policy',
    function_schema=> 'INSURANCE',
    policy_function=> 'policy_holder_vpd_function',
    statement_types=> 'SELECT, INSERT, UPDATE'
  );
END;

CREATE OR REPLACE TRIGGER trg_set_user_ids
BEFORE INSERT OR UPDATE ON policy_holder
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    :NEW.created_user_id := SYS_CONTEXT('USERENV', 'SESSION_USER');
  END IF;
  IF UPDATING THEN
    :NEW.updated_user_id := SYS_CONTEXT('USERENV', 'SESSION_USER');
  END IF;
END;
