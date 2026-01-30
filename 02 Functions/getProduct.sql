
DROP FUNCTION IF EXISTS getProduct;

DELIMITER $$

CREATE FUNCTION getProduct(pProductRecId INT)
RETURNS JSON
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
END $$

DELIMITER ;

SELECT getProduct(6);
 
