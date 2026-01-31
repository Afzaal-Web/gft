-- ===================== Step 1: Prepare JSON request =====================
SET @pjReqObj = JSON_OBJECT(
 'first_name', 'john',
  'last_name', 'Khan',
  'user_name', 'asad.khan@finapp.com',
  'email', 'asad.khan@finapp.com',
  'phone', '+971501234567',
  'whatsapp_number', '+971501234567',
  'national_id', '4546DFGRT',
  'password', 'asad123'
);



-- ===================== Step 2: Prepare variable for output =====================
SET @psResult = '';

-- ===================== Step 3: Call the procedure =====================
CALL upsertCustomer(@pjReqObj, @psResult);

-- ===================== Step 4: Check the result =====================
SELECT @psResult AS registration_status;







