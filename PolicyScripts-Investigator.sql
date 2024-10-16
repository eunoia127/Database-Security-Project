BEGIN
  my_context_pkg.set_context('INSURANCE', 'USER_ROLE', 'POLICY_INVESTIGATOR');
END;
/

BEGIN 
my_context_pkg.SET_CONTEXT('INSURANCE', 'SESSION_USER', '1');
END;
/

CREATE OR REPLACE FUNCTION policy_investigator_vpd (
    schema_name IN VARCHAR2, 
    table_name IN VARCHAR2
) RETURN VARCHAR2 AS
    v_predicate VARCHAR2(4000);
BEGIN
    -- Check if the user's role is 'POLICY_INVESTIGATOR'
    IF SYS_CONTEXT('INSURANCE', 'USER_ROLE') = 'POLICY_INVESTIGATOR' THEN
        -- If the role is POLICY_INVESTIGATOR, apply investigator_id restriction
				-- Convert SYS_CONTEXT from VARCHAR TO NUMBER
        v_predicate := 'investigator_id = TO_NUMBER(SYS_CONTEXT(''INSURANCE'', ''SESSION_USER''))';
    ELSE
        -- If the user is not a POLICY_INVESTIGATOR, do not apply any restriction
        v_predicate := NULL;
    END IF;

    RETURN v_predicate;
END policy_investigator_vpd;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'INSURANCE',  -- Your schema
        object_name     => 'CLAIM',      -- Table where VPD is applied
        policy_name     => 'policy_investigator_policy',
        function_schema => 'INSURANCE',   -- Schema where VPD function is located
        policy_function => 'policy_investigator_vpd',
        statement_types => 'SELECT', -- Apply to all DML actions
        update_check    => TRUE  -- Enforce VPD on updates
    );
END;
/

-- BEGIN
--     DBMS_RLS.DROP_POLICY(
--         object_schema   => 'INSURANCE',  -- Your schema
--         object_name     => 'CLAIM',      -- Table where VPD is applied
--         policy_name     => 'investigator_policy'
--     );
-- END;

/

-- 2.coverage:

CREATE OR REPLACE FUNCTION policy_coverage_vpd (
    schema_name IN VARCHAR2, 
    table_name IN VARCHAR2
) 
RETURN VARCHAR2 AS
    v_predicate VARCHAR2(4000);
BEGIN
    -- Check if the user's role is 'POLICY_INVESTIGATOR'
    IF SYS_CONTEXT('INSURANCE', 'USER_ROLE') = 'POLICY_INVESTIGATOR' THEN
        -- Restrict data based on investigator's assigned claim and active status
        v_predicate := 'policy_status = ''Active'' 
                        AND policy_id IN (SELECT POLICY_ID 
                                          FROM CLAIM 
                                          WHERE investigator_id = TO_NUMBER(SYS_CONTEXT(''INSURANCE'', ''SESSION_USER'')))';
    ELSE
        -- If the user is not a POLICY_INVESTIGATOR, do not apply any restriction
        v_predicate := NULL;
    END IF;

    -- Return the generated predicate
    RETURN v_predicate;
END policy_coverage_vpd;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'INSURANCE',  -- Your schema
        object_name     => 'AUTO_POLICY',  -- Table where VPD is applied
        policy_name     => 'policy_coverage_policy',
        function_schema => 'INSURANCE',
        policy_function => 'policy_coverage_vpd',
        statement_types => 'SELECT'
    );
END;
/

3.legal status
CREATE OR REPLACE FUNCTION claim_legal_status_vpd (
    schema_name IN VARCHAR2, 
    table_name IN VARCHAR2
) RETURN VARCHAR2 AS
    v_predicate VARCHAR2(4000);
BEGIN
    -- Restrict access based on legal status
    v_predicate := 'legal_status = ''None'' OR legal_status = ''Ongoing'' OR legal_status = ''resolved''';
    RETURN v_predicate;
END claim_legal_status_vpd;
/

BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'INSURANCE',  -- Your schema
        object_name     => 'CLAIM',  -- Table where VPD is applied
        policy_name     => 'legal_status_policy',
        function_schema => 'INSURANCE',
        policy_function => 'claim_legal_status_vpd',
        statement_types => 'SELECT'
    );
END;
/
