 -- ===================== log the activity of customer wallet in wallet_ledger =====================
 CALL wallet_activity(
    2,                -- customer_rec_id
    'WID-1133',       -- wallet_id
    'CREDIT',           -- txn_type
    250,              -- amount
    'balance credited'    -- remarks
);