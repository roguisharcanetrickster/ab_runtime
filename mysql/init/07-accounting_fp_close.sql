USE `appbuilder-admin`;

DROP PROCEDURE IF EXISTS `CLOSE_FP_PROCESS`;

DELIMITER $$
CREATE PROCEDURE `CLOSE_FP_PROCESS` (
    IN FISCAL_PERIOD_UUID varchar(255)
) 
BEGIN
    -- DECLARE FP_Closed varchar(255) DEFAULT "";
    -- DECLARE FP_Closing varchar(255) DEFAULT "";
    -- DECLARE FP_Next_To_Use varchar(255) DEFAULT "";
    -- DECLARE FP_Future varchar(255) DEFAULT "";
    DECLARE FY_PERIOD varchar(255);
    DECLARE OLD_END_DATE date;
    DECLARE SEARCHDATE date;
    DECLARE NEW_FP varchar(255);
    /* */
    SELECT `Post Period`, `End` 
    INTO FY_PERIOD, SEARCHDATE
    FROM `AB_AccountingApp_FiscalMonth`
    WHERE `uuid` = FISCAL_PERIOD_UUID
    LIMIT 1;

    -- find the next fiscal month(.startDate == my.endDate + 1)
    SELECT DATEADD(day, 1, OLD_END_DATE) AS DateAdd INTO SEARCHDATE;
    SELECT `FY Per` INTO NEW_FP
    FROM `AB_AccountingApp_FiscalMonth`
    WHERE `End` = SEARCHDATE;
    -- set open
    UPDATE `AB_AccountingApp_FiscalMonth`
    SET `Open` = 1,
        `Status` = 1592549785939
    WHERE `End` = SEARCHDATE;

    -- INSERT new GLSegment (inc. 3991) 
    INSERT INTO `AB_AccountingApp_GLSegment` (
            `uuid`,
            `Balndx`,
            `FY Period`,
            `COA Num`,
            `RC Code`,
            `Starting Balance`,
            `Credit`,
            `Debit`,
            `Running Balance`
        ) 
        SELECT
            UUID(),
            -- Balndx
            CONCAT (NEW_FP, '-', GL.`COA Num`, '-', GL.`RC Code`),
            -- Next Fiscal Month
            NEW_FP,
            -- Same as Original Balance Record
            GL.`COA Num`,
            GL.`RC Code`,
            -- Starting Balance: 
            IFNULL(GL.`Running Balance`, 0),
            0,
            0,
            (GL.`Running Balance`, 0)
        FROM `AB_AccountingApp_GLSegment` GL 
        -- Find All Balances (Balance object) connected to the Closed Fiscal Month, 
        WHERE GL.`FY Period` LIKE FY_PERIOD; 

END$$
DELIMITER ;