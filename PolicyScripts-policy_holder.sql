-- BEGIN
--   FOR t IN (SELECT table_name FROM all_tables WHERE owner = 'INSURANCE') LOOP
--     EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER trg_set_user_ids_' || t.table_name ||
--       ' BEFORE INSERT OR UPDATE ON ' || t.table_name || 
--       ' FOR EACH ROW
--        BEGIN
--          IF INSERTING THEN
--            :NEW.created_user_id := SYS_CONTEXT('USERENV', ''SESSION_USER'');
--          END IF;
--          IF UPDATING THEN
--            :NEW.updated_user_id := SYS_CONTEXT('USERENV', ''SESSION_USER'');
--          END IF;
--        END;';
--   END LOOP;
-- END;

CREATE OR REPLACE FUNCTION policy_holder_vpd_function (p_schema VARCHAR2, p_object VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
  IF SYS_CONTEXT('INSURANCE', 'SESSION_USER') = 'SYSTEM' THEN
    RETURN NULL;  -- Don't restrict system user
  ELSIF SYS_CONTEXT('INSURANCE', 'USER_ROLE') = 'POLICY_HOLDER' THEN
    RETURN 'last_name = SYS_CONTEXT(''INSURANCE'', ''SESSION_USER'')';
	ELSE
		RETURN NULL;
  END IF;
END policy_holder_vpd_function;
/


BEGIN
	DBMS_RLS.ADD_POLICY(
    object_schema  => 'INSURANCE',
    object_name    => 'policy_holder',
    policy_name    => 'policy_holder_select_policy',
    function_schema=> 'INSURANCE',
    policy_function=> 'policy_holder_vpd_function',
    statement_types=> 'SELECT, UPDATE'
  );
END;

-- BEGIN
-- 	DBMS_RLS.DROP_POLICY(
--     object_schema  => 'INSURANCE',
--     object_name    => 'policy_holder',
--     policy_name    => 'policy_holder_select_policy'
--   );
-- END;


CREATE OR REPLACE FUNCTION policy_holder_policy_function (p_schema VARCHAR2, p_object VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
  IF SYS_CONTEXT('INSURANCE', 'SESSION_USER') = 'SYSTEM' THEN
    RETURN NULL;  -- Don't restrict system user
  ELSIF SYS_CONTEXT('INSURANCE', 'USER_ROLE') = 'POLICY_HOLDER' THEN
    RETURN 'POLICY_HOLDER_ID = (SELECT POLICY_HOLDER_ID FROM policy_holder WHERE last_name = SYS_CONTEXT(''INSURANCE'', ''SESSION_USER''))';
  ELSE
    RETURN NULL;
  END IF;
END policy_holder_policy_function;
/


BEGIN
	DBMS_RLS.ADD_POLICY(
    object_schema  => 'INSURANCE',
    object_name    => 'auto_policy',
    policy_name    => 'auto_policy_select_policy',
    function_schema=> 'INSURANCE',
    policy_function=> 'policy_holder_policy_function',
    statement_types=> 'SELECT'
  );
END;

-- BEGIN
-- 	DBMS_RLS.DROP_POLICY(
--     object_schema  => 'INSURANCE',
--     object_name    => 'auto_policy',
--     policy_name    => 'auto_policy_select_policy'
--   );
-- END;

CREATE OR REPLACE FUNCTION policy_holder_claim_function (p_schema VARCHAR2, p_object VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
  -- SYSTEM user not restricted
  IF SYS_CONTEXT('INSURANCE', 'SESSION_USER') = 'SYSTEM' THEN
    RETURN NULL;  -- SYSTEM user not restricted
  -- POLICY_HOLDER restriceted to own POLICY_ID
  ELSIF SYS_CONTEXT('INSURANCE', 'USER_ROLE') = 'POLICY_HOLDER' THEN
    RETURN 'POLICY_ID IN (SELECT POLICY_ID 
                          FROM AUTO_POLICY 
                          WHERE POLICY_HOLDER_ID = 
                                (SELECT POLICY_HOLDER_ID 
                                 FROM policy_holder 
                                 WHERE last_name = SYS_CONTEXT(''INSURANCE'', ''SESSION_USER'')))';
  ELSE
    -- Other roles not restricted in this policy
    RETURN NULL;
  END IF;
END policy_holder_claim_function;
/


BEGIN
	DBMS_RLS.ADD_POLICY(
    object_schema  => 'INSURANCE',
    object_name    => 'claim',
    policy_name    => 'claim_select_policy',
    function_schema=> 'INSURANCE',
    policy_function=> 'policy_holder_claim_function',
    statement_types=> 'SELECT'
  );
END;

-- BEGIN
-- 	DBMS_RLS.DROP_POLICY(
--     object_schema  => 'INSURANCE',
--     object_name    => 'claim',
--     policy_name    => 'claim_select_policy'
--   );
-- END;

CREATE OR REPLACE FUNCTION policy_holder_delete_restriction (p_schema VARCHAR2, p_object VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
  IF SYS_CONTEXT('INSURANCE', 'USER_ROLE') = 'POLICY_HOLDER' THEN
    RETURN '1 = 0';
  ELSE
    RETURN NULL;
  END IF;
END policy_holder_delete_restriction;
/

BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema  => 'INSURANCE',
    object_name    => 'policy_holder',
    policy_name    => 'policy_holder_delete_policy',
    function_schema=> 'INSURANCE',
    policy_function=> 'policy_holder_delete_restriction',
    statement_types=> 'DELETE'
  );
END;
/

CREATE OR REPLACE FUNCTION policy_holder_insert_restriction (p_schema VARCHAR2, p_object VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
  IF SYS_CONTEXT('INSURANCE', 'USER_ROLE') = 'POLICY_HOLDER' THEN
    RETURN '1 = 0';
  ELSE
    RETURN NULL;
  END IF;
END policy_holder_insert_restriction;
/


BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema  => 'INSURANCE',
    object_name    => 'policy_holder',
    policy_name    => 'policy_holder_insert_restriction',
    function_schema=> 'INSURANCE',
    policy_function=> 'policy_holder_insert_restriction',
    statement_types=> 'INSERT',
		update_check => true
  );
END;
/

-- BEGIN
--   DBMS_RLS.DROP_POLICY(
--     object_schema  => 'INSURANCE',
--     object_name    => 'policy_holder',
--     policy_name    => 'policy_holder_insert_restriction'
--   );
-- END;
-- /

DROP FUNCTION policy_holder_delete_restriction;
