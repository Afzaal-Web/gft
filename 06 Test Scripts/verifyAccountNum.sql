SET @reqObj = '
{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jMetaData": {
    "page": 1,
    "limit": 10
  },
  "jData": {
    "P_ACTION_CODE": "CUS.U.CUSTOMER",
    "P_APP_NAME": "Gft-Customer-App",

   "P_LOGIN_ID":        "khan@gmail.com",
    "P_ACCOUNT_NUM":    "P-593"
  }
}';
  
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "FIN.S.ACCOUNT_VERIFICATION", @reqObj, @pjObj);

SELECT @pjObj;
