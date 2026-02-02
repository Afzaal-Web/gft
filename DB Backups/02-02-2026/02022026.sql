-- MySQL dump 10.13  Distrib 8.4.6, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: gft
-- ------------------------------------------------------
-- Server version	8.4.6

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `asset_rate_history`
--

DROP TABLE IF EXISTS `asset_rate_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `asset_rate_history` (
  `asset_rate_rec_id` int NOT NULL AUTO_INCREMENT,
  `tradable_assets_rec_id` int DEFAULT NULL,
  `asset_code` varchar(10) DEFAULT NULL,
  `rate_timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `asset_rate_history_json` json DEFAULT NULL,
  `row_metadata` json DEFAULT NULL,
  PRIMARY KEY (`asset_rate_rec_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asset_rate_history`
--

LOCK TABLES `asset_rate_history` WRITE;
/*!40000 ALTER TABLE `asset_rate_history` DISABLE KEYS */;
INSERT INTO `asset_rate_history` VALUES (0,0,'XAU','2026-02-02 08:07:07','{\"spot_rate\": 4433.85, \"asset_code\": \"GLD\", \"source_info\": {\"source_url\": \"https://metals-api.com/\", \"rate_source\": \"metals-api\", \"market_status\": \"Open\", \"update_frequency\": \"Daily\", \"_comment_source_url\": \"Source URL\", \"_comment_rate_source\": \"API or source name\", \"_comment_market_status\": \"Market status\", \"_comment_update_frequency\": \"Frequency of updates\"}, \"valid_until\": \"2026-01-17\", \"weight_unit\": \"gram\", \"currency_unit\": \"USD\", \"effective_date\": \"2026-01-16\", \"rate_timestamp\": \"2026-01-16T06:00:00\", \"foreign_exchange\": {\"foreign_exchange_rate\": 278.5, \"foreign_exchange_source\": \"OpenExchange\", \"_comment_foreign_exchange_rate\": \"FX conversion rate\", \"_comment_foreign_exchange_source\": \"FX rate source\"}, \"asset_rate_rec_id\": 0, \"_comment_spot_rate\": \"Spot market rate\", \"_comment_valid_until\": \"Expiry date of this rate\", \"_comment_weight_unit\": \"Unit of weight for the rate\", \"_comment_currency_unit\": \"Currency of the rate\", \"_comment_internal_code\": \"Internal asset code\", \"tradable_assets_rec_id\": 0, \"_comment_effective_date\": \"Date when rate becomes effective\", \"_comment_rate_timestamp\": \"Timestamp when rate was recorded\", \"_comment_commodity_rec_id\": \"Primary key to tradeable asset\", \"_comment_commodity_rate_rec_id\": \"Auto-incremented asset_rate record ID\"}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}'),(1,1,'GLD','2026-02-02 08:07:49','{\"spot_rate\": 4433.85, \"asset_code\": \"GLD\", \"source_info\": {\"source_url\": \"https://metals-api.com/\", \"rate_source\": \"metals-api\", \"market_status\": \"Open\", \"update_frequency\": \"Daily\"}, \"valid_until\": \"2026-01-17\", \"weight_unit\": \"gram\", \"currency_unit\": \"USD\", \"effective_date\": \"2026-01-16\", \"rate_timestamp\": \"2026-01-16T06:00:00Z\", \"foreign_exchange\": {\"foreign_exchange_rate\": 278.5, \"foreign_exchange_source\": \"OpenExchange\"}, \"asset_rate_rec_id\": 1, \"tradable_assets_rec_id\": 1}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}'),(2,2,'SLV','2026-02-02 08:07:54','{\"spot_rate\": 55.32, \"asset_code\": \"SLV\", \"source_info\": {\"source_url\": \"https://metals-api.com/\", \"rate_source\": \"metals-api\", \"market_status\": \"Open\", \"update_frequency\": \"Daily\"}, \"valid_until\": \"2026-01-17\", \"weight_unit\": \"gram\", \"currency_unit\": \"USD\", \"effective_date\": \"2026-01-16\", \"rate_timestamp\": \"2026-01-16T06:00:00Z\", \"foreign_exchange\": {\"foreign_exchange_rate\": 278.5, \"foreign_exchange_source\": \"OpenExchange\"}, \"asset_rate_rec_id\": 2, \"tradable_assets_rec_id\": 2}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}'),(3,3,'PT','2026-02-02 08:07:59','{\"spot_rate\": 3100.45, \"asset_code\": \"PT\", \"source_info\": {\"source_url\": \"https://metals-api.com/\", \"rate_source\": \"metals-api\", \"market_status\": \"Open\", \"update_frequency\": \"Daily\"}, \"valid_until\": \"2026-01-17\", \"weight_unit\": \"gram\", \"currency_unit\": \"USD\", \"effective_date\": \"2026-01-16\", \"rate_timestamp\": \"2026-01-16T06:00:00Z\", \"foreign_exchange\": {\"foreign_exchange_rate\": 278.5, \"foreign_exchange_source\": \"OpenExchange\"}, \"asset_rate_rec_id\": 3, \"tradable_assets_rec_id\": 3}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}'),(4,4,'USD','2026-02-02 08:08:07','{\"spot_rate\": 1.0, \"asset_code\": \"USD\", \"source_info\": {\"source_url\": \"https://forex-api.com/\", \"rate_source\": \"forex-api\", \"market_status\": \"Open\", \"update_frequency\": \"Daily\"}, \"valid_until\": \"2026-01-17\", \"weight_unit\": \"USD\", \"currency_unit\": \"USD\", \"effective_date\": \"2026-01-16\", \"rate_timestamp\": \"2026-01-16T06:00:00Z\", \"foreign_exchange\": {\"foreign_exchange_rate\": 1.0, \"foreign_exchange_source\": \"OpenExchange\"}, \"asset_rate_rec_id\": 4, \"tradable_assets_rec_id\": 4}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}');
/*!40000 ALTER TABLE `asset_rate_history` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_update_asset_rate_history` AFTER UPDATE ON `asset_rate_history` FOR EACH ROW BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'asset_rate_history',
		  row_rec_id		= OLD.asset_rate_rec_id,
		  prev_row_json		= OLD.asset_rate_history_json,
		  next_row_json		= NEW.asset_rate_history_json,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_delete_asset_rate_history` AFTER DELETE ON `asset_rate_history` FOR EACH ROW BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'asset_rate_history',
		  row_rec_id		= OLD.asset_rate_rec_id,
		  prev_row_json		= OLD.asset_rate_history_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `auth`
--

DROP TABLE IF EXISTS `auth`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth` (
  `auth_rec_id` int NOT NULL AUTO_INCREMENT,
  `parent_table_name` varchar(50) DEFAULT NULL,
  `parent_table_rec_id` int DEFAULT NULL,
  `user_name` varchar(50) DEFAULT NULL,
  `auth_json` json DEFAULT NULL,
  `row_metadata` json DEFAULT NULL,
  PRIMARY KEY (`auth_rec_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth`
--

LOCK TABLES `auth` WRITE;
/*!40000 ALTER TABLE `auth` DISABLE KEYS */;
INSERT INTO `auth` VALUES (0,'CUSTOMER',0,'jhon@gmail.com','{\"user_mfa\": {\"is_MFA\": true, \"MFA_method\": \"SMS\", \"_comment_is_2FA\": \"Whether 2FA is enabled\", \"MFA_method_value\": \"+1234567890\", \"_comment_2FA_method\": \"Method used for 2FA: SMS, Email, Authenticator app, etc.\", \"_comment_2FA_method_value\": \"Value used for 2FA (phone, email, app secret)\"}, \"user_name\": \"john@gmail.com\", \"latest_otp\": {\"next_otp_in\": 60, \"otp_retries\": 0, \"latest_otp_code\": \"123456\", \"latest_otp_sent_at\": \"NOW()\", \"_comment_next_otp_in\": \"Seconds before user can request next OTP\", \"_comment_otp_retries\": \"Number of OTP retry attempts\", \"latest_otp_expires_at\": \"DATE_ADD(NOW(), INTERVAL 5 MINUTE)\", \"_comment_latest_otp_code\": \"Most recent OTP sent to user\", \"_comment_latest_otp_sent_at\": \"Timestamp when OTP was sent\", \"_comment_latest_otp_expires_at\": \"Timestamp when OTP expires\"}, \"auth_rec_id\": 0, \"login_attempts\": [{\"last_login_date\": \"NOW()\", \"login_attempts_count\": 1, \"login_attempt_minutes\": 0, \"_comment_last_login_date\": \"Last login date of user\", \"_comment_login_attempts_count\": \"Number of login attempts\", \"_comment_login_attempt_minutes\": \"Minutes since last login attempt\"}, {\"last_login_date\": \"2026-08-01 09:00\", \"login_attempts_count\": 3, \"login_attempt_minutes\": 30, \"_comment_last_login_date\": \"Last login date of user\", \"_comment_login_attempts_count\": \"Number of login attempts\", \"_comment_login_attempt_minutes\": \"Minutes since last login attempt\"}], \"current_session\": {\"latitude\": 24.8607, \"device_id\": \"device-001\", \"longitude\": 67.0011, \"ip_address\": \"192.168.1.1\", \"last_login_at\": \"NOW(3)\", \"session_status\": \"ACTIVE\", \"user_auth-token\": \"abc123xyz456\", \"user_session_id\": \"session-001\", \"_comment_latitude\": \"Latitude of current session login\", \"last_login_device\": \"iPhone 14\", \"last_login_method\": \"Password + 2FA\", \"_comment_device_id\": \"Device identifier of current session\", \"_comment_longitude\": \"Longitude of current session login\", \"session_expires_at\": \"DATE_ADD(NOW(3), INTERVAL 1 HOUR)\", \"_comment_ip_address\": \"IP address of current session\", \"_comment_last_login_at\": \"Timestamp of last login in this session\", \"_comment_session_status\": \"Current session status: ACTIVE, EXPIRED, LOGGED_OUT\", \"_comment_user_auth_token\": \"Authentication token for current session\", \"_comment_user_session_id\": \"Unique session ID\", \"_comment_last_login_device\": \"Device used in last login\", \"_comment_last_login_method\": \"Method used for last login\", \"_comment_session_expires_at\": \"Expiration timestamp for current session\"}, \"login_credentials\": {\"pin\": \"1234\", \"password\": \"StrongP@ssword1\", \"username\": \"johndoe\", \"_comment_pin\": \"Optional PIN for login\", \"password_policy\": {\"max_length\": 64, \"min_length\": 8, \"allow_reuse\": false, \"require_number\": true, \"lockout_attempts\": 5, \"require_lowercase\": true, \"require_uppercase\": true, \"_comment_max_length\": \"Maximum password length\", \"_comment_min_length\": \"Minimum password length\", \"_comment_allow_reuse\": \"Whether old passwords can be reused\", \"password_expiry_days\": 90, \"require_special_char\": true, \"password_history_limit\": 5, \"_comment_require_number\": \"Password must contain numeric digit\", \"password_strength_level\": \"STRONG\", \"lockout_duration_minutes\": 30, \"_comment_lockout_attempts\": \"Failed login attempts before lockout\", \"_comment_require_lowercase\": \"Password must contain lowercase letter\", \"_comment_require_uppercase\": \"Password must contain uppercase letter\", \"_comment_password_expiry_days\": \"Number of days before password expires\", \"_comment_require_special_char\": \"Password must contain special character\", \"_comment_password_history_limit\": \"Number of previous passwords disallowed\", \"_comment_password_strength_level\": \"Password strength classification\", \"_comment_lockout_duration_minutes\": \"Account lockout duration in minutes\"}, \"_comment_password\": \"User\'s login password (hashed in database)\", \"_comment_username\": \"Primary username for login\", \"alternate_username\": \"john.doe\", \"is_force_password_change\": false, \"_comment_alternate_username\": \"Alternate username for login\", \"_comment_is_force_password_change\": \"Whether user must change password at next login\"}, \"parent_table_name\": \"customers\", \"_comment_user_name\": \"Primary username or email for login\", \"security_questions\": [{\"auth_security_answer\": \"Khan\", \"auth_security_question\": \"What is your mother\'s maiden name?\", \"_comment_auth_security_answer\": \"Answer to security question (hashed in DB)\", \"_comment_auth_security_question\": \"User selected security question\"}, {\"auth_security_answer\": \"Khan\", \"auth_security_question\": \"What is your mother\'s maiden name?\", \"_comment_auth_security_answer\": \"Answer to security question (hashed in DB)\", \"_comment_auth_security_question\": \"User selected security question\"}], \"parent_table_rec_id\": 0, \"_comment_auth_rec_id\": \"Auto-incremented unique auth ID\", \"_comment_parent_table_name\": \"The parent table this auth belongs to, e.g., customers or employees\", \"_comment_parent_table_rec_id\": \"The corresponding record ID in the parent table\"}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}');
/*!40000 ALTER TABLE `auth` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_update_auth` AFTER UPDATE ON `auth` FOR EACH ROW BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'auth',
		  row_rec_id		= OLD.auth_rec_id,
		  prev_row_json		= OLD.auth_json,
		  next_row_json		= NEW.auth_json,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_delete_auth` AFTER DELETE ON `auth` FOR EACH ROW BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'auth',
		  row_rec_id		= OLD.auth_rec_id,
		  prev_row_json		= OLD.auth_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `corporate_account`
--

DROP TABLE IF EXISTS `corporate_account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `corporate_account` (
  `corporate_account_rec_id` int NOT NULL AUTO_INCREMENT,
  `main_account_num` varchar(15) DEFAULT NULL,
  `main_account_title` varchar(50) DEFAULT NULL,
  `account_status` enum('registration req','active','inactive','blocked') NOT NULL,
  `corporate_account_json` json DEFAULT NULL,
  `row_metadata` json DEFAULT NULL,
  PRIMARY KEY (`corporate_account_rec_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `corporate_account`
--

LOCK TABLES `corporate_account` WRITE;
/*!40000 ALTER TABLE `corporate_account` DISABLE KEYS */;
INSERT INTO `corporate_account` VALUES (0,'000',NULL,'inactive','{\"company\": {\"owner_info\": {\"owner_name\": \"Ahmed Khan\", \"owner_email\": \"ahmed.khan@abctraders.com\", \"owner_phone\": \"+92-300-1112233\", \"owner_national_id\": \"35202-3344565-1\", \"_comment_owner_name\": \"Name of company owner\", \"_comment_national_id\": \"CNIC number of company owner\", \"_comment_owner_email\": \"Email of company owner\", \"_comment_owner_phone\": \"Phone number of company owner\"}, \"company_name\": \"AZS Traders Pvt Ltd\", \"company_email\": \"info@abctraders.com\", \"company_phone\": \"+92-300-1234567\", \"company_address\": {\"city\": \"New York\", \"state\": \"New York\", \"country\": \"USA\", \"latitude\": \"40.7128\", \"zip_code\": \"10001\", \"longitude\": \"-74.006\", \"directions\": \"Near Central Park\", \"street_name\": \"Main St\", \"full_address\": \"123 Main St, Apt 4B, New York, USA\", \"_comment_city\": \"City name\", \"_comment_state\": \"State or province\", \"building_number\": \"123\", \"_comment_country\": \"Country name\", \"street_address_2\": \"Apt 4B\", \"_comment_latitude\": \"Latitude coordinate\", \"_comment_zip_code\": \"Postal/zip code\", \"_comment_longitude\": \"Longitude coordinate\", \"_comment_directions\": \"Additional directions to the address\", \"cross_street_1_name\": \"2nd Ave\", \"cross_street_2_name\": \"3rd Ave\", \"_comment_street_name\": \"Street name\", \"_comment_full_address\": \"Complete full address\", \"google_reference_number\": \"ChIJ1234567890\", \"_comment_building_number\": \"Building number or identifier\", \"_comment_street_address_2\": \"Secondary street info or apartment number\", \"_comment_cross_street_1_name\": \"Nearby cross street 1\", \"_comment_cross_street_2_name\": \"Nearby cross street 2\", \"_comment_google_reference_number\": \"Google Maps reference ID\"}, \"company_ntn_number\": \"1234567-8\", \"_comment_company_name\": \"Full registered name of the company\", \"_comment_company_email\": \"Official email of the company\", \"_comment_company_phone\": \"Official phone of the company\", \"_comment_company_ntn_number\": \"National Tax Number of company\", \"company_date_of_incorporation\": \"2018-06-15\", \"_comment_company_date_of_incorporation\": \"Date company was incorporated\"}, \"account_admin\": {\"last_name\": \"Raza\", \"first_name\": \"Ali\", \"primary_email\": \"ali.raza@abctraders.com\", \"primary_phone\": \"+92-300-2223344\", \"primary_contact\": \"Ali Raza\", \"_comment_last_name\": \"Last name of primary contact\", \"_comment_first_name\": \"First name of primary contact\", \"_comment_primary_email\": \"Primary contact email\", \"_comment_primary_phone\": \"Primary contact phone\", \"designation_of_contact\": \"Finance Manager\", \"_comment_primary_contact\": \"Primary contact person name\", \"_comment_designation_of_contact\": \"Designation/title of primary contact\", \"_comment_create_customer_record_with_account_admin_info\": \"create customer record with this account_admin_info as well\"}, \"account_stats\": {\"open_tickets\": 2, \"total_assets\": 85000000, \"total_orders\": 1340, \"num_of_tickets\": 18, \"num_of_employees\": 25, \"total Cash Wallet\": \"PKR 5000.00\", \"total Gold Wallet\": \"230.4567 grams\", \"totla Silver Wallet\": \"1500.7890 grams\", \"year_to_date_orders\": 215, \"_comment_open_tickets\": \"Number of open support tickets\", \"_comment_total_assets\": \"Total assets of the company\", \"_comment_total_orders\": \"Total orders placed by the company\", \"_comment_num_of_tickets\": \"Total number of support tickets\", \"_comment_num_of_employees\": \"Total employees in company\", \"_comment_total_cash_wallet\": \"Total cash balance in wallet\", \"_comment_total_gold_wallet\": \"Total gold holdings in grams\", \"_comment_total_silver_wallet\": \"Total silver holdings in grams\", \"_comment_year_to_date_orders\": \"Orders placed this year\"}, \"account_status\": \"inactive\", \"main_account_num\": \"000\", \"main_account_title\": \"azs\", \"status_change_history\": [{\"notes\": \"Account is opened by the customer\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"SUBMITTED\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}, {\"notes\": \"Approved by Afzaal\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"APPROVED\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}, {\"notes\": \"Approved by Afzaal\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"OPEN\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}, {\"notes\": \"by Afzaal\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"SUSPENDED\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}, {\"notes\": \"REOPEND by Afzaal\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"OPEN\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}, {\"notes\": \"REOPEND by Afzaal\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"CLOSED\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}], \"_comment_account_status\": \"Current status: registration req, active, inactive, blocked, etc.\", \"corporate_account_rec_id\": 0, \"_comment_main_account_num\": \"Unique corporate account number\", \"_comment_main_account_title\": \"Corporate main account title\", \"_comment_corporate_account_rec_id\": \"Auto-incremented unique corporate account ID\"}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}');
/*!40000 ALTER TABLE `corporate_account` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_update_corporate_account` AFTER UPDATE ON `corporate_account` FOR EACH ROW BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'corporate_account',
		  row_rec_id		= OLD.corporate_account_rec_id,
		  prev_row_json		= OLD.corporate_account_json,
		  next_row_json		= NEW.corporate_account_json,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_delete_corporate_account` AFTER DELETE ON `corporate_account` FOR EACH ROW BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'corporate_account',
		  row_rec_id		= OLD.corporate_account_rec_id,
		  prev_row_json		= OLD.corporate_account_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `customer_rec_id` int NOT NULL AUTO_INCREMENT,
  `customer_status` enum('active','inactive','registration_request','suspended') DEFAULT NULL,
  `customer_type` enum('personal','corporate') DEFAULT NULL,
  `corporate_account_rec_id` int DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `user_name` varchar(100) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `whatsapp_num` varchar(20) DEFAULT NULL,
  `national_id` varchar(50) DEFAULT NULL,
  `main_account_num` varchar(50) DEFAULT NULL,
  `account_num` varchar(50) DEFAULT NULL,
  `customer_json` json DEFAULT NULL,
  `row_metadata` json DEFAULT NULL,
  PRIMARY KEY (`customer_rec_id`),
  UNIQUE KEY `national_id` (`national_id`),
  UNIQUE KEY `account_num_combination` (`main_account_num`,`account_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES (0,'active','corporate',1,'John','Doe','john.doe123','johndoe@gmail.com','+92301-1232123','+92301-3212342','331013434343433','AZS-001','001','{\"email\": \"john.doe@example.com\", \"phone\": \"+1234567890\", \"documents\": [{\"is_verified\": true, \"uploaded_at\": \"2026-11-10 09:15\", \"verified_at\": \"2026-11-11 10:41\", \"verified_by\": \"Afzaal\", \"document_name\": \"CNIC\", \"document_rec_id\": 1, \"_comment_is_verified\": \"Boolean: whether document is verified\", \"_comment_uploaded_at\": \"Timestamp when document was uploaded\", \"_comment_verified_at\": \"Timestamp when document was verified\", \"_comment_verified_by\": \"User who verified the document\", \"_comment_document_name\": \"Name or type of document\", \"_comment_document_rec_id\": \"Auto-incremented unique document record ID\"}, {\"is_verified\": false, \"uploaded_at\": \"2026-11-10 11:00\", \"verified_at\": null, \"verified_by\": null, \"document_name\": \"Bank Statement\", \"document_rec_id\": 2, \"_comment_is_verified\": \"Boolean: whether document is verified\", \"_comment_uploaded_at\": \"Timestamp when document was uploaded\", \"_comment_verified_at\": \"Timestamp when document was verified\", \"_comment_verified_by\": \"User who verified the document\", \"_comment_document_name\": \"Name or type of document\", \"_comment_document_rec_id\": \"Auto-incremented unique document record ID\"}], \"last_name\": \"Doe\", \"user_name\": \"johndoe123\", \"first_name\": \"John\", \"is_verified\": true, \"national_id\": \"331013434343433\", \"permissions\": {\"is_buy_allowed\": true, \"is_sell_allowed\": true, \"is_redeem_allowed\": false, \"is_add_funds_allowed\": true, \"is_withdrawl_allowed\": true, \"_comment_is_buy_allowed\": \"Boolean: whether buying is allowed\", \"_comment_is_sell_allowed\": \"Boolean: whether selling is allowed\", \"_comment_is_redeem_allowed\": \"Boolean: whether redeeming is allowed\", \"_comment_is_add_funds_allowed\": \"Boolean: whether adding funds is allowed\", \"_comment_is_withdrawl_allowed\": \"Boolean: whether withdrawing is allowed\"}, \"customer_type\": \"CORPORATE\", \"_comment_email\": \"Primary email of the customer\", \"_comment_phone\": \"Primary phone number\", \"account_number\": \"002\", \"app_preferences\": {\"time_zone\": \"America/New_York\", \"_comment_time_zone\": \"Preferred time zone\", \"is_face_id_enabled\": true, \"preferred_currency\": \"USD\", \"preferred_language\": \"en\", \"auto_logout_minutes\": 15, \"remember_me_enabled\": true, \"default_home_location\": \"New York\", \"is_fingerprint_enabled\": true, \"biometric_login_enabled\": true, \"push_notifications_enabled\": true, \"transaction_alerts_enabled\": true, \"_comment_is_face_id_enabled\": \"Whether Face ID is enabled\", \"_comment_preferred_currency\": \"Preferred currency\", \"_comment_preferred_language\": \"Preferred language\", \"email_notifications_enabled\": true, \"_comment_auto_logout_minutes\": \"Minutes before automatic logout\", \"_comment_remember_me_enabled\": \"Boolean: remember me enabled\", \"_comment_default_home_location\": \"Default home location in app\", \"_comment_is_fingerprint_enabled\": \"Whether fingerprint login is enabled\", \"_comment_biometric_login_enabled\": \"Boolean: biometric login enabled\", \"_comment_push_notifications_enabled\": \"Boolean: push notifications enabled\", \"_comment_transaction_alerts_enabled\": \"Boolean: transaction alerts enabled\", \"_comment_email_notifications_enabled\": \"Boolean: email notifications enabled\"}, \"cus_profile_pic\": \"https://example.com/profile_pic.jpg\", \"customer_rec_id\": 0, \"customer_status\": \"ACTIVE\", \"whatsapp_number\": \"+1234567890\", \"_comment_last_name\": \"Customer\'s last name\", \"_comment_user_name\": \"Unique username for login\", \"_comment_first_name\": \"Customer\'s first name\", \"additional_contacts\": [{\"Additional_email_1\": \"j.doe.secondary@example.com\", \"Additional_phone_1\": \"+1234567891\", \"_comment_Additional_email_1\": \"Secondary email for the customer\", \"_comment_Additional_phone_1\": \"Emergency contact phone number\"}, {\"Additional_email_2\": \"j.doe.secondary@example.com\", \"Additional_phone_2\": \"+1234567891\", \"_comment_Additional_email_2\": \"Secondary email for the customer\", \"_comment_Additional_phone_2\": \"Emergency contact phone number\"}], \"main_account_number\": \"AZS-001\", \"residential_address\": {\"city\": \"New York\", \"state\": \"New York\", \"country\": \"USA\", \"latitude\": \"40.7128\", \"zip_code\": \"10001\", \"longitude\": \"-74.006\", \"directions\": \"Near Central Park\", \"street_name\": \"Main St\", \"full_address\": \"123 Main St, Apt 4B, New York, USA\", \"_comment_city\": \"City name\", \"_comment_state\": \"State or province\", \"building_number\": \"123\", \"_comment_country\": \"Country name\", \"street_address_2\": \"Apt 4B\", \"_comment_latitude\": \"Latitude coordinate\", \"_comment_zip_code\": \"Postal/zip code\", \"_comment_longitude\": \"Longitude coordinate\", \"_comment_directions\": \"Additional directions to the address\", \"cross_street_1_name\": \"2nd Ave\", \"cross_street_2_name\": \"3rd Ave\", \"_comment_street_name\": \"Street name\", \"_comment_full_address\": \"Complete full address\", \"google_reference_number\": \"ChIJ1234567890\", \"_comment_building_number\": \"Building number or identifier\", \"_comment_street_address_2\": \"Secondary street info or apartment number\", \"_comment_cross_street_1_name\": \"Nearby cross street 1\", \"_comment_cross_street_2_name\": \"Nearby cross street 2\", \"_comment_google_reference_number\": \"Google Maps reference ID\"}, \"_comment_is_verified\": \"Boolean: whether the customer is verified\", \"_comment_national_id\": \"Government-issued national ID\", \"status_change_history\": [{\"notes\": \"Account is opened by the customer\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"SUBMITTED\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}, {\"notes\": \"Approved by Afzaal\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"APPROVED\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}, {\"notes\": \"Approved by Afzaal\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"OPEN\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}, {\"notes\": \"by Afzaal\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"SUSPENDED\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}, {\"notes\": \"REOPEND by Afzaal\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"OPEN\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}, {\"notes\": \"REOPEND by Afzaal\", \"changed_at\": \"2026-11-11 10:41\", \"new_status\": \"CLOSED\", \"_comment_notes\": \"Remarks related to status change\", \"_comment_changed_at\": \"Timestamp when status was changed\", \"_comment_new_status\": \"New status after change\"}], \"_comment_customer_type\": \"PERSONAL or CORPORATE\", \"_comment_account_number\": \"account number for the customer\", \"_comment_cus_profile_pic\": \"URL to profile picture\", \"_comment_customer_rec_id\": \"Auto-incremented unique customer ID\", \"_comment_customer_status\": \"Possible values: Active, Pending, Suspended, etc.\", \"_comment_whatsapp_number\": \"WhatsApp contact number\", \"corporate_account_rec_id\": 1, \"_comment_main_account_number\": \"Main account number for the customer\", \"_comment_corporate_account_rec_id\": \"References corporate_accounts table if customer_type is CORPORATE\"}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_update_customer` AFTER UPDATE ON `customer` FOR EACH ROW BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'customer',
		  row_rec_id		= OLD.customer_rec_id,
		  prev_row_json		= OLD.customer_json,
		  next_row_json		= NEW.customer_json,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_delete_customer` AFTER DELETE ON `customer` FOR EACH ROW BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'customer',
		  row_rec_id		= OLD.customer_rec_id,
		  prev_row_json		= OLD.customer_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `inventory_rec_id` int NOT NULL AUTO_INCREMENT,
  `product_rec_id` int DEFAULT NULL,
  `item_name` varchar(255) DEFAULT NULL,
  `item_type` varchar(255) DEFAULT NULL,
  `asset_type` varchar(255) DEFAULT NULL,
  `availability_status` varchar(255) DEFAULT NULL,
  `inventory_json` json DEFAULT NULL,
  `row_metadata` json DEFAULT NULL,
  PRIMARY KEY (`inventory_rec_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (0,0,'Gold Bar - 1000g','Bar','Gold','Available','{\"sold_to\": [{\"taxes\": 1.2, \"sold_date\": \"2025-11-02\", \"metal_rate\": 65.0, \"order_date\": \"2025-11-01\", \"sold_to_id\": 501, \"weight_sold\": 2.5, \"order_number\": \"ORD-1001\", \"sold_to_name\": \"Ali Khan\", \"sold_to_email\": \"ali@email.com\", \"sold_to_phone\": \"+923001112233\", \"_comment_taxes\": \"Taxes charged\", \"making_charges\": 2.0, \"receipt_number\": \"SR-1001\", \"premium_charged\": 5.0, \"sold_to_address\": \"Karachi\", \"taxes_description\": \"Sales tax\", \"_comment_sold_date\": \"Sold date\", \"_comment_metal_rate\": \"Metal rate at sale\", \"_comment_order_date\": \"Order date\", \"_comment_sold_to_id\": \"Customer ID\", \"total_price_charged\": 180.0, \"transaction_details\": {\"fee_type\": \"percentage\", \"fee_value\": 1.5, \"fee_currency\": \"USD\", \"fee_description\": \"Platform transaction charges\", \"transaction_num\": \"TXN-555666\", \"_comment_fee_type\": \"Fee type (percentage/fixed)\", \"_comment_fee_value\": \"Transaction fee value\", \"transaction_status\": \"Completed\", \"_comment_fee_currency\": \"Currency for fixed fee\", \"_comment_fee_description\": \"Fee explanation\", \"_comment_transaction_num\": \"Unique transaction number\", \"_comment_transaction_status\": \"Transaction status\"}, \"_comment_weight_sold\": \"Weight sold\", \"_comment_order_number\": \"Order number\", \"_comment_sold_to_name\": \"Customer name\", \"_comment_sold_to_email\": \"Customer email\", \"_comment_sold_to_phone\": \"Customer phone\", \"_comment_making_charges\": \"Making charges\", \"_comment_receipt_number\": \"Sales receipt number\", \"_comment_premium_charged\": \"Premium charged\", \"_comment_sold_to_address\": \"Customer address\", \"_comment_taxes_description\": \"Tax description\", \"_comment_total_price_charged\": \"Total charged amount\"}], \"item_Size\": \"2 inches\", \"item_name\": \"Gold Bar - 1000g\", \"item_type\": \"Bar\", \"asset_type\": \"Gold\", \"net_weight\": 1000.0, \"item_quality\": \"24K\", \"_comment_Size\": \"like ring size\", \"media_library\": [{\"media_url\": \"/media/inventory/item1.png\", \"media_type\": \"image\", \"is_featured\": true, \"_comment_media_url\": \"Media file URL\", \"_comment_media_type\": \"Media type\", \"_comment_is_featured\": \"Primary media flag\"}], \"purchase_from\": {\"from_name\": \"ABC Bullion Ltd\", \"packaging\": \"Sealed\", \"from_email\": \"sales@abc.com\", \"from_phone\": \"+971000000\", \"metal_rate\": 63.5, \"from_address\": \"Dubai, UAE\", \"metal_weight\": 10.0, \"premium_paid\": 10.0, \"receipt_date\": \"2025-10-05\", \"purchase_date\": \"2025-10-05\", \"making_charges\": 5.0, \"receipt_number\": \"RCPT-8899\", \"total_tax_paid\": 3.5, \"mode_of_payment\": \"Bank Transfer\", \"tax_description\": \"Import tax\", \"total_price_paid\": 650.0, \"_comment_from_name\": \"Supplier name\", \"_comment_packaging\": \"Packaging details\", \"_comment_from_email\": \"Supplier email\", \"_comment_from_phone\": \"Supplier phone\", \"_comment_metal_rate\": \"Metal rate at purchase\", \"purchase_from_rec_id\": 22, \"_comment_from_address\": \"Supplier address\", \"_comment_metal_weight\": \"Metal weight purchased\", \"_comment_premium_paid\": \"Premium paid\", \"_comment_receipt_date\": \"Receipt date\", \"_comment_purchase_date\": \"Purchase date\", \"_comment_making_charges\": \"Making charges\", \"_comment_receipt_number\": \"Purchase receipt number\", \"_comment_total_tax_paid\": \"Total tax paid\", \"check_or_transaction_no\": \"TXN-778899\", \"_comment_mode_of_payment\": \"Payment method\", \"_comment_tax_description\": \"Tax description\", \"_comment_total_price_paid\": \"Total amount paid\", \"_comment_purchase_from_rec_id\": \"Supplier record ID\", \"_comment_check_or_transaction_no\": \"Payment reference\"}, \"product_rec_id\": 0, \"available_weight\": 330.0, \"inventory_rec_id\": 0, \"location_details\": \"dollman \", \"manufacturer_info\": {\"dimensions\": \"120mm x 55mm x 9mm\", \"serial_number\": \"VAL-1000G-001\", \"manufacturer_name\": \"Valcambi\", \"manufacturing_date\": \"2025-01-10\", \"_comment_dimensions\": \"Physical dimensions\", \"manufacturing_country\": \"Switzerland\", \"_comment_serial_number\": \"Unique serial number\", \"serial_verification_url\": \"https://verify.valcambi.com/VAL-1000G-001\", \"serial_verification_text\": \"Verified\", \"_comment_manufacturer_name\": \"Manufacturer name\", \"_comment_manufacturing_date\": \"Manufacturing date\", \"_comment_manufacturing_country\": \"Country of manufacture\", \"_comment_serial_verification_url\": \"Verification URL\", \"_comment_serial_verification_text\": \"Verification status\"}, \"ownership_metrics\": {\"weight_sold_so_far\": 770.0, \"_comment_weight_sold\": \"Total weight sold already\", \"number_of_shareholders\": 3, \"number_of_transactions\": 12, \"_comment_number_of_shareholders\": \"Total shareholders\", \"_comment_number_of_transactions\": \"Total transactions count\"}, \"weight_adjustment\": 0.5, \"_comment_item_name\": \"Inventory item name\", \"_comment_item_type\": \"Inventory item type like: Bar,Gold Ring, Bracelet, Locket, Jwellery etc\", \"_comment_asset_type\": \"Type of asset like Gold, silver , etc\", \"_comment_net_weight\": \"Net usable weight\", \"availability_status\": \"Available\", \"pricing_adjustments\": {\"Discount\": 0.5, \"Promotions\": \"Ramadan Offer\", \"_comment_Discount\": \"Discount percentage\", \"_comment_Promotions\": \"Active promotion details\", \"item_margin_adjustment\": 1.2, \"_comment_item_margin_adjustment\": \"Margin adjustment percentage\"}, \"_comment_item_quality\": \"Quality of the item\", \"_comment_product_rec_id\": \"Linked product record ID\", \"_comment_available_weight\": \"Remaining available weight\", \"_comment_inventory_rec_id\": \"Auto-increment inventory record ID\", \"_comment_location_details\": \"Physical storage location details\", \"_comment_weight_adjustment\": \"Weight adjustment applied\", \"_comment_availability_status\": \"Current availability status like: Available,Sold, redeemed, Slice Bought\"}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_update_inventory` AFTER UPDATE ON `inventory` FOR EACH ROW BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'inventory',
		  row_rec_id		= OLD.inventory_rec_id,
		  prev_row_json		= OLD.inventory_json,
		  next_row_json		= NEW.inventory_json,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_delete_inventory` AFTER DELETE ON `inventory` FOR EACH ROW BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'inventory',
		  row_rec_id		= OLD.inventory_rec_id,
		  prev_row_json		= OLD.inventory_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `password_history`
--

DROP TABLE IF EXISTS `password_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_history` (
  `password_history_rec_id` int NOT NULL AUTO_INCREMENT,
  `parent_table_name` varchar(255) DEFAULT NULL,
  `parent_table_rec_id` int DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `password_set_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `password_changed_by` varchar(50) DEFAULT NULL,
  `password_change_reason` varchar(255) DEFAULT NULL,
  `last_password_updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `password_expiration_date` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`password_history_rec_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_history`
--

LOCK TABLES `password_history` WRITE;
/*!40000 ALTER TABLE `password_history` DISABLE KEYS */;
INSERT INTO `password_history` VALUES (0,'customer',0,'K9QpZzZxXxYyAaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRr','2026-02-02 13:06:35','SYSTEM','Initial password setup','2026-02-02 13:06:35','2026-05-03 13:06:35',1);
/*!40000 ALTER TABLE `password_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_rec_id` int NOT NULL AUTO_INCREMENT,
  `tradable_assets_rec_id` int DEFAULT NULL,
  `asset_code` varchar(50) DEFAULT NULL,
  `product_code` varchar(100) DEFAULT NULL,
  `product_type` varchar(255) DEFAULT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `products_json` json DEFAULT NULL,
  `row_metadata` json DEFAULT NULL,
  PRIMARY KEY (`product_rec_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (0,0,'GLD','PG-2323','Bar','Gold Bar 10g','{\"asset_code\": \"GLD\", \"asset_type\": \"Gold\", \"dimensions\": \"25mm x 15mm x 2mm\", \"total_sold\": 250, \"is_physical\": true, \"weight_unit\": \"gram\", \"is_SliceAble\": false, \"product_code\": \"PG-3344\", \"product_name\": \"Gold Bar 10g\", \"product_type\": \"bar\", \"display_order\": 1, \"media_library\": [{\"media_url\": \"/media/products/gold_bar_10g_xl.png\", \"media_type\": \"image\", \"is_featured\": true, \"_comment_media_url\": \"Media file path or URL\", \"_comment_media_type\": \"Type of media (image | video | document | certificate)\", \"_comment_is_featured\": \"featured display media\"}, {\"media_url\": \"/media/products/gold_bar_10g_sm.png\", \"media_type\": \"image\", \"is_featured\": true}, {\"media_url\": \"/media/products/gold_bar_cert.pdf\", \"media_type\": \"certificate\", \"is_featured\": false}], \"price_currency\": \"USD\", \"product_rec_id\": 0, \"standard_price\": 650.0, \"product_quality\": \"24K\", \"transaction_fee\": {\"fee_type\": \"percentage\", \"fee_value\": 1.5, \"fee_currency\": \"USD\", \"fee_description\": \"Platform transaction charges\", \"_comment_fee_type\": \"Fee type (percentage/fixed)\", \"_comment_fee_value\": \"Transaction fee value\", \"_comment_fee_currency\": \"Currency for fixed fee\", \"_comment_fee_description\": \"Fee explanation\"}, \"applicable_taxes\": [{\"amount\": 5, \"tax_name\": \"Sales Tax\", \"_comment_amount\": \"Tax amount\", \"_comment_tax_name\": \"Applicable tax name\", \"fixed or perecent\": \"percentage\", \"taxes_description\": \"Some description of tax\", \"_comment_fixed_or_perecent\": \"Is tax fixed amount or percentage\", \"_comment_taxes_description\": \"Tax details description\"}], \"quantity_on_hand\": 100, \"standard_premium\": 15.0, \"offer_to_customer\": true, \"Alert_on_low_stock\": true, \"approximate_weight\": 10.0, \"product_short_name\": \"GB10\", \"_comment_asset_code\": \"Owning company code like GLD for gold, SLV for silver, etc.\", \"_comment_asset_type\": \"Type of asset like Gold, silver , etc\", \"_comment_dimensions\": \"Physical dimensions\", \"_comment_total_sold\": \"Total units sold\", \"product_description\": \"24K pure gold bar\", \"_comment_is_physical\": \"Indicates if product is physical\", \"_comment_weight_unit\": \"Weight unit\", \"_comment_is_SliceAble\": \"Indicates if product can be sliced\", \"_comment_product_code\": \"Unique User typed product code\", \"_comment_product_name\": \"Full product name\", \"_comment_product_type\": \"product type values: bar, jewellry\", \"_comment_display_order\": \"Determines sorting order on the mobile app list. Lower numbers appear first.\", \"minimum_order_quantity\": 1, \"product_classification\": \"Bar\", \"tradable_assets_rec_id\": 0, \"_comment_price_currency\": \"Price currency\", \"_comment_product_rec_id\": \"Auto-increment product record ID\", \"_comment_product_quality\": \"Metal purity or quality\", \"_comment_approximat_price\": \"Approximate selling price\", \"_comment_quantity_on_hand\": \"Available stock quantity\", \"_comment_standard_premium\": \"Standard premium over spot\", \"_comment_offer_to_customer\": \"Is product available for sale\", \"_comment_Alert_on_low_stock\": \"Low stock alert flag\", \"_comment_approximate_weight\": \"Approximate product weight\", \"_comment_product_short_name\": \"Short display name\", \"_comment_product_description\": \"Detailed product description\", \"_comment_minimum_order_quantity\": \"Minimum order quantity\", \"_comment_product_classification\": \"Product classification\", \"_comment_tradable_assets_rec_id\": \"Linked tradable_assets record\"}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_update_products` AFTER UPDATE ON `products` FOR EACH ROW BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'products',
		  row_rec_id		= OLD.product_rec_id,
		  prev_row_json		= OLD.products_json,
		  next_row_json		= NEW.products_json,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_delete_products` AFTER DELETE ON `products` FOR EACH ROW BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'products',
		  row_rec_id		= OLD.product_rec_id,
		  prev_row_json		= OLD.products_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `row_audit_logs`
--

DROP TABLE IF EXISTS `row_audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `row_audit_logs` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `table_name` varchar(100) DEFAULT NULL,
  `row_rec_id` int DEFAULT NULL,
  `prev_row_json` json DEFAULT NULL,
  `next_row_json` json DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `row_audit_logs`
--

LOCK TABLES `row_audit_logs` WRITE;
/*!40000 ALTER TABLE `row_audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `row_audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seq_num`
--

DROP TABLE IF EXISTS `seq_num`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seq_num` (
  `seq_rec_id` int NOT NULL AUTO_INCREMENT,
  `column_name` varchar(255) NOT NULL,
  `sequence_value` varchar(255) NOT NULL,
  `requested_by` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`seq_rec_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seq_num`
--

LOCK TABLES `seq_num` WRITE;
/*!40000 ALTER TABLE `seq_num` DISABLE KEYS */;
/*!40000 ALTER TABLE `seq_num` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tradable_assets`
--

DROP TABLE IF EXISTS `tradable_assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tradable_assets` (
  `tradable_assets_rec_id` int NOT NULL AUTO_INCREMENT,
  `asset_name` varchar(50) DEFAULT NULL,
  `short_name` varchar(20) DEFAULT NULL,
  `asset_code` varchar(10) DEFAULT NULL,
  `asset_intl_code` varchar(10) DEFAULT NULL,
  `asset_type` varchar(20) DEFAULT NULL,
  `forex_code` varchar(20) DEFAULT NULL,
  `available_to_customers` tinyint(1) DEFAULT NULL,
  `tradable_assets_json` json DEFAULT NULL,
  `row_metadata` json DEFAULT NULL,
  PRIMARY KEY (`tradable_assets_rec_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tradable_assets`
--

LOCK TABLES `tradable_assets` WRITE;
/*!40000 ALTER TABLE `tradable_assets` DISABLE KEYS */;
INSERT INTO `tradable_assets` VALUES (0,'GOLD','gold','gld','XAU','Metal','XAU',1,'{\"stats\": {\"products_weight\": 1500.0, \"_comment_products_weight\": \"Weight of ready products available\", \"bullion_weight_available\": 5000.0, \"_comment_bullion_weight_available\": \"Total bullion weight available in grams\"}, \"taxes\": {\"GST\": \"18%\", \"Luxury_Tax\": 2, \"Import_Duty\": 5, \"_comment_GST\": \"Goods and Service Tax in percent\", \"withholding_tax\": \"10%\", \"_comment_LuxuryTax\": \"Luxury tax percent if applicable\", \"_comment_ImportDuty\": \"Import duty in percent\", \"_comment_withholding_tax\": \"Withholding tax in percent\"}, \"max_order\": 10000.0, \"min_order\": 1.0, \"spot_rate\": {\"url\": \"https://metals-api.com/\", \"unit\": \"gram\", \"quality\": \"24K\", \"api_name\": \"metals-api\", \"currency\": \"USD\", \"updated_at\": \"2026-01-16T06:00:00Z\", \"_comment_url\": \"API endpoint URL\", \"current_rate\": 4433.85, \"_comment_unit\": \"Unit for spot rate\", \"_comment_quality\": \"Purity or quality of the commodity\", \"_comment_api_name\": \"API providing spot rate\", \"_comment_currency\": \"Currency of rate\", \"_comment_updated_at\": \"Timestamp of last spot rate update\", \"_comment_current_rate\": \"Current market rate\"}, \"asset_code\": \"GLD\", \"asset_name\": \"Gold\", \"asset_type\": \"Metal\", \"forex_code\": \"XAU\", \"short_name\": \"gold\", \"asset_rec_id\": 0, \"media_library\": [{\"url\": \"https://example.com/images/gold_front.jpg\", \"description\": \"Front view of Gold Bar\", \"uploaded_at\": \"2024-05-20T09:15:00Z\"}, {\"url\": \"https://example.com/images/gold_side.jpg\", \"description\": \"Side view of Gold Bar\", \"uploaded_at\": \"2024-05-22T11:45:00Z\"}], \"how_to_measure\": \"by_weight\", \"standard_units\": \"gram\", \"tradeable_json\": \"{}\", \"asset_intl_code\": \"XAU\", \"max_reedem_level\": \"10 toz\", \"_comment_comm_code\": \"Short code\", \"_comment_comm_name\": \"Commodity name\", \"_comment_comm_type\": \"metal, crptocurrency, fiat, currency\", \"_comment_forex_code\": \"Foreign exchange code\", \"minimum_reedem_level\": \"1 g\", \"_comment_internal_code\": \"Internal asset code\", \"available_to_customers\": true, \"_comment_commodity_code\": \"Commodity code\", \"_comment_how_to_measure\": \"by_weight, by number\", \"_comment_tradeable_json\": \" tradeable assets all columns json\", \"_comment_commodity_rec_id\": \"Primary ID\", \"_comment_max_order_weight\": \"Maximum order weight\", \"_comment_max_reedem_level\": \"Max Redeem Level\", \"_comment_minimum_order_weight\": \"Minimum order weight\", \"_comment_minimum_reedem_level\": \"Minimum redeem level\", \"_comment_standard_weight_units\": \"grams, QTY etc\", \"_comment_available_to_customers\": \"Is available for customers\"}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}'),(1,'GOLD','gold','GLD','XAU','METAL','XAU',1,'{\"stats\": {\"products_weight\": 1500.0, \"bullion_weight_available\": 5000.0}, \"taxes\": {\"GST\": \"18%\", \"Luxury_Tax\": \"2%\", \"Import_Duty\": \"5%\", \"withholding_tax\": \"10%\"}, \"max_order\": 10000.0, \"min_order\": 1.0, \"spot_rate\": {\"url\": \"https://metals-api.com/\", \"unit\": \"gram\", \"quality\": \"24K\", \"api_name\": \"metals-api\", \"currency\": \"USD\", \"updated_at\": \"2026-01-16T06:00:00Z\", \"current_rate\": 4433.85}, \"asset_code\": \"GLD\", \"asset_name\": \"Gold\", \"forex_code\": \"XAU\", \"short_name\": \"gold\", \"wallet_type\": \"METAL\", \"media_library\": [{\"url\": \"https://example.com/images/gold_front.jpg\", \"description\": \"Front view of Gold Bar\", \"uploaded_at\": \"2024-05-20T09:15:00Z\"}, {\"url\": \"https://example.com/images/gold_side.jpg\", \"description\": \"Side view of Gold Bar\", \"uploaded_at\": \"2024-05-22T11:45:00Z\"}], \"how_to_measure\": \"by_weight\", \"standard_units\": \"gram\", \"asset_intl_code\": \"XAU\", \"max_reedem_level\": \"10 toz\", \"minimum_reedem_level\": \"1 g\", \"available_to_customers\": true, \"tradable_assets_rec_id\": 1}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}'),(2,'SILVER','silver','SLV','XAG','METAL','XAG',1,'{\"stats\": {\"products_weight\": 3000.0, \"bullion_weight_available\": 8000.0}, \"taxes\": {\"GST\": \"18%\", \"Luxury_Tax\": \"2%\", \"Import_Duty\": \"5%\", \"withholding_tax\": \"10%\"}, \"max_order\": 20000.0, \"min_order\": 10.0, \"spot_rate\": {\"url\": \"https://metals-api.com/\", \"unit\": \"gram\", \"quality\": \"999\", \"api_name\": \"metals-api\", \"currency\": \"USD\", \"updated_at\": \"2026-01-16T06:00:00Z\", \"current_rate\": 55.32}, \"asset_code\": \"SLV\", \"asset_name\": \"Silver\", \"forex_code\": \"XAG\", \"short_name\": \"silver\", \"wallet_type\": \"METAL\", \"media_library\": [{\"url\": \"https://example.com/images/silver_front.jpg\", \"description\": \"Front view of Silver Bar\", \"uploaded_at\": \"2024-05-20T09:15:00Z\"}, {\"url\": \"https://example.com/images/silver_side.jpg\", \"description\": \"Side view of Silver Bar\", \"uploaded_at\": \"2024-05-22T11:45:00Z\"}], \"how_to_measure\": \"by_weight\", \"standard_units\": \"gram\", \"asset_intl_code\": \"XAG\", \"max_reedem_level\": \"1000 toz\", \"minimum_reedem_level\": \"10 g\", \"available_to_customers\": true, \"tradable_assets_rec_id\": 2}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}'),(3,'PLATINUM','platinum','PT','XPT','METAL','XPT',0,'{\"stats\": {\"products_weight\": 1200.0, \"bullion_weight_available\": 4000.0}, \"taxes\": {\"GST\": \"18%\", \"Luxury_Tax\": \"2%\", \"Import_Duty\": \"5%\", \"withholding_tax\": \"10%\"}, \"max_order\": 5000.0, \"min_order\": 5.0, \"spot_rate\": {\"url\": \"https://metals-api.com/\", \"unit\": \"gram\", \"quality\": \"999\", \"api_name\": \"metals-api\", \"currency\": \"USD\", \"updated_at\": \"2026-01-16T06:00:00Z\", \"current_rate\": 3100.45}, \"asset_code\": \"PT\", \"asset_name\": \"Platinum\", \"forex_code\": \"XPT\", \"short_name\": \"platinum\", \"wallet_type\": \"METAL\", \"media_library\": [{\"url\": \"https://example.com/images/platinum_front.jpg\", \"description\": \"Front view of Platinum Bar\", \"uploaded_at\": \"2024-05-20T09:15:00Z\"}, {\"url\": \"https://example.com/images/platinum_side.jpg\", \"description\": \"Side view of Platinum Bar\", \"uploaded_at\": \"2024-05-22T11:45:00Z\"}], \"how_to_measure\": \"by_weight\", \"standard_units\": \"gram\", \"asset_intl_code\": \"XPT\", \"max_reedem_level\": \"50 toz\", \"minimum_reedem_level\": \"5 g\", \"available_to_customers\": false, \"tradable_assets_rec_id\": 3}','{\"status\": null, \"created_at\": null, \"created_by\": null, \"updated_at\": null, \"updated_by\": null}'),(4,'CASH','usd','USD','USD','CASH','USD',1,'{\"stats\": {\"products_weight\": 0.0, \"bullion_weight_available\": 0.0}, \"taxes\": {\"GST\": \"0%\", \"Luxury_Tax\": \"0%\", \"Import_Duty\": \"0%\", \"withholding_tax\": \"0%\"}, \"max_order\": 1000000.0, \"min_order\": 1.0, \"spot_rate\": {\"url\": \"https://forex-api.com/\", \"unit\": \"USD\", \"quality\": \"1 USD\", \"api_name\": \"forex-api\", \"currency\": \"USD\", \"updated_at\": \"2026-01-16T06:00:00Z\", \"current_rate\": 1.0}, \"asset_code\": \"csh\", \"asset_name\": \"CASH\", \"forex_code\": \"USD\", \"short_name\": \"cash\", \"wallet_type\": \"CASH\", \"media_library\": [{\"url\": null, \"description\": null, \"uploaded_at\": null}], \"how_to_measure\": \"by_unit\", \"standard_units\": \"USD\", \"asset_intl_code\": \"USD\", \"max_reedem_level\": \"100000\", \"minimum_reedem_level\": \"1\", \"available_to_customers\": true, \"tradable_assets_rec_id\": 4}','{\"status\": null, \"created_at\": null, \"created_by\": null, \"updated_at\": null, \"updated_by\": null}');
/*!40000 ALTER TABLE `tradable_assets` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_update_tradable_assets` AFTER UPDATE ON `tradable_assets` FOR EACH ROW BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'tradable_assets',
		  row_rec_id		= OLD.tradable_assets_rec_id,
		  prev_row_json		= OLD.tradable_assets_json,
		  next_row_json		= NEW.tradable_assets_json,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_delete_tradable_assets` AFTER DELETE ON `tradable_assets` FOR EACH ROW BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'tradable_assets',
		  row_rec_id		= OLD.tradable_assets_rec_id,
		  prev_row_json		= OLD.tradable_assets_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `wallet_ledger`
--

DROP TABLE IF EXISTS `wallet_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet_ledger` (
  `wallet_ledger_rec_id` int NOT NULL AUTO_INCREMENT,
  `customer_rec_id` int DEFAULT NULL,
  `account_number` varchar(100) DEFAULT NULL,
  `wallet_id` varchar(100) DEFAULT NULL,
  `wallet_title` varchar(100) DEFAULT NULL,
  `asset_code` varchar(10) DEFAULT NULL,
  `asset_name` varchar(50) DEFAULT NULL,
  `order_rec_id` int DEFAULT NULL,
  `order_number` varchar(50) DEFAULT NULL,
  `transaction_number` varchar(50) DEFAULT NULL,
  `transaction_type` varchar(20) DEFAULT NULL,
  `wallet_ledger_json` json DEFAULT NULL,
  `row_metadata` json DEFAULT NULL,
  PRIMARY KEY (`wallet_ledger_rec_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_ledger`
--

LOCK TABLES `wallet_ledger` WRITE;
/*!40000 ALTER TABLE `wallet_ledger` DISABLE KEYS */;
INSERT INTO `wallet_ledger` VALUES (0,0,'ACC123456','WALLET001','Main Trading Wallet','XAU','Gold',5001,'ORD5001','TXN10001','buy','{\"wallet_id\": 0, \"asset_code\": null, \"asset_name\": null, \"order_number\": null, \"order_rec_id\": null, \"wallet_title\": null, \"approval_info\": {\"approved_at\": null, \"approval_number\": null, \"approved_by_name\": null, \"approved_by_rec_id\": null, \"_comment_approved_at\": \"Timestamp of approval\", \"_comment_approval_number\": \"Approval reference number\", \"_comment_approved_by_name\": \"Approver name\", \"_comment_approved_by_rec_id\": \"Approver ID\"}, \"contract_info\": {\"contract_number\": null, \"_comment_contract_number\": \"Contract reference number\"}, \"account_number\": null, \"blockchain_info\": {\"blockchain_id\": null, \"blockchain_url\": null, \"blockchain_name\": null, \"_comment_blockchain_id\": \"Blockchain record ID\", \"_comment_blockchain_url\": \"Blockchain explorer URL\", \"_comment_blockchain_name\": \"Blockchain name\"}, \"customer_rec_id\": 0, \"transaction_type\": \"debit\", \"initiated_by_info\": {\"initiated_by\": null, \"initiated_by_name\": null, \"_comment_initiated_by\": \"User who initiated transaction\", \"_comment_initiated_by_name\": \"Name of initiator\"}, \"_comment_wallet_id\": \"sequence number\", \"ledger_transaction\": {\"debit_amount\": null, \"balance_after\": null, \"credit_amount\": null, \"_comment_debit\": \"Debited amount\", \"balance_before\": null, \"transaction_at\": null, \"_comment_credit\": \"Credited amount\", \"transaction_number\": null, \"transaction_reason\": null, \"_comment_transaction_at\": \"Timestamp of transaction\", \"_comment_current_balance\": \"Balance after transaction\", \"_comment_opening_balance\": \"Balance before transaction\", \"_comment_transaction_number\": \"Unique transaction number: Sequence number\", \"_comment_transaction_reason\": \"Reason for transaction\"}, \"_comment_asset_code\": \"Asset code LIKE gld\", \"_comment_asset_name\": \"Asset name like Gold\", \"wallet_ledger_rec_id\": 0, \"_comment_order_number\": \"order number: Sequence number\", \"_comment_order_rec_id\": \"Foreign key to orders table\", \"_comment_wallet_title\": \"Wallet title\", \"_comment_customer_name\": \"customer account number\", \"_comment_transaction_type\": \"debit or credit or open\", \"_comment_wallet_ledger_rec_id\": \"Auto-incremented ledger ID\", \"_comment_customer_wallet_rec_id\": \"Foreign key to customer_wallets\"}','{\"status\": \"active\", \"created_at\": \"2026-01-19 20:10:29.282000\", \"created_by\": \"system\", \"updated_at\": \"2026-01-19 20:10:29.282000\", \"updated_by\": \"system\"}');
/*!40000 ALTER TABLE `wallet_ledger` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_update_wallet_ledger` AFTER UPDATE ON `wallet_ledger` FOR EACH ROW BEGIN

	  INSERT INTO row_audit_logs
	  SET table_name		= 'wallet_ledger',
		  row_rec_id		= OLD.wallet_ledger_rec_id,
		  prev_row_json		= OLD.wallet_ledger_json,
		  next_row_json		= NEW.wallet_ledger_json,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `after_delete_wallet_ledger` AFTER DELETE ON `wallet_ledger` FOR EACH ROW BEGIN
	 
	  INSERT INTO row_audit_logs
	  SET table_name		= 'wallet_ledger',
		  row_rec_id		= OLD.wallet_ledger_rec_id,
		  prev_row_json		= OLD.wallet_ledger_json,
		  next_row_json		= NULL,
		  updated_at		= NOW();
		
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Dumping events for database 'gft'
--

--
-- Dumping routines for database 'gft'
--
/*!50003 DROP FUNCTION IF EXISTS `buildJSONSmart` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `buildJSONSmart`(
								json_obj 	JSON,
								simple_key 	VARCHAR(255),
								key_value 	TEXT
								) RETURNS json
    DETERMINISTIC
BEGIN
			DECLARE roots 		JSON;
			DECLARE r 			INT 			DEFAULT 0;
			DECLARE root_name 	VARCHAR(255);

			DECLARE arr_len 	INT;
			DECLARE a 			INT;

			DECLARE child_keys 	 JSON;
			DECLARE c 			 INT;
			DECLARE child_name   VARCHAR(255);

			DECLARE path 		 VARCHAR(500);
			DECLARE jsonValue 	 JSON;

    /* ===================== VALUE TYPE DETECTION  ===================== */
			IF key_value IS NULL THEN
				SET jsonValue = CAST(NULL AS JSON);
                
			ELSEIF JSON_VALID(key_value) THEN
				SET jsonValue = CAST(key_value AS JSON);
                
			ELSEIF key_value REGEXP '^-?[0-9]+(\\.[0-9]+)?$' THEN
				SET jsonValue = CAST(key_value AS DECIMAL(20,6));
                
			ELSEIF UPPER(key_value) IN ('TRUE','FALSE') THEN
				SET jsonValue = IF(UPPER(key_value)='TRUE', TRUE, FALSE);
                
			ELSE
				SET jsonValue = JSON_QUOTE(key_value);
			END IF;
    
      /* ===================== TOP-LEVEL KEY SUPPORT   ===================== */
			SET path = CONCAT('$.', simple_key);
			IF JSON_CONTAINS_PATH(json_obj, 'one', path) THEN
				RETURN JSON_SET(json_obj, path, jsonValue);
			END IF;

			SET roots = JSON_KEYS(json_obj);

			ROOT_LOOP: WHILE r < JSON_LENGTH(roots) DO
				SET root_name = JSON_UNQUOTE(JSON_EXTRACT(roots, CONCAT('$[', r, ']')));

              /* ===================== root.key ===================== */  
				SET path = CONCAT('$.', root_name, '.', simple_key);
				IF JSON_CONTAINS_PATH(json_obj, 'one', path) THEN
					RETURN JSON_SET(json_obj, path, jsonValue);
				END IF;

                /* ===================== root[index].key (ARRAY SAFE)  ===================== */
				IF JSON_TYPE(JSON_EXTRACT(json_obj, CONCAT('$.', root_name))) = 'ARRAY' THEN
					SET arr_len = JSON_LENGTH(JSON_EXTRACT(json_obj, CONCAT('$.', root_name)));
					SET a = 0;

					ARRAY_LOOP: WHILE a < arr_len DO
						SET path = CONCAT('$.', root_name, '[', a, '].', simple_key);
						IF JSON_CONTAINS_PATH(json_obj, 'one', path) THEN
							SET json_obj = JSON_SET(json_obj, path, jsonValue);
						END IF;
						SET a = a + 1;
					END WHILE;

                /* ===================== root.child.key (OBJECT ONLY) ===================== */
				ELSEIF JSON_TYPE(JSON_EXTRACT(json_obj, CONCAT('$.', root_name))) = 'OBJECT' THEN
                
					SET child_keys = JSON_KEYS(JSON_EXTRACT(json_obj, CONCAT('$.', root_name)));
					SET c 		   = 0;

					CHILD_LOOP: WHILE c < JSON_LENGTH(child_keys) DO
						SET child_name = JSON_UNQUOTE(JSON_EXTRACT(child_keys, CONCAT('$[', c, ']')));
						SET path	   = CONCAT('$.', root_name, '.', child_name, '.', simple_key);
						IF JSON_CONTAINS_PATH(json_obj, 'one', path) THEN
							RETURN JSON_SET(json_obj, path, jsonValue);
						END IF;
						SET c = c + 1;
					END WHILE;
				END IF;

				SET r = r + 1;
			END WHILE;

    RETURN json_obj;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `castJson` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `castJson`(
	p_table_name VARCHAR(255)
) RETURNS json
    DETERMINISTIC
BEGIN
		IF p_table_name IS NULL THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Parameter p_table_name must be provided';
		END IF;
		
        CASE p_table_name
-- =======================================================================
-- corporate_account.corporate_account_json
-- =======================================================================
		WHEN 'corporate_account' THEN
			RETURN CAST(
				'{
					"corporate_account_rec_id"        : 0,                                          "_comment_corporate_account_rec_id"         : "Auto-incremented unique corporate account ID",
					"main_account_num"                : "000",                                      "_comment_main_account_num"                 : "Unique corporate account number",
					"main_account_title"              : "azs",                                      "_comment_main_account_title"                : "Corporate main account title",
					"account_status"                  : "inactive",                                 "_comment_account_status"                   : "Current status: registration req, active, inactive, blocked, etc.",


					"status_change_history":[
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "SUBMITTED",                                     "_comment_new_status"                    : "New status after change",
						  "notes"                    : "Account is opened by the customer",             "_comment_notes"                         : "Remarks related to status change"
						  },
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "APPROVED",                                      "_comment_new_status"                    : "New status after change",
						  "notes"                    : "Approved by Afzaal",                            "_comment_notes"                         : "Remarks related to status change"
						  },
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "OPEN",                                          "_comment_new_status"                    : "New status after change",
						  "notes"                    : "Approved by Afzaal",                            "_comment_notes"                         : "Remarks related to status change"
						  },
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "SUSPENDED",                                     "_comment_new_status"                    : "New status after change",
						  "notes"                    : "by Afzaal",                                    "_comment_notes"                         : "Remarks related to status change"
						  },
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "OPEN",                                          "_comment_new_status"                    : "New status after change",
						  "notes"                    : "REOPEND by Afzaal",                             "_comment_notes"                         : "Remarks related to status change"
						  },
						  {
						  "changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
						  "new_status"               : "CLOSED",                                        "_comment_new_status"                    : "New status after change",
						  "notes"                    : "REOPEND by Afzaal",                             "_comment_notes"                         : "Remarks related to status change"
						  }
					  ],          

					"account_admin" : { 
					  "_comment_create_customer_record_with_account_admin_info"                    : "create customer record with this account_admin_info as well",
					  "first_name"                   : "Ali",                                       "_comment_first_name"                      : "First name of primary contact",
					  "last_name"                    : "Raza",                                      "_comment_last_name"                       : "Last name of primary contact",
					  "primary_email"                : "ali.raza@abctraders.com",                   "_comment_primary_email"                   : "Primary contact email",
					  "primary_phone"                : "+92-300-2223344",                           "_comment_primary_phone"                   : "Primary contact phone",
					  "primary_contact"              : "Ali Raza",                                  "_comment_primary_contact"                 : "Primary contact person name",
					  "designation_of_contact"       : "Finance Manager",                           "_comment_designation_of_contact"          : "Designation/title of primary contact"
					},          

					"company" : {
						"company_name"                 : "AZS Traders Pvt Ltd",                        "_comment_company_name"                    : "Full registered name of the company",
						"company_email"                : "info@abctraders.com",                        "_comment_company_email"                   : "Official email of the company",
						"company_phone"                : "+92-300-1234567",                            "_comment_company_phone"                   : "Official phone of the company",
						"company_ntn_number"           : "1234567-8",                                  "_comment_company_ntn_number"              : "National Tax Number of company",
						"company_date_of_incorporation": "2018-06-15",                                 "_comment_company_date_of_incorporation"   : "Date company was incorporated",          

						"owner_info" : {
							"owner_name"                 : "Ahmed Khan",                               "_comment_owner_name"                      : "Name of company owner",
							"owner_email"                : "ahmed.khan@abctraders.com",                "_comment_owner_email"                     : "Email of company owner",
							"owner_phone"                : "+92-300-1112233",                          "_comment_owner_phone"                     : "Phone number of company owner",
							"owner_national_id"          : "35202-3344565-1",                          "_comment_national_id"                     : "CNIC number of company owner"
					  },          

						"company_address" : {
							"google_reference_number"       : "ChIJ1234567890",                        "_comment_google_reference_number"         : "Google Maps reference ID",
							"full_address"                  : "123 Main St, Apt 4B, New York, USA",    "_comment_full_address"                  : "Complete full address",
							"country"                       : "USA",                                   "_comment_country"                        : "Country name",
							"building_number"               : "123",                                   "_comment_building_number"                : "Building number or identifier",
							"street_name"                   : "Main St",                               "_comment_street_name"                    : "Street name",
							"street_address_2"              : "Apt 4B",                                 "_comment_street_address_2"               : "Secondary street info or apartment number",
							"city"                          : "New York",                              "_comment_city"                           : "City name",
							"state"                         : "New York",                              "_comment_state"                          : "State or province",
							"zip_code"                      : "10001",                                 "_comment_zip_code"                       : "Postal/zip code",
							"directions"                    : "Near Central Park",                     "_comment_directions"                     : "Additional directions to the address",
							"cross_street_1_name"           : "2nd Ave",                               "_comment_cross_street_1_name"             : "Nearby cross street 1",
							"cross_street_2_name"           : "3rd Ave",                               "_comment_cross_street_2_name"             : "Nearby cross street 2",
							"latitude"                      : "40.7128",                               "_comment_latitude"                       : "Latitude coordinate",
							"longitude"                     : "-74.006",                               "_comment_longitude"                      : "Longitude coordinate"
					  }
					},          

					"account_stats" : {
						"total Cash Wallet"           : "PKR 5000.00",                                  "_comment_total_cash_wallet"                : "Total cash balance in wallet",
						"total Gold Wallet"           : "230.4567 grams",                               "_comment_total_gold_wallet"                : "Total gold holdings in grams",
						"totla Silver Wallet"         : "1500.7890 grams",                              "_comment_total_silver_wallet"              : "Total silver holdings in grams",  
						"total_orders"                : 1340,                                           "_comment_total_orders"                     : "Total orders placed by the company",
						"total_assets"                : 85000000,                                       "_comment_total_assets"                     : "Total assets of the company",
						"open_tickets"                : 2,                                              "_comment_open_tickets"                     : "Number of open support tickets",
						"num_of_tickets"              : 18,                                             "_comment_num_of_tickets"                   : "Total number of support tickets",
						"num_of_employees"            : 25,                                             "_comment_num_of_employees"                 : "Total employees in company",
						"year_to_date_orders"         : 215,                                            "_comment_year_to_date_orders"              : "Orders placed this year"
					}
					}' AS JSON);

