/* ==========================================================
   Test Case 1: Deposit using E-Wallet
   All fields on root, nested sender/receiver info
   ========================================================== */

SET @reqObj = JSON_OBJECT(
    'customer_rec_id', 1,
    'request_type', 'deposit',
    'transaction_type', 'e wallets',
    'amount', 5000,

    /* ---------------- Sender Info ---------------- */
    'sender_info', JSON_OBJECT(
        'initiated_by', 'Ali Khan',
        'institution_name', 'Jazz',
        'account_holder_name', 'John smith',
        'account_number', '03300-3398393',
        'amount_sent', 22000.00,
        'transaction_id', 'TXN-2026-001',
        'receipt_number', 'rec-112323',
        'receipt_picture_rec_id', 121,
        'trans_at', '2026-02-03 09:00:00'
    ),

    /* ---------------- Receiver Info ---------------- */
    'receiver_info', JSON_OBJECT(
        'institution_name', 'EasyPaisa',
        'account_holder_name', 'GFT company',
        'account_number', 'PK12345566',
        'amount_received', 22000.00,
        'received_at', '2026-02-03 09:30:00',
        'processing_fee', 0
    )
);


SET @reqObj = CAST('{
						  "customer_rec_id":          1,
						  "request_type":            "deposit",
						  "transaction_type":         "cash deposit",

						  "sender_info": {
							"initiated_by":            "Ali Khan",
							"institution_name":        "Jazz",
							"account_holder_name":     "John smith",
							"account_number":          "03300-3398393",
							"amount_sent":             "22000.00",
							"transaction_id":          "TXN-2026-001",
							"receipt_number":          "rec-112323",
							"receipt_picture_rec_id":  121,
							"trans_at":                "2026-02-03 09:00:00"
						  },

						  "receiver_info": {
							"institution_name":        "EasyPaisa",
							"account_holder_name":     "GFT company",
							"account_number":          "PK12345566",
							"amount_received":         "22000.00",
							"received_at":             "2026-02-03 09:30:00",
							"processing_fee":          0
						  }
						}' AS JSON);

CALL createMoneyTransaction(@reqObj, @resObj);
SELECT @resObj AS response;

-- update
SET @reqObj = CAST('{
							
							"money_manager_rec_id": 1,
                            "backoffice_post_number": "GFT0011",
                            "trans_posted_at": "10/11/2026 10:41",
                            
						    "status":    "posted",        
							"user_name": "Kamran.iqbal@gmail.com",        
							"action_by": "Kamran Iqbal",               
							"action_at": "2026-01-14 16:10:00",        
							"notes":     "transaction is posted"
							
							
							
							            
									
						}' AS JSON);

CALL updateMoneyTransaction(@reqObj, @resObj);
SELECT @resObj AS response;
  

/* ==========================================================
   Test Case 2: Withdraw using E-Wallet
   All fields on root, nested sender/receiver info
   ========================================================== */

SET @reqObj = JSON_OBJECT(
    'customer_rec_id', 1,
    'status', NULL,
    'account_number', 'MM-ACC-WD-EW-1003',
    'request_type', 'withdraw',
    'transaction_type', 'e wallets',
    'backoffice_post_number', NULL,
    'trans_posted_at', NULL,
    'amount', 8000,


    /* ---------------- Receiver Info ---------------- */
    'receiver_info', JSON_OBJECT(
      'initiated_by', 'Bilal Raza',
        'institution_name', 'GFT Wallet',
        'account_holder_name', 'Bilal Raza',
        'account_number', 'MM-ACC-WD-EW-1003',
        'amount_sent', 8000.00,
        'transaction_id', 'WD-EW-2026-003',
        'receipt_number', NULL,
        'receipt_picture_rec_id', NULL,
        'trans_at', '2026-02-03 10:00:00'
    ),

    /* ---------------- Lifecycle ---------------- */
    'life_cycle', JSON_ARRAY()
);

CALL createMoneyTransaction(@reqObj, @resObj);
SELECT @resObj AS response;


/* ==========================================================
   Test Case 3: Deposit using Credit Card
   All fields on root, nested sender/receiver info
   ========================================================== */

SET @reqObj = JSON_OBJECT(
    'customer_rec_id', 1,
    'status', NULL,
    'account_number', 'MM-ACC-DP-CC-1005',
    'request_type', 'deposit',
    'transaction_type', 'credit card',
    'backoffice_post_number', NULL,
    'trans_posted_at', NULL,
    'amount', 12000,

    /* ---------------- Credit Card Info ---------------- */
    'card_number', '41111111111124122',
    'cvv2', '123',
    'processor_name', 'Visa',
    'processor_token', 'tok_visa_2026',

    /* ---------------- Sender Info ---------------- */
    'sender_info', JSON_OBJECT(
        'initiated_by', 'Sara Ali',
        'institution_name', 'Visa Bank',
        'account_holder_name', 'Sara Ali',
        'account_number', 'MM-ACC-DP-CC-1005',
        'amount_sent', 12000.00,
        'transaction_id', 'DP-CC-2026-005',
        'receipt_number', NULL,
        'receipt_picture_rec_id', NULL,
        'trans_at', '2026-02-03 11:00:00'
    ),

    /* ---------------- Receiver Info ---------------- */
    'receiver_info', JSON_OBJECT(
        'institution_name', 'GFT Wallet',
        'account_holder_name', 'Sara Ali',
        'account_number', 'MM-ACC-DP-CC-1005',
        'amount_received', 12000.00,
        'received_at', '2026-02-03 11:30:00',
        'processing_fee', 50.00
    )

   
);

SET @reqObj = CAST('{
						  "customer_rec_id":          1,
						  "request_type":            "deposit",
						  "transaction_type":         "credit card",
                          "processor_name":			 "Visa",
                          "processor_token":		 "tok_visa_2026",

						  "sender_info": {
							"initiated_by":            "Ali Khan",
							"institution_name":        "Credit Card",
							"account_holder_name":     "Ali Khan",
							"account_number":          "4520 111 222 333",
							"amount_sent":             "22000",
							"transaction_id":          "TXN-2026-001",
							"trans_at":                "2026-02-03 09:00:00"
						  },

						  "receiver_info": {
							"institution_name":        "Stripe",
							"account_holder_name":     "GFT company",
							"account_number":          "Stripe123",
							"amount_received":         "19900.00",
							"received_at":             "2026-02-03 09:30:00",
							"processing_fee":          330.00
						  },
                          
                            "card_info": {
							"card_type":               "visa",
							"card_number":             "4520 111 222 333",
							"card_holder_name":        "Ali Khan",
							"card_expiration_date":    "2026-02-03 09:30:00",
							"cvv2":                    321
                            }
						}' AS JSON);
                       
CALL createMoneyTransaction(@reqObj, @resObj);
SELECT @resObj AS response;
