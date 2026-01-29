DROP FUNCTION IF EXISTS get_template_auth;
DELIMITER $$
CREATE FUNCTION get_template_auth(
    p_column_type ENUM('auth_json', 'row_metadata')
)
RETURNS JSON
DETERMINISTIC
BEGIN

    IF p_column_type IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Parameter p_column_type must be provided: auth_json or row_metadata';
    END IF;

    IF p_column_type = 'auth_json' THEN
        RETURN CAST(
        '{
            "auth_rec_id" :                 null,
            "parent_table_name" :           null,
            "parent_table_rec_id" :         null,
            "user_name" :                   null,

            "latest_otp" : {
                "latest_otp_code" :         null,
                "latest_otp_sent_at" :      null,
                "latest_otp_expires_at" :   null,
                "otp_retries" :             null,
                "next_otp_in" :             null
            },

            "user_mfa" : {
                "is_MFA" :                  null,
                "MFA_method" :              null,
                "MFA_method_value" :        null
            },

            "login_attempts" : [
                {
                    "last_login_date" :     null,
                    "login_attempts_count" :null,
                    "login_attempt_minutes":null
                }
            ],

            "current_session" : {
                "latitude" :                null,
                "device_id" :               null,
                "longitude" :               null,
                "ip_address" :              null,
                "last_login_at" :           null,
                "session_status" :          null,
                "user_auth_token" :         null,
                "user_session_id" :         null,
                "last_login_device" :       null,
                "last_login_method" :       null,
                "session_expires_at" :      null
            },

            "password_history" : [
                {
                    "is_active" :               null,
                    "password" :                null,
                    "password_set_at" :         null,
                    "password_changed_by" :    null,
                    "password_change_reason" : null,
                    "last_password_updated_at":null,
                    "password_expiration_date":null
                }
            ],

            "login_credentials" : {
                "pin" :                        null,
                "password" :                   null,
                "username" :                   null,
                "alternate_username" :         null,
                "is_force_password_change" :   null,

                "password_policy" : {
                    "min_length" :              null,
                    "max_length" :              null,
                    "require_uppercase" :       null,
                    "require_lowercase" :       null,
                    "require_number" :          null,
                    "require_special_char" :    null,
                    "password_expiry_days" :    null,
                    "password_history_limit" :  null,
                    "lockout_attempts" :        null,
                    "lockout_duration_minutes":null,
                    "allow_reuse" :             null,
                    "password_strength_level" : null
                }
            },

            "security_questions" : [
                {
                    "auth_security_question" : null,
                    "auth_security_answer" :   null
                }
            ]
        }' AS JSON);
    END IF;

    IF p_column_type = 'row_metadata' THEN
        RETURN CAST(
        '{
            "status" :      null,
            "created_at" :  null,
            "created_by" :  null,
            "updated_at" :  null,
            "updated_by" :  null
        }' AS JSON);
    END IF;

    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid p_column_type parameter. Must be auth_json or row_metadata';

END$$ 
DELIMITER ;