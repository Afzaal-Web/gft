DELIMITER $$
CREATE FUNCTION isFalsy(val TEXT) RETURNS tinyint(1)
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
END $$
DELIMITER ;