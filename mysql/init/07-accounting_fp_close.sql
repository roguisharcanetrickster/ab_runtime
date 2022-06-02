USE `appbuilder-admin`;
DROP PROCEDURE IF EXISTS `CLOSE_FP_PROCESS`;
DELIMITER $$ CREATE PROCEDURE `CLOSE_FP_PROCESS` (IN FISCAL_PERIOD_UUID varchar(255)) BEGIN
DECLARE ACCOUNT_Assets varchar(255) DEFAULT "1585806356532";
DECLARE ACCOUNT_Expenses varchar(255) DEFAULT "1585806356789";
DECLARE ACCOUNT_Liabilities varchar(255) DEFAULT "1585806356570";
DECLARE ACCOUNT_Equity varchar(255) DEFAULT "1585806356643";
DECLARE ACCOUNT_Income varchar(255) DEFAULT "1590392412833";
DECLARE FY_PERIOD varchar(255);
DECLARE OLD_END_DATE date;
DECLARE SEARCHDATE date;
/* Get FY Period */
-- looking up Current FP:
SELECT `Post Period`,
    `End` INTO FY_PERIOD,
    BATCH_INDEX
FROM `AB_AccountingApp_FiscalMonth`
WHERE `uuid` = FISCAL_PERIOD_UUID
LIMIT 1;
-- find the next fiscal month(.startDate == my.endDate + 1)
SELECT DATEADD(day, 1, OLD_END_DATE) AS DateAdd INTO SEARCHDATE;
-- Find the next fiscal month (Fiscal Month object) and set it to Status Active
UPDATE `AB_AccountingApp_FiscalMonth`
SET `Open` = 1,
    `Status` = 1592549785939
WHERE `End` = SEARCHDATE;
-- Find All Balances (Balance object) connected to the Closed Fiscal Month, 
--     for example, in the Balance object filter by Fiscal Period contains FY22 M10 (current active month)
-- For Each Balance Record create a Copy
--     Account: Same as Original Balance Record
--     RC: Same as Original Balance Record
--     Fiscal Month: Next Fiscal Month
- - Starting Balance: Original Balance > Running Balance --     Debits/Credits: 0
--     Running Balance ... update to equal Starting balance (since there are no modifiers yet:)
/* INSERT new GLSegment (inc. 3991) */
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
            GL.`Balndx`,
            -- TODO
            FY_PERIOD,
            -- TODO
            GL.`COA Num`,
            GL.`RC Code`,
            /* set STARTING BALANCE */
            (GL.`Running Balance`, 0),
            0,
            0,
            0,
            NOW(),
            NOW()
        FROM `AB_AccountingApp_GLSegment`
        WHERE GL.`FY Period` = FY_PERIOD -- !TODO this might be wrong
            AND JE.`COA Num` IS NOT NULL
            AND JE.`RC Code` IS NOT NULL
    )
    /* UPDATE GLSegment (Account 3500) */
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
        SELECT DISTINCT IFNULL(GL3991.`uuid`, UUID()),
            GL3500.`Balndx`,
            FY_PERIOD,
            3500,
            GL.`RC Code`,
            IFNULL(GL3991.`Starting Balance`, 0),
            SUM(IFNULL(GL.`Credit`, 0)) `Credit`,
            SUM(IFNULL(GL.`Debit`, 0)) `Debit`,
            IFNULL(GL3991.`Starting Balance`, 0) - SUM(IFNULL(GL.`Debit`, 0)) + SUM(IFNULL(GL.`Credit`, 0)) `Running Balance`,
            NOW() `created_at`,
            NOW() `updated_at`
        FROM `AB_AccountingApp_GLSegment` GL
            LEFT JOIN `AB_AccountingApp_GLSegment` GL3991 ON GL3991.`COA Num` = 3991
            AND GL.`RC Code` = GL3991.`RC Code`
            AND GL.`FY Period` = GL3991.`FY Period`
        WHERE GL.`FY Period` = FY_PERIOD
            AND (
                GL.`COA Num` = "3500"
            )
        GROUP BY GL.`FY Period`,
            GL.`RC Code`
    ) r ON DUPLICATE KEY
UPDATE `Credit` = r.`Credit`,
    `Debit` = r.`Debit`,
    `Running Balance` = r.`Running Balance`,
    `updated_at` = NOW();
END $$ DELIMITER;