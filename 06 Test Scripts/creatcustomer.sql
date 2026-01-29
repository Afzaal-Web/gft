SET @pjReqObj = JSON_OBJECT(
    'first_name',        'ahmad',
    'last_name',         'hassan',
    'email',             'ahmadhassan@testmail.com',
    'phone',             '+92301-4344444',
    'whatsapp_number',   '+92301-4344444',
    'national_id',       '43435344564-678678',
    'password',          'Test@1234',

    'city',              'New York',
    'state',             'NY',
    'country',           'USA',
    'latitude',          40.7128,
    'longitude',         -74.0060
);

CALL createCustomer(@pjReqObj, @psResult);

SELECT @psResult AS result;
