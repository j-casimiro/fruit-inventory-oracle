CREATE OR REPLACE PACKAGE FruitInventory_Pkg AS
    PROCEDURE GetAllFruits(p_cursor OUT SYS_REFCURSOR);
        
    PROCEDURE AddFruit(
        p_fruitname IN VARCHAR2,
        p_fruittype IN VARCHAR2
    );
        
    PROCEDURE UpsertInventory(
        p_fruitid IN NUMBER,
        p_price IN NUMBER,
        p_stock IN NUMBER
    );
    
    PROCEDURE UpdateStock(
        p_fruitid IN NUMBER,
        p_changetype IN VARCHAR2,
        p_quantitychanged IN NUMBER
    );
        
END FruitInventory_Pkg;
/

CREATE OR REPLACE PACKAGE BODY FruitInventory_Pkg AS
    
    PROCEDURE GetAllFruits(p_cursor OUT SYS_REFCURSOR) AS
    BEGIN
        OPEN p_cursor FOR
        SELECT f.FruitID, f.FruitName, f.FruitType,
               i.InventoryID, i.Price, i.Stock
        FROM Fruits f
        LEFT JOIN INVENTORY i ON f.FRUITID = i.FRUITID;
    END;
        
    PROCEDURE AddFruit(p_fruitName IN VARCHAR2, p_fruittype IN VARCHAR2) AS
    BEGIN
        INSERT INTO Fruits (FRUITNAME, FRUITTYPE) 
        VALUES (p_fruitName, p_fruittype);
    END;
        
    PROCEDURE UpsertInventory(
        p_fruitid IN NUMBER,
        p_price IN NUMBER,
        p_stock IN NUMBER
    ) AS v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM INVENTORY WHERE FruitID = p_fruitid;
        
        IF v_count = 0 THEN
            INSERT INTO INVENTORY (FRUITID, PRICE, STOCK) VALUES (p_fruitid, p_price, p_stock);
        ELSE
            UPDATE Inventory
            SET Price = p_price,
                Stock = p_stock
            WHERE FruitID = p_fruitid;
        END IF;
    END;

    PROCEDURE UpdateStock(
        p_fruitid IN NUMBER,
        p_changetype IN VARCHAR2,
        p_quantitychanged IN NUMBER
    ) AS
        v_new_stock NUMBER;
    BEGIN
        -- Insert transaction
        INSERT INTO Transactions (FruitID, ChangeType, QuantityChanged)
        VALUES (p_fruitid, p_changetype, p_quantitychanged);

        -- Update inventory stock
        IF UPPER(p_changetype) = 'ADD' THEN
            UPDATE Inventory
            SET Stock = Stock + p_quantitychanged
            WHERE FruitID = p_fruitid;
        ELSIF UPPER(p_changetype) = 'REMOVE' THEN
            UPDATE Inventory
            SET Stock = Stock - p_quantitychanged
            WHERE FruitID = p_fruitid;
        END IF;
    END;

END FruitInventory_Pkg;
/