-- =======================================================================
-- customer.customer_json    
-- =======================================================================	
		WHEN 'customer' THEN
			RETURN CAST(
				'{
					"customer_rec_id"                : 0,                                               "_comment_customer_rec_id"                : "Auto-incremented unique customer ID",
					"customer_status"                : "ACTIVE",                                        "_comment_customer_status"                : "Possible values: Active, Pending, Suspended, etc.",
					"customer_type"                  : "CORPORATE",                                     "_comment_customer_type"                  : "PERSONAL or CORPORATE",
					"corporate_account_rec_id"       : 1,                                               "_comment_corporate_account_rec_id"       : "References corporate_accounts table if customer_type is CORPORATE",
					"first_name"                     : "John",                                          "_comment_first_name"                     : "Customer\'s first name",
					"last_name"                      : "Doe",                                           "_comment_last_name"                      : "Customer\'s last name",
					"user_name"                      : "johndoe123",                                    "_comment_user_name"                      : "Unique username for login",
					"email"                          : "john.doe@example.com",                          "_comment_email"                          : "Primary email of the customer",
					"phone"                          : "+1234567890",                                   "_comment_phone"                          : "Primary phone number",
					"whatsapp_number"                : "+1234567890",                                   "_comment_whatsapp_number"                : "WhatsApp contact number",
					"national_id"                    : "331013434343433",                               "_comment_national_id"                    : "Government-issued national ID",
					"main_account_number"            : "AZS-001",                                       "_comment_main_account_number"            : "Main account number for the customer",
					"account_number"                 : "002",                                           "_comment_account_number"                 : "account number for the customer",              



					"cus_profile_pic"                : "https://example.com/profile_pic.jpg",           "_comment_cus_profile_pic"                : "URL to profile picture",
					"is_verified"                    : true,                                            "_comment_is_verified"                    : "Boolean: whether the customer is verified",              

					"status_change_history":[
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "SUBMITTED",                                     "_comment_new_status"                    : "New status after change",
							"notes"                    : "Account is opened by the customer",             "_comment_notes"                         : "Remarks related to status change"
							},
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "APPROVED",                                      "_comment_new_status"                    : "New status after change",
							"notes"                    : "Approved by Afzaal",                            "_comment_notes"                         : "Remarks related to status change"
							},
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "OPEN",                                          "_comment_new_status"                    : "New status after change",
							"notes"                    : "Approved by Afzaal",                            "_comment_notes"                         : "Remarks related to status change"
							},
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "SUSPENDED",                                     "_comment_new_status"                    : "New status after change",
							"notes"                    : "by Afzaal",                                    "_comment_notes"                         : "Remarks related to status change"
							},
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "OPEN",                                          "_comment_new_status"                    : "New status after change",
							"notes"                    : "REOPEND by Afzaal",                             "_comment_notes"                         : "Remarks related to status change"
							},
							{
							"changed_at"               : "2026-11-11 10:41",                               "_comment_changed_at"                    : "Timestamp when status was changed",
							"new_status"               : "CLOSED",                                        "_comment_new_status"                    : "New status after change",
							"notes"                    : "REOPEND by Afzaal",                             "_comment_notes"                         : "Remarks related to status change"
							}
						],              

					"documents": [
							{
								"document_rec_id"        : 1,                             "_comment_document_rec_id"        : "Auto-incremented unique document record ID",
								"document_name"          : "CNIC",                        "_comment_document_name"          : "Name or type of document",
								"is_verified"            : true,                          "_comment_is_verified"            : "Boolean: whether document is verified",
								"uploaded_at"            : "2026-11-10 09:15",            "_comment_uploaded_at"            : "Timestamp when document was uploaded",
								"verified_at"            : "2026-11-11 10:41",            "_comment_verified_at"            : "Timestamp when document was verified",
								"verified_by"            : "Afzaal",                      "_comment_verified_by"            : "User who verified the document"
							},
							{
								"document_rec_id"        : 2,                             "_comment_document_rec_id"        : "Auto-incremented unique document record ID",
								"document_name"          : "Bank Statement",               "_comment_document_name"          : "Name or type of document",
								"is_verified"            : false,                         "_comment_is_verified"            : "Boolean: whether document is verified",
								"uploaded_at"            : "2026-11-10 11:00",            "_comment_uploaded_at"            : "Timestamp when document was uploaded",
								"verified_at"            : null,                          "_comment_verified_at"            : "Timestamp when document was verified",
								"verified_by"            : null,                           "_comment_verified_by"            : "User who verified the document"
							}
						],              

					"additional_contacts" : [
							{
								"Additional_email_1"         : "j.doe.secondary@example.com",                  "_comment_Additional_email_1"            : "Secondary email for the customer",
								"Additional_phone_1"         : "+1234567891",                                  "_comment_Additional_phone_1"            : "Emergency contact phone number"
							},
							{
								"Additional_email_2"         : "j.doe.secondary@example.com",                  "_comment_Additional_email_2"            : "Secondary email for the customer",
								"Additional_phone_2"         : "+1234567891",                                  "_comment_Additional_phone_2"            : "Emergency contact phone number"
							}
					],             

					"residential_address" : {
							"google_reference_number"       : "ChIJ1234567890",                             "_comment_google_reference_number"         : "Google Maps reference ID",
							"full_address"                  : "123 Main St, Apt 4B, New York, USA",         "_comment_full_address"                    : "Complete full address",
							"country"                       : "USA",                                        "_comment_country"                         : "Country name",
							"building_number"               : "123",                                        "_comment_building_number"                 : "Building number or identifier",
							"street_name"                   : "Main St",                                    "_comment_street_name"                     : "Street name",
							"street_address_2"              : "Apt 4B",                                      "_comment_street_address_2"                : "Secondary street info or apartment number",
							"city"                          : "New York",                                   "_comment_city"                            : "City name",
							"state"                         : "New York",                                   "_comment_state"                           : "State or province",
							"zip_code"                      : "10001",                                      "_comment_zip_code"                        : "Postal/zip code",
							"directions"                    : "Near Central Park",                          "_comment_directions"                      : "Additional directions to the address",
							"cross_street_1_name"           : "2nd Ave",                                    "_comment_cross_street_1_name"             : "Nearby cross street 1",
							"cross_street_2_name"           : "3rd Ave",                                    "_comment_cross_street_2_name"             : "Nearby cross street 2",
							"latitude"                      : "40.7128",                                    "_comment_latitude"                        : "Latitude coordinate",
							"longitude"                     : "-74.006",                                    "_comment_longitude"                       : "Longitude coordinate"
					},              

					"permissions" : {
							"is_buy_allowed"                : true,                                         "_comment_is_buy_allowed"                 : "Boolean: whether buying is allowed",
							"is_sell_allowed"               : true,                                         "_comment_is_sell_allowed"                : "Boolean: whether selling is allowed",
							"is_redeem_allowed"             : false,                                        "_comment_is_redeem_allowed"              : "Boolean: whether redeeming is allowed",
							"is_add_funds_allowed"          : true,                                         "_comment_is_add_funds_allowed"           : "Boolean: whether adding funds is allowed",
							"is_withdrawl_allowed"          : true,                                         "_comment_is_withdrawl_allowed"           : "Boolean: whether withdrawing is allowed"
					},              

					"app_preferences" : {
							"time_zone"                     : "America/New_York",                           "_comment_time_zone"                      : "Preferred time zone",
							"preferred_currency"            : "USD",                                        "_comment_preferred_currency"             : "Preferred currency",
							"preferred_language"            : "en",                                         "_comment_preferred_language"             : "Preferred language",
							"auto_logout_minutes"           : 15,                                           "_comment_auto_logout_minutes"            : "Minutes before automatic logout",
							"remember_me_enabled"           : true,                                         "_comment_remember_me_enabled"            : "Boolean: remember me enabled",
							"default_home_location"         : "New York",                                   "_comment_default_home_location"          : "Default home location in app",
							"biometric_login_enabled"       : true,                                         "_comment_biometric_login_enabled"        : "Boolean: biometric login enabled",
							"push_notifications_enabled"    : true,                                         "_comment_push_notifications_enabled"     : "Boolean: push notifications enabled",
							"transaction_alerts_enabled"    : true,                                         "_comment_transaction_alerts_enabled"     : "Boolean: transaction alerts enabled",
							"email_notifications_enabled"   : true,                                         "_comment_email_notifications_enabled"    : "Boolean: email notifications enabled",
							"is_face_id_enabled"            : true,                                         "_comment_is_face_id_enabled"             : "Whether Face ID is enabled",
							"is_fingerprint_enabled"        : true,                                         "_comment_is_fingerprint_enabled"         : "Whether fingerprint login is enabled"
				} }' AS JSON);

