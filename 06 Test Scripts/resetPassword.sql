-- ==================================================================================================
-- Test Script: resetPassword
-- ==================================================================================================

-- ============================================================
-- SETUP: Insert a customer with a valid reset token
-- ============================================================

UPDATE customer
SET customer_json = JSON_SET(
                              customer_json,
                              '$.otp_reset_token',    'TOKEN-TEST-001',
                              '$.reset_token_expiry',  DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 30 MINUTE), '%Y-%m-%d %H:%i:%s')
                            )
WHERE customer_rec_id = 2;

-- ============================================================
-- TC-01: Happy Path — valid token, new password
-- ============================================================
SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":  "AUT.U.RESET_PASSWORD",
    "P_APP_NAME":     "Gft-Customer-App",
    "P_LOGIN_ID":     "ali.raza92@gmail.com",
    "P_NEW_PASSWORD": "NewSecure@456",
    "P_RESET_TOKEN":  "TOKEN-TEST-001"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.RESET_PASSWORD", @req, @resp);
SELECT 'TC-01 Happy Path' AS test_case, @resp AS response;

-- ============================================================
-- TC-02: Wrong reset token
-- ============================================================
-- Re-seed token first
UPDATE customer
SET customer_json = JSON_SET(
                              customer_json,
                              '$.otp_reset_token',   'TOKEN-TEST-001',
                              '$.reset_token_expiry', DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 30 MINUTE), '%Y-%m-%d %H:%i:%s')
                            )
WHERE customer_rec_id = 2;

SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":  "AUT.U.RESET_PASSWORD",
    "P_APP_NAME":     "Gft-Customer-App",
    "P_LOGIN_ID":     "ali.raza92@gmail.com",
    "P_NEW_PASSWORD": "NewSecure@456",
    "P_RESET_TOKEN":  "WRONG-TOKEN-999"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.RESET_PASSWORD", @req, @resp);
SELECT 'TC-02 Wrong Token' AS test_case, @resp AS response;

-- ============================================================
-- TC-03: Expired token
-- ============================================================
UPDATE customer
SET customer_json = JSON_SET(
                              customer_json,
                              '$.otp_reset_token',   'TOKEN-TEST-001',
                              '$.reset_token_expiry', DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 10 MINUTE), '%Y-%m-%d %H:%i:%s')
                            )
WHERE customer_rec_id = 2;

SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":  "AUT.U.RESET_PASSWORD",
    "P_APP_NAME":     "Gft-Customer-App",
    "P_LOGIN_ID":     "ali.raza92@gmail.com",
    "P_NEW_PASSWORD": "NewSecure@456",
    "P_RESET_TOKEN":  "TOKEN-TEST-001"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.RESET_PASSWORD", @req, @resp);
SELECT 'TC-03 Expired Token' AS test_case, @resp AS response;

-- ============================================================
-- TC-04: Password reuse — same as current password
-- ============================================================
UPDATE customer
SET customer_json = JSON_SET(
                              customer_json,
                              '$.otp_reset_token',   'TOKEN-TEST-001',
                              '$.reset_token_expiry', DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 30 MINUTE), '%Y-%m-%d %H:%i:%s')
                            )
WHERE customer_rec_id = 2;

SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":  "AUT.U.RESET_PASSWORD",
    "P_APP_NAME":     "Gft-Customer-App",
    "P_LOGIN_ID":     "ali.raza92@gmail.com",
    "P_NEW_PASSWORD": "Secure@123",
    "P_RESET_TOKEN":  "TOKEN-TEST-001"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.RESET_PASSWORD", @req, @resp);
SELECT 'TC-04 Password Reuse' AS test_case, @resp AS response;

-- ============================================================
-- TC-05: Customer not found — bad login ID
-- ============================================================
UPDATE customer
SET customer_json = JSON_SET(
                              customer_json,
                              '$.otp_reset_token',   'TOKEN-TEST-001',
                              '$.reset_token_expiry', DATE_FORMAT(DATE_ADD(NOW(), INTERVAL 30 MINUTE), '%Y-%m-%d %H:%i:%s')
                            )
WHERE customer_rec_id = 2;

SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":  "AUT.U.RESET_PASSWORD",
    "P_APP_NAME":     "Gft-Customer-App",
    "P_LOGIN_ID":     "ghost.user@nowhere.com",
    "P_NEW_PASSWORD": "NewSecure@456",
    "P_RESET_TOKEN":  "TOKEN-TEST-001"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.RESET_PASSWORD", @req, @resp);
SELECT 'TC-05 Customer Not Found' AS test_case, @resp AS response;

-- ============================================================
-- TC-06: Missing required fields
-- ============================================================
SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":  "AUT.U.RESET_PASSWORD",
    "P_APP_NAME":     "Gft-Customer-App",
    "P_LOGIN_ID":     "ali.raza92@gmail.com"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.RESET_PASSWORD", @req, @resp);
SELECT 'TC-06 Missing Fields' AS test_case, @resp AS response;

-- ============================================================
-- Verify: Check password_history and auth after TC-01
-- ============================================================
SELECT  'password_history'          AS check_table,
        parent_table_rec_id,
        LEFT(password_hash,20)      AS hash_preview,
        is_active,
        password_change_reason,
        password_expiration_date
FROM    password_history
WHERE   parent_table_name   = 'customer'
AND     parent_table_rec_id = 2
ORDER   BY password_set_at DESC;

SELECT  'auth check'                                        AS check_table,
        getJval(auth_json, 'login_credentials.password')   AS stored_hash,
        SHA2('NewSecure@456', 256)                          AS expected_hash,
        getJval(auth_json, 'login_credentials.password')
            = SHA2('NewSecure@456', 256)                    AS hashes_match
FROM    auth
WHERE   parent_table_name   = 'customer'
AND     parent_table_rec_id = 2;

SELECT  'token cleared'                                     AS check_table,
        getJval(customer_json, '$.otp_reset_token')         AS token_after,
        getJval(customer_json, '$.reset_token_expiry')      AS expiry_after
FROM    customer
WHERE   customer_rec_id = 2;