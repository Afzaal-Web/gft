DELIMITER $ $ CREATE PROCEDURE create_customer(
    IN pjReqObj JSON,
    OUT psResult VARCHAR(255)
) BEGIN
/* ===================== Variable Declarations Customer ===================== */
DECLARE v_customer_rec_id INT;

DECLARE v_customer_status VARCHAR(30);

DECLARE v_customer_type VARCHAR(30);

DECLARE v_first_name VARCHAR(100);

DECLARE v_last_name VARCHAR(100);

DECLARE v_user_name VARCHAR(100);

DECLARE v_email VARCHAR(50);

DECLARE v_phone VARCHAR(20);

DECLARE v_whatsapp_num VARCHAR(20);

DECLARE v_national_id VARCHAR(50);

DECLARE v_customer_json JSON;

DECLARE v_customer_row_metadata JSON;

/* ===================== Variable Declarations Auth ===================== */
DECLARE v_auth_rec_id INT;

DECLARE v_password_plain VARCHAR(255);

DECLARE v_password_hashed VARCHAR(255);

DECLARE v_auth_json JSON;

DECLARE v_auth_row_metadata JSON;

DECLARE v_error_message VARCHAR(255);

/* ===================== Error Handler ===================== */
DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK;

GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;

SET
    psResult = CONCAT('Registration failed: ', v_error_message);

END;

/* ===================== Main Block ===================== */
main_block: BEGIN -- Extract scalars from JSON request
SET
    v_first_name = JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.first_name'));

SET
    v_last_name = JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.last_name'));

SET
    v_email = JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.email'));

SET
    v_phone = JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.phone'));

SET
    v_whatsapp_num = JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.whatsapp_number'));

SET
    v_national_id = JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.national_id'));

SET
    v_password_plain = JSON_UNQUOTE(JSON_EXTRACT(pjReqObj, '$.password'));

SET
    v_user_name = v_email;

SET
    v_customer_status = 'registration_request';

SET
    v_customer_type = 'personal';

/* ===================== Validations ===================== */
SET
    psResult = '';

IF isFalsy(v_first_name) THEN
SET
    psResult = CONCAT(psResult, 'First name is required. ');

END IF;

IF isFalsy(v_last_name) THEN
SET
    psResult = CONCAT(psResult, 'Last name is required. ');

END IF;

IF isFalsy(v_national_id) THEN
SET
    psResult = CONCAT(psResult, 'National ID is required. ');

END IF;

IF isFalsy(v_email) THEN
SET
    psResult = CONCAT(psResult, 'Email is required. ');

END IF;

IF isFalsy(v_phone) THEN
SET
    psResult = CONCAT(psResult, 'Phone number is required. ');

END IF;

IF isFalsy(v_password_plain) THEN
SET
    psResult = CONCAT(psResult, 'Password is required. ');

END IF;

-- Uniqueness checks
IF EXISTS (
    SELECT
        1
    FROM
        customer
    WHERE
        national_id = v_national_id
) THEN
SET
    psResult = CONCAT(
        psResult,
        'Customer already exists with this National ID. '
    );

END IF;

-- Stop if validation failed
IF LENGTH(TRIM(psResult)) > 0 THEN LEAVE main_block;

END IF;

-- Initialize JSON templates
SET
    v_customer_json = get_template_customer('customer_json');

SET
    v_customer_row_metadata = get_template_customer('row_metadata');

SET
    v_auth_json = get_template_auth('auth_json');

SET
    v_auth_row_metadata = get_template_auth('row_metadata');