-- =======================================================================
-- customer.customer_json.customer_wallets 
-- =======================================================================
		WHEN 'customer_wallets' THEN
			RETURN CAST(
						 '{
							  "wallet_id":					null,
							  "tradeable_asset_rec_id": 	null,
							  "wallet_title": 				null,
							  "asset_name": 				null,
							  "asset_code": 				null,
							  "wallet_type": 				null,
							  "wallet_status": 				null,
							  "wallet_balance": 			null,
							  "balance_unit": 				null,
							  "balance_last_updated_at": 	null,
							  "blockchain_info": {
									"blockchain_id": 		null,
									"blockchain_name": 		null,
									"blockchain_url": 		null
							}
						} ' AS JSON);

-- =======================================================================
-- auth.auth_json
-- =======================================================================
		WHEN 'auth' THEN
			RETURN CAST(
				'{
					"auth_rec_id"                 : 0,                                          "_comment_auth_rec_id"                 : "Auto-incremented unique auth ID",
					"parent_table_name"           : "customers",                                "_comment_parent_table_name"           : "The parent table this auth belongs to, e.g., customers or employees",
					"parent_table_rec_id"         : 0,                                          "_comment_parent_table_rec_id"         : "The corresponding record ID in the parent table",
					"user_name" 				    :"john@gmail.com",                            "_comment_user_name"                   : "Primary username or email for login",



				"latest_otp": {
					"latest_otp_code"         : "123456",                                    "_comment_latest_otp_code"             : "Most recent OTP sent to user",
					"latest_otp_sent_at"      : "NOW()",                                     "_comment_latest_otp_sent_at"          : "Timestamp when OTP was sent",
					"latest_otp_expires_at"   : "DATE_ADD(NOW(), INTERVAL 5 MINUTE)",        "_comment_latest_otp_expires_at"       : "Timestamp when OTP expires",
					"otp_retries"             : 0,                                           "_comment_otp_retries"                 : "Number of OTP retry attempts",
					"next_otp_in"             : 60,                                          "_comment_next_otp_in"                 : "Seconds before user can request next OTP"
					},

				"user_mfa" : {
					"is_MFA"                    : true,                                       "_comment_is_2FA"                      : "Whether 2FA is enabled",
					"MFA_method"                : "SMS",                                      "_comment_2FA_method"                  : "Method used for 2FA: SMS, Email, Authenticator app, etc.",
					"MFA_method_value"          : "+1234567890",                              "_comment_2FA_method_value"            : "Value used for 2FA (phone, email, app secret)"
				},

				"login_attempts" : [
					{ 
					"last_login_date"           : "NOW()",                                   "_comment_last_login_date"             : "Last login date of user",
					"login_attempts_count"      : 1,                                         "_comment_login_attempts_count"        : "Number of login attempts",
					"login_attempt_minutes"     : 0,                                         "_comment_login_attempt_minutes"       : "Minutes since last login attempt"
					},
					{ 
					"last_login_date"           : "2026-08-01 09:00",                        "_comment_last_login_date"             : "Last login date of user",
					"login_attempts_count"      : 3,                                         "_comment_login_attempts_count"        : "Number of login attempts",
					"login_attempt_minutes"     : 30,                                        "_comment_login_attempt_minutes"       : "Minutes since last login attempt"
					}
				],

				"current_session" : {
					"latitude"                  : 24.8607,                                    "_comment_latitude"                    : "Latitude of current session login",
					"device_id"                 : "device-001",                               "_comment_device_id"                   : "Device identifier of current session",
					"longitude"                 : 67.0011,                                    "_comment_longitude"                   : "Longitude of current session login",
					"ip_address"                : "192.168.1.1",                              "_comment_ip_address"                  : "IP address of current session",
					"last_login_at"             : "NOW(3)",                                   "_comment_last_login_at"               : "Timestamp of last login in this session",
					"session_status"            : "ACTIVE",                                   "_comment_session_status"              : "Current session status: ACTIVE, EXPIRED, LOGGED_OUT",
					"user_auth-token"           : "abc123xyz456",                             "_comment_user_auth_token"             : "Authentication token for current session",
					"user_session_id"           : "session-001",                              "_comment_user_session_id"             : "Unique session ID",
					"last_login_device"         : "iPhone 14",                                "_comment_last_login_device"           : "Device used in last login",
					"last_login_method"         : "Password + 2FA",                           "_comment_last_login_method"           : "Method used for last login",
					"session_expires_at"        : "DATE_ADD(NOW(3), INTERVAL 1 HOUR)",        "_comment_session_expires_at"          : "Expiration timestamp for current session"
				},

				"login_credentials" : {
				"pin"                       	: "1234",                                     "_comment_pin"                         : "Optional PIN for login",
				"password"                  	: "StrongP@ssword1",                          "_comment_password"                    : "User\'s login password (hashed in database)",
				"username"                  	: "johndoe",                                  "_comment_username"                    : "Primary username for login",
				"alternate_username"        	: "john.doe",                                 "_comment_alternate_username"          : "Alternate username for login",
				"is_force_password_change"  	: false,                                      "_comment_is_force_password_change"    : "Whether user must change password at next login",
				"password_policy" : {
						"min_length"              : 8,                                      "_comment_min_length"                  : "Minimum password length",
						"max_length"              : 64,                                     "_comment_max_length"                  : "Maximum password length",
						"require_uppercase"       : true,                                   "_comment_require_uppercase"           : "Password must contain uppercase letter",
						"require_lowercase"       : true,                                   "_comment_require_lowercase"           : "Password must contain lowercase letter",
						"require_number"          : true,                                   "_comment_require_number"              : "Password must contain numeric digit",
						"require_special_char"    : true,                                   "_comment_require_special_char"        : "Password must contain special character",
						"password_expiry_days"    : 90,                                     "_comment_password_expiry_days"        : "Number of days before password expires",
						"password_history_limit"  : 5,                                      "_comment_password_history_limit"      : "Number of previous passwords disallowed",
						"lockout_attempts"        : 5,                                      "_comment_lockout_attempts"            : "Failed login attempts before lockout",
						"lockout_duration_minutes": 30,                                     "_comment_lockout_duration_minutes"    : "Account lockout duration in minutes",
						"allow_reuse"             : false,                                  "_comment_allow_reuse"                 : "Whether old passwords can be reused",
						"password_strength_level" : "STRONG",                                "_comment_password_strength_level"    : "Password strength classification"
				}
				},

				"security_questions" :[
					{
					"auth_security_question"    : "What is your mother\'s maiden name?",       "_comment_auth_security_question"     : "User selected security question",
					"auth_security_answer"      : "Khan",                                     "_comment_auth_security_answer"        : "Answer to security question (hashed in DB)"
				},
				{
					"auth_security_question"    : "What is your mother\'s maiden name?",       "_comment_auth_security_question"     : "User selected security question",
					"auth_security_answer"      : "Khan",                                     "_comment_auth_security_answer"        : "Answer to security question (hashed in DB)"
				}
				]
				}' AS JSON);

