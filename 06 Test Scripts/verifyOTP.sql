
-- ==================================================================================================
-- TEST 1: Missing Parameters
-- Pre-condition: None
-- Expected: responseCode = 1, message = 'Missing required parameters'
-- ==================================================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page":  1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE": "AUT.S.VERIFY_OTP",
    "P_APP_NAME":    "Gft-Customer-App"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 2: OTP Not Found
-- Pre-condition: No OTP record exists for this phone + purpose combination
-- Expected: responseCode = 1, message = 'OTP not found'
-- ==================================================================================================
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page":  1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.S.VERIFY_OTP",
    "P_APP_NAME":       "Gft-Customer-App",

    "P_CONTACT_TYPE":   "phone",
    "P_DESTINATION":    "03099999999",
    "P_OTP_CODE":       "123456",
    "P_PURPOSE":        "RESET PASSWORD"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 3: OTP Expired
-- Pre-condition: Manually insert an already-expired OTP record
-- ==================================================================================================

-- Setup: insert expired OTP
INSERT INTO otp
SET contact_type     = 'phone',
    destination      = '03011111111',
    otp_code         = '654321',
    expires_at       = NOW() - INTERVAL 10 MINUTE,   -- already expired
    otp_retries      = 3,
    next_otp_in_secs = 60,
    purpose          = 'RESET PASSWORD';

-- Expected: responseCode = 1, message = 'OTP EXPIRED'
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page":  1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.S.VERIFY_OTP",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_CONTACT_TYPE":   "phone",
    "P_DESTINATION":    "03011111111",
    "P_OTP_CODE":       "654321",
    "P_PURPOSE":        "RESET PASSWORD"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 4: OTP Mismatch - Retries Remaining
-- Pre-condition: Valid OTP exists with otp_retries > 1, send wrong code
-- Expected: responseCode = 1, message = 'OTP IS INVALID, 2 retries left.'
-- ==================================================================================================

-- Setup: insert valid OTP
INSERT INTO otp
SET contact_type     = 'phone',
    destination      = '03022222222',
    otp_code         = '111111',
    expires_at       = NOW() + INTERVAL 5 MINUTE,
    otp_retries      = 3,
    next_otp_in_secs = 60,
    purpose          = 'RESET PASSWORD';

-- Send wrong OTP code
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page":  1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.S.VERIFY_OTP",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_CONTACT_TYPE":   "phone",
    "P_DESTINATION":    "03022222222",
    "P_OTP_CODE":       "999999",
    "P_PURPOSE":        "RESET PASSWORD"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_OTP", @reqObj, @pjObj);
SELECT @pjObj;

-- Confirm retries decremented
SELECT otp_rec_id, otp_retries, expires_at FROM otp WHERE destination = '03022222222';


-- ==================================================================================================
-- TEST 5: OTP Mismatch - No Retries Left (FAILED)
-- Pre-condition: Same OTP from TEST 4, send wrong code 2 more times to exhaust retries
-- Expected: responseCode = 1, message = 'OTP IS FAILED, 0 retries left.'
--           expires_at set to NOW() in otp table
-- ==================================================================================================

-- Run twice more with wrong code to exhaust retries
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_OTP", @reqObj, @pjObj);
SELECT @pjObj;

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_OTP", @reqObj, @pjObj);
SELECT @pjObj;

-- Confirm OTP is now expired and retries = 0
SELECT otp_rec_id, otp_retries, expires_at FROM otp WHERE destination = '03022222222';


-- ==================================================================================================
-- TEST 6: OTP Success - FORGOT LOGIN ID (contact type = phone)
-- Pre-condition: 
--      1. Valid OTP exists for this phone
--      2. Customer exists with this phone in customer table
-- Expected: responseCode = 0
--           message = 'OTP verified successfully'
--           outbound_msgs record created with login ID
-- ==================================================================================================

-- Setup: generate OTP first via verifyExistingNumber or insert directly
INSERT INTO otp
SET contact_type     = 'phone',
    destination      = '321-12121',
    otp_code         = '222222',
    expires_at       = NOW() + INTERVAL 5 MINUTE,
    otp_retries      = 3,
    next_otp_in_secs = 60,
    purpose          = 'FORGOT LOGIN ID';

-- Make sure customer exists
-- INSERT INTO customer SET phone = '03033333333', user_name = 'john.doe', email = 'john@gft.com', ...;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page":  1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.S.VERIFY_OTP",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_CONTACT_TYPE":   "phone",
    "P_DESTINATION":    "321-12121",
    "P_OTP_CODE":       "222222",
    "P_PURPOSE":        "FORGOT LOGIN ID"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_OTP", @reqObj, @pjObj);
