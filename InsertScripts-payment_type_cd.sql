INSERT INTO SYSTEM.PAYMENT_TYPE_CD (PAYMENT_TYPE_CODE, PAYMENT_TYPE_NAME, PAYMENT_TYPE_DESCRIPTION, CREATED_USER_ID, UPDATED_USER_ID)
VALUES ('FS', 'Full Claim Settlement', 'Claim amount has been settled completely', 'admin', 'admin');

INSERT INTO SYSTEM.PAYMENT_TYPE_CD (PAYMENT_TYPE_CODE, PAYMENT_TYPE_NAME, PAYMENT_TYPE_DESCRIPTION, CREATED_USER_ID, UPDATED_USER_ID)
VALUES ('PS', 'Partial Claim Settlement', 'Claim amount has been settled partially', 'admin', 'admin');

INSERT INTO SYSTEM.PAYMENT_TYPE_CD (PAYMENT_TYPE_CODE, PAYMENT_TYPE_NAME, PAYMENT_TYPE_DESCRIPTION, CREATED_USER_ID, UPDATED_USER_ID)
VALUES ('RE', 'Reimbursement', 'Amount paid by the claim contact has been reimbursed', 'admin', 'admin');

INSERT INTO SYSTEM.PAYMENT_TYPE_CD (PAYMENT_TYPE_CODE, PAYMENT_TYPE_NAME, PAYMENT_TYPE_DESCRIPTION, CREATED_USER_ID, UPDATED_USER_ID)
VALUES ('OT', 'Other', 'Other settlements', 'admin', 'admin');
