-- ===================== Test: upsertCustomer Validation Errors =====================
-- Purpose: Verify required field validation and duplicate checks.

SET @psResult = '';

-- Insert a baseline customer to trigger duplicates
SET @pjReqObj = JSON_OBJECT(
    'first_name', 'Validation',
    'last_name', 'Base',
    'email', 'validation.duplicate@example.com',
    'phone', '+971501234570',
    'whatsapp_number', '+971501234570',
    'national_id', 'NID-TEST-1003',
    'password', 'Password123!'
);
CALL upsertCustomer(@pjReqObj, @psResult);
SELECT @psResult AS initial_insert;

-- Attempt insert with duplicate email and national_id
SET @pjReqObj = JSON_OBJECT(
    'first_name', 'Validation',
    'last_name', 'Duplicate',
    'email', 'validation.duplicate@example.com',
    'phone', '+971501234571',
    'whatsapp_number', '+971501234571',
    'national_id', 'NID-TEST-1003',
    'password', 'Password123!'
);
CALL upsertCustomer(@pjReqObj, @psResult);
SELECT @psResult AS duplicate_insert_result;

-- Attempt insert with missing required fields
SET @pjReqObj = JSON_OBJECT(
    'email', 'validation.missing@example.com',
    'password', 'Password123!'
);
CALL upsertCustomer(@pjReqObj, @psResult);
SELECT @psResult AS missing_fields_result;
