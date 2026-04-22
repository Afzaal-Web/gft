-- ==================================================================================================
-- Test Scripts: verifiyExistingNumber
-- Scenarios:
--		1. Missing Phone Number
--		2. Existing Customer
--		3. Phone in Reverse Lookup  (OTP success)
--		4. Phone in Reverse Lookup  (OTP cooldown)
--		5. New User                 (OTP success)
--		6. New User                 (OTP cooldown)
-- ==================================================================================================


-- ==================================================================================================
-- TEST 1: Missing Phone Number
-- Expected: responseCode = 1, message = 'Phone number is required'
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
    "P_ACTION_CODE": "AUT.S.VERIFY_EXISTING_NUMBER",
    "P_APP_NAME":    "Gft-Customer-App"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_EXISTING_NUMBER", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 2: Existing Customer
-- Pre-condition: '03001234567' must exist in customer table
-- Expected: responseCode = 1, message = 'User already exists with this phone number'
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
    "P_ACTION_CODE": "AUT.S.VERIFY_EXISTING_NUMBER",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_PHONE_NUM":   "321-12121"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_EXISTING_NUMBER", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 3: Phone in Reverse Lookup - OTP Success
-- Pre-condition: '03007654321' must NOT exist in customer, but MUST exist in reverse_lookup
-- Expected: responseCode = 0
--           message = 'Success - Phone exists in reverse lookup...'
--           jData.contents has first_name, last_name, email etc.
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
    "P_ACTION_CODE": "AUT.S.VERIFY_EXISTING_NUMBER",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_PHONE_NUM":   "9876543210"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_EXISTING_NUMBER", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 4: Phone in Reverse Lookup - OTP Cooldown (run within 60 seconds of TEST 3)
-- Pre-condition: TEST 3 must have been run within last 60 seconds
-- Expected: responseCode = 1
--           message = 'Please wait before requesting OTP again.'
--           jData.contents.next_otp_in_secs shows remaining seconds
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
    "P_ACTION_CODE": "AUT.S.VERIFY_EXISTING_NUMBER",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_PHONE_NUM":   "9876543210"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_EXISTING_NUMBER", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 5: New User - OTP Success
-- Pre-condition: '03111111111' must NOT exist in customer or reverse_lookup
-- Expected: responseCode = 0
--           message = 'New user - Phone number is not found, proceed with registration.'
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
    "P_ACTION_CODE": "AUT.S.VERIFY_EXISTING_NUMBER",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_PHONE_NUM":   "03111111111"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_EXISTING_NUMBER", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- TEST 6: New User - OTP Cooldown (run within 60 seconds of TEST 5)
-- Pre-condition: TEST 5 must have been run within last 60 seconds
-- Expected: responseCode = 1
--           message = 'Please wait before requesting OTP again.'
--           jData.contents.next_otp_in_secs shows remaining seconds
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
    "P_ACTION_CODE": "AUT.S.VERIFY_EXISTING_NUMBER",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_PHONE_NUM":   "03111111111"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.VERIFY_EXISTING_NUMBER", @reqObj, @pjObj);
SELECT @pjObj;


-- ==================================================================================================
-- VERIFY OTP TABLE after TEST 3 and TEST 5
-- ==================================================================================================
SELECT  otp_rec_id, contact_type, destination, otp_code, expires_at, otp_retries, purpose, created_at
FROM    otp
WHERE   destination IN ('03007654321', '03111111111')
ORDER   BY created_at DESC;


