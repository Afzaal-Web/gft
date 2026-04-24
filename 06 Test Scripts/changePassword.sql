-- ==================================================================================================
-- Test Script: changePassword
-- ==================================================================================================

-- ============================================================
-- SETUP: Verify starting state
-- ============================================================
SELECT  'SETUP CHECK' AS test_case,
        customer_rec_id,
        email,
        phone,
        user_name
FROM    customer
WHERE   customer_rec_id = 2;

SELECT  'SETUP - password_history' AS test_case,
        parent_table_rec_id,
        LEFT(password_hash, 20)     AS hash_preview,
        is_active,
        password_change_reason,
        password_set_at
FROM    password_history
WHERE   parent_table_name   = 'customer'
AND     parent_table_rec_id = 2
ORDER BY password_set_at DESC;

-- ============================================================
-- TC-01: Happy Path — valid old password, new password
-- ============================================================
SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.U.CHANGE_PASSWORD",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_LOGIN_ID":       "ali.raza92@gmail.com",
    "P_OLD_PASSWORD":   "Secure@123",
    "P_NEW_PASSWORD":   "NewSecure@456"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.CHANGE_PASSWORD", @req, @resp);
SELECT 'TC-01 Happy Path' AS test_case, @resp AS response;

-- ============================================================
-- TC-02: Wrong old password
-- ============================================================
SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.U.CHANGE_PASSWORD",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_LOGIN_ID":       "ali.raza92@gmail.com",
    "P_OLD_PASSWORD":   "WrongPassword@999",
    "P_NEW_PASSWORD":   "AnotherNew@789"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.CHANGE_PASSWORD", @req, @resp);
SELECT 'TC-02 Wrong Old Password' AS test_case, @resp AS response;

-- ============================================================
-- TC-03: New password same as current password
-- ============================================================
SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.U.CHANGE_PASSWORD",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_LOGIN_ID":       "ali.raza92@gmail.com",
    "P_OLD_PASSWORD":   "NewSecure@456",
    "P_NEW_PASSWORD":   "NewSecure@456"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.CHANGE_PASSWORD", @req, @resp);
SELECT 'TC-03 Same As Current Password' AS test_case, @resp AS response;

-- ============================================================
-- TC-04: Reuse of a previous password (Secure@123 was the original)
-- ============================================================
SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.U.CHANGE_PASSWORD",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_LOGIN_ID":       "ali.raza92@gmail.com",
    "P_OLD_PASSWORD":   "NewSecure@456",
    "P_NEW_PASSWORD":   "Secure@123"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.CHANGE_PASSWORD", @req, @resp);
SELECT 'TC-04 Password Reuse' AS test_case, @resp AS response;

-- ============================================================
-- TC-05: Customer not found — bad login ID
-- ============================================================
SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.U.CHANGE_PASSWORD",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_LOGIN_ID":       "ghost.user@nowhere.com",
    "P_OLD_PASSWORD":   "Secure@123",
    "P_NEW_PASSWORD":   "NewSecure@456"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.CHANGE_PASSWORD", @req, @resp);
SELECT 'TC-05 Customer Not Found' AS test_case, @resp AS response;

-- ============================================================
-- TC-06: Login via phone number
-- ============================================================
SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.U.CHANGE_PASSWORD",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_LOGIN_ID":       "300-9876543",
    "P_OLD_PASSWORD":   "NewSecure@456",
    "P_NEW_PASSWORD":   "PhoneChange@789"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.CHANGE_PASSWORD", @req, @resp);
SELECT 'TC-06 Login via Phone' AS test_case, @resp AS response;

-- ============================================================
-- TC-07: Missing required fields
-- ============================================================
SET @req = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.U.CHANGE_PASSWORD",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_LOGIN_ID":       "ali.raza92@gmail.com"
  }
}';
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.U.CHANGE_PASSWORD", @req, @resp);
SELECT 'TC-07 Missing Fields' AS test_case, @resp AS response;

-- ============================================================
-- VERIFY: Final state after all tests
-- ============================================================
SELECT  'FINAL - password_history' AS check_table,
        parent_table_rec_id,
        LEFT(password_hash, 20)     AS hash_preview,
        is_active,
        password_change_reason,
        password_set_at,
        password_expiration_date
FROM    password_history
WHERE   parent_table_name   = 'customer'
AND     parent_table_rec_id = 2
ORDER BY password_set_at DESC;

SELECT  'FINAL - auth check'                                        AS check_table,
        LEFT(getJval(auth_json, 'login_credentials.password'), 20)  AS stored_hash_preview,
        is_active                                                    AS auth_is_active
FROM    auth
WHERE   parent_table_name   = 'customer'
AND     parent_table_rec_id = 2;