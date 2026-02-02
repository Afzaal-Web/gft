-- ===================== Step 1: Prepare JSON request =====================
SET @pjReqObj = JSON_OBJECT(
 'first_name', 'asad',
  'last_name', 'Khan',
  'email', 'khan@gmail.com',
  'phone', '321-12121',
   "national_id", "4546DF565465GRT",
   "whatsapp_number", "+971501234567",
  
  'password', 'ASAQW4545'
);



-- ===================== Step 2: Prepare variable for output =====================
SET @psResult = '';

-- ===================== Step 3: Call the procedure =====================
CALL upsertCustomer(@pjReqObj, @psResult);

-- ===================== Step 4: Check the result =====================
SELECT @psResult AS registration_status;







