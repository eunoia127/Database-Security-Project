--DYNAMIC DATA TABLES and SCHEMAS:
--Available tables:
-- 1. policy_holder
-- 2. auto_policy
-- 3. claims
-- 4. payments
-- 5. injury
-- 6. vendor

-- have not added adjuster code, ids if needed in claims table, but feel free to do so, as that helps filter claims related to that 
-- adjuster only
--
-- a group of adjusters can come under one manager/ all adjusters can come under one manager; 
-- can introduce static data tables for holding manager and adjuster id/code values.
-- 
-- same goes for policy investigator and auditor. please feel to add columns/tables if needed. Or else we can just use
-- the existing db to create policies to only show the particular role - particular data

--SCHEMAS:

CREATE TABLE policy_holder (
    policy_holder_id                INT PRIMARY KEY AUTO_INCREMENT,     
    first_name                      VARCHAR(100) NOT NULL,              
    last_name                       VARCHAR(100) NOT NULL,              
    date_of_birth                   DATE NOT NULL,                      
    gender                          ENUM('Male', 'Female', 'Other', 'Not specified') DEFAULT 'Not specified',  
    email                           VARCHAR(150) NOT NULL UNIQUE,       
    phone_number                    VARCHAR(20) NOT NULL, 
    nric_or_fin                     VARCHAR(9) NOT NULL,              
    address_line_1                  VARCHAR(255) NOT NULL,              
    address_line_2                  VARCHAR(255),                       
    city                            VARCHAR(100) NOT NULL,              
    state_of_residence              VARCHAR(100),                       
    postal_code                     VARCHAR(20),                        
    country                         VARCHAR(100) NOT NULL,              
    policy_holder_type              ENUM('Person', 'Business') DEFAULT 'Person',
    preferred_contact_method        ENUM('Phone', 'Email') DEFAULT 'Email', 
    rep_first_name                  VARCHAR(100) NOT NULL,         -- Representative of the policy holder details          
    rep_last_name                   VARCHAR(100) NOT NULL,              
    rep_date_of_birth               DATE NOT NULL,                      
    rep_gender                      ENUM('Male', 'Female', 'Other', 'Not specified') DEFAULT 'Not specified',  
    rep_email                       VARCHAR(150) NOT NULL UNIQUE,       
    rep_phone_number                VARCHAR(20) NOT NULL, 
    rep_nric_or_fin                 VARCHAR(9) NOT NULL,              
    rep_address_line_1              VARCHAR(255) NOT NULL,              
    rep_address_line_2              VARCHAR(255),                       
    rep_city                        VARCHAR(100) NOT NULL,              
    rep_state_of_residence          VARCHAR(100),                       
    rep_postal_code                 VARCHAR(20),                        
    rep_country                     VARCHAR(100) NOT NULL,              
    rep_policy_holder_type          ENUM('Person', 'Business') DEFAULT 'Person',
    rep_preferred_contact_method    ENUM('Phone', 'Email') DEFAULT 'Email',         
    total_claim_count               INT DEFAULT 0,                         -- Number of claims associated with the policy_holder/History of claim count
    created_user_id                 VARCHAR(100),                   
    created_timestamp               TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_user_id	            VARCHAR(100),
    updated_timestamp	            TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE auto_policy (
	policy_id                INT PRIMARY KEY AUTO_INCREMENT,               
	policy_holder_id         INT NOT NULL,                   -- FK to policy_holder table
	policy_number            VARCHAR(50) UNIQUE NOT NULL,    
	coverage_code            VARCHAR(20) NOT NULL,           -- Code for specific coverages(FK to coverage_cd table)
	total_coverage_limit     DECIMAL(10, 2) NOT NULL,        -- Policy coverage limit
	amount_deductible        DECIMAL(10, 2) NOT NULL,        -- deductible amount left for the policy
	total_premium_amount     DECIMAL(10, 2) NOT NULL,        -- total policy premium amount    
	policy_start_date        DATE NOT NULL,                  -- Policy start date
	policy_expiry_date       DATE NOT NULL,                  -- Policy expiration date
	policy_expired_flag      BOOLEAN DEFAULT FALSE,          -- Policy expiry indicator
	policy_status      	 ENUM('Active', 'Expired', 'Cancelled') DEFAULT 'Active',
	policy_renewal_date      DATE,                           -- Policy renewal date
	payment_type        	 VARCHAR(20),                    -- Monthly/quarterly/annually
	payment_method           VARCHAR(20),                    -- Payment method for policy payment(credit/debit card etc.)
	cancellation_reason      VARCHAR(255),                   -- Reason for policy cancellation (if the status is cancelled, otherwise null)
	created_user_id          VARCHAR(100),                   
	created_timestamp        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	updated_user_id		 VARCHAR(100),
	updated_timestamp	 TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (policy_holder_id) REFERENCES policy_holder(policy_holder_id),            -- FK to policy_holder table
	FOREIGN KEY (coverage_code)    REFERENCES coverage_cd(coverage_code)                  -- FK to coverage_cd table
    );

CREATE TABLE claims (
    claim_id                 INT PRIMARY KEY AUTO_INCREMENT,          
    claim_contact_id         INT NOT NULL,                            -- FK to policy_handler table
    policy_id                INT NOT NULL,                            -- FK to the policy table
    claim_number             VARCHAR(50) UNIQUE NOT NULL,             -- Claim reference number
    claim_date               DATE NOT NULL,                           -- Date claim was filed
    actual_loss_date         DATE NOT NULL,                           -- Date of the actual incident
    claim_type               ENUM('Auto', 'Homeowners', 'Not Specified') DEFAULT 'Not Specified',
    claim_status             ENUM('Open', 'Closed', 'Rejected', 'Pending', 'Validating') DEFAULT 'Pending', 
    claim_description        TEXT,                                    
    claim_reported_channel   ENUM('Phone', 'Online', 'In Person') DEFAULT 'Online', 
    coverage_code            VARCHAR(20) NOT NULL,                    -- Code for specific coverages(FK to coverage_cd table)
    sub_coverage_code        VARCHAR(20) NOT NULL,                    -- Code for specific sub coverages(FK to coverage_cd table)
    self_fault_indicator     BOOLEAN DEFAULT FALSE,                   -- Indicates if the policyholder is at fault
    claim_contact_alive_flag BOOLEAN DEFAULT TRUE,
    legal_status             ENUM('None', 'Ongoing', 'Resolved') DEFAULT 'None', -- Any legal disputes related to the claim
    claim_amount             DECIMAL(15, 2) NOT NULL,                 -- Claim amount required to settle the claim
    claim_reserve_amount     DECIMAL(15, 2),                          -- Reserved amount for the claim
    payment_amount           DECIMAL(15, 2),                          -- Actual payout amount for the claim
    payment_date             DATE,                                    -- Date the payment/claim was settled
    claim_validation_notes   TEXT,                                    -- Additional notes for claim validation and processing
    created_user_id          VARCHAR(100),                   
    created_timestamp        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_user_id	     VARCHAR(100),
    updated_timestamp	     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (policy_id) REFERENCES auto_policy(policy_id),                        -- FK to auto_policy table
    FOREIGN KEY (claim_contact_id) REFERENCES policy_holder(policy_holder_id),        -- FK to policy_holder table
    FOREIGN KEY (coverage_code, sub_coverage_code)    
                            REFERENCES coverage_cd(coverage_code, sub_coverage_code)  -- FK to coverage_cd table
);

CREATE TABLE payments (
    payment_id               INT PRIMARY KEY AUTO_INCREMENT,               
    claim_id                 INT NOT NULL,                                  -- FK to claims table
    claim_contact_id         INT NOT NULL,                                  -- FK to policy_handler table
    payment_date             DATE NOT NULL,                                 -- Date when payment was made
    payment_amount           DECIMAL(15, 2) NOT NULL,                       -- Total payment amount
    payment_type_code        VARCHAR(20) NOT NULL,                          -- Code for payment types(FK to payment_type_cd table)
    payment_method           ENUM('Bank Transfer', 'Check', 'Credit Card', 'Cash') DEFAULT 'Bank Transfer', 
    payment_status           ENUM('Paid', 'Pending', 'Rejected', 'Failed') DEFAULT 'Pending', 
    previous_claim_id        INT DEFAULT NULL,                              -- Related previous claim (if applicable - FK to claims table)
    payment_reference_number VARCHAR(50) UNIQUE,                            -- Unique reference number for the payment
    bank_account_number      VARCHAR(50),                                   -- Bank account number for deposit
    payment_note             TEXT,                                          -- Additional notes regarding the payment
    payment_currency         VARCHAR(10) DEFAULT 'SGD',                     -- Currency of the payment (e.g., USD, EUR)
    tax_amount               DECIMAL(15, 2) DEFAULT 0.00,                   -- (included in payment_amount, if applicable)
    foreign_trans_fee        DECIMAL(15, 2) DEFAULT 0.00,                   -- (included in payment_amount, if applicable)
    created_user_id          VARCHAR(100),                   
    created_timestamp        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_user_id	     VARCHAR(100),
    updated_timestamp	     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (claim_id) REFERENCES claims(claim_id),                     -- FK to claims table
    FOREIGN KEY (previous_claim_id) REFERENCES claims(claim_id)             -- FK to claims table
    FOREIGN KEY (claim_contact_id) REFERENCES policy_holder(policy_holder_id),        -- FK to policy_holder table
    FOREIGN KEY (payment_type_code) REFERENCES payment_type_cd(payment_type_code)     -- FK to payment_type_cd table
);

CREATE TABLE injury (
    injury_id                INT PRIMARY KEY AUTO_INCREMENT,             
    claim_id                 INT NOT NULL,                                 -- FK to claims table
    claim_contact_id         INT NOT NULL,                                 -- FK to policy_holder table
    injury_code              VARCHAR(20) NOT NULL,                         -- Injury code (FK to injury_cd table)
    injury_description       TEXT,                                         
    injury_severity          ENUM('Minor', 'Moderate', 'Major', 'Critical') NOT NULL, 
    med_expenses             DECIMAL(15, 2) DEFAULT 0.00,                  -- Medical expenses related to injury
    ongoing_treatment_indicator   ENUM('Yes', 'No', 'Completed') DEFAULT 'Yes'                        
    created_user_id          VARCHAR(100),                   
    created_timestamp        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_user_id			 VARCHAR(100),
    updated_timestamp	     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (claim_id) REFERENCES claims(claim_id),                    -- FK to claims table
    FOREIGN KEY (claim_contact_id) REFERENCES policy_holder(policy_holder_id),        -- FK to policy_holder table
    FOREIGN KEY (injury_code) REFERENCES injury_cd(injury_code)            -- FK to injury_cd table
);

CREATE TABLE vendor (
    vendor_id                INT PRIMARY KEY AUTO_INCREMENT,                   -- Unique identifier for each vendor
    claim_id                 INT NOT NULL,                                     -- FK to claims table
    claim_contact_id         INT NOT NULL,                                     -- FK to policy_holder table
    vendor_name_code         VARCHAR(100) NOT NULL,                            -- Vendor's business name code(FK to vendor_available_list table)
    vendor_type_code         VARCHAR(20) NOT NULL,                             -- Vendor type code(FK to vendor_available_list)
    vendor_email             VARCHAR(100) UNIQUE,                                  
    vendor_phone             VARCHAR(20),
    vendor_rating            DECIMAL(3, 2),                                    -- Rating of the vendor (1.00 to 5.00)
    service_rate             DECIMAL(10, 2),                                   -- Service rate charged by the vendor per service
    created_user_id          VARCHAR(100),                   
    created_timestamp        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_user_id	     VARCHAR(100),
    updated_timestamp	     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_type_code, vendor_name_code) 
        REFERENCES vendor_available_list(vendor_type_code, vendor_name_code),    -- Link to vendor_available_list for service type
    FOREIGN KEY (claim_id) REFERENCES claims(claim_id),                        -- Link to claims table
    FOREIGN KEY (claim_contact_id) REFERENCES policy_holder(policy_holder_id)  -- Link to policy_holder table  
);


