-- ===================== Test: Update Customer =====================
-- Purpose: Verify upsertCustomer updates an existing customer record.

SET @psResult = '';

-- Create initial customer for update test
SET @pjReqObj = JSON_OBJECT(
    'first_name', 'Update',
    'last_name', 'Test',
    'email', 'asad.khan+update@example.com',
    'phone', '+971501234568',
    'whatsapp_number', '+971501234568',
    'national_id', 'NID-TEST-1002',
    'password', 'Password123!'
);
CALL upsertCustomer(@pjReqObj, @psResult);
SELECT @psResult AS create_status;

SELECT customer_rec_id
INTO @v_customer_rec_id
FROM customer
WHERE email = 'asad.khan+update@example.com'
LIMIT 1;

-- Update the customer record
SET @pjReqObj = JSON_OBJECT(
    'customer_rec_id', @v_customer_rec_id,
    'first_name', 'Asad Updated',
    'last_name', 'Khan Updated',
    'email', 'asad.khan+update@example.com',
    'phone', '+971501234569',
    'national_id', 'NID-TEST-1002',
    'password', 'NewPassword123!'
);

CALL upsertCustomer(@pjReqObj, @psResult);
SELECT @psResult AS update_status;

SELECT customer_rec_id,
       first_name,
       last_name,
       email,
       phone,
       national_id,
       customer_status
FROM customer
WHERE customer_rec_id = @v_customer_rec_id;
