-- ==================================================================================================
-- Test Scripts: forgotLoginID (via requestHandler)
-- Scenarios:
--		1. Missing All Parameters
--		2. Missing CNIC
--		3. Customer Not Found (wrong CNIC)
--		4. Customer Not Found (email/phone not in DB)
--		5. Success - via Email
--		6. Success - via Phone
--		7. OTP Cooldown (run within 60 seconds of TEST 5 or TEST 6)
-- ==================================================================================================


-- ==================================================================================================
-- TEST 1: Missing All Parameters
-- Pre-condition: None
-- Expected: responseCode = 1, message = 'customer not found'
--           (since all inputs are NULL, WHERE clause matches nothing)
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
    "P_ACTION_CODE": "AUT.S.FORGOT_LOGIN_ID",
    "P_APP_NAME":    "Gft-Customer-App"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_LOGIN_ID", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 2: Missing CNIC
-- Pre-condition: None
-- Expected: responseCode = 1, message = 'customer not found'
--           (CNIC is NULL so AND national_id = NULL never matches)
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
    "P_ACTION_CODE": "AUT.S.FORGOT_LOGIN_ID",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_EMAIL":       "john@gft.com"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_LOGIN_ID", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 3: Customer Not Found - Wrong CNIC
-- Pre-condition: Email exists in customer table but CNIC does not match
-- Expected: responseCode = 1, message = 'customer not found'
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
    "P_ACTION_CODE": "AUT.S.FORGOT_LOGIN_ID",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_EMAIL":       "khan@gmail.com",
    "P_CNIC":        "99999-9999999-9"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_LOGIN_ID", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 4: Customer Not Found - Email/Phone Not In DB
-- Pre-condition: CNIC is valid but email does not exist in customer table
-- Expected: responseCode = 1, message = 'customer not found'
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
    "P_ACTION_CODE": "AUT.S.FORGOT_LOGIN_ID",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_EMAIL":       "notexist@gft.com",
    "P_CNIC":        "42101-1234567-1"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_LOGIN_ID", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 5: Success - via Email
-- Pre-condition: Customer must exist with this email AND cnic combination
--   INSERT INTO customer SET email='john@gft.com', national_id='42101-1234567-1', 
--                            user_name='john.doe', phone='03011111111', ...;
-- Expected: responseCode = 0
--           message = 'OTP has been sent to your verified contact...'
--           OTP record created with contact_type = 'email'
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
    "P_ACTION_CODE": "AUT.S.FORGOT_LOGIN_ID",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_EMAIL":       "arslan@gmail.com",
    "P_CNIC":        "331022233333"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_LOGIN_ID", @reqObj, @pjObj);
SELECT @pjObj;

-- Verify OTP created with email as destination
SELECT otp_rec_id, contact_type, destination, otp_code, expires_at, purpose
FROM   otp
WHERE  destination = 'john@gft.com'
ORDER  BY otp_rec_id DESC
LIMIT  1;


-- ==================================================================================================
-- TEST 6: Success - via Phone (no email provided)
-- Pre-condition: Customer must exist with this phone AND cnic combination
--   INSERT INTO customer SET phone='03022222222', national_id='42101-7654321-2',
--                            user_name='jane.doe', email=NULL, ...;
-- Expected: responseCode = 0
--           message = 'OTP has been sent to your verified contact...'
--           OTP record created with contact_type = 'phone'
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
    "P_ACTION_CODE": "AUT.S.FORGOT_LOGIN_ID",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_PHONE":       "03022222222",
    "P_CNIC":        "42101-7654321-2"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_LOGIN_ID", @reqObj, @pjObj);
SELECT @pjObj;

-- Verify OTP created with phone as destination
SELECT otp_rec_id, contact_type, destination, otp_code, expires_at, purpose
FROM   otp
WHERE  destination = '03022222222'
ORDER  BY otp_rec_id DESC
LIMIT  1;


-- ==================================================================================================
-- TEST 7: OTP Cooldown (run within 60 seconds of TEST 5 or TEST 6)
-- Pre-condition: TEST 5 or TEST 6 must have been run within last 60 seconds
-- Expected: responseCode = 1
--           message = 'Please wait before requesting OTP again.'
--           jData.contents.next_otp_in_secs shows remaining seconds
-- ==================================================================================================

-- Cooldown test for email (repeat TEST 5 immediately)
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
    "P_ACTION_CODE": "AUT.S.FORGOT_LOGIN_ID",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_EMAIL":       "john@gft.com",
    "P_CNIC":        "42101-1234567-1"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_LOGIN_ID", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- VERIFY OTP TABLE after all tests
-- ==================================================================================================
SELECT  otp_rec_id, contact_type, destination, otp_code,
        expires_at, otp_retries, purpose, created_at
FROM    otp
WHERE   purpose = 'FORGOT LOGIN ID'
ORDER   BY created_at DESC
LIMIT   5;


-- ==================================================================================================
-- VERIFY OUTBOUND_MSGS TABLE after all tests
-- ==================================================================================================
SELECT  outbound_msgs_rec_id, message_guid, object_name,
        parent_message_table_name, parent_message_table_rec_id,
        outbound_msgs_json
FROM    outbound_msgs
WHERE   object_name = 'FORGOT_LOGIN_ID'
ORDER   BY outbound_msgs_rec_id DESC
LIMIT   5;