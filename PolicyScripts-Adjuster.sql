-- Create User
CREATE USER NEW_USERNAME IDENTIFIED BY user_password;
ALTER USER NEW_USERNAME QUOTA UNLIMITED ON USERS;
GRANT CONNECT, RESOURCE, CREATE SESSION TO NEW_USERNAME;

-- GRANT CREATE ANY CONTEXT, CREATE PROCEDURE, CREATE TRIGGER, ADMINISTER DATABASE TRIGGER TO NEW_USERNAME;
-- GRANT EXECUTE ON DBMS_SESSION TO NEW_USERNAME;
-- GRANT EXECUTE ON DBMS_RLS TO NEW_USERNAME;

-- Create Role
CREATE ROLE ADJUSTER;
GRANT ADJUSTER TO NEW_USERNAME;

-- Grant access to the table
GRANT SELECT, INSERT, UPDATE ON insurance.claim TO ADJUSTER;
GRANT SELECT, INSERT, UPDATE ON insurance.status TO ADJUSTER;
GRANT SELECT ON insurance.auditor_cd TO ADJUSTER;
GRANT SELECT ON insurance.policy_investigator_cd TO ADJUSTER;
GRANT SELECT ON insurance.vendor_cd TO ADJUSTER;
GRANT SELECT ON insurance.payment TO ADJUSTER;

CREATE OR REPLACE FUNCTION insurance.get_adjuster_id RETURN NUMBER AS
    adjuster_id_from_table NUMBER;
BEGIN
    SELECT
        adjuster_id INTO adjuster_id_from_table
    FROM
        insurance.adjuster_cd
    WHERE
        adjuster_name = sys_context('USERENV', 'SESSION_USER');
    RETURN adjuster_id_from_table;
EXCEPTION
    WHEN no_data_found THEN
        RETURN 0;
END get_adjuster_id;

CREATE OR REPLACE FUNCTION insurance.has_adjuster_role RETURN NUMBER AS
    role_count NUMBER;
BEGIN
    SELECT
        count(*) INTO role_count
    FROM
        USER_ROLE_PRIVS
    WHERE
        GRANTED_ROLE = 'ADJUSTER';
    
    RETURN role_count;
EXCEPTION
    WHEN no_data_found THEN
        RETURN 0;
END has_adjuster_role;

GRANT EXECUTE ON insurance.get_adjuster_id TO test_role;
GRANT EXECUTE ON insurance.has_adjuster_role TO test_role;




-- Create policy
CREATE OR REPLACE FUNCTION insurance.adjuster_on_claim_and_status (
    schema_name IN VARCHAR2,
    table_name IN VARCHAR2
) RETURN VARCHAR2 AS
    condition VARCHAR2(100);
BEGIN
    IF insurance.has_adjuster_role = 1 THEN
        condition := 'ADJUSTER_ID = ''' || insurance.get_adjuster_id || '''';
    END IF;

    RETURN condition;
END adjuster_on_claim_and_status;

CREATE OR REPLACE FUNCTION insurance.adjuster_select_on_cd ( schema_name IN VARCHAR2, table_name IN VARCHAR2 ) RETURN VARCHAR2 AS
    condition VARCHAR2(100);
BEGIN
    IF insurance.has_adjuster_role = 1 THEN
        condition := '1=0';
    END IF;

    RETURN condition;
END adjuster_select_on_cd;

BEGIN
    dbms_rls.add_policy(
        object_schema => 'INSURANCE',
        object_name => 'claim',
        policy_name => 'policy_adjuster_on_claim',
        function_schema => 'INSURANCE',
        policy_function => 'adjuster_on_claim_and_status',
        statement_types => 'SELECT, UPDATE'
    );
    dbms_rls.add_policy(
        object_schema => 'INSURANCE',
        object_name => 'status',
        policy_name => 'policy_adjuster_on_status',
        function_schema => 'INSURANCE',
        policy_function => 'adjuster_on_claim_and_status',
        statement_types => 'SELECT, UPDATE'
    );
    dbms_rls.add_policy (
        object_schema => 'INSURANCE',
        object_name => 'auditor_cd',
        policy_name => 'policy_adjuster_on_auditor_cd',
        function_schema => 'INSURANCE',
        policy_function => 'adjuster_select_on_cd',
        statement_types => 'SELECT',
        sec_relevant_cols => 'auditor_name,auditor_email,auditor_number'
    );
    dbms_rls.add_policy (
        object_schema => 'INSURANCE',
        object_name => 'policy_investigator_cd',
        policy_name => 'policy_adjuster_on_policy_investigator_cd',
        function_schema => 'INSURANCE',
        policy_function => 'adjuster_select_on_cd',
        statement_types => 'SELECT',
        sec_relevant_cols => 'investigator_first_name,investigator_last_name,investigator_email,investigator_phone,assigned_region,investigator_role,investigator_status'
    );
    dbms_rls.add_policy (
        object_schema => 'INSURANCE',
        object_name => 'vendor_cd',
        policy_name => 'policy_adjuster_on_vendor_cd',
        function_schema => 'INSURANCE',
        policy_function => 'adjuster_select_on_cd',
        statement_types => 'SELECT',
        sec_relevant_cols => 'vendor_name_code,vendor_full_name,vendor_email,vendor_phone,vendor_city,vendor_state,vendor_country,vendor_rating,service_rate'
    );
    dbms_rls.add_policy (
        object_schema => 'INSURANCE',
        object_name => 'payment',
        policy_name => 'policy_adjuster_on_payment',
        function_schema => 'INSURANCE',
        policy_function => 'adjuster_select_on_cd',
        statement_types => 'SELECT',
        sec_relevant_cols => 'payment_id,claim_contact_id,payment_date,payment_type_code,payment_method,previous_claim_id,payment_reference_number,bank_account_number,payment_note,payment_currency,tax_amount,foreign_trans_fee'
    );
END;