-- =======================================================================
-- tradeable_assets.tradeable_assets_json
-- =======================================================================		
		WHEN 'tradable_assets' THEN
			RETURN CAST(
						 '
                         {
							"asset_rec_id"              : 0,                              "_comment_commodity_rec_id"            : "Primary ID",
							"asset_name"                : "Gold",                         "_comment_comm_name"                   : "Commodity name",
							"short_name"                : "gold",                         "_comment_comm_code"                   : "Short code",
							"asset_code"                : "GLD",                          "_comment_internal_code"               : "Internal asset code",
							"asset_intl_code"           : "XAU",                          "_comment_commodity_code"              : "Commodity code",
							"asset_type"                : "Metal",                        "_comment_comm_type"                   : "metal, crptocurrency, fiat, currency",
							"forex_code"                : "XAU",                          "_comment_forex_code"                  : "Foreign exchange code",
							"available_to_customers"    : true,                           "_comment_available_to_customers"      : "Is available for customers",
							"tradeable_json"            : "{}",                           "_comment_tradeable_json"              : " tradeable assets all columns json",

							"how_to_measure"             : "by_weight",                   "_comment_how_to_measure"              : "by_weight, by number",
							"standard_units"             : "gram",                        "_comment_standard_weight_units"       : "grams, QTY etc",
							"min_order"                  : 1.0,                           "_comment_minimum_order_weight"        : "Minimum order weight",
							"max_order"                  : 10000.0,                       "_comment_max_order_weight"            : "Maximum order weight",
							"minimum_reedem_level"       : "1 g",                         "_comment_minimum_reedem_level"        : "Minimum redeem level",
							"max_reedem_level"           : "10 toz",                      "_comment_max_reedem_level"            : "Max Redeem Level",

							"taxes" : {
								"GST"                    : "18%",                         "_comment_GST"                         : "Goods and Service Tax in percent",
								"withholding_tax"        : "10%",                         "_comment_withholding_tax"             : "Withholding tax in percent",
								"Import_Duty"            : 5,                             "_comment_ImportDuty"                  : "Import duty in percent",
								"Luxury_Tax"             : 2,                             "_comment_LuxuryTax"                   : "Luxury tax percent if applicable"
							},

							"stats" : {
								"bullion_weight_available": 5000.0,                         "_comment_bullion_weight_available"    : "Total bullion weight available in grams",
								"products_weight"         : 1500.0,                         "_comment_products_weight"             : "Weight of ready products available"
							},

							"spot_rate" : {
								"updated_at"              : "2026-01-16T06:00:00Z",         "_comment_updated_at"               : "Timestamp of last spot rate update",
								"api_name"                : "metals-api",                   "_comment_api_name"                 : "API providing spot rate",
								"url"                     : "https://metals-api.com/",      "_comment_url"                  : "API endpoint URL",
								"unit"                    : "gram",                         "_comment_unit"                     : "Unit for spot rate",
								"current_rate"            : 4433.85,                        "_comment_current_rate"              : "Current market rate",
								"currency"                : "USD",                          "_comment_currency"                  : "Currency of rate",
								"quality"                 : "24K",                          "_comment_quality"                   : "Purity or quality of the commodity"
							},
							"media_library" : [
									{
										"url"               : "https://example.com/images/gold_front.jpg",
										"description"       : "Front view of Gold Bar",
										"uploaded_at"       : "2024-05-20T09:15:00Z"
									},
									{
										"url"               : "https://example.com/images/gold_side.jpg",
										"description"       : "Side view of Gold Bar",
										"uploaded_at"       : "2024-05-22T11:45:00Z"
									}
						]
						}' AS JSON);
 
-- =======================================================================
-- asset_rate_history.asset_rate_history_json
-- =======================================================================
		WHEN 'asset_rate_history' THEN
			RETURN CAST(
						 '{
							"asset_rate_rec_id"          : 0,                                 "_comment_commodity_rate_rec_id"      : "Auto-incremented asset_rate record ID",
							"tradable_assets_rec_id"     : 0,                                 "_comment_commodity_rec_id"           : "Primary key to tradeable asset",
							"asset_code"                 : "GLD",                             "_comment_internal_code"              : "Internal asset code",

							"spot_rate"                  : 4433.85,                           "_comment_spot_rate"                  : "Spot market rate",
							"weight_unit"                : "gram",                            "_comment_weight_unit"                : "Unit of weight for the rate",
							"currency_unit"              : "USD",                             "_comment_currency_unit"              : "Currency of the rate",
							"rate_timestamp"             : "2026-01-16T06:00:00",             "_comment_rate_timestamp"             : "Timestamp when rate was recorded",
							"effective_date"             : "2026-01-16",                      "_comment_effective_date"             : "Date when rate becomes effective",
							"valid_until"                : "2026-01-17",                      "_comment_valid_until"                : "Expiry date of this rate",

							"source_info"                : 
								{
								"rate_source"            : "metals-api",                       "_comment_rate_source"                : "API or source name",
								"source_url"             : "https://metals-api.com/",          "_comment_source_url"                 : "Source URL",
								"market_status"          : "Open",                             "_comment_market_status"              : "Market status",
								"update_frequency"       : "Daily",                            "_comment_update_frequency"           : "Frequency of updates"
								},

							"foreign_exchange"           : 
								{
								"foreign_exchange_rate"  : 278.50,                             "_comment_foreign_exchange_rate"     : "FX conversion rate",
								"foreign_exchange_source": "OpenExchange",                     "_comment_foreign_exchange_source"   : "FX rate source"
								}
						}' AS JSON);

-- =======================================================================
-- wallet_ledger.wallet_ledger_json
-- ======================================================================= 
		WHEN 'wallet_ledger' THEN
			RETURN CAST(
						'
                        {
							"wallet_ledger_rec_id"        : 0,                              "_comment_wallet_ledger_rec_id"        : "Auto-incremented ledger ID",
							"customer_rec_id"             : 0,                              "_comment_customer_wallet_rec_id"      : "Foreign key to customer_wallets",
							"account_number"              : null,                           "_comment_customer_name"               : "customer account number",
							"wallet_id"                  :  0,                              "_comment_wallet_id"                   : "sequence number",
							"wallet_title"                : null,                           "_comment_wallet_title"                : "Wallet title",
							"asset_code"                  : null,                           "_comment_asset_code"                  : "Asset code LIKE gld",
							"asset_name"                  : null,                           "_comment_asset_name"                  : "Asset name like Gold",
							"order_rec_id"                : null,                           "_comment_order_rec_id"                : "Foreign key to orders table",
							"order_number"                : null,                           "_comment_order_number"                : "order number: Sequence number",  
							"transaction_type"            : "debit",                        "_comment_transaction_type"            : "debit or credit or open",

							"ledger_transaction" : {
								"transaction_number"      : null,                           "_comment_transaction_number"          : "Unique transaction number: Sequence number",
								"transaction_at"          : null,                           "_comment_transaction_at"              : "Timestamp of transaction",
								"transaction_reason"      : null,                           "_comment_transaction_reason"          : "Reason for transaction",
								"balance_before"         : null,                            "_comment_opening_balance"             : "Balance before transaction",
								"debit_amount"            : null,                           "_comment_debit"                       : "Debited amount",
								"credit_amount"           : null,                           "_comment_credit"                      : "Credited amount",
								"balance_after"         : null,                             "_comment_current_balance"             : "Balance after transaction"
							},

							"initiated_by_info" : {
								"initiated_by"            : null,                           "_comment_initiated_by"                : "User who initiated transaction",
								"initiated_by_name"       : null,                           "_comment_initiated_by_name"          : "Name of initiator"
							},

							"approval_info" : {
								"approved_at"             : null,                           "_comment_approved_at"                 : "Timestamp of approval",
								"approved_by_rec_id"      : null,                           "_comment_approved_by_rec_id"          : "Approver ID",
								"approved_by_name"        : null,                           "_comment_approved_by_name"            : "Approver name",
								"approval_number"         : null,                           "_comment_approval_number"             : "Approval reference number"
							},

							"contract_info" : {
								"contract_number"         : null,                           "_comment_contract_number"             : "Contract reference number"
							},

							"blockchain_info" : {
								"blockchain_id"           : null,                           "_comment_blockchain_id"               : "Blockchain record ID",
								"blockchain_name"         : null,                           "_comment_blockchain_name"             : "Blockchain name",
								"blockchain_url"          : null,                           "_comment_blockchain_url"              : "Blockchain explorer URL"
							}
						}' AS JSON);

-- =======================================================================
-- products.products_json
-- =======================================================================
		WHEN 'products' THEN
			RETURN CAST(
						'{
							"product_rec_id":               0,                                             "_comment_product_rec_id":             "Auto-increment product record ID",
							"tradable_assets_rec_id":       0,                                             "_comment_tradable_assets_rec_id":     "Linked tradable_assets record",
							"asset_code":                   "GLD",                                         "_comment_asset_code":                 "Owning company code like GLD for gold, SLV for silver, etc.",
							"product_code":                 "PG-3344" ,                                    "_comment_product_code":               "Unique User typed product code",
							"product_type":                 "bar",                                         "_comment_product_type":               "product type values: bar, jewellry",
							"product_name":                 "Gold Bar 10g",                                "_comment_product_name":               "Full product name",

							"product_short_name":           "GB10",                                        "_comment_product_short_name":        "Short display name",
							"product_description":          "24K pure gold bar",                           "_comment_product_description":       "Detailed product description",
							"product_classification":       "Bar",                                         "_comment_product_classification":    "Product classification",
							"asset_type":                   "Gold",                                        "_comment_asset_type":                "Type of asset like Gold, silver , etc",
							"product_quality":              "24K",                                         "_comment_product_quality":           "Metal purity or quality",
							"approximate_weight":           10.0,                                          "_comment_approximate_weight":        "Approximate product weight",
							"weight_unit":                  "gram",                                        "_comment_weight_unit":               "Weight unit",
							"dimensions":                   "25mm x 15mm x 2mm",                           "_comment_dimensions":                "Physical dimensions",
							"is_physical":                  true,                                          "_comment_is_physical":               "Indicates if product is physical",
							"is_SliceAble":                 false,                                         "_comment_is_SliceAble":              "Indicates if product can be sliced",
							"standard_price":               650.00,                                        "_comment_approximat_price":          "Approximate selling price",
							"standard_premium":             15.00,                                         "_comment_standard_premium":          "Standard premium over spot",
							"price_currency":               "USD",                                         "_comment_price_currency":            "Price currency",

							"applicable_taxes":[
								{ 
								"tax_name":                 "Sales Tax",                                   "_comment_tax_name":                  "Applicable tax name",
								"taxes_description":        "Some description of tax",                     "_comment_taxes_description":         "Tax details description",
								"amount":                   5,                                             "_comment_amount":                    "Tax amount", 
								"fixed or perecent":        "percentage",                                  "_comment_fixed_or_perecent":         "Is tax fixed amount or percentage" 
								}
							],

							"quantity_on_hand":             100,                                           "_comment_quantity_on_hand":          "Available stock quantity",
							"minimum_order_quantity":       1,                                             "_comment_minimum_order_quantity":    "Minimum order quantity",
							"total_sold":                   250,                                           "_comment_total_sold":                "Total units sold",
							"offer_to_customer":            true,                                          "_comment_offer_to_customer":         "Is product available for sale",
							"display_order":                1,                                             "_comment_display_order":             "Determines sorting order on the mobile app list. Lower numbers appear first.",
							"Alert_on_low_stock":           true,                                          "_comment_Alert_on_low_stock":        "Low stock alert flag",

							"media_library": [
								{
									"media_type":           "image",                                       "_comment_media_type":                "Type of media (image | video | document | certificate)",
									"media_url":            "/media/products/gold_bar_10g_xl.png",         "_comment_media_url":                 "Media file path or URL",
									"is_featured":          true,                                          "_comment_is_featured":               "featured display media"
								},
								{
									"media_type":           "image",                                       
									"media_url":            "/media/products/gold_bar_10g_sm.png",         
									"is_featured":          true                                          
								},
								{
									"media_type":           "certificate",
									"media_url":            "/media/products/gold_bar_cert.pdf",
									"is_featured":          false
								}
							],

							"transaction_fee": {
								"fee_type":                 "percentage",                                  "_comment_fee_type":                  "Fee type (percentage/fixed)",
								"fee_value":                1.5,                                           "_comment_fee_value":                 "Transaction fee value",
								"fee_currency":             "USD",                                         "_comment_fee_currency":              "Currency for fixed fee",
								"fee_description":          "Platform transaction charges",                "_comment_fee_description":           "Fee explanation"
							}
						}' AS JSON);

-- =======================================================================
-- inventory.inventory_json
-- =======================================================================
		WHEN 'inventory' THEN
			RETURN CAST(
						'{
							"inventory_rec_id":            0,                                              "_comment_inventory_rec_id":           "Auto-increment inventory record ID",
							"product_rec_id":              0,                                              "_comment_product_rec_id":             "Linked product record ID",
							"item_name":                   "Gold Bar - 1000g",                             "_comment_item_name":                  "Inventory item name",
							"item_type":                   "Bar",                                          "_comment_item_type":                  "Inventory item type like: Bar,Gold Ring, Bracelet, Locket, Jwellery etc",
							"asset_type":                  "Gold",                                         "_comment_asset_type":                 "Type of asset like Gold, silver , etc",  
							"availability_status":         "Available",                                    "_comment_availability_status":        "Current availability status like: Available,Sold, redeemed, Slice Bought",



							"item_Size":                    "2 inches",                                    "_comment_Size":                       "like ring size",
							"weight_adjustment":            0.5,                                           "_comment_weight_adjustment":          "Weight adjustment applied",
							"net_weight":                   1000.0,                                        "_comment_net_weight":                 "Net usable weight",
							"available_weight":             330.00,                                        "_comment_available_weight":           "Remaining available weight",
							"item_quality":                 "24K",                                         "_comment_item_quality":               "Quality of the item",
							"location_details":             "dollman ",                                    "_comment_location_details":           "Physical storage location details",
						 
							"pricing_adjustments": {
								"item_margin_adjustment":    1.2,                                           "_comment_item_margin_adjustment":     "Margin adjustment percentage",
								"Discount":                  0.5,                                           "_comment_Discount":                   "Discount percentage",
								"Promotions":                "Ramadan Offer",                               "_comment_Promotions":                 "Active promotion details"
							},

							"media_library": [
								{
									"media_type":            "image",                                       "_comment_media_type":                 "Media type",
									"media_url":             "/media/inventory/item1.png",                  "_comment_media_url":                  "Media file URL",
									"is_featured":           true,                                          "_comment_is_featured":                "Primary media flag"
								}
							],

							"ownership_metrics": {
								"weight_sold_so_far":       770.00,                                        "_comment_weight_sold":                "Total weight sold already",
								"number_of_shareholders":    3,                                             "_comment_number_of_shareholders":     "Total shareholders",
								"number_of_transactions":    12,                                            "_comment_number_of_transactions":     "Total transactions count"
							},

							"manufacturer_info": {
								"manufacturing_country":     "Switzerland",                                 "_comment_manufacturing_country":      "Country of manufacture",
								"manufacturer_name":         "Valcambi",                                    "_comment_manufacturer_name":          "Manufacturer name",
								"manufacturing_date":        "2025-01-10",                                  "_comment_manufacturing_date":         "Manufacturing date",
								"serial_number":             "VAL-1000G-001",                               "_comment_serial_number":              "Unique serial number",
								"serial_verification_url":   "https://verify.valcambi.com/VAL-1000G-001",   "_comment_serial_verification_url":    "Verification URL",
								"serial_verification_text":  "Verified",                                    "_comment_serial_verification_text":   "Verification status",
								"dimensions":                "120mm x 55mm x 9mm",                          "_comment_dimensions":                 "Physical dimensions"
							},

							"purchase_from": {
								"purchase_from_rec_id":      22,                                            "_comment_purchase_from_rec_id":       "Supplier record ID",
								"receipt_number":            "RCPT-8899",                                   "_comment_receipt_number":             "Purchase receipt number",
								"receipt_date":              "2025-10-05",                                  "_comment_receipt_date":               "Receipt date",
								"from_name":                 "ABC Bullion Ltd",                             "_comment_from_name":                  "Supplier name",
								"from_address":              "Dubai, UAE",                                  "_comment_from_address":               "Supplier address",
								"from_phone":                "+971000000",                                  "_comment_from_phone":                 "Supplier phone",
								"from_email":                "sales@abc.com",                               "_comment_from_email":                 "Supplier email",
								"purchase_date":             "2025-10-05",                                  "_comment_purchase_date":              "Purchase date",
								"packaging":                 "Sealed",                                      "_comment_packaging":                  "Packaging details",
								"metal_rate":                63.5,                                          "_comment_metal_rate":                 "Metal rate at purchase",
								"metal_weight":              10.0,                                          "_comment_metal_weight":               "Metal weight purchased",
								"making_charges":            5.0,                                           "_comment_making_charges":             "Making charges",
								"premium_paid":              10.0,                                          "_comment_premium_paid":               "Premium paid",
								"total_tax_paid":            3.5,                                           "_comment_total_tax_paid":             "Total tax paid",
								"tax_description":           "Import tax",                                  "_comment_tax_description":            "Tax description",
								"total_price_paid":          650.0,                                         "_comment_total_price_paid":           "Total amount paid",
								"mode_of_payment":           "Bank Transfer",                               "_comment_mode_of_payment":            "Payment method",
								"check_or_transaction_no":   "TXN-778899",                                  "_comment_check_or_transaction_no":    "Payment reference"
							},

							"sold_to": [
										{
											"order_date":             "2025-11-01",                                 "_comment_order_date":                 "Order date",
											"order_number":           "ORD-1001",                                   "_comment_order_number":               "Order number",
											"receipt_number":         "SR-1001",                                    "_comment_receipt_number":             "Sales receipt number",
											"sold_date":              "2025-11-02",                                 "_comment_sold_date":                  "Sold date",
											"sold_to_id":              501,                                         "_comment_sold_to_id":                 "Customer ID",
											"sold_to_name":            "Ali Khan",                                  "_comment_sold_to_name":               "Customer name",
											"sold_to_phone":           "+923001112233",                             "_comment_sold_to_phone":              "Customer phone",
											"sold_to_email":           "ali@email.com",                             "_comment_sold_to_email":              "Customer email",
											"sold_to_address":         "Karachi",                                   "_comment_sold_to_address":            "Customer address",
											"metal_rate":              65.0,                                        "_comment_metal_rate":                 "Metal rate at sale",
											"weight_sold":             2.5,                                         "_comment_weight_sold":                "Weight sold",
											"making_charges":          2.0,                                         "_comment_making_charges":             "Making charges",
											"premium_charged":         5.0,                                         "_comment_premium_charged":            "Premium charged",
											"taxes":                   1.2,                                         "_comment_taxes":                      "Taxes charged",
											"taxes_description":       "Sales tax",                                 "_comment_taxes_description":          "Tax description",
											"total_price_charged":     180.0,                                       "_comment_total_price_charged":        "Total charged amount",
											"transaction_details": 
											{
												"transaction_num":         "TXN-555666",                                  "_comment_transaction_num":            "Unique transaction number",
												"fee_type":                  "percentage",                                  "_comment_fee_type":                  "Fee type (percentage/fixed)",
												"fee_value":                 1.5,                                           "_comment_fee_value":                 "Transaction fee value",
												"fee_currency":              "USD",                                         "_comment_fee_currency":              "Currency for fixed fee",
												"fee_description":           "Platform transaction charges",                "_comment_fee_description":           "Fee explanation",
												"transaction_status":        "Completed",                                   "_comment_transaction_status":        "Transaction status"
										}
									}

							]

						}' AS JSON);

-- =======================================================================
-- row_metadta for all tables
-- =======================================================================
        WHEN 'row_metadata' THEN
			RETURN CAST(
          		'{
					"status" : "active",
					"created_at" : "2026-01-19 20:10:29.282000",
					"created_by" : "system",
					"updated_at" : "2026-01-19 20:10:29.282000",
					"updated_by" : "system"
				}' AS JSON);

				
		ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid p_table_name value';
        
        END CASE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fillTemplate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fillTemplate`(
    pjReqObj     JSON,
    pjTemplateObj JSON
) RETURNS json
    DETERMINISTIC
BEGIN
    DECLARE v_result 			JSON DEFAULT pjTemplateObj;
    DECLARE v_req_keys 			JSON;
    DECLARE v_key 				VARCHAR(255);
    DECLARE v_value 			JSON;
    DECLARE i 					INT DEFAULT 0;
    DECLARE v_count 			INT;

    -- Get all keys of the request JSON
    SET v_req_keys 		= JSON_KEYS(pjReqObj);
    SET v_count 		= JSON_LENGTH(v_req_keys);

    WHILE i < v_count DO
        SET v_key 		= JSON_UNQUOTE(JSON_EXTRACT(v_req_keys, CONCAT('$[', i, ']')));
        SET v_value 	= JSON_EXTRACT(pjReqObj, CONCAT('$.', v_key));

        SET v_result = 	  buildJSONSmart(v_result, v_key, v_value);

        SET i = i + 1;
    END WHILE;

    RETURN v_result;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getAuth` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getAuth`(pCustomerRecId INT) RETURNS json
    DETERMINISTIC
BEGIN
    DECLARE v_auth_json JSON;

    SELECT 	auth_json
    INTO 	v_auth_json
    FROM 	auth
    WHERE parent_table_rec_id = pCustomerRecId
    LIMIT 1;

    IF v_auth_json IS NULL THEN
        SET v_auth_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Customer does not exist',
            'customer_rec_id', pCustomerRecId
        );
    END IF;

    RETURN v_auth_json;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getCustomer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getCustomer`(pCustomerRecId INT) RETURNS json
    DETERMINISTIC
BEGIN
    DECLARE v_customer_json JSON;

    SELECT customer_json
    INTO v_customer_json
    FROM customer
    WHERE customer_rec_id = pCustomerRecId
    LIMIT 1;

    IF v_customer_json IS NULL THEN
        SET v_customer_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Customer does not exist',
            'customer_rec_id', pCustomerRecId
        );
    END IF;

    RETURN v_customer_json;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getInventory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getInventory`(pInventoryRecId INT) RETURNS json
    DETERMINISTIC
BEGIN
    DECLARE v_inventory_json JSON;

    SELECT inventory_json
    INTO v_inventory_json
    FROM inventory
    WHERE inventory_rec_id = pInventoryRecId
    LIMIT 1;

    IF v_inventory_json IS NULL THEN
        SET v_inventory_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Inventory record does not exist',
            'inventory_rec_id', pInventoryRecId
        );
    END IF;

    RETURN v_inventory_json;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getJval` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getJval`(
						json_doc JSON,
						key_name TEXT
						) RETURNS longtext CHARSET utf8mb4
    DETERMINISTIC
BEGIN

    RETURN JSON_UNQUOTE(JSON_EXTRACT(json_doc, CONCAT('$.', key_name)));
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getProduct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getProduct`(pProductRecId INT) RETURNS json
    DETERMINISTIC
BEGIN
    DECLARE v_product_json JSON;

    SELECT products_json
    INTO v_product_json
    FROM products
    WHERE product_rec_id = pProductRecId
    LIMIT 1;

    IF v_product_json IS NULL THEN
        SET v_product_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Product does not exist',
            'product_rec_id', pProductRecId
        );
    END IF;

    RETURN v_product_json;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `getTemplate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `getTemplate`(
	p_table_name VARCHAR(255)
) RETURNS json
    DETERMINISTIC
BEGIN
		IF p_table_name IS NULL THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Parameter p_table_name must be provided';
		END IF;
		
        CASE p_table_name
        
-- =======================================================================
-- corporate_account.corporate_account_json
-- =======================================================================
		WHEN 'corporate_account' THEN
			RETURN CAST(
				'{
					"corporate_account_rec_id" 	 				  : null,
					"main_account_num"         	 				  : null,
					"main_account_title"       	 				  : null,
					"account_status"           	 				  : null,

					"status_change_history":  [
						{
							"changed_at" 	   	 				  : null,
							"new_status" 	   	 				  : null,
							"notes"      	   	 				  : null
						},
						{
							"changed_at" 	   	 				  : null,
							"new_status" 	   	 				  : null,
							"notes"      	   	 				  : null
						},
						{
							"changed_at" 	   	 				  : null,
							"new_status" 	   	 				  : null,
							"notes"      	   	 				  : null
						}
					],

					"account_admin":  {
						"first_name"             				  : null,
						"last_name"              				  : null,
						"primary_email"          				  : null,
						"primary_phone"          				  : null,
						"primary_contact"        				  : null,
						"designation_of_contact" 				  : null
					},

					"company":  {
						"company_name"                  		  : null,
						"company_email"                 		  : null,
						"company_phone"                 		  : null,
						"company_ntn_number"            		  : null,
						"company_date_of_incorporation" 		  : null,

						"owner_info":  {
							"owner_name"        				  : null,
							"owner_email"       				  : null,
							"owner_phone"       				  : null,
							"owner_national_id" 				  : null
						},

						"company_address": {
							"google_reference_number" 			  : null,
							"full_address"            			  : null,
							"country"                 			  : null,
							"building_number"         			  : null,
							"street_name"             			  : null,
							"street_address_2"        			  : null,
							"city"                    			  : null,
							"state"                   			  : null,
							"zip_code"                			  : null,
							"directions"              			  : null,
							"cross_street_1_name"     			  : null,
							"cross_street_2_name"     			  : null,
							"latitude"                			  : null,
							"longitude"               			  : null
						}
					},

					"account_stats":  {
						"total_cash_wallet"   					  : null,
						"total_gold_wallet"   					  : null,
						"total_silver_wallet" 					  : null,
						"total_orders"        					  : null,
						"total_assets"        					  : null,
						"open_tickets"        					  : null,
						"num_of_tickets"      					  : null,
						"num_of_employees"    					  : null,
						"year_to_date_orders" 					  : null
					}
				}' AS JSON);

-- =======================================================================
-- customer.customer_json    
-- =======================================================================
		WHEN 'customer' THEN
			RETURN CAST(
				'{
					"customer_rec_id"                			  : null,
					"customer_status"                			  : null,
					"customer_type"                  			  : null,
					"corporate_account_rec_id"       			  : null,
					"first_name"                    			  : null,
					"last_name"                      			  : null,
					"user_name"                      			  : null,
					"email"                         			  : null,
					"phone"                          			  : null,
					"whatsapp_number"                			  : null,
					"national_id"                    			  : null,
					"main_account_number"            			  : null,
					"account_number"                 			  : null,
					"cus_profile_pic"                			  : null,
					"is_verified"                    			  : null,

					"status_change_history":  [
						{
							"changed_at"             			  : null,
							"new_status"             			  : null,
							"notes"                  			  : null
						}
					],

					"documents":  [
						{
							"document_rec_id"        			  : null,
							"document_name"          			  : null,
							"is_verified"            			  : null,
							"uploaded_at"            			  : null,
							"verified_at"            			  : null,
							"verified_by"            			  : null
						}
					],

					"additional_contacts":  [
						{
							"additional_email"       			  : null,
							"additional_phone"       			  : null
						}
					],

					"residential_address":  {
						"google_reference_number"    			  : null,
						"full_address"               			  : null,
						"country"                    			  : null,
						"building_number"            			  : null,
						"street_name"                			  : null,
						"street_address_2"           			  : null,
						"city"                       			  : null,
						"state"                      			  : null,
						"zip_code"                   			  : null,
						"directions"                 			  : null,
						"cross_street_1_name"        			  : null,
						"cross_street_2_name"        			  : null,
						"latitude"                   			  : null,
						"longitude"                  			  : null
					},

					"permissions":  {
						"is_buy_allowed"             			  : null,
						"is_sell_allowed"            			  : null,
						"is_redeem_allowed"          			  : null,
						"is_add_funds_allowed"       			  : null,
						"is_withdrawl_allowed"       			  : null
					},

					"app_preferences":  {
						"time_zone"                  			  : null,
						"preferred_currency"         			  : null,
						"preferred_language"         			  : null,
						"auto_logout_minutes"        			  : null,
						"remember_me_enabled"        			  : null,
						"default_home_location"      			  : null,
						"biometric_login_enabled"    			  : null,
						"push_notifications_enabled" 			  : null,
						"transaction_alerts_enabled" 			  : null,
						"email_notifications_enabled" 			  : null,
						"is_face_id_enabled"         			  : null,
						"is_fingerprint_enabled"     			  : null
					},
                    "customer_wallets": []
				}' AS JSON);

-- =======================================================================
-- customer.customer_json.customer_wallets 
-- =======================================================================
		WHEN 'customer_wallets' THEN
			RETURN CAST(
						 '{
							  "wallet_id":					null,
							  "tradable_assets_rec_id": 	null,
							  "wallet_title": 				null,
							  "asset_name": 				null,
							  "asset_code": 				null,
							  "wallet_type": 				null,
							  "wallet_status": 				null,
							  "wallet_balance": 			null,
							  "balance_unit": 				null,
							  "balance_last_updated_at": 	null,
							  "blockchain_info": {
									"blockchain_id": 		null,
									"blockchain_name": 		null,
									"blockchain_url": 		null
							}
						} ' AS JSON);
  
-- =======================================================================
-- auth.auth_json
-- =======================================================================
		WHEN 'auth' THEN
			RETURN CAST(
				'{
					"auth_rec_id"                  				  : null,
					"parent_table_name"            				  : null,
					"parent_table_rec_id"          				  : null,
					"user_name"                    				  : null,

					"latest_otp":  {
						"latest_otp_code"          				  : null,
						"latest_otp_sent_at"       				  : null,
						"latest_otp_expires_at"    				  : null,
						"otp_retries"              				  : null,
						"next_otp_in"              				  : null
					},

					"user_mfa":  {
						"is_MFA"                   				  : null,
						"MFA_method"               				  : null,
						"MFA_method_value"         				  : null
					},

					"login_attempts":  [
						{
							"last_login_date"      				  : null,
							"login_attempts_count" 				  : null,
							"login_attempt_minutes"				  : null
						}
					],

					"current_session":  {
						"latitude"                 				  : null,
						"device_id"                				  : null,
						"longitude"                				  : null,
						"ip_address"               				  : null,
						"last_login_at"            				  : null,
						"session_status"           				  : null,
						"user_auth_token"          				  : null,
						"user_session_id"          				  : null,
						"last_login_device"        				  : null,
						"last_login_method"        				  : null,
						"session_expires_at"       				  : null
					},

					"login_credentials":  {
						"pin"                         			  : null,
						"password"                    			  : null,
						"username"                    			  : null,
						"alternate_username"          			  : null,
						"is_force_password_change"    			  : null,

						"password_policy":  {
							"min_length"              		 	  : null,
							"max_length"              		 	  : null,
							"require_uppercase"       		 	  : null,
							"require_lowercase"       		 	  : null,
							"require_number"          		 	  : null,
							"require_special_char"    		 	  : null,
							"password_expiry_days"    		 	  : null,
							"password_history_limit"  		 	  : null,
							"lockout_attempts"        		 	  : null,
							"lockout_duration_minutes"		 	  : null,
							"allow_reuse"             		 	  : null,
							"password_strength_level" 		 	  : null
						}
					},

					"security_questions":  [
						{
							"auth_security_question"  			  : null,
							"auth_security_answer"    			  : null
						}
					]
				}' AS JSON);

-- =======================================================================
-- tradeable_assets.tradeable_assets_json
-- =======================================================================
		WHEN 'tradable_assets' THEN
			RETURN CAST(
						 '
                         {
							"tradable_assets_rec_id"  : null,
							"asset_name"              : null,
							"short_name"              : null,
							"asset_code"              : null,
							"asset_intl_code"         : null,
							"wallet_type"              : null,
							"forex_code"              : null,
							"available_to_customers"  : null,

							"how_to_measure"          : null,
							"standard_units"          : null,
							"min_order"               : null,
							"max_order"               : null,
							"minimum_reedem_level"    : null,
							"max_reedem_level"        : null,

							"taxes" : {
								"GST"                 : null,
								"withholding_tax"     : null,
								"Import_Duty"         : null,
								"Luxury_Tax"          : null
							},

							"stats" : {
								"bullion_weight_available" : null,
								"products_weight"          : null
							},

							"spot_rate" : {
								"updated_at"           : null,
								"api_name"             : null,
								"url"                  : null,
								"unit"                 : null,
								"current_rate"         : null,
								"currency"             : null,
								"quality"              : null
							},

							"media_library" : [
								{
									"url"             : null,
									"description"     : null,
									"uploaded_at"     : null
								},
								{
									"url"             : null,
									"description"     : null,
									"uploaded_at"     : null
								}
							]
						}' AS JSON);
  
-- =======================================================================
-- asset_rate_history.asset_rate_history_json
-- =======================================================================
		WHEN 'asset_rate_history' THEN
			RETURN CAST(
						 '
						{
							"asset_rate_rec_id"        : null,
							"tradable_assets_rec_id"   : null,
							"asset_code"               : null,

							"spot_rate"                : null,
							"weight_unit"              : null,
							"currency_unit"            : null,
							"rate_timestamp"           : null,
							"effective_date"           : null,
							"valid_until"              : null,

							"source_info" : {
								"rate_source"          : null,
								"source_url"           : null,
								"market_status"        : null,
								"update_frequency"     : null
							},

							"foreign_exchange" : {
								"foreign_exchange_rate"  : null,
								"foreign_exchange_source": null
							}
						}' AS JSON);

-- =======================================================================
-- wallet_ledger.wallet_ledger_json
-- =======================================================================
		WHEN 'wallet_ledger' THEN
			RETURN CAST(
						'{
							"wallet_ledger_rec_id"      : null,
							"customer_rec_id"           : null,
							"account_number"            : null,
							"wallet_id"                 : null,
							"wallet_title"              : null,
							"asset_code"                : null,
							"asset_name"                : null,
							"order_rec_id"              : null,
							"order_number"              : null,
							"transaction_number"        : null,
							"transaction_type"          : null,

							"ledger_transaction" : {
								"transaction_number"    : null,
								"transaction_at"        : null,
								"transaction_reason"    : null,
								"balance_before"        : null,
								"debit_amount"          : null,
								"credit_amount"         : null,
								"balance_after"         : null
							},

							"initiated_by_info" : {
								"initiated_by"          : null,
								"initiated_by_name"     : null
							},

							"approval_info" : {
								"approved_at"           : null,
								"approved_by_rec_id"    : null,
								"approved_by_name"      : null,
								"approval_number"       : null
							},

							"contract_info" : {
								"contract_number"       : null
							},

							"blockchain_info" : {
								"blockchain_id"         : null,
								"blockchain_name"       : null,
								"blockchain_url"        : null
							}
						}' AS JSON);

-- =======================================================================
-- products.products_json
-- =======================================================================
		WHEN 'products' THEN
			RETURN CAST(
						'{
							"product_rec_id":               null,
							"tradable_assets_rec_id":       null,
							"asset_code":                   null,
							"product_code":                 null,
							"product_type":                 null,
							"product_name":                 null,

							"product_short_name":           null,
							"product_description":          null,
							"product_classification":       null,
							"asset_type":                   null,
							"product_quality":              null,
							"approximate_weight":           null,
							"weight_unit":                  null,
							"dimensions":                   null,
							"is_physical":                  null,
							"is_SliceAble":                 null,
							"standard_price":               null,
							"standard_premium":             null,
							"price_currency":               null,

							"applicable_taxes": [
								{
									"tax_name":              null,
									"taxes_description":     null,
									"amount":                null,
									"fixed or perecent":     null
								}
							],

							"quantity_on_hand":             null,
							"minimum_order_quantity":       null,
							"total_sold":                   null,
							"offer_to_customer":            null,
							"display_order":                null,
							"Alert_on_low_stock":           null,

							"media_library": [
								{
									"media_type":            null,
									"media_url":             null,
									"is_featured":           null
								},
								{
									"media_type":            null,
									"media_url":             null,
									"is_featured":           null
								},
								{
									"media_type":            null,
									"media_url":             null,
									"is_featured":           null
								}
							],

							"transaction_fee": {
								"fee_type":                 null,
								"fee_value":                null,
								"fee_currency":             null,
								"fee_description":          null
							}
						}' AS JSON);

-- =======================================================================
-- inventory.inventory_json
-- =======================================================================
 		WHEN 'inventory' THEN
			RETURN CAST(
						'{
							"inventory_rec_id"       :  null,
							"product_rec_id"         :  null,
							"item_name"              :  null,
							"item_type"              :  null,
							"asset_type"             :  null,
							"availability_status"    :  null,
							"item_Size"              :  null,
							"weight_adjustment"      :  null,
							"net_weight"             :  null,
							"available_weight"       :  null,
							"item_quality"           :  null,
							"location_details"       :  null,
							"pricing_adjustments"    :  {
															"item_margin_adjustment" :  null,
															"Discount"               :  null,
															"Promotions"             :  null
														 },
							"media_library"          :  [
															{
																"media_type"     :  null,
																"media_url"      :  null,
																"is_featured"    :  null
															}
														],
							"ownership_metrics"      :  {
															"weight_sold_so_far"       :  null,
															"number_of_shareholders"   :  null,
															"number_of_transactions"   :  null
														},
							"manufacturer_info"      :  {
															"manufacturing_country"       :  null,
															"manufacturer_name"           :  null,
															"manufacturing_date"          :  null,
															"serial_number"               :  null,
															"serial_verification_url"     :  null,
															"serial_verification_text"    :  null,
															"dimensions"                  :  null
														},
							"purchase_from"          :  {
															"purchase_from_rec_id"       :  null,
															"receipt_number"             :  null,
															"receipt_date"               :  null,
															"from_name"                  :  null,
															"from_address"               :  null,
															"from_phone"                 :  null,
															"from_email"                 :  null,
															"purchase_date"              :  null,
															"packaging"                  :  null,
															"metal_rate"                 :  null,
															"metal_weight"               :  null,
															"making_charges"             :  null,
															"premium_paid"               :  null,
															"total_tax_paid"             :  null,
															"tax_description"            :  null,
															"total_price_paid"           :  null,
															"mode_of_payment"            :  null,
															"check_or_transaction_no"    :  null
														},
							"sold_to"                :  [
															{
																"order_date"          :  null,
																"order_number"        :  null,
																"receipt_number"      :  null,
																"sold_date"           :  null,
																"sold_to_id"          :  null,
																"sold_to_name"        :  null,
																"sold_to_phone"       :  null,
																"sold_to_email"       :  null,
																"sold_to_address"     :  null,
																"metal_rate"          :  null,
																"weight_sold"         :  null,
																"making_charges"      :  null,
																"premium_charged"     :  null,
																"taxes"               :  null,
																"taxes_description"   :  null,
																"total_price_charged" :  null,
																"transaction_details" :  {
																							"transaction_num"      :  null,
																							"fee_type"             :  null,
																							"fee_value"            :  null,
																							"fee_currency"         :  null,
																							"fee_description"      :  null,
																							"transaction_status"   :  null
																						}
														}
							]
						}' AS JSON);

-- =======================================================================
-- row_metadta for all tables
-- =======================================================================
		WHEN 'password_history' THEN
			RETURN CAST(
				'{
					"password": null,
					"is_active": null,
					"password_set_at": null,
					"password_changed_by": null,
					"password_change_reason": null,
					"last_password_updated_at": null,
					"password_expiration_date": null

				}' AS JSON);
	
-- =======================================================================
-- row_metadta for all tables
-- =======================================================================
		WHEN 'row_metadata' THEN
			RETURN CAST(
				'{
					"status"       								  : null,
					"created_at"   								  : null,
					"created_by"   								  : null,
					"updated_at"   								  : null,
					"updated_by"   								  : null
				}' AS JSON);
		
		ELSE
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid p_table_name value';
        
        END CASE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `isFalsy` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `isFalsy`(val TEXT) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN
    DECLARE vText TEXT;

    -- If it's NULL, it's falsy
    IF val IS NULL THEN
        RETURN 1;
    END IF;

    SET vText = TRIM(val);

    -- Handle falsy string/numeric values
    IF vText = '' 
        OR LOWER(vText) = 'false'
        OR LOWER(vText) = 'null'
        OR LOWER(vText) = 'undefined'
        OR vText = '0'
        OR vText = '0.0'
    THEN
        RETURN 1;
    END IF;

    -- Everything else is truthy
    RETURN 0;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `mergeIfMissing` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `mergeIfMissing`(
                            pjTarget    JSON,       -- inventory_json
                            pjKeys      JSON,       -- JSON array of key names to copy from product_json
                            pjSource    JSON        -- product_json
) RETURNS json
    DETERMINISTIC
BEGIN
    DECLARE i           INT DEFAULT 0;
    DECLARE n           INT;
    DECLARE keyName     VARCHAR(255);
    DECLARE vResult     JSON;

    SET vResult         = pjTarget;
    SET n               = JSON_LENGTH(pjKeys);

    WHILE i < n DO
        SET keyName = JSON_UNQUOTE(JSON_EXTRACT(pjKeys, CONCAT('$[', i, ']')));

        -- If key exists in source
        IF JSON_CONTAINS_PATH(pjSource, 'one', CONCAT('$.', keyName)) THEN

            -- If key is missing in target, copy it
            IF NOT JSON_CONTAINS_PATH(vResult, 'one', CONCAT('$.', keyName)) THEN
                SET vResult = JSON_SET(
                    vResult,
                    CONCAT('$.', keyName),
                    JSON_EXTRACT(pjSource, CONCAT('$.', keyName))
                );
            ELSE
                -- If key exists and is an object, merge recursively
                IF JSON_TYPE(JSON_EXTRACT(vResult, CONCAT('$.', keyName))) = 'OBJECT'
                   AND JSON_TYPE(JSON_EXTRACT(pjSource, CONCAT('$.', keyName))) = 'OBJECT' THEN
                    SET vResult = JSON_MERGE_PATCH(
                        vResult,
                        JSON_OBJECT(keyName, JSON_MERGE_PATCH(
                            JSON_EXTRACT(vResult, CONCAT('$.', keyName)),
                            JSON_EXTRACT(pjSource, CONCAT('$.', keyName))
                        ))
                    );
                END IF;
            END IF;

        END IF;

        SET i = i + 1;
    END WHILE;

    RETURN vResult;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `createAcustomerWallet` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `createAcustomerWallet`(
										IN p_customer_rec_id         INT,
										IN p_tradable_assets_rec_id  INT
									   )
BEGIN
    DECLARE v_customer_json     JSON;
    DECLARE v_asset_json        JSON;
    DECLARE v_wallet            JSON;
    DECLARE v_wallet_path       VARCHAR(100);
    DECLARE v_wallet_id         VARCHAR(100);

    /* ================= VALIDATE + LOAD CUSTOMER ================= */
    SELECT 	customer_json 
    INTO   	v_customer_json
    FROM   	customer
    WHERE  	customer_rec_id = p_customer_rec_id;

    IF v_customer_json IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer not found';
    END IF;

    /* ================= VALIDATE + LOAD ASSET ================= */
	SELECT 	tradable_assets_json
    INTO   	v_asset_json
    FROM   	tradable_assets
    WHERE  	tradable_assets_rec_id = p_tradable_assets_rec_id;
    

	IF v_asset_json IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tradable asset not found or unavailable';
    END IF;

    /* ============== CHECK WALLET EXISTS =============== */
    SET v_wallet_path = JSON_SEARCH(
                            v_customer_json,
                            'one',
                            JSON_UNQUOTE(JSON_EXTRACT(v_asset_json, '$.asset_code')),
                            NULL,
                            '$.customer_wallets[*].asset_code'
                        );

    IF v_wallet_path IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer wallet already exists for this asset';
    END IF;

    /* =============== GENERATE WALLET ID ============== */
    CALL getSequence(
					   'CUSTOMER.WALLET_ID',
					   'WID-',
						1122,
						'createCustomerWallet',
						@wallet_id
					);
    SET v_wallet_id = @wallet_id;

    /* =============== BUILD WALLET JSON ============= */
    SET v_wallet = fillTemplate(
								 v_asset_json,
								 getTemplate('customer_wallets')
								);

    SET v_wallet = JSON_SET( v_wallet,
							'$.wallet_id', 					v_wallet_id,
							'$.wallet_status', 				'OPEN',
							'$.wallet_balance', 			0,
							'$.balance_unit',  				'UNIT',
							'$.balance_last_updated_at', 	NOW()
						 );

    /* ================ APPEND WALLET ============ */
    SET v_customer_json = JSON_ARRAY_APPEND( v_customer_json,
											 '$.customer_wallets',
											  v_wallet
										   );

    /* =============== UPDATE CUSTOMER ============ */
    UPDATE customer
    SET customer_json 	= v_customer_json
    WHERE customer_rec_id = p_customer_rec_id;
    
	/* ================= Wallet_activity ============= */
	CALL wallet_activity(
						  p_customer_rec_id,     -- customer_rec_id
						  v_wallet_id,           -- wallet_id
						  'CREATE',              -- activity type
						  0,                     -- amount
						  'Wallet created'       -- reason
					    );

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `generate_audit_triggers_sql` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_audit_triggers_sql`(
    IN tbl_name VARCHAR(64),
    IN pk_col VARCHAR(64),
    IN json_col VARCHAR(64)
)
BEGIN