SELECT @pjObj;

-- Confirm outbound_msgs record created
SELECT outbound_msgs_rec_id, message_guid, object_name, outbound_msgs_json
FROM   outbound_msgs
WHERE  parent_message_table_name = 'customer'
ORDER  BY outbound_msgs_rec_id DESC
LIMIT  3;


-- ==================================================================================================
-- TEST 7: OTP Success - RESET PASSWORD
-- Pre-condition:
--      1. Valid OTP exists for this phone
--      2. Customer exists with this phone in customer table
-- Expected: responseCode = 0
--           message = 'Reset token generated successfully'
--           jData.contents.reset_token populated
--           jData.contents.reset_token_expires_in_minutes = 10
--           customer_json updated with reset token and expiry
-- ==================================================================================================

-- Setup
INSERT INTO otp
SET contact_type     = 'phone',
    destination      = '0305-4827724',
    otp_code         = '333333',
    expires_at       = NOW() + INTERVAL 5 MINUTE,
    otp_retries      = 3,
    next_otp_in_secs = 60,
    purpose          = 'RESET PASSWORD';

-- Make sure customer exists
-- INSERT INTO customer SET phone = '03044444444', user_name = 'jane.doe', email = 'jane@gft.com', ...;

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page":  1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.S.VERIFY_OTP",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_CONTACT_TYPE":   "phone",
    "P_DESTINATION":    "0305-4827724",
    "P_OTP_CODE":       "222222",
    "P_PURPOSE":        "RESET PASSWORD"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_OTP", @reqObj, @pjObj);
SELECT @pjObj;

-- Confirm reset token saved in customer_json
SELECT customer_rec_id,
       JSON_UNQUOTE(JSON_EXTRACT(customer_json, '$.otp_reset_token'))    AS reset_token,
       JSON_UNQUOTE(JSON_EXTRACT(customer_json, '$.reset_token_expiry')) AS token_expiry
FROM   customer
WHERE  phone = '03044444444';


-- ==================================================================================================
-- TEST 8: OTP Success - REGISTER
-- Pre-condition: Valid OTP exists, customer does NOT need to exist (REGISTER skips lookup)
-- Expected: responseCode = 0
--           message = 'OTP verified for registration'
-- ==================================================================================================

-- Setup
INSERT INTO otp
SET contact_type     = 'phone',
    destination      = '03055555555',
    otp_code         = '654321',
    expires_at       = NOW() + INTERVAL 5 MINUTE,
    otp_retries      = 3,
    next_otp_in_secs = 60,
    purpose          = 'REGISTER';

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page":  1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.S.VERIFY_OTP",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_CONTACT_TYPE":   "phone",
    "P_DESTINATION":    "03055555555",
    "P_OTP_CODE":       "444444",
    "P_PURPOSE":        "REGISTER"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 9: OTP Success - Invalid Purpose
-- Pre-condition: Valid OTP exists
-- Expected: responseCode = 1, message = 'Invalid purpose'
-- ==================================================================================================

-- Setup
INSERT INTO otp
SET contact_type     = 'phone',
    destination      = '03066666666',
    otp_code         = '555555',
    expires_at       = NOW() + INTERVAL 5 MINUTE,
    otp_retries      = 3,
    next_otp_in_secs = 60,
    purpose          = 'UNKNOWN PURPOSE';

SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page":  1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE":    "AUT.S.VERIFY_OTP",
    "P_APP_NAME":       "Gft-Customer-App",
    "P_CONTACT_TYPE":   "phone",
    "P_DESTINATION":    "03066666666",
    "P_OTP_CODE":       "555555",
    "P_PURPOSE":        "UNKNOWN PURPOSE"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- VERIFY OTP TABLE after all tests
-- ==================================================================================================
SELECT  otp_rec_id, contact_type, destination, otp_code, 
        expires_at, otp_retries, purpose, created_at
FROM    otp
WHERE   destination IN ('03011111111','03022222222','03033333333',
                        '03044444444','03055555555','03066666666')
ORDER   BY created_at DESC;


-- ==================================================================================================
-- VERIFY OUTBOUND_MSGS TABLE after TEST 6
-- ==================================================================================================
SELECT  outbound_msgs_rec_id, message_guid, object_name,
        parent_message_table_name, parent_message_table_rec_id,
        outbound_msgs_json
FROM    outbound_msgs
WHERE   object_name = 'FORGOT_LOGIN_ID'
ORDER   BY outbound_msgs_rec_id DESC
LIMIT   5;