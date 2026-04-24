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

    "P_FIRST_NAME": "Ali",
    "P_LAST_NAME": "Raza",
    "P_EMAIL": "ali.raza92@gmail.com",
    "P_PHONE": "300-9876543",
    "P_NATIONAL_ID": "35202-9876543-1",
    "P_WHATSAPP_NUMBER": "+923009876543",
    "P_PASSWORD": "Secure@123",

    "P_RESIDENTIAL_ADDRESS": {
                            "google_reference_number":   "ChIJKarachi987654",
                            "full_address":              "Flat 12, Block B, Gulshan-e-Iqbal, Karachi, Pakistan",
                            "country":                   "Pakistan",
                            "building_number":           "12",
                            "street_name":               "Block B Road",
                            "street_address_2":         "Gulshan-e-Iqbal",
                            "city":                     "Karachi",
                            "state":                    "Sindh",
                            "zip_code":                 "75300",
                            "directions":               "Near Maskan Chowrangi",
                            "cross_street_1_name":      "University Road",
                            "cross_street_2_name":      "Abul Hasan Isphahani Road",
                            "latitude":                 "24.8607",
                            "longitude":                "67.0011"
                            }
  }
}';
  
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "CUS.U.CUSTOMER", @reqObj, @pjObj);

SELECT @pjObj;


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

    "P_FIRST_NAME": "Usman",
    "P_LAST_NAME": "Sheikh",
    "P_EMAIL": "usman.sheikh88@gmail.com",
    "P_PHONE": "301-5566778",
    "P_NATIONAL_ID": "42101-2233445-6",
    "P_WHATSAPP_NUMBER": "+923015566778",
    "P_PASSWORD": "Pass@456",

    "P_RESIDENTIAL_ADDRESS": {
      "google_reference_number": "ChIJKarachi112233",
      "full_address": "House 45, Street 10, Clifton, Karachi, Pakistan",
      "country": "Pakistan",
      "building_number": "45",
      "street_name": "Street 10",
      "street_address_2": "Clifton",
      "city": "Karachi",
      "state": "Sindh",
      "zip_code": "75600",
      "directions": "Near Clifton Beach",
      "cross_street_1_name": "Shahrah-e-Faisal",
      "cross_street_2_name": "Mai Kolachi Road",
      "latitude": "24.8138",
      "longitude": "67.0305"
    }
  }
}';
  
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "CUS.U.CUSTOMER", @reqObj, @pjObj);

SELECT @pjObj;


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

    "P_FIRST_NAME": "Sara",
    "P_LAST_NAME": "Ahmed",
    "P_EMAIL": "sara.ahmed77@gmail.com",
    "P_PHONE": "333-1122334",
    "P_NATIONAL_ID": "61101-7788990-2",
    "P_WHATSAPP_NUMBER": "+923331122334",
    "P_PASSWORD": "Sara@789",

    "P_RESIDENTIAL_ADDRESS": {
      "google_reference_number": "ChIJIslamabad445566",
      "full_address": "Apartment 8, Sector F-10, Islamabad, Pakistan",
      "country": "Pakistan",
      "building_number": "8",
      "street_name": "Street 5",
      "street_address_2": "F-10 Markaz",
      "city": "Islamabad",
      "state": "ICT",
      "zip_code": "44000",
      "directions": "Near F-10 Markaz Market",
      "cross_street_1_name": "Margalla Road",
      "cross_street_2_name": "Service Road",
      "latitude": "33.6844",
      "longitude": "73.0479"
    }
  }
}';
  
CALL requestHandler("127.0.0.0", "Gft-Customer-App", "CUS.U.CUSTOMER", @reqObj, @pjObj);

SELECT @pjObj;