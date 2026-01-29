DROP FUNCTION IF EXISTS get_template_corporate;

DELIMITER $$
CREATE FUNCTION get_template_corporate(
    p_column_type ENUM('corporate_account_json', 'row_metadata')
)
RETURNS JSON
DETERMINISTIC
BEGIN

    IF p_column_type IS NULL 	THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Parameter p_column_type must be provided: corporate_account_json or row_metadata';
	END IF;

    IF p_column_type = 'corporate_account_json'
    THEN
    RETURN CAST(
    '
    {
        "corporate_account_rec_id" : null,
        "main_account_num"         : null,
        "main_account_title"       : null,
        "account_status"           : null,

        "status_change_history" : [
            {
                "changed_at" : null,
                "new_status" : null,
                "notes"      : null
            },
            {
                "changed_at" : null,
                "new_status" : null,
                "notes"      : null
            },
            {
                "changed_at" : null,
                "new_status" : null,
                "notes"      : null
            }
        ],

        "account_admin" : {
            "first_name"             : null,
            "last_name"              : null,
            "primary_email"          : null,
            "primary_phone"          : null,
            "primary_contact"        : null,
            "designation_of_contact" : null
        },

        "company" : {
            "company_name"                  : null,
            "company_email"                 : null,
            "company_phone"                 : null,
            "company_ntn_number"             : null,
            "company_date_of_incorporation"  : null,

            "owner_info" : {
                "owner_name"        : null,
                "owner_email"       : null,
                "owner_phone"       : null,
                "owner_national_id" : null
            },

            "company_address" : {
                "google_reference_number" : null,
                "full_address"            : null,
                "country"                 : null,
                "building_number"         : null,
                "street_name"             : null,
                "street_address_2"        : null,
                "city"                    : null,
                "state"                   : null,
                "zip_code"                : null,
                "directions"              : null,
                "cross_street_1_name"     : null,
                "cross_street_2_name"     : null,
                "latitude"                : null,
                "longitude"               : null
            }
        },

        "account_stats" : {
            "total_cash_wallet"   : null,
            "total_gold_wallet"   : null,
            "total_silver_wallet" : null,
            "total_orders"        : null,
            "total_assets"        : null,
            "open_tickets"        : null,
            "num_of_tickets"      : null,
            "num_of_employees"    : null,
            "year_to_date_orders" : null
        }
    }'
    AS JSON);
    END IF;
    
    IF p_column_type = 'row_metadata'
    THEN
	RETURN CAST(
        '
        {
            "status"     : null,
            "created_at" : null,
            "created_by" : null,
            "updated_at" : null,
            "updated_by" : null
        }'
        AS JSON);
    END IF;

	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Parameter p_column_type must be provided: corporate_account_json or row_metadata';
    
END $$
DELIMITER ;