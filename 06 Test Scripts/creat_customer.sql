-- ===================== Step 1 Prepare JSON request =====================
SET @pjReqObj = JSON_OBJECT(
 'first_name', 'asad',
  'last_name', 'Khan',
  'email', 'khan@gmail.com',
  'phone', '321-12121',
   "national_id", "4546DF565465GRT",
   "whatsapp_number", "+971501234567",
  'password', 'ASAQW4545',
  'residential_address', JSON_OBJECT(
                                  "google_reference_number",   "ChIJLahore123456",
                                  "full_address",               "House 123, Street 45, DHA Phase 5, Lahore, Pakistan",
                                  "country",                    "Pakistan",
                                  "building_number",            "123",
                                  "street_name",                "Street 45",
                                  "street_address_2",           "DHA Phase 5",
                                  "city",                       "Lahore",
                                  "state",                      "Punjab",
                                  "zip_code",                   "54000",
                                  "directions",                 "Near Y Block Commercial Area",
                                  "cross_street_1_name",        "Khayaban-e-Iqbal",
                                  "cross_street_2_name",        "Main Boulevard DHA",
                                  "latitude",                    "31.5204",
                                  "longitude",                   "74.3587"
                                  )
);



-- ===================== Step 2 Prepare variable for output =====================
SET @psResult = '';

-- ===================== Step 3 Call the procedure =====================
CALL upsertCustomer(@pjReqObj, @psResult);

-- ===================== Step 4 Check the result =====================
SELECT @psResult AS registration_status;