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

    "P_CUSTOMER_REC_ID": 1,
    "P_FIRST_NAME": "Amran",
    "P_LAST_NAME": "Khan",
    "P_EMAIL": "khan@gmail.com",
    "P_PHONE": "321-12121",
    "P_NATIONAL_ID": "4546DF565465GRT",
    "P_WHATSAPP_NUMBER": "+971501234567",
    "P_PASSWORD": "ASAQW4545",

    "P_RESIDENTIAL_ADDRESS": {
                            "google_reference_number":   "ChIJLahore123456",
                            "full_address":              "House 123, Street 45, DHA Phase 5, Lahore, Pakistan",
                            "country":                   "Pakistan",
                            "building_number":           "123",
                            "street_name":               "Street 45",
                            "street_address_2":         "DHA Phase 5",
                            "city":                     "Lahore",
                            "state":                    "Punjab",
                            "zip_code":                 "54000",
                            "directions":               "Near Y Block Commercial Area",
                            "cross_street_1_name":      "Khayaban-e-Iqbal",
                            "cross_street_2_name":      "Main Boulevard DHA",
                            "latitude":                 "31.5204",
                            "longitude":                "74.3587"
                            }
  }
}';
  
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "CUS.U.CUSTOMER", @reqObj, @pjObj);

SELECT @pjObj;
