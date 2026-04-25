-- Test script for documentManagment stored procedure using requestHandler
-- Action Code: DOC.U.MANAGEMENT

SET @reqObj = '
{
  "jHeader": {
    "accessToken": "fad9017e31bd0927a6bc42996df9e22708b736112f3ef801fd30d7213c146a03",
    "accessKey":   "0f5aac120ac2746e8548dcdb565b06d9772248b51ab669f45c08dc51a4291f16"
  },
  "jData": {
    "P_DOC_TYPE": "ID_PROOF",
    "P_NOTES": "Uploaded ID proof document",
    "P_ATTACHMENT_URL": "https://example.com/uploads/id_proof.jpg",
    "P_LOGIN_ID": "test@example.com",
    "P_USER_TYPE": "CUSTOMER"
  }
}';

CALL requestHandler("127.0.0.1", "gft-app", "DOC.U.MANAGEMENT", @reqObj, @pjObj);

SELECT @pjObj AS response;