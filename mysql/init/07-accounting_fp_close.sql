USE `appbuilder-admin`;
DROP PROCEDURE IF EXISTS `CLOSE_FP_PROCESS`;
DELIMITER $$ CREATE PROCEDURE `CLOSE_FP_PROCESS` (IN FISCAL_PERIOD_UUID varchar(255)) --
BEGIN
    DECLARE FP_Closed varchar(255) DEFAULT "";
    DECLARE FP_Closing varchar(255) DEFAULT "";
    DECLARE FP_Next_To_Use varchar(255) DEFAULT "";
    DECLARE FP_Future varchar(255) DEFAULT "";
    DECLARE FY_PERIOD varchar(255);
    DECLARE OLD_END_DATE date;
    DECLARE SEARCHDATE date;
    DECLARE NEW_FP varchar(255);
    /* Get FY Period */
    SELECT `Post Period`,
        `End` INTO FY_PERIOD,
        BATCH_INDEX
    FROM `AB_AccountingApp_FiscalMonth`
    WHERE `uuid` = FISCAL_PERIOD_UUID
    LIMIT 1;
    -- find the next fiscal month(.startDate == my.endDate + 1)
    SELECT DATEADD(day, 1, OLD_END_DATE) AS DateAdd INTO SEARCHDATE;
    -- Find the next fiscal month (Fiscal Month object) and set it to Status Active
    -- ? can these be combined?
    SELECT `FY Per` INTO NEW_FP
    FROM `AB_AccountingApp_FiscalMonth`
    WHERE `End` = SEARCHDATE;
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
            `Running Balance`,
            `created_at`,
            `updated_at`
        ) -- For Each Balance Record create a Copy
    SELECT *
    FROM (
            SELECT DISTINCT UUID(),
                -- ? Balndx
                CONCAT (NEW_FP, '-', GL.`COA Num`, '-', GL.`RC Code`),
                -- ? check this
                --     Fiscal Month: Next Fiscal Month
                NEW_FP,
                GL.`COA Num`,
                --     Account: Same as Original Balance Record
                --     RC: Same as Original Balance Record
                GL.`RC Code`,
                /* set STARTING BALANCE */
                -- Starting Balance: 
                (GL.`Running Balance`, 0),
                -- Original Balance to Running Balance --     Debits/Credits: 0
                0,
                0,
                (GL.`Running Balance`, 0),
                NOW(),
                NOW()
            FROM `AB_AccountingApp_GLSegment` -- Balance object filter by Fiscal Period contains FY22 M10 (current active month)
            WHERE GL.`FY Period` = FY_PERIOD -- Find All Balances (Balance object) connected to the Closed Fiscal Month, 
                AND GL.`COA Num` IS NOT NULL
                AND GL.`COA Num` IS NOT LIKE "3500"
                AND GL.`RC Code` IS NOT NULL
        ) --
        -- /* UPDATE GLSegment (Account 3500) */
    INSERT INTO `AB_AccountingApp_GLSegment` (
            `uuid`,
            `Balndx`,
            `FY Period`,
            `COA Num`,
            `RC Code`,
            `Starting Balance`,
            `Credit`,
            `Debit`,
            `Running Balance`,
            `created_at`,
            `updated_at`
        )
    SELECT *
    FROM (
            SELECT DISTINCT UUID(),
                CONCAT (NEW_FP, '-', 3500, '-', GL.`RC Code`),
                NEW_FP,
                3500,
                GL.`RC Code`,
                IFNULL(GL.`Starting Balance`, 0),
                0,
                0,
                IFNULL(GL.`Starting Balance`, 0),
                NOW(),
                NOW()
            FROM `AB_AccountingApp_GLSegment` GL
            WHERE GL.`FY Period` = FY_PERIOD
                AND (
                    GL.`COA Num` = "3500"
                )
        )
END --
$$ DELIMITER;