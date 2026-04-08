 -- ===================== log the activity of customer wallet in wallet_ledger =====================
 CALL wallet_activity(
    1,                -- customer_rec_id
    'WID-1218',       -- wallet_id
    'CREDIT',           -- txn_type
    1222250,              -- amount
    'balance credited',    -- remarks
    NULL,
    NULL,
    NULL
);