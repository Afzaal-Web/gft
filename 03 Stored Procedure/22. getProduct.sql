DROP PROCEDURE IF EXISTS getProduct;

DELIMITER $$

CREATE PROCEDURE getProduct(
    IN  pProductRecId   INT,
    OUT p_product_json  JSON
)
BEGIN
    -- Fetch product JSON
    SELECT products_json
    INTO p_product_json
    FROM products
    WHERE product_rec_id = pProductRecId
    LIMIT 1;

    -- If not found
    IF p_product_json IS NULL THEN
        SET p_product_json = JSON_OBJECT(
            'status', 'error',
            'message', 'Product does not exist',
            'product_rec_id', pProductRecId
        );
    END IF;

END $$

DELIMITER ;
