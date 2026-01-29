-- ===================== Step 1: Prepare JSON request =====================
SET @pjReqObj = JSON_OBJECT(
--  'customer_rec_id', 2,
  'first_name', 'ASAD',
  'last_name', 'Khan',
  'email', 'asad.khan@finapp.com',
  'phone', '+971501234567',
  'whatsapp_number', '+971501234567',
  'national_id', '4546DFGRT',
  'password', 'Secure@789'
);



-- ===================== Step 2: Prepare variable for output =====================
SET @psResult = '';

-- ===================== Step 3: Call the procedure =====================
CALL createCustomer(@pjReqObj, @psResult);

-- ===================== Step 4: Check the result =====================
SELECT @psResult AS registration_status;








-- ===================== populate customer wallets from tradable assets =====================
 CALL populateCustomerWallets(1);
 
 -- ===================== log the activity of customer wallet in wallet_ledger =====================
 CALL wallet_activity(
    2,                -- customer_rec_id
    'WID-1133',       -- wallet_id
    'CREDIT',           -- txn_type
    250,              -- amount
    'balance credited'    -- remarks
);