SELECT
		CONCAT(
				'DELIMITER $$

				CREATE TRIGGER after_update_', tbl_name, '
				AFTER UPDATE ON ', tbl_name, '
				FOR EACH ROW
				BEGIN
                
					  INSERT INTO update_logs
                      SET table_name		= ''', tbl_name, ''',
						  row_rec_id		= OLD.', pk_col, ',
                          prev_row_json		= OLD.', json_col, ',
                          next_row_json		= NEW.', json_col, ',
                          updated_at		= NOW();
						
				END$$
				
				DELIMITER ;'
			) AS update_trigger_sql,

		CONCAT(
				'DELIMITER $$

				CREATE TRIGGER after_delete_', tbl_name, '
				AFTER DELETE ON ', tbl_name, '
				FOR EACH ROW
				BEGIN
					 
					  INSERT INTO update_logs
                      SET table_name		= ''', tbl_name, ''',
						  row_rec_id		= OLD.', pk_col, ',
                          prev_row_json		= OLD.', json_col, ',
                          next_row_json		= NULL,
                          updated_at		= NOW();
						
				END$$

				DELIMITER ;'
			) AS delete_trigger_sql;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getSequence` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `getSequence`(
							IN  psColumnName       	VARCHAR(255),
							IN  psPrefix           	VARCHAR(255),
							IN  psStartingNumber   	INT,
                            IN  psRequestedBy		VARCHAR(255),
							OUT psSequenceNumber   	VARCHAR(255)
							)
BEGIN
    DECLARE v_prefix           	VARCHAR(255);
    DECLARE v_starting_number  	INT;
    DECLARE v_seq_id           	INT;
    
    DECLARE v_requested_by		VARCHAR(255);

    /* ==============================
       CASE Column-based
       ============================== */
    CASE psColumnName
        WHEN 'CUSTOMER.MAIN_ACCOUNT_NUM' THEN
            SET v_prefix 			= 'P-';
            SET v_starting_number 	= 500;

        WHEN 'ORDERS.ORDER_NUM' THEN
            SET v_prefix 			= 'ORD-';
            SET v_starting_number 	= 1000;

		WHEN 'EMPLOYEE.EMPLOYEE_NUM' THEN
            SET v_prefix 			= 'EMP-';
            SET v_starting_number 	= 2000;

        ELSE
            SET v_prefix 			= 'GEN-';
            SET v_starting_number 	= 1;
    END CASE;

    /* ==============================
       Override defaults
       ============================== */
    IF psPrefix IS NOT NULL AND psPrefix <> '' THEN
        SET v_prefix = psPrefix;
    END IF;

    IF psStartingNumber IS NOT NULL AND psStartingNumber > 0 THEN
        SET v_starting_number = psStartingNumber;
    END IF;
    
	/* ==============================
       Set default value for requested by
	============================== */
    IF psRequestedBy IS NULL OR psRequestedBy = '' THEN
        SET v_requested_by = 'SYSTEM';
    ELSE
        SET v_requested_by = psRequestedBy;
    END IF;

    /* ==============================
       Generate sequence
       ============================== */
	INSERT INTO seq_num
        SET column_name 		= psColumnName,
            sequence_value   	= 'TEMP',
            requested_by   		= v_requested_by;

		SET v_seq_id 			= LAST_INSERT_ID();

    /* ==============================
       Build final sequence
       ============================== */
    SET psSequenceNumber = CONCAT(v_prefix, v_starting_number + v_seq_id);
    
    /* ==============================
       Update stored sequence value
       ============================== */
    UPDATE seq_num
       SET sequence_value 	= psSequenceNumber
	   WHERE seq_rec_id = v_seq_id;
       
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `upsertCustomer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `upsertCustomer`(
								 IN  pjReqObj   JSON,
								 OUT psResObj   JSON
								)