/* ===================== Merge Customer JSON ===================== */
SET
    v_customer_json = JSON_SET(
        v_customer_json,
        '$.first_name',
        v_first_name,
        '$.last_name',
        v_last_name,
        '$.email',
        v_email,
        '$.phone',
        v_phone,
        '$.whatsapp_number',
        v_whatsapp_num,
        '$.user_name',
        v_user_name,
        '$.national_id',
        v_national_id,
        '$.customer_status',
        v_customer_status,
        '$.customer_type',
        v_customer_type,
        '$.residential_address.google_reference_number',
        JSON_EXTRACT(pjReqObj, '$.google_reference_number'),
        '$.residential_address.full_address',
        JSON_EXTRACT(pjReqObj, '$.full_address'),
        '$.residential_address.country',
        JSON_EXTRACT(pjReqObj, '$.country'),
        '$.residential_address.building_number',
        JSON_EXTRACT(pjReqObj, '$.building_number'),
        '$.residential_address.street_name',
        JSON_EXTRACT(pjReqObj, '$.street_name'),
        '$.residential_address.street_address_2',
        JSON_EXTRACT(pjReqObj, '$.street_address_2'),
        '$.residential_address.city',
        JSON_EXTRACT(pjReqObj, '$.city'),
        '$.residential_address.state',
        JSON_EXTRACT(pjReqObj, '$.state'),
        '$.residential_address.zip_code',
        JSON_EXTRACT(pjReqObj, '$.zip_code'),
        '$.residential_address.directions',
        JSON_EXTRACT(pjReqObj, '$.directions'),
        '$.residential_address.cross_street_1_name',
        JSON_EXTRACT(pjReqObj, '$.cross_street_1_name'),
        '$.residential_address.cross_street_2_name',
        JSON_EXTRACT(pjReqObj, '$.cross_street_2_name'),
        '$.residential_address.latitude',
        JSON_EXTRACT(pjReqObj, '$.latitude'),
        '$.residential_address.longitude',
        JSON_EXTRACT(pjReqObj, '$.longitude')
    );

/* Merge Customer row metadata */
SET
    v_customer_row_metadata = JSON_SET(
        v_customer_row_metadata,
        '$.status',
        v_customer_status,
        '$.created_at',
        NOW(),
        '$.created_by',
        'SYSTEM'
    );

/* ===================== Transaction ===================== */
START TRANSACTION;

-- Insert Customer with customer_rec_id in JSON
INSERT INTO
    customer
SET
    customer_status = v_customer_status,
    customer_type = v_customer_type,
    first_name = v_first_name,
    last_name = v_last_name,
    user_name = v_user_name,
    email = v_email,
    phone = v_phone,
    whatsapp_num = v_whatsapp_num,
    national_id = v_national_id,
    customer_json = JSON_SET(
        v_customer_json,
        '$.customer_rec_id',
        LAST_INSERT_ID()
    ),
    row_metadata = v_customer_row_metadata;

SET
    v_customer_rec_id = LAST_INSERT_ID();

-- Update customer JSON with rec_id
SET
    v_customer_json = JSON_SET(
        v_customer_json,
        '$.customer_rec_id',
        v_customer_rec_id
    );

UPDATE
    customer
SET
    customer_json = v_customer_json
WHERE
    customer_rec_id = v_customer_rec_id;

/* ===================== Merge Auth JSON ===================== */
SET
    v_password_hashed = SHA2(v_password_plain, 256);

SET
    v_auth_json = JSON_SET(
        v_auth_json,
        '$.parent_table_name',
        'customer',
        '$.parent_table_rec_id',
        v_customer_rec_id,
        '$.user_name',
        v_user_name,
        '$.login_credentials.password',
        v_password_hashed,
        '$.password_history[0].password',
        v_password_hashed
    );

/* Merge Auth row metadata */
SET
    v_auth_row_metadata = JSON_SET(
        v_auth_row_metadata,
        '$.status',
        v_customer_status,
        '$.created_at',
        NOW(),
        '$.created_by',
        'SYSTEM'
    );

-- Insert Auth record
INSERT INTO
    auth
SET
    parent_table_name = 'customer',
    parent_table_rec_id = v_customer_rec_id,
    user_name = v_user_name,
    auth_json = v_auth_json,
    row_metadata = v_auth_row_metadata;

SET
    v_auth_rec_id = LAST_INSERT_ID();

SET
    v_auth_json = JSON_SET(v_auth_json, '$.auth_rec_id', v_auth_rec_id);

UPDATE
    auth
SET
    auth_json = v_auth_json
WHERE
    auth_rec_id = v_auth_rec_id;

COMMIT;

SET
    psResult = 'Your account has been successfully created. To continue, please complete the verification steps below.';

END main_block;

END $ $ DELIMITER;