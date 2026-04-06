-- ===================== Test: Create Customer =====================
-- Purpose: Verify upsertCustomer inserts a new customer record.

SET @pjReqObj = JSON_OBJECT(
    'first_name', 'john',
    'last_name', 'smith',
    'email', 'asad.khan+test1@example.com',
    'phone', '+971501234567',
    'whatsapp_number', '+971501234567',
    'national_id', 'NID-TEST-1001',
    'password', 'Password123!'
);

SET @psResult = '';
CALL upsertCustomer(@pjReqObj, @psResult);

SELECT @psResult AS registration_status;

SELECT customer_rec_id,
       email,
       national_id,
       customer_status,
       account_num
FROM customer
WHERE email = 'asad.khan+test1@example.com';