BEGIN

    DECLARE v_customer_rec_id     		 	INT;
    DECLARE v_auth_rec_id         		 	INT;

    /* ===================== Customer Core ===================== */
    DECLARE v_customer_status     			VARCHAR(30) DEFAULT 'registration_request';
    DECLARE v_customer_type       			VARCHAR(30) DEFAULT 'personal';
    DECLARE v_email               			VARCHAR(100);
    DECLARE v_user_name           			VARCHAR(100);
    DECLARE v_password_plain      			VARCHAR(255);
    DECLARE v_password_hashed     			VARCHAR(255);
    DECLARE v_account_seq 		  			VARCHAR(255);
    DECLARE v_mode 							VARCHAR(20);

    /* ===================== JSON Objects ===================== */
    DECLARE v_customer_json       		JSON;
    DECLARE v_auth_json           		JSON;
    DECLARE v_row_metadata   			JSON;

    /* ===================== Validation Variables ===================== */
    DECLARE v_errors              		JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg       			TEXT;
    
   /* ===================== Variable for tradable_assets table and for cursor ===================== */
	DECLARE done 						INT;
	DECLARE v_tradable_asset_rec_id 	INT;

	DECLARE 	asset_cursor 			CURSOR FOR
    SELECT  	tradable_assets_rec_id
    FROM    	tradable_assets
    WHERE   	available_to_customers = TRUE  AND tradable_assets_rec_id > 0;

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	/* ===================== Error Handler ===================== */

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET psResObj = JSON_OBJECT(
									'status', 			'error',
									'status_code',		'1',
									'message', 			'Registration failed',
									'system_error',		v_err_msg
								   );
    END;
    /* ===================== Main ===================== */
    main_block: BEGIN

        /* ===================== Extract Scalars ===================== */
        SET v_email     		= getJval(pjReqObj, 'email');
        SET v_user_name 		= v_email;
	
            /* ===================== Set template values from Request Object ===================== */
        SET v_customer_json 			= fillTemplate(pjReqObj, getTemplate('customer'));
		SET v_row_metadata 				= getTemplate('row_metadata');
        
    SET v_mode =
				CASE
					WHEN isFalsy(getJval(pjReqObj,'customer_rec_id')) THEN
					'INSERT'
					ELSE
					'UPDATE'
				END;
                
		/* ========================================================================================= */
        /* ======================================= INSERT ========================================== */
        /* ========================================================================================= */
    
    CASE v_mode
        
		WHEN 'INSERT' THEN
        
            /* ===================== Validations ===================== */
			IF isFalsy(getJval(pjReqObj,'first_name')) THEN
				SET v_errors		= JSON_ARRAY_APPEND(v_errors,'$','First name is required');
			END IF;

			IF isFalsy(getJval(pjReqObj,'last_name')) THEN
				SET v_errors 		= JSON_ARRAY_APPEND(v_errors,'$','Last name is required');
			END IF;

			IF isFalsy(getJval(pjReqObj,'national_id')) THEN
				SET v_errors 		= JSON_ARRAY_APPEND(v_errors,'$','National ID is required');
			END IF;

			IF isFalsy(getJval(pjReqObj,'phone')) THEN
				SET v_errors 		= JSON_ARRAY_APPEND(v_errors,'$','Phone number is required');
			END IF;

			IF isFalsy(getJval(pjReqObj,'password')) THEN
				SET v_errors		= JSON_ARRAY_APPEND(v_errors,'$','Password is required');
			END IF;
        
        /* ===================== Check the INSERT uniqueness ===================== */

			IF EXISTS (
						SELECT 1 FROM customer
						WHERE national_id = getJval(pjReqObj,'national_id')
					  ) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$', 'Customer already exists with this National ID');
			END IF;

			IF EXISTS (
						SELECT 1 FROM customer
						WHERE email = v_email
					  ) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Email already exists');
			END IF;
            
			IF JSON_LENGTH(v_errors) > 0 THEN
			SET psResObj = JSON_OBJECT(
										'status', 				'error',
										'status_code', 			'1',
										'errors', 				v_errors
									   );
            LEAVE main_block;
			END IF;


			/* =============== CREATE CUSTOMER: INSERT NEW ROW IF REC ID NOT EXISTS in Request ============= */
            
			CALL getSequence('CUSTOMER.MAIN_ACCOUNT_NUM',NULL, NULL,'creatCustomer sp', v_account_seq);
        
			SET v_customer_json				= JSON_SET( v_customer_json,
														'$.customer_status',		v_customer_status,
														'$.customer_type', 			v_customer_type,
														'$.user_name', 				v_user_name,
														'$.main_account_number',	v_account_seq,
														'$.account_number',			v_account_seq
											  );
            
			SET v_row_metadata				= JSON_SET( v_row_metadata,
														'$.status', 		v_customer_status,   -- reg req
														'$.created_at',		DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
														'$.created_by', 	'SYSTEM'
														);
                                                   
			INSERT INTO customer
			SET customer_status 			= v_customer_status,		-- registration_request
					customer_type   		= v_customer_type,			-- personal
					first_name				= getJval(pjReqObj, 'first_name'),
					last_name				= getJval(pjReqObj, 'last_name'),
					user_name       		= v_user_name,
					email           		= v_email,
					phone           		= getJval(pjReqObj,'phone'),
					whatsapp_num    		= getJval(pjReqObj,'whatsapp_number'),
					national_id     		= getJval(pjReqObj,'national_id'),
					main_account_num       	= v_account_seq,
					account_num            	= v_account_seq,
					customer_json   		= v_customer_json,
					row_metadata    		= v_row_metadata;

			SET v_customer_rec_id 			= LAST_INSERT_ID();

			SET v_customer_json 			= JSON_SET( v_customer_json,
														'$.customer_rec_id', v_customer_rec_id
													  );

			UPDATE  customer
			SET 	customer_json  	= v_customer_json
			WHERE   customer_rec_id = v_customer_rec_id;
				
				 /* ---------- get Auth JSON ---------- */
			SET v_auth_json 	= getTemplate('auth');
                
				/* ===================== Password ===================== */
			SET v_password_plain  			= getJval(pjReqObj,'password');
			SET v_password_hashed 			= SHA2(v_password_plain,256);
            
            

				/* ---------- Prepare Auth JSON ---------- */
			SET v_auth_json					= JSON_SET( v_auth_json,
														'$.parent_table_name',						'customer',
														'$.parent_table_rec_id',					v_customer_rec_id,
														'$.user_name',								v_user_name,
														'$.login_credentials.password',				v_password_hashed,
														'$.login_credentials.username',				v_email                                               
													);
                                      
				/* ---------- Insert Auth ---------- */
			INSERT INTO auth
			SET parent_table_name   			= 'customer',
					parent_table_rec_id 		= v_customer_rec_id,
					user_name           		= v_user_name,
					auth_json           		= v_auth_json,
					row_metadata        		= v_row_metadata;

			SET v_auth_rec_id 	= LAST_INSERT_ID();
				
			SET v_auth_json 	= JSON_SET( v_auth_json,'$.auth_rec_id', v_auth_rec_id );

			UPDATE  auth
			SET 	auth_json 	  = v_auth_json
			WHERE   auth_rec_id = v_auth_rec_id;
            
            INSERT INTO password_history
			SET 	parent_table_name   		= 'customer',
					parent_table_rec_id 		= v_customer_rec_id,
					password_hash           	= v_password_hashed,
					password_set_at           	= DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
					password_changed_by        	= null,
                    password_change_reason		= 'Initial password setup',
                    last_password_updated_at	= DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
                    password_expiration_date	= DATE_ADD(NOW(),INTERVAL 90 DAY),
                    is_active					= TRUE;
                
				/* ===================== CREATE CUSTOMER WALLETS ===================== */
			
            SET done = FALSE;
			OPEN asset_cursor;

				asset_loop: LOOP
				FETCH asset_cursor INTO v_tradable_asset_rec_id;
				IF done THEN
					LEAVE asset_loop;
				END IF;
			
				CALL createAcustomerWallet(v_customer_rec_id,v_tradable_asset_rec_id);
		
				END LOOP asset_loop;

			CLOSE asset_cursor;
            




		/* ***************************************************************************************** */            
		/* ***************************************************************************************** */            
		/* ***************************************************************************************** */            
		/* ***************************************************************************************** */     
        
        
        
		
		WHEN 'UPDATE' THEN
        
				SET v_customer_rec_id 		= getJval(pjReqObj,'customer_rec_id');
                
		/* ===================== Update Validations ===================== */
            
		/* ===================== UPDATE must target existing record ===================== */
			IF NOT EXISTS (
							SELECT 1 FROM customer
							WHERE customer_rec_id = v_customer_rec_id
						  ) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Invalid customer_rec_id: record does not exist');
			END IF;

	 /* ===================== Check NIC Uniqueness ===================== */
			IF EXISTS (
						SELECT 1 FROM customer
						WHERE national_id	 = getJval(pjReqObj,'national_id')
						AND customer_rec_id  <> v_customer_rec_id
					  ) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$', 'National ID already used by another customer');
			END IF;
	
    /* ===================== Check Email Uniqueness ===================== */
			IF EXISTS (
					SELECT 1 FROM customer
					WHERE email = v_email
					AND customer_rec_id <> v_customer_rec_id
				) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Email already used by another customer');
            END IF;
            
   /* ===================== Stop if errors  ===================== */
			IF JSON_LENGTH(v_errors) > 0 THEN
            SET psResObj = JSON_OBJECT(
										'status', 				'error',
										'status_code', 			'1',
										'errors', 				v_errors
									   );
            LEAVE main_block;
			END IF;
            
			 /* =============== Customer Profile and password update: UPDATE EXISTING ROW IF REC ID EXISTS in Request ============= */
            
             /* =============== fil existed CustomerJson from reqObj ============= */
			SET v_customer_json = fillTemplate(pjReqObj, getCustomer(v_customer_rec_id));
            
            SELECT 	row_metadata
            INTO 	v_row_metadata
            FROM 	customer
            WHERE 	customer_rec_id = v_customer_rec_id;
				
			SET v_row_metadata	  		= JSON_SET( v_row_metadata,
													'$.status',			COALESCE(getJval(pjReqObj, 'customer_status'),	v_customer_status),	
													'$.updated_by', 	'SYSTEM',
													'$.updated_at', 	DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
												 );
			
			UPDATE customer
			SET customer_status 			= COALESCE(getJval(v_customer_json, 'customer_status'),		 v_customer_status),		-- registration_request
				customer_type   			= COALESCE(getJval(v_customer_json, 'customer_type'),		 v_customer_type),			-- personal
                corporate_account_rec_id	= getJval(pjReqObj, 'corporate_account_rec_id'),			
				first_name					= getJval(v_customer_json, 'first_name'),
				last_name					= getJval(v_customer_json, 'last_name'), 						
				user_name       			= getJval(v_customer_json, 'email'), 						
				email           			= getJval(v_customer_json, 'email'), 							
				phone           			= getJval(v_customer_json,'phone'),							
				whatsapp_num    			= getJval(v_customer_json,'whatsapp_number'),					
				national_id     			= getJval(v_customer_json,'national_id'),						
				customer_json   			= v_customer_json,
				row_metadata    			= v_row_metadata
				WHERE customer_rec_id		= v_customer_rec_id;
				
                
			/* =============== get existed AuthJson ============= */
                
            SET v_auth_json			= getAuth(v_customer_rec_id);
            
            		/* ---------- update Auth Json ---------- */
			SET v_auth_json					= JSON_SET( v_auth_json,
														'$.user_name',								getJval(v_customer_json, 'email'),
														'$.login_credentials.username',				getJval(v_customer_json, 'email')                                               
													);
												   
			/* ---------- Update password if provided  ---------- */
            IF NOT isFalsy(getJval(pjReqObj,'password')) THEN
            
					SET v_password_plain  		= getJval(pjReqObj,'password');
					SET v_password_hashed 		= SHA2(v_password_plain,256);
					
					UPDATE  password_history
					SET 	is_active 				= FALSE
					WHERE   parent_table_name 		= 'customer'
					AND 	parent_table_rec_id 	= v_customer_rec_id
					AND 	is_active 				= TRUE;

					INSERT INTO password_history
					SET parent_table_name         	= 'customer',
						parent_table_rec_id       	= v_customer_rec_id,
						password_hash             	= v_password_hashed,
						password_set_at           	= DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
						password_changed_by 		= CONCAT(getJval(v_customer_json, 'first_name'),' ', getJval(v_customer_json, 'last_name')),
						password_change_reason    	= 'UPDATE',
						last_password_updated_at  	= DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s'),
						password_expiration_date  	= DATE_ADD(NOW(), INTERVAL 90 DAY),
						is_active                 	= TRUE;

					SET v_auth_json 				= JSON_SET( v_auth_json, '$.login_credentials.password', v_password_hashed );
			 END IF;
	

				/* ---------- Update Auth table with  ---------- */
			UPDATE auth
			SET   user_name        		= COALESCE(getJval(pjReqObj, 'email'),getJval(v_auth_json, 'user_name')),
				  auth_json        		= v_auth_json,
				  row_metadata     		= v_row_metadata
			WHERE parent_table_rec_id 	= v_customer_rec_id;
				
			IF ROW_COUNT() = 0 THEN
				SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Update failed: no rows affected';
			END IF;

	END CASE;



		        /* ===================== Successful Registration ===================== */
		SET psResObj = JSON_OBJECT(
									'status', 'success',
									'status_code', '0',
									'message',
									IF(isFalsy(getJval(pjReqObj,'customer_rec_id')),
									   'Customer created successfully',
									   'Customer updated successfully'
                                   )
		);
    END main_block;
    
	-- inert general code here like LOG
	-- call log proc
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `upsertInventory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `upsertInventory`(
								IN  pjReqObj JSON,
								OUT psResObj JSON
							  )
BEGIN
    /* ================ VARIABLE DECLARATIONS ================ */
    
	DECLARE v_inventory_rec_id      INT;
    DECLARE v_mode 					VARCHAR(20);
    
    DECLARE v_inventory_json        JSON;
    DECLARE v_row_metadata          JSON;
	DECLARE v_product_json			JSON;

    DECLARE v_errors                JSON DEFAULT JSON_ARRAY();
    DECLARE v_err_msg               VARCHAR(1000);

    /* =============== GLOBAL ERROR HANDLER ============ */

    -- EXIT HANDLER for any SQL exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
        SET psResObj = JSON_OBJECT(
                                'status', 'error',
                                'message', 'Inventory creation failed',
                                'system_error', v_err_msg
                                );
    END;

    main_block: BEGIN
    
    SET v_mode =
                CASE
                    WHEN isFalsy(getJval(pjReqObj,'inventory_rec_id')) THEN
                    'INSERT'
                    ELSE
                    'UPDATE'
				END;
                    
	CASE v_mode
    
    WHEN 'INSERT' THEN

    /* =============== INVENTORTY Insert VALIDATIONS : If required fields are missing in reqObj ================ */

		IF isFalsy(getJval(pjReqObj,'product_rec_id')) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','product_rec_id is required');
		END IF;

		IF isFalsy(getJval(pjReqObj,'item_name')) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','item_name is required');
		END IF;

		IF isFalsy(getJval(pjReqObj,'item_type')) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','item_type is required');
		END IF;

		IF isFalsy(getJval(pjReqObj,'availability_status')) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','availability_status is required');
		END IF;

		IF JSON_LENGTH(v_errors) > 0 THEN
			SET psResObj = JSON_OBJECT(
									   'status',      'error',
									   'status_code', '1',
									   'errors',      v_errors
									);
        LEAVE main_block;
        END IF;

        /* =============== CREATE INVENTORY: Inventory Insertation started ================ */

        /* ============= JSON PREPARATION =========== */

        SET v_inventory_json 	= getTemplate('inventory');

            -- fill template from reqJson
    
        SET v_inventory_json 	= fillTemplate(pjReqObj, v_inventory_json);
        
        SET v_row_metadata   	= getTemplate('row_metadata');

        SET v_row_metadata      = JSON_SET(v_row_metadata,
                                            '$.created_by', 'SYSTEM',
											'$.created_at', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                                         );

        INSERT INTO inventory
        SET product_rec_id       = getJval(pjReqObj,'product_rec_id'),
            item_name            = getJval(pjReqObj,'item_name'),
            item_type            = getJval(pjReqObj,'item_type'),
            asset_type           = getJval(pjReqObj,'asset_type'),
            availability_status  = getJval(pjReqObj,'availability_status'),
            inventory_json       = v_inventory_json,
            row_metadata         = v_row_metadata;

        SET v_inventory_rec_id   = LAST_INSERT_ID();

        -- Sync REC ID back into Inventory JSON
        SET v_inventory_json = JSON_SET(v_inventory_json,'$.inventory_rec_id', v_inventory_rec_id);

        -- get json of existed product from product table
        
         SET v_product_json     = getProduct(getJval(pjReqObj,'product_rec_id'));

		-- fill the inventory json from product json
		SET v_inventory_json 	= mergeIfMissing( v_inventory_json,
													JSON_ARRAY(
																'product_quality',
																'approximate_weight',
																'weight_unit',
																'is_physical',
																'is_SliceAble',
																'standard_price',
																'standard_premium',
																'price_currency',
																'applicable_taxes',
																'quantity_on_hand',
																'minimum_order_quantity',
																'total_sold',
																'offer_to_customer',
																'display_order',
																'Alert_on_low_stock',
																'transaction_fee'
																),
													v_product_json
												);

        UPDATE  inventory
        SET 	inventory_json = v_inventory_json
        WHERE  inventory_rec_id = v_inventory_rec_id; 


    /* =============== UPDATE Inventory: Product UPDATION started ================ */

    WHEN 'UPDATE' THEN
        
        /* =============== Inventory Insert VALIDATIONS: UPDATE must target existing record ================ */
        SET v_inventory_rec_id = getJval(pjReqObj,'inventory_rec_id');
     
		IF v_inventory_rec_id IS NOT NULL
		AND NOT EXISTS (
                          SELECT 1
                          FROM   inventory
                          WHERE  inventory_rec_id = getJval(pjReqObj,'inventory_rec_id')
                        ) THEN
                                                              
			   SET v_errors = JSON_ARRAY_APPEND( v_errors,'$','Invalid inventory_rec_id: record does not exist');
		END IF;

    
    IF JSON_LENGTH(v_errors) > 0 THEN
        SET psResObj = JSON_OBJECT(
								   'status',      'error',
								   'status_code', '1',
								   'errors',      v_errors
                                );
        LEAVE main_block;
    END IF;

             /* =============== Update started: update the existed row ================ */   

        SET v_inventory_json = getInventory(v_inventory_rec_id);

        SET v_inventory_json = fillTemplate(pjReqObj,v_inventory_json);

        SELECT  row_metadata
        INTO 	v_row_metadata
        FROM 	inventory
        WHERE 	inventory_rec_id = v_inventory_rec_id;

        SET v_row_metadata = JSON_SET( v_row_metadata,
										'$.updated_by', 'SYSTEM',
										'$.updated_at', DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
                                  );

        UPDATE inventory
        SET product_rec_id       = getJval(v_inventory_json,'product_rec_id'),	
            item_name            = getJval(v_inventory_json,'item_name'), 		
            item_type            = getJval(v_inventory_json,'item_type'), 		
            asset_type           = getJval(v_inventory_json,'asset_type'), 		
            availability_status  = getJval(v_inventory_json,'availability_status'),
            inventory_json       = v_inventory_json,
            row_metadata         = v_row_metadata
        WHERE inventory_rec_id   = v_inventory_rec_id;

        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Update failed: no rows affected';
        END IF;
	END CASE;

    SET psResObj = JSON_OBJECT(
                                'status',      'success',
                                'status_code', '0',
                                'message',     IF(isFalsy(getJval(pjReqObj,'inventory_rec_id')),
												   'Inventory saved successfully',
												   'Inventory updated successfully'
													)
                              );

    END main_block;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `upsertProduct` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `upsertProduct`(
								IN  pjReqObj JSON,
								OUT psResObj JSON
							  )
BEGIN
		/* ================ VARIABLE DECLARATIONS ================ */

		DECLARE v_product_rec_id         	INT;
        DECLARE v_tradable_assets_rec_id	INT;
        DECLARE v_mode 						VARCHAR(20);
        
		DECLARE v_products_json          	JSON;
		DECLARE v_row_metadata           	JSON;
    
		DECLARE v_errors 					JSON 				DEFAULT JSON_ARRAY();
		DECLARE v_err_msg       		    VARCHAR(1000);

    /* =============== GLOBAL ERROR HANDLER ============ */

		-- EXIT HANDLER for any SQL exception
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
				GET STACKED DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
				SET psResObj = JSON_OBJECT(
											'status', 'error',
											'message', 'Product creation failed',
											'system_error', v_err_msg
											);
		END;

	main_block: BEGIN
     
     	SET v_mode =
					CASE
						WHEN isFalsy(getJval(pjReqObj,'product_rec_id')) THEN
						'INSERT'
						ELSE
						'UPDATE'
					END;
	
    CASE v_mode
    
		WHEN 'INSERT' THEN

			/* =============== Product Insert VALIDATIONS : If required fields are missing in reqObj ================ */

			IF isFalsy(getJval(pjReqObj,'tradable_assets_rec_id')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','tradable_assets_rec_id is required');
			END IF;
			
			IF isFalsy(getJval(pjReqObj,'asset_code')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','asset_code is required');
			END IF;
			
			IF isFalsy(getJval(pjReqObj,'product_code')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','product_code is required');
			END IF;
			
			IF isFalsy(getJval(pjReqObj,'product_name')) THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','product_name is required');
			END IF;
    
			/* =============== Duplicate product code check for INSERT ================ */
		   IF EXISTS (
						SELECT 1
						FROM products
						WHERE product_code = getJval(pjReqObj,'product_code')
					) 	THEN
				SET v_errors = JSON_ARRAY_APPEND(v_errors,'$',CONCAT('Product already exists with product_code: ', getJval(pjReqObj,'product_code')));
		   END IF;
       
	   	/* =============== Show errors in array in response Obj ================ */  
		   IF JSON_LENGTH(v_errors) > 0 THEN
		   SET psResObj = JSON_OBJECT(
									   'status', 		 'error',
									   'status_code', 	 '1',
									   'errors',	 	 v_errors
										);
		   LEAVE main_block;
		   END IF;


			/* =============== CREATE PRODUCT: Product Insertation started ================ */
            
                /* ============= JSON PREPARATION ================== */
    
		 SET v_products_json 	= getTemplate('products');
		 SET v_products_json 	= fillTemplate(pjReqObj, v_products_json);
			
		 SET v_row_metadata		= getTemplate('row_metadata');
		 SET v_row_metadata 	= JSON_SET( v_row_metadata,
											'$.created_by', 	'SYSTEM',
											'$.created_at', 	 DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
										  );

		 INSERT INTO products
				SET	tradable_assets_rec_id		= getJval(pjReqObj,	 'tradable_assets_rec_id'),
					asset_code					= getJval(pjReqObj,	  'asset_code'),
					product_code				= getJval(pjReqObj,	  'product_code'),
					product_type				= getJval(pjReqObj,	  'product_type'),
					product_name				= getJval(pjReqObj,	  'product_name'),
					products_json				= v_products_json,
					row_metadata				= v_row_metadata;
					
				SET v_product_rec_id 			= LAST_INSERT_ID();

				-- Sync generated ID back into JSON
				SET v_products_json 			= JSON_SET( v_products_json,
															'$.product_rec_id', v_product_rec_id
														  );

				UPDATE products
				SET    products_json 	= v_products_json
				WHERE  product_rec_id 	= v_product_rec_id;
    
    

    /* =============== UPDATE PRODUCT: Product UPDATION started ================ */

    WHEN 'UPDATE' THEN

      	/* =============== Product Insert VALIDATIONS: UPDATE must target existing record ================ */

		SET v_product_rec_id = getJval(pjReqObj,'product_rec_id');
      
		IF v_product_rec_id IS NOT NULL
		AND NOT EXISTS (
						SELECT 1
						FROM products
						WHERE product_rec_id = v_product_rec_id
					 )  THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$','Invalid product_rec_id: record does not exist');

		END IF;
        
    /* =============== Duplicate check with other rows except the updated row ================ */  
    
        IF EXISTS (
					SELECT 1
					FROM products
					WHERE product_code = getJval(pjReqObj,'product_code')
					AND product_rec_id <> v_product_rec_id
					) THEN
			SET v_errors = JSON_ARRAY_APPEND(v_errors,'$',CONCAT('Product already exists with product_code: ', getJval(pjReqObj,'product_code')));
		END IF;	
    
	/* =============== Show errors in array in response Obj ================ */  
		IF JSON_LENGTH(v_errors) > 0 THEN
			SET psResObj = JSON_OBJECT(
									   'status', 		 'error',
									   'status_code', 	 '1',
									   'errors',	 	 v_errors
										);
		LEAVE main_block;
		END IF;
        
     /* =============== Update started ================ */    


        SET v_products_json 	= getProduct(v_product_rec_id);

		SET v_products_json 	= fillTemplate(pjReqObj, v_products_json);

		SELECT 	row_metadata
		INTO 	v_row_metadata
		FROM 	products
		WHERE 	product_rec_id = v_product_rec_id;

        SET v_row_metadata = JSON_SET(
										v_row_metadata,
										'$.updated_by', 	'SYSTEM',
										'$.updated_at', 	DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s')
									);
		

        
        UPDATE products
        SET tradable_assets_rec_id		= getJval(v_products_json, 'tradable_assets_rec_id'),
			asset_code					= getJval(v_products_json, 'asset_code'), 			
            product_code				= getJval(v_products_json, 'product_code'),			
            product_type				= getJval(v_products_json, 'product_type'),			
            product_name				= getJval(v_products_json, 'product_name'),			
            products_json				= v_products_json,
			row_metadata				= v_row_metadata
		WHERE product_rec_id			= v_product_rec_id;
        
		IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Update failed: no rows affected';
        END IF;
    END CASE;

    SET psResObj = JSON_OBJECT(
								'status', 		 'success',
								'status_code',   '0',
								'message',        IF(isFalsy(getJval(pjReqObj,'product_rec_id')),
												   'Product saved successfully',
												   'Product updated successfully'
													)
							);
    
    
     END main_block;
     
     -- inert general code here like LOG
	-- call log proc
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `wallet_activity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `wallet_activity`(
									IN p_customer_rec_id  		INT,
									IN p_wallet_id 				VARCHAR(100),
									IN p_activity_type 			ENUM('CREATE','CREDIT','DEBIT'),
									IN p_amount 				DECIMAL(20,6),
									IN p_reason 				VARCHAR(255)
								)