--STATIC DATA TABLES AND SCHEMAS
--Available tables:
-- 1. coverage_cd
-- 2. payment_type_cd
-- 3. injury_cd
-- 4. vendor_available_list

--SCHEMAS:

CREATE TABLE coverage_cd (
    coverage_code            VARCHAR(20) NOT NULL,              
    sub_coverage_code        VARCHAR(20) NOT NULL,              
    coverage_name            VARCHAR(100) NOT NULL,              
    coverage_description     TEXT,         
    created_user_id          VARCHAR(100),                   
    created_timestamp        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_user_id	     VARCHAR(100),
    updated_timestamp	     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,                         
    PRIMARY KEY (coverage_code, sub_coverage_code)        
);

CREATE TABLE payment_type_cd (
    payment_type_code        VARCHAR(20) PRIMARY KEY,            
    payment_type_name        VARCHAR(50) NOT NULL,      -- Full claim settlement/Partial claim settlement/Medical Reimbursement/Other
    payment_type_description TEXT,                
    created_user_id          VARCHAR(100),                   
    created_timestamp        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_user_id	     VARCHAR(100),
    updated_timestamp	     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP          
);

CREATE TABLE injury_cd (
    injury_code              VARCHAR(20) PRIMARY KEY,            
    injury_name              VARCHAR(100) NOT NULL,              
    injury_description       TEXT,  
    created_user_id          VARCHAR(100),                   
    created_timestamp        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_user_id	     VARCHAR(100),
    updated_timestamp	     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP                                  
);

CREATE TABLE vendor_available_list (
    vendor_type_code         VARCHAR(50) NOT NULL,       -- Type of service (towing/labor/salvage)
    vendor_name_code         INT NOT NULL,                       
    vendor_full_name         VARCHAR(100) NOT NULL,      -- Name of the vendor
    created_user_id          VARCHAR(100),                   
    created_timestamp        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_user_id	     VARCHAR(100),
    updated_timestamp	     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP    
    PRIMARY KEY (vendor_type_code, vendor_name_code)  
);










