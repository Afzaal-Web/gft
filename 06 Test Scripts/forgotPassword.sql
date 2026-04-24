-- ==================================================================================================
-- Test Suite: forgotPassword
-- ==================================================================================================

-- -----------------------------------------------------------------------
-- TEST 1: Valid EMAIL input  →  OTP sent to email
-- -----------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE": "AUT.S.FORGOT_PASSWORD_OTP",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_LOGIN_ID":    "customer@example.com"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_PASSWORD_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- -----------------------------------------------------------------------
-- TEST 2: Valid PHONE input  →  OTP sent to phone
-- -----------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE": "AUT.S.FORGOT_PASSWORD_OTP",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_LOGIN_ID":    "03001234567"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_PASSWORD_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- -----------------------------------------------------------------------
-- TEST 3: Valid USERNAME input  →  OTP sent to BOTH email and phone
-- -----------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE": "AUT.S.FORGOT_PASSWORD_OTP",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_LOGIN_ID":    "john_doe"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_PASSWORD_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- -----------------------------------------------------------------------
-- TEST 4: USERNAME with only EMAIL on record  →  OTP sent to email only
-- -----------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE": "AUT.S.FORGOT_PASSWORD_OTP",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_LOGIN_ID":    "khan@gmail.com"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_PASSWORD_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- -----------------------------------------------------------------------
-- TEST 5: USERNAME with only PHONE on record  →  OTP sent to phone only
-- -----------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE": "AUT.S.FORGOT_PASSWORD_OTP",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_LOGIN_ID":    "0305-4827724"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_PASSWORD_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- -----------------------------------------------------------------------
-- TEST 6: Non-existent LOGIN_ID  →  customer not found
-- -----------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE": "AUT.S.FORGOT_PASSWORD_OTP",
    "P_APP_NAME":    "Gft-Customer-App",
    "P_LOGIN_ID":    "ghost_user_999"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_PASSWORD_OTP", @reqObj, @pjObj);
SELECT @pjObj;


-- -----------------------------------------------------------------------
-- TEST 7: NULL / missing LOGIN_ID  →  customer not found
-- -----------------------------------------------------------------------
SET @reqObj = '{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_ACTION_CODE": "AUT.S.FORGOT_PASSWORD_OTP",
    "P_APP_NAME":    "Gft-Customer-App"
  }
}';

CALL requestHandler("127.0.0.0", "Gft-Customer-App", "AUT.S.FORGOT_PASSWORD_OTP", @reqObj, @pjObj);
SELECT @pjObj;