BEGIN
    /* =============== VARIABLE DECLARATIONS ============= */
    DECLARE v_wallet_index 			INT;
    DECLARE v_wallet_path 			VARCHAR(100);

    DECLARE v_wallet_balance 		DECIMAL(20,6);
    DECLARE v_new_balance 			DECIMAL(20,6);

    DECLARE v_asset_code 			VARCHAR(10);
    DECLARE v_asset_name 			VARCHAR(50);
    DECLARE v_wallet_title 			VARCHAR(100);
    DECLARE v_account_number 		VARCHAR(100);

    DECLARE v_wallet_ledger_json 	JSON;
    DECLARE v_row_metadata			JSON;



    START TRANSACTION;

    /* ================ LOCK CUSTOMER ROW =========== */
	SELECT 	account_num
	INTO 	v_account_number
	FROM 	customer
	WHERE 	customer_rec_id = p_customer_rec_id
	FOR UPDATE;

    /* ================ FIND WALLET PATH Example: $.customer_wallets[2].wallet_id============== */
    SELECT JSON_UNQUOTE(
						JSON_SEARCH( customer_json,
										'one',
										p_wallet_id,
										NULL,
										'$.customer_wallets[*].wallet_id'
									)
					  )
						INTO v_wallet_path
						FROM customer
						WHERE customer_rec_id = p_customer_rec_id;

    IF v_wallet_path IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Wallet not found for customer';
    END IF;

    /* ==============================
       EXTRACT WALLET INDEX
    ============================== */
    SET v_wallet_index = CAST(REGEXP_REPLACE(v_wallet_path, '[^0-9]', '') AS UNSIGNED);


    /* ==============================
       READ WALLET DATA
    ============================== */
    SELECT
			JSON_UNQUOTE(JSON_EXTRACT(customer_json, CONCAT('$.customer_wallets[', v_wallet_index, '].wallet_balance'))),
			JSON_UNQUOTE(JSON_EXTRACT(customer_json, CONCAT('$.customer_wallets[', v_wallet_index, '].asset_code'))),
			JSON_UNQUOTE(JSON_EXTRACT(customer_json, CONCAT('$.customer_wallets[', v_wallet_index, '].asset_name')))
    INTO
			v_wallet_balance,
			v_asset_code,
			v_asset_name
    FROM 	customer
    WHERE 	customer_rec_id = p_customer_rec_id
    FOR UPDATE;

    SET v_wallet_balance 	= COALESCE(v_wallet_balance, 0);
    SET v_wallet_title 		= CONCAT(v_asset_name, ' Wallet');

    /* ==============================
       BALANCE CALCULATION
    ============================== */
    IF p_activity_type = 'CREDIT' THEN
        SET v_new_balance = v_wallet_balance + p_amount;
        
    ELSEIF p_activity_type = 'DEBIT' THEN
    
        IF v_wallet_balance < p_amount THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient wallet balance';
            
        END IF;
        
        SET v_new_balance = v_wallet_balance - p_amount;
    ELSE
    
        SET v_new_balance = v_wallet_balance;
    END IF;

		/* ==============================
			LOAD LEDGER TEMPLATE
		============================== */
	SET v_wallet_ledger_json = getTemplate('wallet_ledger');
    
	SET v_wallet_ledger_json = JSON_SET( v_wallet_ledger_json,
										'$.customer_rec_id',		 					p_customer_rec_id,
										'$.account_number', 							v_account_number,
										'$.wallet_id', 									p_wallet_id,
										'$.wallet_title', 								v_wallet_title,
										'$.asset_code',									v_asset_code,
										'$.asset_name', 								v_asset_name,
										'$.transaction_type', 							p_activity_type,

										'$.ledger_transaction.transaction_at', 			NOW(),
										'$.ledger_transaction.transaction_reason', 		p_reason,
										'$.ledger_transaction.balance_before', 			v_wallet_balance,
										'$.ledger_transaction.debit_amount',			IF(p_activity_type='DEBIT', p_amount, 0),
										'$.ledger_transaction.credit_amount',			IF(p_activity_type='CREDIT', p_amount, 0),
										'$.ledger_transaction.balance_after', 			v_new_balance,
										'$.initiated_by_info.initiated_by', 			'SYSTEM',
										'$.initiated_by_info.initiated_by_name', 		'System Auto'
										);

    /* ==============================
       INSERT LEDGER
    ============================== */
    SET v_row_metadata			= getTemplate('row_metadata');
    
    INSERT INTO wallet_ledger
    SET customer_rec_id 		= p_customer_rec_id,
		account_number			= v_account_number,
        wallet_id				= p_wallet_id,
        wallet_title			= v_wallet_title,
        asset_code				= v_asset_code,
        asset_name				= v_asset_name,
        transaction_type		= CASE p_activity_type WHEN 'CREATE' THEN 'WALLET_CREATE' ELSE p_activity_type END,
        wallet_ledger_json		= v_wallet_ledger_json,
        row_metadata			= JSON_SET(v_row_metadata,
											'$.created_at', NOW(),
											'$.created_by', 'SYSTEM'
											);
                                            
    /* ==============================
       UPDATE WALLET BALANCE
    ============================== */
    IF v_new_balance <> v_wallet_balance THEN
    UPDATE customer
    SET customer_json = JSON_SET(customer_json,
								  CONCAT('$.customer_wallets[', v_wallet_index, '].wallet_balance'), v_new_balance,
								  CONCAT('$.customer_wallets[', v_wallet_index, '].balance_last_updated_at'), NOW()
								)
    WHERE customer_rec_id = p_customer_rec_id;
    END IF;
    
    COMMIT;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-02 13:28:31
