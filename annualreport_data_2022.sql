-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Feb 06, 2023 at 06:04 AM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `new_data`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAuthor` (IN `fname` TEXT, IN `mname` TEXT, IN `lname` TEXT, IN `subtype` INT, IN `fromdate` DATE, IN `todate` DATE, IN `category` VARCHAR(25), IN `nationality` INT, IN `categoryname` VARCHAR(20), IN `authortypeid` INT, IN `title` TEXT, IN `conference` TEXT, IN `ranking` TEXT)  BEGIN
 
 	DECLARE element varchar(150);
    
    DECLARE query1 text;
    DECLARE query2 text;
    DECLARE concatquery text;
    DECLARE catcheck text;
    DECLARE checktext text;
    DECLARE rankingcopy int;
    
	IF CONVERT(ranking,int) = 0 THEN 
		SET rankingcopy = 0; 
	ELSE 
		SET rankingcopy = 1; 
	END IF;
    
    IF fname = '' THEN SET fname = ','; END IF;
    IF mname = '' THEN SET mname = ','; END IF;
    IF lname = '' THEN SET lname = ','; END IF;
    
    SET query1 = ''; SET query2 = ''; SET concatquery = '';
    
    DROP TEMPORARY TABLE IF EXISTS Temp_Rankings_Print_Author;
    DROP TEMPORARY TABLE IF EXISTS Temp_Ranking_Print_Author_Table;
    DROP TEMPORARY TABLE IF EXISTS Temp_Author_Fname;
    DROP TEMPORARY TABLE IF EXISTS Temp_Author_Mname;
    DROP TEMPORARY TABLE IF EXISTS Temp_Author_Lname;
    DROP TEMPORARY TABLE IF EXISTS Temp_Header_Id;
    
    CREATE TEMPORARY TABLE Temp_Rankings_Print_Author (rankingids int);
    CREATE TEMPORARY TABLE Temp_Ranking_Print_Author_Table (id int,ranking varchar(15));
    CREATE TEMPORARY TABLE Temp_Author_Fname (Fname text);
    CREATE TEMPORARY TABLE Temp_Author_Mname (Mname text);
    CREATE TEMPORARY TABLE Temp_Author_Lname (Lname text);
    CREATE TEMPORARY TABLE Temp_Header_Id (headerid int);
   
    WHILE fname != '' DO
    	SET element = SUBSTRING_INDEX(fname, ',', 1);
        
        IF element = 'nodata' THEN SET element = ''; END IF;
        
        INSERT INTO Temp_Author_Fname VALUES(element);
        
        IF LOCATE(',', fname) > 0 THEN
            SET fname = SUBSTRING(fname, LOCATE(',', fname) + 1);
        ELSE
            SET fname = '';
       	END IF;
    END WHILE;
    
    WHILE mname != '' DO
    	SET element = SUBSTRING_INDEX(mname, ',', 1);
        
        IF element = 'nodata' THEN SET element = ''; END IF;
        
        INSERT INTO Temp_Author_Mname VALUES(element);
        
        IF LOCATE(',', mname) > 0 THEN
            SET mname = SUBSTRING(mname, LOCATE(',', mname) + 1);
        ELSE
            SET mname = '';
       	END IF;
    END WHILE;
    
    WHILE lname != '' DO
    	SET element = SUBSTRING_INDEX(lname, ',', 1);
        
        IF element = 'nodata' THEN SET element = ''; END IF;
        
        INSERT INTO Temp_Author_Lname VALUES(element);
        
        IF LOCATE(',', lname) > 0 THEN
            SET lname = SUBSTRING(lname, LOCATE(',', lname) + 1);
        ELSE
            SET lname = '';
       	END IF;
    END WHILE;
    
    WHILE ranking != '' DO
    	SET element = SUBSTRING_INDEX(ranking, ',', 1);
      
        IF(element > 0) THEN
        	INSERT INTO Temp_Rankings_Print_Author VALUES(element);
        END IF;
        
        IF LOCATE(',', ranking) > 0 THEN
            SET ranking = SUBSTRING(ranking, LOCATE(',', ranking) + 1);
        ELSE
            SET ranking = '';
       	END IF;
    END WHILE;
    
    INSERT INTO Temp_Header_Id
    SELECT DISTINCT pubdtls.pubhdrid FROM  pubdtls WHERE IFNULL(pubdtls.athrfirstname COLLATE utf8mb4_unicode_ci,'') IN (SELECT * FROM Temp_Author_Fname)
    		AND IFNULL(pubdtls.athrmiddlename COLLATE utf8mb4_unicode_ci,'') IN (SELECT * FROM Temp_Author_Mname)
    		AND IFNULL(pubdtls.athrlastname COLLATE utf8mb4_unicode_ci,'') IN (SELECT * FROM Temp_Author_Lname);
            
    IF rankingcopy = 0 THEN /* when ranking not exists */

    		SELECT DISTINCT 
        		pubhdrs.pubdate,
        		pubdtls.pubhdrid, 
        		GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) AS slno,
        		/*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
                GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,
        		IFNULL(pubhdrs.title,'') AS title,
        		IFNULL(pubhdrs.confname,'') as conference,
        		IFNULL(pubhdrs.volume,'') as volume,
        		IFNULL(pubhdrs.issue,'') as issue,
                IFNULL(pubhdrs.pp,'') as pages,
                IFNULL(pubhdrs.nationality,'') AS nationality,
                IFNULL(pubhdrs.digitallibrary,'') AS Doi,
                IFNULL(art.article,'') AS article,
                IFNULL(rnk.ranking,'') as ranking, 
                IFNULL(brdarea.broadarea,'') as broadarea,
                IFNULL(pubhdrs.impactfactor,'') as impactfactor, 
                IFNULL(pubhdrs.place,'') AS location 
              FROM pubhdrs 
                INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
                LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
                LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid 
                /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
                LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
                INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid  
                INNER JOIN categories ON categories.id = pubhdrs.categoryid 
              WHERE LOWER(categories.category) = CASE WHEN IFNULL(category,'') = '' THEN (categoryname COLLATE utf8mb4_unicode_ci) ELSE (category COLLATE utf8mb4_unicode_ci) END
                AND CASE WHEN (IFNULL(fromdate,'') != '' AND IFNULL(todate,'') != '') THEN pubhdrs.pubdate BETWEEN fromdate AND todate ELSE 1=1 END
                AND CASE WHEN authortypeid > 0 THEN authtype.id = authortypeid ELSE 1=1 END
                AND	CASE WHEN IFNULL(nationality,0) > 0 THEN pubhdrs.nationality = IFNULL(nationality,0) ELSE 1=1 END
                AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND pubdtls.pubhdrid IN (SELECT * FROM Temp_Header_Id)
                AND pubhdrs.deleted = 0
              GROUP by pubdtls.pubhdrid 
              order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;
       
	END IF;
    
    IF rankingcopy = 1 THEN /* when ranking exists */
    
    		INSERT INTO Temp_Ranking_Print_Author_Table
    		SELECT rnk.id,rnk.ranking from rankings rnk INNER JOIN Temp_Rankings_Print_Author tmprnk on rnk.id = tmprnk.rankingids;
    
    	   SELECT DISTINCT 
        		pubhdrs.pubdate,
        		pubdtls.pubhdrid, 
        		GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) AS slno,
        		/*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
                GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,
        		IFNULL(pubhdrs.title,'') AS title,
        		IFNULL(pubhdrs.confname,'') as conference,
        		IFNULL(pubhdrs.volume,'') as volume,
        		IFNULL(pubhdrs.issue,'') as issue,
                IFNULL(pubhdrs.pp,'') as pages,
                IFNULL(pubhdrs.nationality,'') AS nationality,
                IFNULL(pubhdrs.digitallibrary,'') AS Doi,
                IFNULL(art.article,'') AS article,
                IFNULL(rnk.ranking,'') as ranking, 
                IFNULL(brdarea.broadarea,'') as broadarea,
                IFNULL(pubhdrs.impactfactor,'') as impactfactor, 
                IFNULL(pubhdrs.place,'') AS location 
              FROM pubhdrs 
                INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
                INNER JOIN Temp_Ranking_Print_Author_Table rnk on rnk.id = pubhdrs.rankingid
                LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid 
                /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/ 
                LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
                INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid  
                INNER JOIN categories ON categories.id = pubhdrs.categoryid 
              WHERE LOWER(categories.category) = CASE WHEN IFNULL(category,'') = '' THEN (categoryname COLLATE utf8mb4_unicode_ci) ELSE (category COLLATE utf8mb4_unicode_ci) END
                AND CASE WHEN (IFNULL(fromdate,'') != '' AND IFNULL(todate,'') != '') THEN pubhdrs.pubdate BETWEEN fromdate AND todate ELSE 1=1 END
                AND CASE WHEN authortypeid > 0 THEN authtype.id = authortypeid ELSE 1=1 END
                AND	CASE WHEN IFNULL(nationality,0) > 0 THEN pubhdrs.nationality = IFNULL(nationality,0) ELSE 1=1 END
                AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND pubdtls.pubhdrid IN (SELECT * FROM Temp_Header_Id)
                AND pubhdrs.deleted = 0
              GROUP by pubdtls.pubhdrid 
              order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;
    
    END IF;

              
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Author_Data_For_Update` (IN `hdrid` INT)  BEGIN

SELECT slno,IFNULL(dtls.athrfirstname,'') AS firstname, 
IFNULL(dtls.athrmiddlename,'') AS middlename, IFNULL(dtls.athrlastname,'') AS lastname, 
dtls.fullname 
FROM pubdtls dtls
WHERE dtls.pubhdrid = hdrid
ORDER BY slno;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Autocmplete_Data` (IN `autotext` VARCHAR(50), IN `type` INT)  BEGIN

IF type = 1 THEN
	SELECT DISTINCT CONCAT(UPPER(SUBSTRING(pubhdrs.digitallibrary,1,1)),LOWER(SUBSTRING(pubhdrs.digitallibrary,2))) as autocomplete FROM pubhdrs
    WHERE pubhdrs.digitallibrary LIKE concat('%',autotext,'%')
    AND IFNULL(pubhdrs.digitallibrary,'') != '';

ELSEIF type = 2 THEN
	SELECT DISTINCT CONCAT(UPPER(SUBSTRING(pubhdrs.title,1,1)),LOWER(SUBSTRING(pubhdrs.title,2))) as autocomplete FROM pubhdrs
    WHERE pubhdrs.title LIKE concat('%',autotext,'%')
    AND IFNULL(pubhdrs.title,'') != '';

ELSEIF type = 3 THEN
	SELECT DISTINCT CONCAT(UPPER(SUBSTRING(pubhdrs.confname,1,1)),LOWER(SUBSTRING(pubhdrs.confname,2))) as autocomplete FROM pubhdrs
    WHERE pubhdrs.confname LIKE concat('%',autotext,'%')
    AND IFNULL(pubhdrs.confname,'') != '';
    
ELSEIF type = 4 THEN
	SELECT DISTINCT CONCAT(UPPER(SUBSTRING(pubhdrs.place,1,1)),LOWER(SUBSTRING(pubhdrs.place,2))) as autocomplete FROM pubhdrs
    WHERE pubhdrs.place LIKE concat('%',autotext,'%');

ELSEIF type = 5 THEN
	SELECT DISTINCT
CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2)) as autocomplete,
	IFNULL(athrfirstname,'') as fname, IFNULL(athrmiddlename,'') as mname,IFNULL(athrlastname,'') as lname from pubdtls
	where pubdtls.athrfirstname like concat('%',autotext,'%')
	or pubdtls.athrmiddlename like concat('%',autotext,'%')
	or pubdtls.athrlastname like concat('%',autotext,'%');

END IF;


END$$

CREATE DEFINER=`` PROCEDURE `Get_Every_Year_Data` ()  BEGIN

	CREATE TEMPORARY TABLE Temp_Display_Year_Data_Count (pubyear int, journal int, 	   conference int, total int);
    
    /* SELECT year(pubdate) AS year, COUNT(*) AS count FROM pubhdrs GROUP BY year ORDER BY year DESC; */
    
    INSERT INTO Temp_Display_Year_Data_Count (pubyear)
    SELECT year(pubdate) FROM pubhdrs GROUP BY  year(pubdate) ;
    
    UPDATE Temp_Display_Year_Data_Count AS TEMP
    INNER JOIN
    (SELECT year(pubdate) AS year, COUNT(*) AS journalcount FROM pubhdrs
     WHERE categoryid = 7 GROUP BY year) T1
     ON TEMP.pubyear = T1.year
    SET journal = T1.journalcount;
    
  	UPDATE Temp_Display_Year_Data_Count AS TEMP
    INNER JOIN
    (SELECT year(pubdate) AS year, COUNT(*) AS conferencecount FROM pubhdrs
     WHERE categoryid = 8 GROUP BY year) T1
     ON TEMP.pubyear = T1.year
    SET conference = T1.conferencecount;
    
     UPDATE Temp_Display_Year_Data_Count AS TEMP
    INNER JOIN
    (SELECT year(pubdate) AS year, COUNT(*) AS totalcount FROM pubhdrs GROUP BY year) T1
     ON TEMP.pubyear = T1.year
    SET total = T1.totalcount;

	SELECT pubyear year, IFNULL(journal, 0) journal, IFNULL(conference, 0) conference, IFNULL(total, 0) total  FROM Temp_Display_Year_Data_Count ORDER BY pubyear DESC;

	DROP TEMPORARY TABLE IF EXISTS Temp_Display_Year_Data_Count ;

 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Print_Data` (IN `fromdt` DATE, IN `todt` DATE, IN `authortypeid` INT, IN `categoryid` INT, IN `nationality` INT, IN `title` TEXT, IN `conference` TEXT, IN `ranking` TEXT, IN `fname` VARCHAR(30), IN `mname` VARCHAR(30), IN `lname` VARCHAR(30), IN `categoryname` VARCHAR(25))  BEGIN


DECLARE required INT;
DECLARE element INT;
DECLARE authorelement varchar(30);

SET required = 0;

IF (IFNULL(fromdt,'') = '' AND IFNULL(todt,'') = '' AND IFNULL(authortypeid,0) = 0 AND IFNULL(categoryid,0) = 0
AND IFNULL(nationality,0) = 0 AND IFNULL(title,'') = '' AND IFNULL(conference,'') = '' AND IFNULL(ranking,'') = '0'
AND IFNULL(fname,'') = '' AND IFNULL(mname,'') = '' AND IFNULL(lname,'') = '') THEN
	SET required = 1;  
END IF;

IF ((IFNULL(fromdt,'') != '' AND IFNULL(todt,'') = '') OR (IFNULL(fromdt,'') = '' AND IFNULL(todt,'') != '')) THEN
	SET required = 1;
END IF;

IF ((IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '')) THEN
	SET required = 0;
END IF;

IF required = 0 THEN
    CREATE TEMPORARY TABLE Temp_Rankings (rankingids int);
    CREATE TEMPORARY TABLE Temp_Ranking_Table (id int,ranking varchar(15));
    
    CREATE TEMPORARY TABLE Temp_Author_Fname (Fname text);
    CREATE TEMPORARY TABLE Temp_Author_Mname (Mname text);
    CREATE TEMPORARY TABLE Temp_Author_Lname (Lname text);
    CREATE TEMPORARY TABLE Temp_Header_Id (headerid int);

    IF ranking = '' THEN SET ranking = ','; END IF;
    IF fname = '' THEN SET fname = ','; END IF;
    IF mname = '' THEN SET mname = ','; END IF;
    IF lname = '' THEN SET lname = ','; END IF;
    
    WHILE ranking != '' DO
    	SET element = SUBSTRING_INDEX(ranking, ',', 1);
      
        IF(element > 0) THEN
        	INSERT INTO Temp_Rankings VALUES(element);
        END IF;
        
        IF LOCATE(',', ranking) > 0 THEN
            SET ranking = SUBSTRING(ranking, LOCATE(',', ranking) + 1);
        ELSE
            SET ranking = '';
       	END IF;
    END WHILE;
    
    WHILE fname != '' DO
    	SET authorelement = SUBSTRING_INDEX(fname, ',', 1);
        
        IF authorelement = 'nodata' THEN SET authorelement = ''; END IF;
        
        INSERT INTO Temp_Author_Fname VALUES(authorelement);
        
        IF LOCATE(',', fname) > 0 THEN
            SET fname = SUBSTRING(fname, LOCATE(',', fname) + 1);
        ELSE
            SET fname = '';
       	END IF;
    END WHILE;
    
    WHILE mname != '' DO
    	SET authorelement = SUBSTRING_INDEX(mname, ',', 1);
        
        IF authorelement = 'nodata' THEN SET authorelement = ''; END IF;
        
        INSERT INTO Temp_Author_Mname VALUES(authorelement);
        
        IF LOCATE(',', mname) > 0 THEN
            SET mname = SUBSTRING(mname, LOCATE(',', mname) + 1);
        ELSE
            SET mname = '';

       	END IF;
    END WHILE;
    
    WHILE lname != '' DO
    	SET authorelement = SUBSTRING_INDEX(lname, ',', 1);
        
        IF authorelement = 'nodata' THEN SET authorelement = ''; END IF;
        
        INSERT INTO Temp_Author_Lname VALUES(authorelement);
        
        IF LOCATE(',', lname) > 0 THEN
            SET lname = SUBSTRING(lname, LOCATE(',', lname) + 1);
        ELSE
            SET lname = '';
       	END IF;
    END WHILE;
    
    INSERT INTO Temp_Header_Id
    SELECT DISTINCT pubdtls.pubhdrid FROM  pubdtls WHERE IFNULL(pubdtls.athrfirstname,'') IN (SELECT * FROM Temp_Author_Fname)
    		AND IFNULL(pubdtls.athrmiddlename,'') IN (SELECT * FROM Temp_Author_Mname)
    		AND IFNULL(pubdtls.athrlastname,'') IN (SELECT * FROM Temp_Author_Lname);
    
IF categoryid > 0 THEN  	/* category > 0 */

	 IF (EXISTS (SELECT 1 FROM Temp_Rankings) && NOT EXISTS (SELECT 1 FROM Temp_Header_Id)) THEN 
 		/* Ranking search exists and Author search not exists */
		SELECT 
       	hdr.pubdate,
  		dtls.pubhdrid,
        cat.category,
		GROUP_CONCAT(dtls.slno ORDER BY dtls.slno) as slno,  
		GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''),   2) ORDER BY dtls.slno) as authorname,
        IFNULL(hdr.title,'') AS title,
        IFNULL(hdr.confname,'') as conference,
        IFNULL(hdr.volume,'') as volume,
        IFNULL(hdr.issue,'') as issue,
        IFNULL(hdr.pp,'') as pages,
        IFNULL(hdr.nationality,'') AS nationality,
        IFNULL(hdr.digitallibrary,'') AS Doi,
        IFNULL(art.article,'') AS article,
		IFNULL(rnk.ranking,'') as ranking, 
        IFNULL(brdarea.broadarea,'') as broadarea,
		IFNULL(impact.impactfactor,'') as impactfactor, 
        IFNULL(hdr.place,'') AS location
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes art ON art.articleid = hdr.articletypeid
        LEFT OUTER JOIN rankings rnk on rnk.id = hdr.rankingid
  		RIGHT OUTER JOIN Temp_Rankings rank ON rnk.id = rank.rankingids
  		LEFT OUTER JOIN broadareas brdarea ON brdarea.id = hdr.broadareaid
  		LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid
  	WHERE cat.id = categoryid
    	AND CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title,'') != '' THEN hdr.title like concat('%',IFNULL(title,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference,'') != '' THEN hdr.confname like concat('%',IFNULL(conference,''),'%') ELSE 1=1 END
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
    
 ELSEIF (EXISTS (SELECT 1 FROM Temp_Header_Id) && NOT EXISTS (SELECT 1 FROM Temp_Rankings)) THEN
 	/* Ranking search not exists and Author search exists */
 	SELECT 
    	hdr.pubdate,
  		dtls.pubhdrid,
        cat.category,
		GROUP_CONCAT(dtls.slno ORDER BY dtls.slno) as slno,  
		GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''),   2) ORDER BY dtls.slno) as authorname,
        IFNULL(hdr.title,'') AS title,
        IFNULL(hdr.confname,'') as conference,
        IFNULL(hdr.volume,'') as volume,
        IFNULL(hdr.issue,'') as issue,
        IFNULL(hdr.pp,'') as pages,
        IFNULL(hdr.nationality,'') AS nationality,
        IFNULL(hdr.digitallibrary,'') AS Doi,
        IFNULL(art.article,'') AS article,
		IFNULL(rnk.ranking,'') as ranking, 
        IFNULL(brdarea.broadarea,'') as broadarea,
		IFNULL(impact.impactfactor,'') as impactfactor, 
        IFNULL(hdr.place,'') AS location
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes art ON art.articleid = hdr.articletypeid
        LEFT OUTER JOIN rankings rnk on rnk.id = hdr.rankingid
  		LEFT OUTER JOIN broadareas brdarea ON brdarea.id = hdr.broadareaid
  		LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid 
        INNER JOIN Temp_Header_Id thd ON thd.headerid = hdr.id
  	WHERE cat.id = categoryid
    	AND CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title,'') != '' THEN hdr.title like concat('%',IFNULL(title,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference,'') != '' THEN hdr.confname like concat('%',IFNULL(conference,''),'%') ELSE 1=1 END
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
    
 ELSEIF (EXISTS (SELECT 1 FROM Temp_Header_Id) && EXISTS (SELECT 1 FROM Temp_Rankings)) THEN
 	/* Ranking search exists and Author search exists */
    
    INSERT INTO Temp_Ranking_Table
    SELECT rnk.id,rnk.ranking from rankings rnk INNER JOIN Temp_Rankings tmprnk on rnk.id = tmprnk.rankingids;
    
 	SELECT 
    	hdr.pubdate,
  		dtls.pubhdrid,
        cat.category,
		GROUP_CONCAT(dtls.slno ORDER BY dtls.slno) as slno,  
		GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''),   2) ORDER BY dtls.slno) as authorname,
        IFNULL(hdr.title,'') AS title,
        IFNULL(hdr.confname,'') as conference,
        IFNULL(hdr.volume,'') as volume,
        IFNULL(hdr.issue,'') as issue,
        IFNULL(hdr.pp,'') as pages,
        IFNULL(hdr.nationality,'') AS nationality,
        IFNULL(hdr.digitallibrary,'') AS Doi,
        IFNULL(art.article,'') AS article,
		IFNULL(rnk.ranking,'') as ranking, 
        IFNULL(brdarea.broadarea,'') as broadarea,
		IFNULL(impact.impactfactor,'') as impactfactor, 
        IFNULL(hdr.place,'') AS location
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes art ON art.articleid = hdr.articletypeid
        INNER JOIN Temp_Ranking_Table rnk on rnk.id = hdr.rankingid
  		LEFT OUTER JOIN broadareas brdarea ON brdarea.id = hdr.broadareaid
  		LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid 
        INNER JOIN Temp_Header_Id thd ON thd.headerid = hdr.id
  	WHERE cat.id = categoryid
    	AND CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title,'') != '' THEN hdr.title like concat('%',IFNULL(title,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference,'') != '' THEN hdr.confname like concat('%',IFNULL(conference,''),'%') ELSE 1=1 END
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
   
 ELSE  
   	SELECT 
    	hdr.pubdate,
  		dtls.pubhdrid,
        cat.category,
		GROUP_CONCAT(dtls.slno ORDER BY dtls.slno) as slno,  
		GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''),   2) ORDER BY dtls.slno) as authorname,
        IFNULL(hdr.title,'') AS title,
        IFNULL(hdr.confname,'') as conference,
        IFNULL(hdr.volume,'') as volume,
        IFNULL(hdr.issue,'') as issue,
        IFNULL(hdr.pp,'') as pages,
        IFNULL(hdr.nationality,'') AS nationality,
        IFNULL(hdr.digitallibrary,'') AS Doi,
        IFNULL(art.article,'') AS article,
		IFNULL(rnk.ranking,'') as ranking, 
        IFNULL(brdarea.broadarea,'') as broadarea,
		IFNULL(impact.impactfactor,'') as impactfactor, 
        IFNULL(hdr.place,'') AS location
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes art ON art.articleid = hdr.articletypeid
        LEFT OUTER JOIN rankings rnk on rnk.id = hdr.rankingid
  		LEFT OUTER JOIN broadareas brdarea ON brdarea.id = hdr.broadareaid
  		LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid
  	WHERE cat.id = categoryid
    	AND CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title,'') != '' THEN hdr.title like concat('%',IFNULL(title,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference,'') != '' THEN hdr.confname like concat('%',IFNULL(conference,''),'%') ELSE 1=1 END
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
    
 END IF;   
    
 ELSEIF categoryid = 0 THEN /* category = 0 */  
 
 	IF (EXISTS (SELECT 1 FROM Temp_Rankings) && NOT EXISTS (SELECT 1 FROM Temp_Header_Id)) THEN 
 		/* Ranking search exists and Author search not exists */
		SELECT 
       	hdr.pubdate,
  		dtls.pubhdrid,
        cat.category,
		GROUP_CONCAT(dtls.slno ORDER BY dtls.slno) as slno,  
		GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''),   2) ORDER BY dtls.slno) as authorname,
        IFNULL(hdr.title,'') AS title,
        IFNULL(hdr.confname,'') as conference,
        IFNULL(hdr.volume,'') as volume,
        IFNULL(hdr.issue,'') as issue,
        IFNULL(hdr.pp,'') as pages,
        IFNULL(hdr.nationality,'') AS nationality,
        IFNULL(hdr.digitallibrary,'') AS Doi,
        IFNULL(art.article,'') AS article,
		IFNULL(rnk.ranking,'') as ranking, 
        IFNULL(brdarea.broadarea,'') as broadarea,
		IFNULL(impact.impactfactor,'') as impactfactor, 
        IFNULL(hdr.place,'') AS location
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes art ON art.articleid = hdr.articletypeid
        LEFT OUTER JOIN rankings rnk on rnk.id = hdr.rankingid
  		RIGHT OUTER JOIN Temp_Rankings rank ON rnk.id = rank.rankingids
  		LEFT OUTER JOIN broadareas brdarea ON brdarea.id = hdr.broadareaid
  		LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid
  	WHERE cat.category = categoryname
    	AND CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title,'') != '' THEN hdr.title like concat('%',IFNULL(title,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference,'') != '' THEN hdr.confname like concat('%',IFNULL(conference,''),'%') ELSE 1=1 END
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
    
 ELSEIF (EXISTS (SELECT 1 FROM Temp_Header_Id) && NOT EXISTS (SELECT 1 FROM Temp_Rankings)) THEN
 	/* Ranking search not exists and Author search exists */
 	SELECT 
    	hdr.pubdate,
  		dtls.pubhdrid,
        cat.category,
		GROUP_CONCAT(dtls.slno ORDER BY dtls.slno) as slno,  
		GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''),   2) ORDER BY dtls.slno) as authorname,
        IFNULL(hdr.title,'') AS title,
        IFNULL(hdr.confname,'') as conference,
        IFNULL(hdr.volume,'') as volume,
        IFNULL(hdr.issue,'') as issue,
        IFNULL(hdr.pp,'') as pages,
        IFNULL(hdr.nationality,'') AS nationality,
        IFNULL(hdr.digitallibrary,'') AS Doi,
        IFNULL(art.article,'') AS article,
		IFNULL(rnk.ranking,'') as ranking, 
        IFNULL(brdarea.broadarea,'') as broadarea,
		IFNULL(impact.impactfactor,'') as impactfactor, 
        IFNULL(hdr.place,'') AS location
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes art ON art.articleid = hdr.articletypeid
        LEFT OUTER JOIN rankings rnk on rnk.id = hdr.rankingid
  		LEFT OUTER JOIN broadareas brdarea ON brdarea.id = hdr.broadareaid
  		LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid 
        INNER JOIN Temp_Header_Id thd ON thd.headerid = hdr.id
  	WHERE LOWER(cat.category) = categoryname
    	AND CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title,'') != '' THEN hdr.title like concat('%',IFNULL(title,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference,'') != '' THEN hdr.confname like concat('%',IFNULL(conference,''),'%') ELSE 1=1 END
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
    
 ELSEIF (EXISTS (SELECT 1 FROM Temp_Header_Id) && EXISTS (SELECT 1 FROM Temp_Rankings)) THEN
 	/* Ranking search exists and Author search exists */
    
    INSERT INTO Temp_Ranking_Table
    SELECT rnk.id,rnk.ranking from rankings rnk INNER JOIN Temp_Rankings tmprnk on rnk.id = tmprnk.rankingids;
    
 	SELECT hdr.pubdate,
  		dtls.pubhdrid,
        cat.category,
		GROUP_CONCAT(dtls.slno ORDER BY dtls.slno) as slno,  
		GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''),   2) ORDER BY dtls.slno) as authorname,
        IFNULL(hdr.title,'') AS title,
        IFNULL(hdr.confname,'') as conference,
        IFNULL(hdr.volume,'') as volume,
        IFNULL(hdr.issue,'') as issue,
        IFNULL(hdr.pp,'') as pages,
        IFNULL(hdr.nationality,'') AS nationality,
        IFNULL(hdr.digitallibrary,'') AS Doi,
        IFNULL(art.article,'') AS article,
		IFNULL(rnk.ranking,'') as ranking, 
        IFNULL(brdarea.broadarea,'') as broadarea,
		IFNULL(impact.impactfactor,'') as impactfactor, 
        IFNULL(hdr.place,'') AS location
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes art ON art.articleid = hdr.articletypeid
        INNER JOIN Temp_Ranking_Table rnk on rnk.id = hdr.rankingid
  		LEFT OUTER JOIN broadareas brdarea ON brdarea.id = hdr.broadareaid
  		LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid 
        INNER JOIN Temp_Header_Id thd ON thd.headerid = hdr.id
  	WHERE LOWER(cat.category) = categoryname
    	AND CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title,'') != '' THEN hdr.title like concat('%',IFNULL(title,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference,'') != '' THEN hdr.confname like concat('%',IFNULL(conference,''),'%') ELSE 1=1 END
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
   
 ELSE  
   	SELECT 
    	hdr.pubdate,
  		dtls.pubhdrid,
        cat.category,
		GROUP_CONCAT(dtls.slno ORDER BY dtls.slno) as slno,  
		GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''),   2) ORDER BY dtls.slno) as authorname,
        IFNULL(hdr.title,'') AS title,
        IFNULL(hdr.confname,'') as conference,
        IFNULL(hdr.volume,'') as volume,
        IFNULL(hdr.issue,'') as issue,
        IFNULL(hdr.pp,'') as pages,
        IFNULL(hdr.nationality,'') AS nationality,
        IFNULL(hdr.digitallibrary,'') AS Doi,
        IFNULL(art.article,'') AS article,
		IFNULL(rnk.ranking,'') as ranking, 
        IFNULL(brdarea.broadarea,'') as broadarea,
		IFNULL(impact.impactfactor,'') as impactfactor, 
        IFNULL(hdr.place,'') AS location
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes art ON art.articleid = hdr.articletypeid
        LEFT OUTER JOIN rankings rnk on rnk.id = hdr.rankingid
  		LEFT OUTER JOIN broadareas brdarea ON brdarea.id = hdr.broadareaid
  		LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid
  	WHERE LOWER(cat.category) = categoryname
    	AND CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title,'') != '' THEN hdr.title like concat('%',IFNULL(title,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference,'') != '' THEN hdr.confname like concat('%',IFNULL(conference,''),'%') ELSE 1=1 END
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
    
 END IF; 

END IF;
   
 DROP TEMPORARY TABLE IF EXISTS Temp_Rankings;
 DROP TEMPORARY TABLE IF EXISTS Temp_Ranking_Table;
 DROP TEMPORARY TABLE IF EXISTS Temp_Author_Fname;
 DROP TEMPORARY TABLE IF EXISTS Temp_Author_Mname;
 DROP TEMPORARY TABLE IF EXISTS Temp_Author_Lname;
 DROP TEMPORARY TABLE IF EXISTS Temp_Header_Id;
   
 END IF;
 
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Search_Data` (IN `fromdt` DATE, IN `todt` DATE, IN `authortypeid` INT, IN `categoryid` INT, IN `nationality` INT, IN `title` TEXT, IN `conference` TEXT, IN `ranking` TEXT, IN `fname` VARCHAR(30), IN `mname` VARCHAR(30), IN `lname` VARCHAR(30))  BEGIN

BEGIN

DECLARE required INT;
DECLARE element INT;
DECLARE authorelement varchar(30);

SET required = 0;

IF (IFNULL(fromdt,'') = '' AND IFNULL(todt,'') = '' AND IFNULL(authortypeid,0) = 0 AND IFNULL(categoryid,0) = 0
AND IFNULL(nationality,0) = 0 AND IFNULL(title,'') = '' AND IFNULL(conference,'') = '' AND IFNULL(ranking,'') = '0'
AND IFNULL(fname,'') = '' AND IFNULL(mname,'') = '' AND IFNULL(lname,'') = '') THEN
	SET required = 1;  
END IF;

IF ((IFNULL(fromdt,'') != '' AND IFNULL(todt,'') = '') OR (IFNULL(fromdt,'') = '' AND IFNULL(todt,'') != '')) THEN
	SET required = 1;
END IF;

IF ((IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '')) THEN
	SET required = 0;
END IF;

IF required = 0 THEN
    CREATE TEMPORARY TABLE Temp_Rankings (rankingids int);
    CREATE TEMPORARY TABLE Temp_Ranking_Table (id int,ranking varchar(15));
    
    CREATE TEMPORARY TABLE Temp_Author_Fname (Fname text);
    CREATE TEMPORARY TABLE Temp_Author_Mname (Mname text);
    CREATE TEMPORARY TABLE Temp_Author_Lname (Lname text);
    CREATE TEMPORARY TABLE Temp_Header_Id (headerid int);

    IF ranking = '' THEN SET ranking = ','; END IF;
    IF fname = '' THEN SET fname = ','; END IF;
    IF mname = '' THEN SET mname = ','; END IF;
    IF lname = '' THEN SET lname = ','; END IF;
    
    WHILE ranking != '' DO
    	SET element = SUBSTRING_INDEX(ranking, ',', 1);
      
        IF(element > 0) THEN
        	INSERT INTO Temp_Rankings VALUES(element);
        END IF;
        
        IF LOCATE(',', ranking) > 0 THEN
            SET ranking = SUBSTRING(ranking, LOCATE(',', ranking) + 1);
        ELSE
            SET ranking = '';
       	END IF;
    END WHILE;
    
    WHILE fname != '' DO
    	SET authorelement = SUBSTRING_INDEX(fname, ',', 1);
        
        IF authorelement = 'nodata' THEN SET authorelement = ''; END IF;
        
        INSERT INTO Temp_Author_Fname VALUES(authorelement);
        
        IF LOCATE(',', fname) > 0 THEN
            SET fname = SUBSTRING(fname, LOCATE(',', fname) + 1);
        ELSE
            SET fname = '';
       	END IF;
    END WHILE;
    
    WHILE mname != '' DO
    	SET authorelement = SUBSTRING_INDEX(mname, ',', 1);
        
        IF authorelement = 'nodata' THEN SET authorelement = ''; END IF;
        
        INSERT INTO Temp_Author_Mname VALUES(authorelement);
        
        IF LOCATE(',', mname) > 0 THEN
            SET mname = SUBSTRING(mname, LOCATE(',', mname) + 1);
        ELSE
            SET mname = '';

       	END IF;
    END WHILE;
    
    WHILE lname != '' DO
    	SET authorelement = SUBSTRING_INDEX(lname, ',', 1);
        
        IF authorelement = 'nodata' THEN SET authorelement = ''; END IF;
        
        INSERT INTO Temp_Author_Lname VALUES(authorelement);
        
        IF LOCATE(',', lname) > 0 THEN
            SET lname = SUBSTRING(lname, LOCATE(',', lname) + 1);
        ELSE
            SET lname = '';
       	END IF;
    END WHILE;
    
    INSERT INTO Temp_Header_Id
    SELECT DISTINCT pubdtls.pubhdrid FROM  pubdtls WHERE IFNULL(pubdtls.athrfirstname COLLATE utf8mb4_unicode_ci,'') IN (SELECT * FROM Temp_Author_Fname)
    		AND IFNULL(pubdtls.athrmiddlename COLLATE utf8mb4_unicode_ci,'') IN (SELECT * FROM Temp_Author_Mname)
    		AND IFNULL(pubdtls.athrlastname COLLATE utf8mb4_unicode_ci,'') IN (SELECT * FROM Temp_Author_Lname);
    
 IF (EXISTS (SELECT 1 FROM Temp_Rankings) && NOT EXISTS (SELECT 1 FROM Temp_Header_Id)) THEN 
 		/* Ranking search exists and Author search not exists */
		SELECT hdr.id as hdrid, DATE_FORMAT(hdr.pubdate, "%d/%m/%Y") as publicationdate,
  		CONCAT(UPPER(SUBSTRING(authtype.authortype,1,1)),LOWER(SUBSTRING(authtype.authortype,2))) as authortype,
  		CONCAT(UPPER(SUBSTRING(cat.category,1,1)),LOWER(SUBSTRING(cat.category,2))) as category,
  		hdr.nationality,
  		IFNULL(article.article,'') as article,
  		IFNULL(rnk.ranking,'') as ranking,
  		IFNULL(brdar.broadarea,'') as broadarea,
  		IFNULL(hdr.impactfactor,'') as impactfactor,
  		IFNULL(hdr.title,'') as title,
  		IFNULL(hdr.confname,'') as confname,
  		IFNULL(hdr.place,'') as location,
  		IFNULL(hdr.volume,'') as volume,
  		IFNULL(hdr.issue,'') as issue,
  		IFNULL(hdr.pp,'') as pp,
  		IFNULL(hdr.digitallibrary,'') as doi,
        
         GROUP_CONCAT(UCASE(LEFT(IFNULL(dtls.athrfirstname,''),1)),SUBSTRING(IFNULL(dtls.athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(dtls.athrmiddlename,''), 1)),SUBSTRING(IFNULL(dtls.athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(dtls.athrlastname,''), 1)),SUBSTRING(IFNULL(dtls.athrlastname,''), 2) ORDER BY dtls.slno) as authorname, hdr.userid as userid
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes article ON article.articleid = hdr.articletypeid
        LEFT OUTER JOIN rankings rnk on rnk.id = hdr.rankingid
  		RIGHT OUTER JOIN Temp_Rankings rank ON rnk.id = rank.rankingids
  		LEFT OUTER JOIN broadareas brdar ON brdar.id = hdr.broadareaid
  		/*LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid*/
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid
  	WHERE
    	CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND CASE WHEN IFNULL(categoryid,0) > 0 THEN cat.id = IFNULL(categoryid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
    AND hdr.deleted = 0    
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
    
 ELSEIF (EXISTS (SELECT 1 FROM Temp_Header_Id) && NOT EXISTS (SELECT 1 FROM Temp_Rankings)) THEN
 	/* Ranking search not exists and Author search exists */
 	SELECT hdr.id as hdrid, DATE_FORMAT(hdr.pubdate, "%d/%m/%Y") as publicationdate,
  		CONCAT(UPPER(SUBSTRING(authtype.authortype,1,1)),LOWER(SUBSTRING(authtype.authortype,2))) as authortype,
  		CONCAT(UPPER(SUBSTRING(cat.category,1,1)),LOWER(SUBSTRING(cat.category,2))) as category,
  		hdr.nationality,
  		IFNULL(article.article,'') as article,
  		IFNULL(rnk.ranking,'') as ranking,
  		IFNULL(brdar.broadarea,'') as broadarea,
  		IFNULL(hdr.impactfactor,'') as impactfactor,
  		IFNULL(hdr.title,'') as title,
  		IFNULL(hdr.confname,'') as confname,
  		IFNULL(hdr.place,'') as location,
  		IFNULL(hdr.volume,'') as volume,
  		IFNULL(hdr.issue,'') as issue,
  		IFNULL(hdr.pp,'') as pp,
  		IFNULL(hdr.digitallibrary,'') as doi, 
        
        GROUP_CONCAT(UCASE(LEFT(IFNULL(dtls.athrfirstname,''),1)),SUBSTRING(IFNULL(dtls.athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(dtls.athrmiddlename,''), 1)),SUBSTRING(IFNULL(dtls.athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(dtls.athrlastname,''), 1)),SUBSTRING(IFNULL(dtls.athrlastname,''), 2) ORDER BY dtls.slno) as authorname, hdr.userid as userid
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes article ON article.articleid = hdr.articletypeid
        LEFT OUTER JOIN rankings rnk on rnk.id = hdr.rankingid
  		LEFT OUTER JOIN broadareas brdar ON brdar.id = hdr.broadareaid
  		/*LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid*/
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid 
        INNER JOIN Temp_Header_Id thd ON thd.headerid = hdr.id
  	WHERE
    	CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND CASE WHEN IFNULL(categoryid,0) > 0 THEN cat.id = IFNULL(categoryid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
    AND hdr.deleted = 0    
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
    
 ELSEIF (EXISTS (SELECT 1 FROM Temp_Header_Id) && EXISTS (SELECT 1 FROM Temp_Rankings)) THEN
 	/* Ranking search exists and Author search exists */
    
    INSERT INTO Temp_Ranking_Table
    SELECT rnk.id,rnk.ranking from rankings rnk INNER JOIN Temp_Rankings tmprnk on rnk.id = tmprnk.rankingids;
    
 	SELECT hdr.id as hdrid, DATE_FORMAT(hdr.pubdate, "%d/%m/%Y") as publicationdate,
  		CONCAT(UPPER(SUBSTRING(authtype.authortype,1,1)),LOWER(SUBSTRING(authtype.authortype,2))) as authortype,
  		CONCAT(UPPER(SUBSTRING(cat.category,1,1)),LOWER(SUBSTRING(cat.category,2))) as category,
  		hdr.nationality,
  		IFNULL(article.article,'') as article,
  		IFNULL(rnk.ranking,'') as ranking,
  		IFNULL(brdar.broadarea,'') as broadarea,
  		IFNULL(hdr.impactfactor,'') as impactfactor,
  		IFNULL(hdr.title,'') as title,
  		IFNULL(hdr.confname,'') as confname,
  		IFNULL(hdr.place,'') as location,
  		IFNULL(hdr.volume,'') as volume,
  		IFNULL(hdr.issue,'') as issue,
  		IFNULL(hdr.pp,'') as pp,
  		IFNULL(hdr.digitallibrary,'') as doi,
        
		GROUP_CONCAT(UCASE(LEFT(IFNULL(dtls.athrfirstname,''),1)),SUBSTRING(IFNULL(dtls.athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(dtls.athrmiddlename,''), 1)),SUBSTRING(IFNULL(dtls.athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(dtls.athrlastname,''), 1)),SUBSTRING(IFNULL(dtls.athrlastname,''), 2) ORDER BY dtls.slno) as authorname, hdr.userid as userid
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes article ON article.articleid = hdr.articletypeid
        INNER JOIN Temp_Ranking_Table rnk on rnk.id = hdr.rankingid
  		LEFT OUTER JOIN broadareas brdar ON brdar.id = hdr.broadareaid
  		/*LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid*/
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid 
        INNER JOIN Temp_Header_Id thd ON thd.headerid = hdr.id
  	WHERE
    	CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND CASE WHEN IFNULL(categoryid,0) > 0 THEN cat.id = IFNULL(categoryid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
    AND hdr.deleted = 0    
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
   
 ELSE  
   	SELECT hdr.id as hdrid, DATE_FORMAT(hdr.pubdate, "%d/%m/%Y") as publicationdate,
  		CONCAT(UPPER(SUBSTRING(authtype.authortype,1,1)),LOWER(SUBSTRING(authtype.authortype,2))) as authortype,
  		CONCAT(UPPER(SUBSTRING(cat.category,1,1)),LOWER(SUBSTRING(cat.category,2))) as category,
  		hdr.nationality,
  		IFNULL(article.article,'') as article,
  		IFNULL(rnk.ranking,'') as ranking,
  		IFNULL(brdar.broadarea,'') as broadarea,
  		IFNULL(hdr.impactfactor,'') as impactfactor,
  		IFNULL(hdr.title,'') as title,
  		IFNULL(hdr.confname,'') as confname,
  		IFNULL(hdr.place,'') as location,
  		IFNULL(hdr.volume,'') as volume,
  		IFNULL(hdr.issue,'') as issue,
  		IFNULL(hdr.pp,'') as pp,
  		IFNULL(hdr.digitallibrary,'') as doi, 
        
        GROUP_CONCAT(UCASE(LEFT(IFNULL(dtls.athrfirstname,''),1)),SUBSTRING(IFNULL(dtls.athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(dtls.athrmiddlename,''), 1)),SUBSTRING(IFNULL(dtls.athrmiddlename,''), 2),' ', UCASE(LEFT(IFNULL(dtls.athrlastname,''), 1)),SUBSTRING(IFNULL(dtls.athrlastname,''), 2) ORDER BY dtls.slno) as authorname, hdr.userid as userid
  	FROM pubhdrs hdr 
  		INNER JOIN categories cat ON cat.id = hdr.categoryid 
  		INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
  		LEFT OUTER JOIN articletypes article ON article.articleid = hdr.articletypeid
        LEFT OUTER JOIN rankings rnk on rnk.id = hdr.rankingid
  		LEFT OUTER JOIN broadareas brdar ON brdar.id = hdr.broadareaid
  		/*LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid*/
  		INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid
  	WHERE
    	CASE WHEN (IFNULL(fromdt,'') != '' AND IFNULL(todt,'') != '') THEN hdr.pubdate BETWEEN fromdt AND todt ELSE 1=1 END
    	AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
    	AND CASE WHEN IFNULL(categoryid,0) > 0 THEN cat.id = IFNULL(categoryid,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(nationality,0) > 0 THEN hdr.nationality = IFNULL(nationality,0) ELSE 1=1 END
    	AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
    	AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
    AND hdr.deleted = 0    
  	GROUP by hdr.id,hdr.pubdate
  	ORDER BY hdr.pubdate,hdr.id;
    
 END IF;   
   
 DROP TEMPORARY TABLE IF EXISTS Temp_Rankings;
 DROP TEMPORARY TABLE IF EXISTS Temp_Ranking_Table;
 DROP TEMPORARY TABLE IF EXISTS Temp_Author_Fname;
 DROP TEMPORARY TABLE IF EXISTS Temp_Author_Mname;
 DROP TEMPORARY TABLE IF EXISTS Temp_Author_Lname;
 DROP TEMPORARY TABLE IF EXISTS Temp_Header_Id;
   
 END IF;
 
END;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Search_View_Data` (IN `fromdt` TEXT, IN `todt` TEXT, IN `authorname` VARCHAR(350), IN `category` INT)  BEGIN

DECLARE required INT;
DECLARE element INT;
DECLARE authorelement varchar(30);

SET required = 0;

IF (IFNULL(fromdt,'') = '' AND IFNULL(todt,'') = '' AND IFNULL(authorname,'') = '') THEN
	SET required = 1;  
END IF;

IF required = 0 THEN
    CREATE TEMPORARY TABLE Temp_Header_Id (headerid int);
    
    INSERT INTO Temp_Header_Id
    SELECT DISTINCT pubdtls.pubhdrid FROM  pubdtls WHERE IFNULL(pubdtls.fullname,'') like concat('%',IFNULL(authorname COLLATE utf8mb4_unicode_ci,''),'%');
    
   	SELECT hdr.id as hdrid, DATE_FORMAT(hdr.pubdate, "%d/%m/%Y") as publicationdate,cat.category,
    	GROUP_CONCAT(CASE WHEN dtls.slno != 1 THEN concat(" ",dtls.fullname) ELSE dtls.fullname END ORDER BY dtls.slno) as authorname,
  		IFNULL(hdr.title,'') as title,
  		IFNULL(hdr.confname,'') as confname
  	FROM pubhdrs hdr
    	INNER JOIN categories cat ON cat.id = hdr.categoryid
    	INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid
  		INNER JOIN Temp_Header_Id temp ON temp.headerid = hdr.id
   	WHERE hdr.deleted = 0  
   		AND YEAR(hdr.pubdate) BETWEEN fromdt AND todt
        AND	CASE WHEN IFNULL(category,0) != 0 THEN cat.id = category ELSE 1=1 END
    GROUP by dtls.pubhdrid
  	ORDER BY hdr.pubdate,hdr.id;

   DROP TEMPORARY TABLE IF EXISTS Temp_Header_Id;
   
 END IF;
 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_update_Data` (IN `hdrid` INT)  BEGIN

SELECT hdr.id,hdr.pubdate,hdr.authortypeid,
CONCAT(UPPER(SUBSTRING(ath.authortype,1,1)),LOWER(SUBSTRING(ath.authortype,2))) AS authortype,
hdr.categoryid,
CONCAT(UPPER(SUBSTRING(cat.category,1,1)),LOWER(SUBSTRING(cat.category,2))) AS category,
hdr.nationality,
hdr.digitallibrary AS doi,
hdr.articletypeid AS articletypeid,
IFNULL(article.article,'') AS article,
hdr.rankingid,
IFNULL(rnk.ranking,'') AS ranking,
hdr.broadareaid,
IFNULL(brd.broadarea,'') AS broadarea,
IFNULL(hdr.impactfactor,'') AS impactfactor,
IFNULL(hdr.place,'') AS location,
IFNULL(hdr.title,'') AS title,
IFNULL(hdr.confname,'') AS confname,
IFNULL(hdr.volume,'') AS volume,IFNULL(hdr.issue,'') AS issue,IFNULL(hdr.pp,'') AS pp,
IFNULL(hdr.publisher,'') AS publisher
FROM pubhdrs hdr
INNER JOIN authortypes ath ON ath.id = hdr.authortypeid
INNER JOIN categories cat ON cat.id = hdr.categoryid
LEFT OUTER JOIN rankings rnk ON rnk.id = hdr.rankingid
LEFT OUTER JOIN broadareas brd ON brd.id = hdr.broadareaid
/*LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid*/
LEFT OUTER JOIN articletypes article ON article.articleid = hdr.articletypeid
WHERE hdr.id = hdrid;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Print_Publication_Data` (IN `fromdate` DATE, IN `todate` DATE, IN `category` VARCHAR(25), IN `nationality` INT, IN `fname` TEXT, IN `mname` TEXT, IN `lname` TEXT, IN `type` INT, IN `subtype` INT, IN `categoryname` VARCHAR(25), IN `authortypeid` INT, IN `title` TEXT, IN `conference` TEXT, IN `ranking` TEXT)  BEGIN

DECLARE rankingcopy int;
DECLARE element INT;

CREATE TEMPORARY TABLE Temp_Rankings_Print (rankingids int);

IF CONVERT(ranking,int) = 0 THEN 
	SET rankingcopy = 0; 
ELSE 
	SET rankingcopy = 1; 
END IF;

IF rankingcopy = 0 AND type <> 8 THEN /* ranking and author condition */
	IF type = 0 THEN /* All search criteria */

          SELECT hdr.pubdate,dtls.pubhdrid,cat.category,
        GROUP_CONCAT(dtls.slno ORDER BY dtls.slno) as slno,  
        /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''),   2) ORDER BY dtls.slno)*/
        GROUP_CONCAT(CASE WHEN dtls.slno != 1 THEN concat(" ",dtls.fullname) ELSE dtls.fullname END ORDER BY dtls.slno) as authorname,IFNULL(hdr.title,'') AS title,IFNULL(hdr.confname,'') as conference,IFNULL(hdr.volume,'') as volume,IFNULL(hdr.issue,'') as issue,IFNULL(hdr.pp,'') as pages, IFNULL(hdr.nationality,'') AS nationality,IFNULL(hdr.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(hdr.impactfactor,'') as impactfactor, IFNULL(hdr.place,'') AS location
           FROM pubhdrs hdr
           INNER JOIN categories cat ON cat.id = hdr.categoryid
           LEFT OUTER JOIN articletypes art ON art.articleid = hdr.articletypeid 
           LEFT OUTER JOIN rankings rnk ON rnk.id = hdr.rankingid
           LEFT OUTER JOIN broadareas brdarea ON brdarea.id = hdr.broadareaid
           /*LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid*/
           INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid
           INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
           WHERE LOWER(cat.category) IN (categoryname COLLATE utf8mb4_unicode_ci)
           AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND hdr.deleted = 0     
           GROUP by dtls.pubhdrid
           order by IFNULL(hdr.nationality,''),pubdate,pubhdrid;

    ELSEIF type = 1 THEN /* Date search criteria */

          SELECT pubhdrs.pubdate,pubdtls.pubhdrid,categories.category,
          GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
          /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),'  ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
          GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') AS volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
           FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
           INNER JOIN categories ON categories.id = pubhdrs.categoryid
           INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
           LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
           LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
           LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
           /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
           where pubdate BETWEEN fromdate and todate
           AND LOWER(categories.category) IN (categoryname COLLATE utf8mb4_unicode_ci)
           AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;

    ELSEIF type = 2 THEN /* Category, Date criteria */

         SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
         GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
         /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
         GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
        LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
        LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
        /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
        where pubdate BETWEEN fromdate and todate
        and categories.category IN (category COLLATE utf8mb4_unicode_ci)
        AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
          AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;

    ELSEIF type = 3 THEN /* Nationality, Date criteria */

         SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
         GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
         /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
         GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article, 
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
        LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
        LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
        /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
        where pubdate BETWEEN fromdate and todate
        and pubhdrs.nationality IN (nationality)
        AND LOWER(categories.category) IN (categoryname COLLATE utf8mb4_unicode_ci)
        AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;

    ELSEIF type = 4 THEN /* Category criteria */

        SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
        GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
        /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
        GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
        LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
        LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
        /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
        where categories.category IN (category COLLATE utf8mb4_unicode_ci)
        AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END

                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;

    ELSEIF type = 5 THEN /* Nationality criteria */

        SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
        GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
        /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
        GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
        LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
        LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
        /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
        where pubhdrs.nationality IN (nationality)
        AND LOWER(categories.category) IN (categoryname COLLATE utf8mb4_unicode_ci)
        AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;

    ELSEIF type = 6 THEN  /* Category, Nationality criteria */

        SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
        GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
        /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
        GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
        LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
        LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
        /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
        where categories.category IN (category COLLATE utf8mb4_unicode_ci)
        and pubhdrs.nationality IN (nationality)
        AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;

    ELSEIF type = 7 THEN  /* Date Category, Nationality criteria */

        SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
        GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
        /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
        GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
        LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
        LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
        /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
        where pubdate BETWEEN fromdate and todate
        and categories.category IN (category COLLATE utf8mb4_unicode_ci)
        and pubhdrs.nationality IN (nationality)
        AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;
       
    END IF;
END IF;

IF rankingcopy = 1 AND type <> 8 THEN  /* ranking and author condition */
    
		IF ranking = '' THEN SET ranking = ','; END IF;

        WHILE ranking != '' DO
            SET element = SUBSTRING_INDEX(ranking, ',', 1);

            IF(element > 0) THEN
                INSERT INTO Temp_Rankings_Print VALUES(element);
            END IF;

            IF LOCATE(',', ranking) > 0 THEN
                SET ranking = SUBSTRING(ranking, LOCATE(',', ranking) + 1);
            ELSE
                SET ranking = '';
            END IF;
    	END WHILE;
        
        IF type = 0 THEN /* All search criteria */

          SELECT hdr.pubdate,dtls.pubhdrid,cat.category,
        GROUP_CONCAT(dtls.slno ORDER BY dtls.slno) as slno,  
        /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''),   2) ORDER BY dtls.slno)*/
        GROUP_CONCAT(CASE WHEN dtls.slno != 1 THEN concat(" ",dtls.fullname) ELSE dtls.fullname END ORDER BY dtls.slno) as authorname,IFNULL(hdr.title,'') AS title,IFNULL(hdr.confname,'') as conference,IFNULL(hdr.volume,'') as volume,IFNULL(hdr.issue,'') as issue,IFNULL(hdr.pp,'') as pages, IFNULL(hdr.nationality,'') AS nationality,IFNULL(hdr.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(hdr.impactfactor,'') as impactfactor, IFNULL(hdr.place,'') AS location
           FROM pubhdrs hdr
           INNER JOIN categories cat ON cat.id = hdr.categoryid
           LEFT OUTER JOIN articletypes art ON art.articleid = hdr.articletypeid 
           LEFT OUTER JOIN rankings rnk ON rnk.id = hdr.rankingid
           RIGHT OUTER JOIN Temp_Rankings_Print rank ON rnk.id = rank.rankingids
           LEFT OUTER JOIN broadareas brdarea ON brdarea.id = hdr.broadareaid
           /*LEFT OUTER JOIN impactfactors impact ON impact.id = hdr.impactfactorid*/
           INNER JOIN pubdtls dtls ON hdr.id = dtls.pubhdrid
           INNER JOIN authortypes authtype ON authtype.id = hdr.authortypeid
           WHERE LOWER(cat.category) IN (categoryname COLLATE utf8mb4_unicode_ci)
           AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN hdr.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND hdr.deleted = 0     
           GROUP by dtls.pubhdrid
           order by IFNULL(hdr.nationality,''),pubdate,pubhdrid;
           
    ELSEIF type = 1 THEN /* Date search criteria */

          SELECT pubhdrs.pubdate,pubdtls.pubhdrid,categories.category,
          GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
          /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),'  ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
          GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') AS volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
           FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
           INNER JOIN categories ON categories.id = pubhdrs.categoryid
           INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
           LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
           LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
           RIGHT OUTER JOIN Temp_Rankings_Print rank ON rnk.id = rank.rankingids
           LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
           /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
           where pubdate BETWEEN fromdate and todate
           AND LOWER(categories.category) IN (categoryname COLLATE utf8mb4_unicode_ci)
           AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0      
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;     
           
      ELSEIF type = 2 THEN /* Category, Date criteria */

         SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
         GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
         /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
         GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
        LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
         RIGHT OUTER JOIN Temp_Rankings_Print rank ON rnk.id = rank.rankingids
         LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
         /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
           where pubdate BETWEEN fromdate and todate
          and categories.category IN (category COLLATE utf8mb4_unicode_ci)
          AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
          AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;
           
     ELSEIF type = 3 THEN /* Nationality, Date criteria */

         SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
         GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
         /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
         GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article, 
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
           LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
           RIGHT OUTER JOIN Temp_Rankings_Print rank ON rnk.id = rank.rankingids
           LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
           /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
           where pubdate BETWEEN fromdate and todate
           and pubhdrs.nationality IN (nationality)
           AND LOWER(categories.category) IN (categoryname COLLATE utf8mb4_unicode_ci)
           AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;
           
     ELSEIF type = 4 THEN /* Category criteria */

        SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
        GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
        /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
        GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
           LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
           RIGHT OUTER JOIN Temp_Rankings_Print rank ON rnk.id = rank.rankingids
           LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
           /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
           where categories.category IN (category COLLATE utf8mb4_unicode_ci)
           AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;
           
    ELSEIF type = 5 THEN /* Nationality criteria */

        SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
        GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
        /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
       GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(pubhdrs.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
           LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
           RIGHT OUTER JOIN Temp_Rankings_Print rank ON rnk.id = rank.rankingids
           LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
           /*LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid*/
           where pubhdrs.nationality IN (nationality)
           AND LOWER(categories.category) IN (categoryname COLLATE utf8mb4_unicode_ci)
           AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;

    ELSEIF type = 6 THEN  /* Category, Nationality criteria */

        SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
        GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
        /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
        GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(impact.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
           LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
           RIGHT OUTER JOIN Temp_Rankings_Print rank ON rnk.id = rank.rankingids
           LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
           LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid
           where categories.category IN (category COLLATE utf8mb4_unicode_ci)
           and pubhdrs.nationality IN (nationality)
           AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;

    ELSEIF type = 7 THEN  /* Date Category, Nationality criteria */

        SELECT pubhdrs.pubdate,pubdtls.pubhdrid,
        GROUP_CONCAT(pubdtls.slno ORDER BY pubdtls.slno) as slno,
        /*GROUP_CONCAT(UCASE(LEFT(IFNULL(athrfirstname,''),1)),SUBSTRING(IFNULL(athrfirstname,''), 2),' ',UCASE(LEFT(IFNULL(athrmiddlename,''), 1)),SUBSTRING(IFNULL(athrmiddlename,''), 2), UCASE(LEFT(IFNULL(athrlastname,''), 1)),SUBSTRING(IFNULL(athrlastname,''), 2) ORDER BY pubdtls.slno)*/
        GROUP_CONCAT(CASE WHEN pubdtls.slno != 1 THEN concat(" ",pubdtls.fullname) ELSE pubdtls.fullname END ORDER BY pubdtls.slno) as authorname,IFNULL(pubhdrs.title,'') AS title,IFNULL(pubhdrs.confname,'') as conference,IFNULL(pubhdrs.volume,'') as volume,IFNULL(pubhdrs.issue,'') as issue,IFNULL(pubhdrs.pp,'') as pages, IFNULL(pubhdrs.nationality,'') AS nationality,
        IFNULL(pubhdrs.digitallibrary,'') AS Doi,IFNULL(art.article,'') AS article,
        IFNULL(rnk.ranking,'') as ranking, IFNULL(brdarea.broadarea,'') as broadarea,
        IFNULL(impact.impactfactor,'') as impactfactor, IFNULL(pubhdrs.place,'') AS location
        FROM pubhdrs INNER JOIN pubdtls ON pubhdrs.id = pubdtls.pubhdrid
        INNER JOIN categories ON categories.id = pubhdrs.categoryid
        INNER JOIN authortypes authtype ON authtype.id = pubhdrs.authortypeid
        LEFT OUTER JOIN articletypes art ON art.articleid = pubhdrs.articletypeid 
           LEFT OUTER JOIN rankings rnk ON rnk.id = pubhdrs.rankingid
           RIGHT OUTER JOIN Temp_Rankings_Print rank ON rnk.id = rank.rankingids
           LEFT OUTER JOIN broadareas brdarea ON brdarea.id = pubhdrs.broadareaid
           LEFT OUTER JOIN impactfactors impact ON impact.id = pubhdrs.impactfactorid
           where pubdate BETWEEN fromdate and todate
           and categories.category IN (category COLLATE utf8mb4_unicode_ci)
           and pubhdrs.nationality IN (nationality)
           AND CASE WHEN IFNULL(authortypeid,0) > 0 THEN authtype.id = IFNULL(authortypeid,0) ELSE 1=1 END
           AND	CASE WHEN IFNULL(title COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.title like concat('%',IFNULL(title COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
                AND	CASE WHEN IFNULL(conference COLLATE utf8mb4_unicode_ci,'') != '' THEN pubhdrs.confname like concat('%',IFNULL(conference COLLATE utf8mb4_unicode_ci,''),'%') ELSE 1=1 END
           AND pubhdrs.deleted = 0     
           GROUP by pubdtls.pubhdrid
           order by IFNULL(pubhdrs.nationality,''),pubdate,pubhdrid;     
           
       END IF;    
        
END IF;         

IF type = 8 THEN /* CALL GetAuthor */

 CALL GetAuthor(fname,mname,lname,subtype,fromdate,todate,category,nationality,categoryname,authortypeid,title,conference,ranking);  
 
END IF; 

DROP TEMPORARY TABLE IF EXISTS Temp_Rankings_Print;

    
	END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `articletypes`
--

CREATE TABLE `articletypes` (
  `articleid` int(11) NOT NULL,
  `article` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `journalconfernce` varchar(11) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `articletypes`
--

INSERT INTO `articletypes` (`articleid`, `article`, `journalconfernce`) VALUES
(1, 'Short Paper', 'conference'),
(2, 'Full Paper', 'conference'),
(3, 'Poster', 'conference');

-- --------------------------------------------------------

--
-- Table structure for table `authortypes`
--

CREATE TABLE `authortypes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `authortype` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `authortypes`
--

INSERT INTO `authortypes` (`id`, `authortype`, `created_at`, `updated_at`) VALUES
(1, 'Faculty', NULL, NULL),
(2, 'Student', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `broadareas`
--

CREATE TABLE `broadareas` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `broadarea` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `broadareas`
--

INSERT INTO `broadareas` (`id`, `broadarea`, `created_at`, `updated_at`) VALUES
(9, 'Networks', '2020-07-14 23:46:23', '2020-07-14 23:46:23'),
(17, 'Data Science', NULL, NULL),
(18, 'Systems', NULL, NULL),
(19, 'Theory', '2020-10-23 04:29:48', '2020-10-23 04:29:48'),
(24, 'HCI and AI', '2021-11-12 11:06:00', '2021-11-12 11:06:00');

-- --------------------------------------------------------

--
-- Table structure for table `campuses`
--

CREATE TABLE `campuses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `campus` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `defaultemail` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `campuses`
--

INSERT INTO `campuses` (`id`, `campus`, `defaultemail`, `created_at`, `updated_at`) VALUES
(1, 'Pilani', 'pilani.bits-pilani.ac.in', NULL, NULL),
(2, 'Goa', 'goa.bits-pilani.ac.in', NULL, NULL),
(3, 'Hyderabad', 'hyderabad.bits-pilani.ac.in', NULL, NULL),
(4, 'Dubai', 'dubai.bits-pilani.ac.in', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `category`, `created_at`, `updated_at`) VALUES
(7, 'Journal', NULL, NULL),
(8, 'Conference/Workshop', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `campusid` bigint(20) UNSIGNED NOT NULL,
  `department` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `campusid`, `department`, `created_at`, `updated_at`) VALUES
(1, 2, 'Department of Biological Sciences', NULL, NULL),
(2, 2, 'Department of Chemical Engineering', NULL, NULL),
(3, 2, 'Department of Chemistry', NULL, NULL),
(4, 2, 'Department of Computer Science & Information Systems', NULL, NULL),
(5, 2, 'Department of Economics', NULL, NULL),
(6, 2, 'Department of Electrical and Electronics Engineering', NULL, NULL),
(7, 2, 'Department of Humanities and Social Sciences', NULL, NULL),
(8, 2, 'Department of Mathematics', NULL, NULL),
(9, 2, 'Department of Mechanical Engineering', NULL, NULL),
(10, 2, 'Department of Physics', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `impactfactors`
--

CREATE TABLE `impactfactors` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `impactfactor` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `impactfactors`
--

INSERT INTO `impactfactors` (`id`, `impactfactor`, `created_at`, `updated_at`) VALUES
(5, 'Others', '2020-07-14 23:46:34', '2020-07-14 23:46:34'),
(12, '2.76', '2020-09-15 04:30:41', '2020-09-15 04:30:41'),
(13, '1.46', '2020-09-15 04:30:49', '2020-09-15 04:30:49'),
(14, '0.7', '2020-09-15 04:31:18', '2020-09-15 04:31:18'),
(15, '2.41', '2020-09-15 04:31:31', '2020-09-15 04:31:31'),
(16, '1.2', '2020-09-15 04:34:45', '2020-09-15 04:34:45'),
(17, '5.23', '2020-09-15 23:46:06', '2020-09-15 23:46:06');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(4, '2014_10_12_100000_create_password_resets_table', 1),
(5, '2019_08_19_000000_create_failed_jobs_table', 1),
(6, '2020_10_21_092327_create_campuses_table', 1),
(7, '2020_10_21_092809_create_departments_table', 1),
(9, '2020_10_22_051814_create_userregistrations_table', 2),
(45, '2014_10_12_000000_create_users_table', 1),
(46, '2014_10_12_100000_create_password_resets_table', 1),
(48, '2020_05_26_043534_create-category-table', 1),
(49, '2020_05_26_043652_create-author-table', 1),
(50, '2020_05_26_054203_create-ranking-table', 1),
(51, '2020_05_26_054226_create-broadarea-table', 1),
(52, '2020_05_26_054251_create-impactfactor-table', 1),
(84, '2019_08_19_000000_create_failed_jobs_table', 2),
(97, '2020_05_26_084403_create-category-table', 3),
(98, '2020_05_26_084417_create-authortype-table', 3),
(99, '2020_05_26_084425_create-ranking-table', 3),
(100, '2020_05_26_084433_create-broadarea-table', 3),
(101, '2020_05_26_084442_create-impactfactor-table', 3),
(102, '2020_05_26_085916_create-testmain-table', 3),
(103, '2020_05_26_100658_create-testprimary-table', 4),
(104, '2020_05_26_100741_create-testforeign-table', 4),
(115, '2020_05_26_102228_create-product-table', 5),
(116, '2020_05_26_102349_create-productprice-table', 5),
(117, '2020_05_26_104815_create-category-table', 6),
(118, '2020_05_26_104933_create-authortype-table', 6),
(119, '2020_05_26_105033_create-ranking-table', 6),
(120, '2020_05_26_105125_create-broadarea-table', 6),
(121, '2020_05_26_105229_create-impactfactor-table', 7),
(122, '2020_05_26_105432_create-pubhdr-table', 7),
(124, '2020_05_26_110308_create-pubdtl-table', 8);

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `productprices`
--

CREATE TABLE `productprices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` bigint(20) UNSIGNED NOT NULL,
  `price` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pubdtls`
--

CREATE TABLE `pubdtls` (
  `slno` bigint(20) NOT NULL,
  `pubhdrid` bigint(20) UNSIGNED NOT NULL,
  `athrfirstname` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `athrmiddlename` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `athrlastname` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fullname` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `inhouseflag` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pubdtls`
--

INSERT INTO `pubdtls` (`slno`, `pubhdrid`, `athrfirstname`, `athrmiddlename`, `athrlastname`, `fullname`, `inhouseflag`, `created_at`, `updated_at`) VALUES
(1, 1, 'Abhiraj', NULL, 'Hinge', 'Abhiraj Hinge', 0, NULL, NULL),
(1, 2, 'Rakesh', 'Ranjan', 'Swain', 'Rakesh Ranjan Swain', 0, NULL, NULL),
(1, 3, 'Sujith', NULL, 'Thomas', 'Sujith Thomas', 0, NULL, NULL),
(1, 4, 'Kushagra', NULL, 'Mahajan', 'Kushagra Mahajan', 0, NULL, NULL),
(1, 5, 'Sujith', NULL, 'Thomas', 'Sujith Thomas', 0, NULL, NULL),
(1, 6, 'Sujith', NULL, 'Thomas', 'Sujith Thomas', 0, NULL, NULL),
(1, 7, 'Soundarya', NULL, 'Krishnan', 'Soundarya Krishnan', 0, NULL, NULL),
(1, 8, 'Sharan', NULL, 'Yalburgi', 'Sharan Yalburgi', 0, NULL, NULL),
(1, 9, 'Soundarya', NULL, 'Krishnan', 'Soundarya Krishnan', 0, NULL, NULL),
(1, 10, 'Raj', 'K', 'Jaiswal', 'Raj K Jaiswal', 0, NULL, NULL),
(1, 11, 'S', NULL, 'Giridher', 'S Giridher', 0, NULL, NULL),
(1, 12, 'K', NULL, 'Phokela', 'K Phokela', 0, NULL, NULL),
(1, 13, 'P', NULL, 'Sharma', 'P Sharma', 0, NULL, NULL),
(1, 14, 'Dheryta', NULL, 'Jaisinghani', 'Dheryta Jaisinghani', 0, NULL, NULL),
(1, 15, 'Sharan', 'Ranjit', 'S', 'Sharan Ranjit S', 0, NULL, NULL),
(1, 16, 'Aman', 'Kumar', 'Singh', 'Aman Kumar Singh', 0, NULL, NULL),
(1, 17, 'Rachit', NULL, 'Rastogi', 'Rachit Rastogi', 0, NULL, NULL),
(1, 18, 'Raj', 'K', 'Jaiswal', 'Raj K Jaiswal', 0, NULL, NULL),
(1, 19, 'Zaiba', 'Hasan', 'Khan', 'Zaiba Hasan Khan', 0, NULL, NULL),
(1, 20, 'Bhavye', NULL, 'Jain', 'Bhavye Jain', 0, NULL, NULL),
(1, 21, 'Rajaswa', NULL, 'Patil', 'Rajaswa Patil', 0, NULL, NULL),
(1, 22, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(1, 23, 'Shourya', NULL, 'Shukla', 'Shourya Shukla', 0, NULL, NULL),
(1, 24, 'Ashwin', NULL, 'Srinivasan', 'Ashwin Srinivasan', 0, NULL, NULL),
(1, 25, 'Tirtharaj', NULL, 'Dash', 'Tirtharaj Dash', 0, NULL, NULL),
(1, 26, 'Mouli', NULL, 'Rastogi', 'Mouli Rastogi', 0, NULL, NULL),
(1, 27, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(1, 28, 'Rahul', NULL, 'Yedida', 'Rahul Yedida', 0, NULL, NULL),
(1, 29, 'Harikrishnan', 'Nellippallil', 'Balakrishnan', 'Harikrishnan Nellippallil Balakrishnan', 0, NULL, NULL),
(1, 30, 'Suryoday', NULL, 'Basak', 'Suryoday Basak', 0, NULL, NULL),
(1, 31, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(1, 32, 'Shailesh', NULL, 'Sridhar', 'Shailesh Sridhar', 0, NULL, NULL),
(1, 33, 'R.', NULL, 'Reddy', 'R. Reddy', 0, NULL, NULL),
(1, 34, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(1, 35, 'Shashank', 'Sanjay', 'Bhat', 'Shashank Sanjay Bhat', 0, NULL, NULL),
(1, 45, 'Rawan', NULL, 'Alharbi', 'Rawan Alharbi', 0, NULL, NULL),
(1, 51, 'Rizwan', NULL, 'Parveen', 'Rizwan Parveen', 0, NULL, NULL),
(1, 52, 'Ishita', NULL, 'Mediratta', 'Ishita Mediratta', 0, NULL, NULL),
(1, 55, 'Kanchan', NULL, 'Jha', 'Kanchan Jha', 0, NULL, NULL),
(1, 58, 'Shrehal', NULL, 'Bohra', 'Shrehal Bohra', 0, NULL, NULL),
(1, 59, 'Ankita', NULL, 'Dewan', 'Ankita Dewan', 0, NULL, NULL),
(1, 60, 'Chinmay', NULL, 'Chiplunkar', 'Chinmay Chiplunkar', 0, NULL, NULL),
(1, 61, 'Sujith', NULL, 'Thomas', 'Sujith Thomas', 0, NULL, NULL),
(1, 63, 'Surjya', NULL, 'Ghosh', 'Surjya Ghosh', 0, NULL, NULL),
(1, 64, 'Surjya', NULL, 'Ghosh', 'Surjya Ghosh', 0, NULL, NULL),
(1, 65, 'Tejal', NULL, 'Karnavat', 'Tejal Karnavat', 0, NULL, NULL),
(1, 66, 'Rakshit', NULL, 'Mittal', 'Rakshit Mittal', 0, NULL, NULL),
(1, 68, 'Rakshit', NULL, 'Mittal', 'Rakshit Mittal', 0, NULL, NULL),
(1, 69, 'Rakshit', NULL, 'Mittal', 'Rakshit Mittal', 0, NULL, NULL),
(1, 70, 'Rakshit', NULL, 'Mittal', 'Rakshit Mittal', 0, NULL, NULL),
(1, 71, 'Arun', 'S', 'Nair', 'Arun S Nair', 0, NULL, NULL),
(1, 72, 'Louella', 'M', 'Colaco', 'Louella M Colaco', 0, NULL, NULL),
(1, 73, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 74, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 75, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 76, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 89, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 90, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(1, 95, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 96, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 97, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 98, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 99, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 100, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 101, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 102, 'Dipayan', NULL, 'Deb', 'Dipayan Deb', 0, NULL, NULL),
(1, 103, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 104, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 105, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 106, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 107, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 108, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 109, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 110, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 111, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 112, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 113, 'Dhairya', NULL, 'Parikh', 'Dhairya Parikh', 0, NULL, NULL),
(1, 114, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 115, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 116, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(1, 117, 'Travis', NULL, 'Peters', 'Travis Peters', 0, NULL, NULL),
(1, 118, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 119, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 120, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 124, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 125, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 126, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 127, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 128, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 129, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 130, 'Pritam', NULL, 'Bhattacharya', 'Pritam Bhattacharya', 0, NULL, NULL),
(1, 131, 'Atharv', NULL, 'Sonwane', 'Atharv Sonwane', 0, NULL, NULL),
(1, 132, 'Het', NULL, 'Shah', 'Het Shah', 0, NULL, NULL),
(1, 133, 'T.', NULL, 'Dash', 'T. Dash', 0, NULL, NULL),
(1, 134, 'T.', NULL, 'Dash', 'T. Dash', 0, NULL, NULL),
(1, 135, 'T.', NULL, 'Dash', 'T. Dash', 0, NULL, NULL),
(1, 136, 'G.', NULL, 'Chhablani', 'G. Chhablani', 0, NULL, NULL),
(1, 137, 'T.', NULL, 'Dash', 'T. Dash', 0, NULL, NULL),
(1, 138, 'T.', NULL, 'Dash', 'T. Dash', 0, NULL, NULL),
(1, 139, 'A.', NULL, 'Sharma', 'A. Sharma', 0, NULL, NULL),
(1, 140, 'Rohit', NULL, 'Kaushik', 'Rohit Kaushik', 0, NULL, NULL),
(1, 141, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 142, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 143, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 144, 'Shibo', NULL, 'Zhang', 'Shibo Zhang', 0, NULL, NULL),
(1, 145, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 146, 'Shengjie', NULL, 'Bi', 'Shengjie Bi', 0, NULL, NULL),
(1, 147, 'Shibo', NULL, 'Zhang', 'Shibo Zhang', 0, NULL, NULL),
(1, 148, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 149, 'Varun', NULL, 'Mishra', 'Varun Mishra', 0, NULL, NULL),
(1, 150, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 151, 'Swapna', NULL, 'Sasi', 'Swapna Sasi', 0, NULL, NULL),
(1, 152, 'Sen Basabdatta', NULL, 'Bhattacharya', 'Sen Basabdatta Bhattacharya', 0, NULL, NULL),
(1, 153, 'Pranav', NULL, 'Mahajan', 'Pranav Mahajan', 0, NULL, NULL),
(1, 154, 'Sen Basabdatta', NULL, 'Bhattacharya', 'Sen Basabdatta Bhattacharya', 0, NULL, NULL),
(1, 155, 'Chinmay', NULL, 'Chiplunkar', 'Chinmay Chiplunkar', 0, NULL, NULL),
(1, 156, 'Shriya', 'T.P.', 'Gupta', 'Shriya T.P. Gupta', 0, NULL, NULL),
(1, 157, 'Swapna', NULL, 'Sasi', 'Swapna Sasi', 0, NULL, NULL),
(1, 158, 'Ajwani', NULL, 'RD', 'Ajwani RD', 0, NULL, NULL),
(1, 159, 'Fahmida', 'N', 'Chowdhury', 'Fahmida N Chowdhury', 0, NULL, NULL),
(1, 160, 'Mahak', NULL, 'Kothari', 'Mahak Kothari', 0, NULL, NULL),
(1, 161, 'Rohan', 'Deepak', 'Ajwani', 'Rohan Deepak Ajwani', 0, NULL, NULL),
(1, 162, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 163, 'Tianli', NULL, 'Mo', 'Tianli Mo', 0, NULL, NULL),
(1, 164, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 165, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 166, 'Kumar', NULL, 'Padmanabh', 'Kumar Padmanabh', 0, NULL, NULL),
(1, 167, 'Kumar', NULL, 'Padmanabh', 'Kumar Padmanabh', 0, NULL, NULL),
(1, 168, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 169, 'Tianli', NULL, 'Mo', 'Tianli Mo', 0, NULL, NULL),
(1, 170, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 171, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 172, 'Meera', NULL, 'Radhakrishnan', 'Meera Radhakrishnan', 0, NULL, NULL),
(1, 173, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 174, 'S.', NULL, 'Sen', 'S. Sen', 0, NULL, NULL),
(1, 175, 'M.', NULL, 'Radhakrishnan', 'M. Radhakrishnan', 0, NULL, NULL),
(1, 176, 'Mateusz', NULL, 'Mikusz', 'Mateusz Mikusz', 0, NULL, NULL),
(1, 177, 'S.', NULL, 'Vigneshwaran', 'S. Vigneshwaran', 0, NULL, NULL),
(1, 178, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 179, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 180, 'Varun', NULL, 'Mishra', 'Varun Mishra', 0, NULL, NULL),
(1, 181, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 182, 'Meera', NULL, 'Radhakrishnan', 'Meera Radhakrishnan', 0, NULL, NULL),
(1, 183, 'Varun', NULL, 'Mishra', 'Varun Mishra', 0, NULL, NULL),
(1, 184, 'Shengjie', NULL, 'Bi', 'Shengjie Bi', 0, NULL, NULL),
(1, 185, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(1, 186, 'Rohan', NULL, 'Mohapatra', 'Rohan Mohapatra', 0, NULL, NULL),
(1, 187, 'Luckyson', NULL, 'Khaidem', 'Luckyson Khaidem', 0, NULL, NULL),
(1, 188, 'Rahul', NULL, 'Yedida', 'Rahul Yedida', 0, NULL, NULL),
(1, 189, 'A.', NULL, 'Tambewkar', 'A. Tambewkar', 0, NULL, NULL),
(1, 190, 'Tejas', NULL, 'Prashanth', 'Tejas Prashanth', 0, NULL, NULL),
(1, 191, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(1, 192, 'Sudeepa Roy', NULL, 'Dey', 'Sudeepa Roy Dey', 0, NULL, NULL),
(1, 193, 'Ishita', NULL, 'Mediratta', 'Ishita Mediratta', 0, NULL, NULL),
(1, 194, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(1, 195, 'Pragnya', NULL, 'Sridhar', 'Pragnya Sridhar', 0, NULL, NULL),
(1, 196, 'Snigdha', NULL, 'Sen', 'Snigdha Sen', 0, NULL, NULL),
(1, 197, 'Jyotirmoy', NULL, 'Sarkar', 'Jyotirmoy Sarkar', 0, NULL, NULL),
(1, 198, 'Rishab', NULL, 'Khincha', 'Rishab Khincha', 0, NULL, NULL),
(1, 199, 'Soundarya', NULL, 'Krishnan', 'Soundarya Krishnan', 0, NULL, NULL),
(1, 200, 'Pedro', NULL, 'Albuquerque', 'Pedro Albuquerque', 0, NULL, NULL),
(1, 201, 'Pedro', NULL, 'Albuquerque', 'Pedro Albuquerque', 0, NULL, NULL),
(1, 202, 'Vedant', NULL, 'Shah', 'Vedant Shah', 0, NULL, NULL),
(1, 203, 'Aditya', NULL, 'Challa', 'Aditya Challa', 0, NULL, NULL),
(1, 204, 'Sravan', NULL, 'Danda', 'Sravan Danda', 0, NULL, NULL),
(1, 205, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(1, 206, 'Trupil', NULL, 'Limbasiya', 'Trupil Limbasiya', 0, NULL, NULL),
(1, 207, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 208, 'Jyotiprakash', NULL, 'Mishra', 'Jyotiprakash Mishra', 0, NULL, NULL),
(1, 209, 'Trupil', NULL, 'Limbasiya', 'Trupil Limbasiya', 0, NULL, NULL),
(1, 210, 'Trupil', NULL, 'Limbasiya', 'Trupil Limbasiya', 0, NULL, NULL),
(1, 211, 'Shriya', 'TP', 'Gupta', 'Shriya TP Gupta', 0, NULL, NULL),
(1, 214, 'Aa', NULL, 'Aa', 'Aa Aa', 0, NULL, NULL),
(1, 215, 'Sujith', NULL, 'Thomas', 'Sujith Thomas', 0, NULL, NULL),
(1, 216, 'Anuja', NULL, 'Pinge', 'Anuja Pinge', 0, NULL, NULL),
(1, 217, 'Rawan', NULL, 'Alharbi', 'Rawan Alharbi', 0, NULL, NULL),
(1, 218, 'Rohan', NULL, 'Agarwal', 'Rohan Agarwal', 0, NULL, NULL),
(1, 219, 'N.', NULL, 'Arya', 'N. Arya', 0, NULL, NULL),
(1, 220, 'J.', NULL, 'Sarkar', 'J. Sarkar', 0, NULL, NULL),
(1, 221, 'Haoxiang', NULL, 'Yu', 'Haoxiang Yu', 0, NULL, NULL),
(1, 222, 'Aishwarya.', NULL, 'M', 'Aishwarya. M', 0, NULL, NULL),
(1, 223, 'Jyotirmoy', NULL, 'sarkar', 'Jyotirmoy sarkar', 0, NULL, NULL),
(1, 224, 'A.', NULL, 'Tambewkar', 'A. Tambewkar', 0, NULL, NULL),
(1, 225, 'Tejas', NULL, 'Prashanth', 'Tejas Prashanth', 0, NULL, NULL),
(1, 226, 'Sarkar', NULL, 'P', 'Sarkar P', 0, NULL, NULL),
(1, 227, 'Dey', NULL, 'Sudeepa', 'Dey Sudeepa', 0, NULL, NULL),
(1, 228, 'John', NULL, 'Hata', 'John Hata', 0, NULL, NULL),
(1, 229, 'Snigdha', NULL, 'Sen', 'Snigdha Sen', 0, NULL, NULL),
(1, 230, 'Abhijeet', NULL, 'Swain', 'Abhijeet Swain', 0, NULL, NULL),
(1, 231, 'A.', NULL, 'Bhattacharya', 'A. Bhattacharya', 0, NULL, NULL),
(1, 232, 'Vaidya', NULL, 'O', 'Vaidya O', 0, NULL, NULL),
(1, 233, 'Y.', NULL, 'Gondhalekar', 'Y. Gondhalekar', 0, NULL, NULL),
(1, 234, 'Yash', NULL, 'Jangir', 'Yash Jangir', 0, NULL, NULL),
(1, 235, 'Rohan', NULL, 'Kumar', 'Rohan Kumar', 0, NULL, NULL),
(1, 236, 'Nagajothi', NULL, 'Kannan', 'Nagajothi Kannan', 0, NULL, NULL),
(1, 237, 'Aditya', NULL, 'Challa', 'Aditya Challa', 0, NULL, NULL),
(1, 238, 'Amit', NULL, 'Adate', 'Amit Adate', 0, NULL, NULL),
(1, 239, 'Soroush', NULL, 'Shahi', 'Soroush Shahi', 0, NULL, NULL),
(1, 240, 'Akhilesh', NULL, 'Adithya', 'Akhilesh Adithya', 0, NULL, NULL),
(1, 241, 'Annie', NULL, 'Lin', 'Annie Lin', 0, NULL, NULL),
(1, 242, 'Satchit', NULL, 'Hari', 'Satchit Hari', 0, NULL, NULL),
(1, 243, 'Salma', NULL, 'Mandi', 'Salma Mandi', 0, NULL, NULL),
(1, 244, 'Surjya', NULL, 'Ghosh', 'Surjya Ghosh', 0, NULL, NULL),
(1, 245, 'Surjya', NULL, 'Ghosh', 'Surjya Ghosh', 0, NULL, NULL),
(1, 246, 'Shruti', NULL, 'Rao', 'Shruti Rao', 0, NULL, NULL),
(1, 247, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 248, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 249, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 250, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 251, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 252, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 253, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 254, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(1, 255, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 256, 'Trupil', NULL, 'Limbasiya', 'Trupil Limbasiya', 0, NULL, NULL),
(1, 257, 'Hadeel', NULL, 'Albahar', 'Hadeel Albahar', 0, NULL, NULL),
(1, 258, 'Jean Luca', NULL, 'Bez', 'Jean Luca Bez', 0, NULL, NULL),
(1, 259, 'Arnab Kumar', NULL, 'Paul', 'Arnab Kumar Paul', 0, NULL, NULL),
(1, 260, 'Ahmad Maroof', NULL, 'Karimi', 'Ahmad Maroof Karimi', 0, NULL, NULL),
(1, 261, 'SHUBHANGI', NULL, 'GAWALI', 'SHUBHANGI GAWALI', 0, NULL, NULL),
(1, 262, 'Shubhangi', NULL, 'Gawali', 'Shubhangi Gawali', 0, NULL, NULL),
(1, 263, 'Dhruv', NULL, 'Nagpal', 'Dhruv Nagpal', 0, NULL, NULL),
(1, 264, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(1, 265, 'Fahmida', 'N.', 'Chowdhury', 'Fahmida N. Chowdhury', 0, NULL, NULL),
(1, 266, 'Swpna', NULL, 'Sasi', 'Swpna Sasi', 0, NULL, NULL),
(1, 267, 'Swapna', NULL, 'Sasi', 'Swapna Sasi', 0, NULL, NULL),
(1, 268, 'Enuganti', 'Pavan', 'Kumar', 'Enuganti Pavan Kumar', 0, NULL, NULL),
(1, 269, 'Remya', NULL, 'Ajai AS', 'Remya Ajai AS', 0, NULL, NULL),
(1, 270, 'Abhishek', NULL, 'Jain', 'Abhishek Jain', 0, NULL, NULL),
(1, 271, 'RK', 'Chandra', 'Shekar', 'RK Chandra Shekar', 0, NULL, NULL),
(1, 272, 'Harikrishnan', NULL, 'NB', 'Harikrishnan NB', 0, NULL, NULL),
(1, 273, 'Deeksha', NULL, 'Sethi', 'Deeksha Sethi', 0, NULL, NULL),
(1, 274, 'Harikrishnan', NULL, 'NB', 'Harikrishnan NB', 0, NULL, NULL),
(1, 275, 'Arun', NULL, 'Sukumaran Nair', 'Arun Sukumaran Nair', 0, NULL, NULL),
(1, 276, 'Louella', NULL, 'Colaco', 'Louella Colaco', 0, NULL, NULL),
(1, 277, 'Shounak', NULL, 'Naik', 'Shounak Naik', 0, NULL, NULL),
(1, 278, 'Anbumunee', NULL, 'Ponniah', 'Anbumunee Ponniah', 0, NULL, NULL),
(1, 279, 'Anbumunee', NULL, 'Ponniah', 'Anbumunee Ponniah', 0, NULL, NULL),
(1, 280, 'Zaiba', 'Hasan', 'Khan', 'Zaiba Hasan Khan', 0, NULL, NULL),
(1, 281, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(1, 282, 'Rahul', NULL, 'Thakur', 'Rahul Thakur', 0, NULL, NULL),
(1, 283, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(1, 284, 'Anbumunee', NULL, 'Ponniah', 'Anbumunee Ponniah', 0, NULL, NULL),
(2, 1, 'Pranav', NULL, 'Garg', 'Pranav Garg', 0, NULL, NULL),
(2, 2, 'Tirtharaj', NULL, 'Dash', 'Tirtharaj Dash', 0, NULL, NULL),
(2, 3, 'Narayanan', NULL, 'Srinivasan', 'Narayanan Srinivasan', 0, NULL, NULL),
(2, 4, 'Monika', NULL, 'Sharma', 'Monika Sharma', 0, NULL, NULL),
(2, 5, 'Aditya', NULL, 'Kapoor', 'Aditya Kapoor', 0, NULL, NULL),
(2, 6, 'Narayanan', NULL, 'Srinivasan', 'Narayanan Srinivasan', 0, NULL, NULL),
(2, 7, 'Rishab', NULL, 'Khincha', 'Rishab Khincha', 0, NULL, NULL),
(2, 8, 'Tirtharaj', NULL, 'Dash', 'Tirtharaj Dash', 0, NULL, NULL),
(2, 9, 'Rishab', NULL, 'Khincha', 'Rishab Khincha', 0, NULL, NULL),
(2, 11, 'A', NULL, 'Gupta', 'A Gupta', 0, NULL, NULL),
(2, 12, 'Vinayak', NULL, 'Naik', 'Vinayak Naik', 0, NULL, NULL),
(2, 13, 'D', NULL, 'Gosain', 'D Gosain', 0, NULL, NULL),
(2, 14, 'Naman', NULL, 'Gupta', 'Naman Gupta', 0, NULL, NULL),
(2, 15, 'Raj', 'K', 'Jaiswal', 'Raj K Jaiswal', 0, NULL, NULL),
(2, 16, 'Raj', 'K', 'Jaiswal', 'Raj K Jaiswal', 0, NULL, NULL),
(2, 17, 'Ritika', NULL, 'Jaiswal', 'Ritika Jaiswal', 0, NULL, NULL),
(2, 19, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(2, 20, 'Kaustubh', NULL, 'Trivedi', 'Kaustubh Trivedi', 0, NULL, NULL),
(2, 21, 'Somesh', NULL, 'Singh', 'Somesh Singh', 0, NULL, NULL),
(2, 22, 'Rahul', NULL, 'Thakur', 'Rahul Thakur', 0, NULL, NULL),
(2, 23, 'Rahul', NULL, 'Thakur', 'Rahul Thakur', 0, NULL, NULL),
(2, 24, 'Lovekesh', NULL, 'Vig', 'Lovekesh Vig', 0, NULL, NULL),
(2, 25, 'Ashwin', NULL, 'Srinivasan', 'Ashwin Srinivasan', 0, NULL, NULL),
(2, 26, 'Syed', NULL, 'Afshan Ali', 'Syed Afshan Ali', 0, NULL, NULL),
(2, 27, 'Nithin', NULL, 'Nagaraj', 'Nithin Nagaraj', 0, NULL, NULL),
(2, 28, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 29, 'Aditi', NULL, 'Kathpalia', 'Aditi Kathpalia', 0, NULL, NULL),
(2, 30, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 31, 'Tejas', NULL, 'Prashanth', 'Tejas Prashanth', 0, NULL, NULL),
(2, 32, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 33, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 34, 'Nithin', NULL, 'Nagaraj', 'Nithin Nagaraj', 0, NULL, NULL),
(2, 35, 'Prabu', NULL, 'T', 'Prabu T', 0, NULL, NULL),
(2, 45, 'Chunlin', NULL, 'Feng', 'Chunlin Feng', 0, NULL, NULL),
(2, 51, 'Neena', NULL, 'Goveas', 'Neena Goveas', 0, NULL, NULL),
(2, 52, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 55, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 58, 'Vinayak', NULL, 'Naik', 'Vinayak Naik', 0, NULL, NULL),
(2, 59, 'V. M. V.', NULL, 'Gunturi', 'V. M. V. Gunturi', 0, NULL, NULL),
(2, 60, 'Nishant', NULL, 'Gautam', 'Nishant Gautam', 0, NULL, NULL),
(2, 61, 'Aditya', NULL, 'Kapoor', 'Aditya Kapoor', 0, NULL, NULL),
(2, 63, 'Salma', NULL, 'Mandi', 'Salma Mandi', 0, NULL, NULL),
(2, 64, 'Tanaya', NULL, 'Guha', 'Tanaya Guha', 0, NULL, NULL),
(2, 65, 'Jaskaran', NULL, 'Bhatia', 'Jaskaran Bhatia', 0, NULL, NULL),
(2, 66, 'Rochishnu', NULL, 'Banerjee', 'Rochishnu Banerjee', 0, NULL, NULL),
(2, 68, 'Dominique', NULL, 'Blouin', 'Dominique Blouin', 0, NULL, NULL),
(2, 69, 'Soumyadip', NULL, 'Bandyopadhyay', 'Soumyadip Bandyopadhyay', 0, NULL, NULL),
(2, 70, 'Dominique', NULL, 'Blouin', 'Dominique Blouin', 0, NULL, NULL),
(2, 71, 'Aboli', 'Vijayan', 'Pai', 'Aboli Vijayan Pai', 0, NULL, NULL),
(2, 72, 'Amol', NULL, 'Pai', 'Amol Pai', 0, NULL, NULL),
(2, 73, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(2, 74, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 75, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 76, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 89, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 90, 'Ashu', NULL, 'Sharma', 'Ashu Sharma', 0, NULL, NULL),
(2, 95, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 96, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 97, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 98, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 99, 'Sanjay', 'K', 'Sahay', 'Sanjay K Sahay', 0, NULL, NULL),
(2, 100, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 101, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 102, 'Ratti', 'Sai', 'Pavan', 'Ratti Sai Pavan', 0, NULL, NULL),
(2, 103, 'Sanjay', 'K', 'Sahay', 'Sanjay K Sahay', 0, NULL, NULL),
(2, 104, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 105, 'Sanjay', 'K', 'Sahay', 'Sanjay K Sahay', 0, NULL, NULL),
(2, 106, 'Sanjay', 'K', 'Sahay', 'Sanjay K Sahay', 0, NULL, NULL),
(2, 107, 'Sanjay', 'K', 'Sahay', 'Sanjay K Sahay', 0, NULL, NULL),
(2, 108, 'Sanjay', 'K', 'Sahay', 'Sanjay K Sahay', 0, NULL, NULL),
(2, 109, 'Sanjay', 'K', 'Sahay', 'Sanjay K Sahay', 0, NULL, NULL),
(2, 110, 'Piyush', NULL, 'Nikam', 'Piyush Nikam', 0, NULL, NULL),
(2, 111, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 113, 'Dilpreet', NULL, 'Kaur', 'Dilpreet Kaur', 0, NULL, NULL),
(2, 114, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 116, 'Rahul', NULL, 'Thakur', 'Rahul Thakur', 0, NULL, NULL),
(2, 117, 'Timothy', 'J.', 'Pierson', 'Timothy J. Pierson', 0, NULL, NULL),
(2, 118, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 124, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 125, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 126, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 127, 'Adithya', NULL, 'Samavedhi', 'Adithya Samavedhi', 0, NULL, NULL),
(2, 128, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 129, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 130, 'Swaroop', 'Ravindra', 'Joshi', 'Swaroop Ravindra Joshi', 0, NULL, NULL),
(2, 131, 'Sharad', NULL, 'Chitlangia', 'Sharad Chitlangia', 0, NULL, NULL),
(2, 132, 'Ashwin', NULL, 'Vaswani', 'Ashwin Vaswani', 0, NULL, NULL),
(2, 133, 'S.', NULL, 'Chitlangia', 'S. Chitlangia', 0, NULL, NULL),
(2, 134, 'A.', NULL, 'Srinivasan', 'A. Srinivasan', 0, NULL, NULL),
(2, 135, 'A.', NULL, 'Srinivasan', 'A. Srinivasan', 0, NULL, NULL),
(2, 136, 'A.', NULL, 'Sharma', 'A. Sharma', 0, NULL, NULL),
(2, 137, 'S.', NULL, 'Chitlangia', 'S. Chitlangia', 0, NULL, NULL),
(2, 138, 'A.', NULL, 'Srinivasan', 'A. Srinivasan', 0, NULL, NULL),
(2, 139, 'H.', NULL, 'Pandey', 'H. Pandey', 0, NULL, NULL),
(2, 140, 'Shikhar', NULL, 'Jain', 'Shikhar Jain', 0, NULL, NULL),
(2, 141, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 142, 'David', NULL, 'Kotz', 'David Kotz', 0, NULL, NULL),
(2, 143, 'Vigneshwaran', NULL, 'Subbaraju', 'Vigneshwaran Subbaraju', 0, NULL, NULL),
(2, 144, 'Qiuyang', NULL, 'Xu', 'Qiuyang Xu', 0, NULL, NULL),
(2, 145, 'David', NULL, 'Kotz', 'David Kotz', 0, NULL, NULL),
(2, 146, 'Yiyang', NULL, 'Lu', 'Yiyang Lu', 0, NULL, NULL),
(2, 147, 'Yuqi', NULL, 'Zhao', 'Yuqi Zhao', 0, NULL, NULL),
(2, 148, 'Varun', NULL, 'Mishra', 'Varun Mishra', 0, NULL, NULL),
(2, 149, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(2, 150, 'Sunghoon', 'Ivan', 'Lee', 'Sunghoon Ivan Lee', 0, NULL, NULL),
(2, 151, 'Basabdatta', 'Sen', 'Bhattacharya', 'Basabdatta Sen Bhattacharya', 0, NULL, NULL),
(2, 153, 'Advait', NULL, 'Rane', 'Advait Rane', 0, NULL, NULL),
(2, 154, 'Teresa', NULL, 'Serrano-Gotarredona', 'Teresa Serrano-Gotarredona', 0, NULL, NULL),
(2, 155, 'Nishant', NULL, 'Gautam', 'Nishant Gautam', 0, NULL, NULL),
(2, 156, 'Pablo', NULL, 'Linares-Serrano', 'Pablo Linares-Serrano', 0, NULL, NULL),
(2, 157, 'Basabdatta', 'Sen', 'Bhattacharya', 'Basabdatta Sen Bhattacharya', 0, NULL, NULL),
(2, 158, 'Lalan', NULL, 'A', 'Lalan A', 0, NULL, NULL),
(2, 159, 'Galia', NULL, 'Marinova', 'Galia Marinova', 0, NULL, NULL),
(2, 160, 'Swapna', NULL, 'Sasi', 'Swapna Sasi', 0, NULL, NULL),
(2, 161, 'Arshika', NULL, 'Lalan', 'Arshika Lalan', 0, NULL, NULL),
(2, 162, 'Kartik', NULL, 'Muralidharan', 'Kartik Muralidharan', 0, NULL, NULL),
(2, 163, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(2, 164, 'Dipanjan', NULL, 'Chakraborty', 'Dipanjan Chakraborty', 0, NULL, NULL),
(2, 165, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(2, 166, 'Malikarjuna', 'V', 'Adi', 'Malikarjuna V Adi', 0, NULL, NULL),
(2, 167, 'Mallikarjuna', 'Reddy', 'Adi V', 'Mallikarjuna Reddy Adi V', 0, NULL, NULL),
(2, 168, 'Karan', NULL, 'Grover', 'Karan Grover', 0, NULL, NULL),
(2, 169, 'Lipyeow', NULL, 'Lim', 'Lipyeow Lim', 0, NULL, NULL),
(2, 170, 'Vigneshwaran', NULL, 'Subbaraju', 'Vigneshwaran Subbaraju', 0, NULL, NULL),
(2, 172, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(2, 173, 'Kiran', 'K.', 'Rachuri', 'Kiran K. Rachuri', 0, NULL, NULL),
(2, 174, 'V.', NULL, 'Subbaraju', 'V. Subbaraju', 0, NULL, NULL),
(2, 175, 'S.', NULL, 'Eswaran', 'S. Eswaran', 0, NULL, NULL),
(2, 176, 'Sarah', NULL, 'Clinch', 'Sarah Clinch', 0, NULL, NULL),
(2, 177, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(2, 178, 'Vigneshwaran', NULL, 'Subbaraju', 'Vigneshwaran Subbaraju', 0, NULL, NULL),
(2, 180, 'Gunnar', NULL, 'Pope', 'Gunnar Pope', 0, NULL, NULL),
(2, 181, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(2, 182, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(2, 183, 'Gunnar', NULL, 'Pope', 'Gunnar Pope', 0, NULL, NULL),
(2, 184, 'Kelly', NULL, 'Caine', 'Kelly Caine', 0, NULL, NULL),
(2, 185, 'Vigneshwaran', NULL, 'Subbaraju', 'Vigneshwaran Subbaraju', 0, NULL, NULL),
(2, 186, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 187, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(2, 188, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 189, 'A.', NULL, 'Maiya', 'A. Maiya', 0, NULL, NULL),
(2, 190, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 191, 'Nagaraj', NULL, 'Nithin', 'Nagaraj Nithin', 0, NULL, NULL),
(2, 192, 'Archana', NULL, 'Mathur', 'Archana Mathur', 0, NULL, NULL),
(2, 193, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 194, 'Archana', NULL, 'Mathur', 'Archana Mathur', 0, NULL, NULL),
(2, 195, 'Deepika', NULL, 'Karanji', 'Deepika Karanji', 0, NULL, NULL),
(2, 196, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 197, 'Santonu', NULL, 'Sarkar', 'Santonu Sarkar', 0, NULL, NULL),
(2, 198, 'Soundarya', NULL, 'Krishnan', 'Soundarya Krishnan', 0, NULL, NULL),
(2, 199, 'Rishabh', NULL, 'Khincha', 'Rishabh Khincha', 0, NULL, NULL),
(2, 200, 'Tanmay', 'Tulsidas', 'Verlekar', 'Tanmay Tulsidas Verlekar', 0, NULL, NULL),
(2, 201, 'João', 'Pedro', 'Machado', 'João Pedro Machado', 0, NULL, NULL),
(2, 202, 'Anmol', NULL, 'Agarwal', 'Anmol Agarwal', 0, NULL, NULL),
(2, 203, 'Geetika', NULL, 'Barman', 'Geetika Barman', 0, NULL, NULL),
(2, 204, 'Aditya', NULL, 'Challa', 'Aditya Challa', 0, NULL, NULL),
(2, 205, 'Nihita', NULL, 'Goel', 'Nihita Goel', 0, NULL, NULL),
(2, 206, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 207, 'Taeeb', NULL, 'Bandwala', 'Taeeb Bandwala', 0, NULL, NULL),
(2, 208, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 209, 'Debasis', NULL, 'Das', 'Debasis Das', 0, NULL, NULL),
(2, 210, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 211, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 216, 'Soumyadip', NULL, 'Bandyopadhyay', 'Soumyadip Bandyopadhyay', 0, NULL, NULL),
(2, 217, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(2, 218, 'Aman', NULL, 'Aziz', 'Aman Aziz', 0, NULL, NULL),
(2, 219, 'A.', NULL, 'Mathur', 'A. Mathur', 0, NULL, NULL),
(2, 220, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(2, 221, 'Vaskar', NULL, 'Raychoudhury', 'Vaskar Raychoudhury', 0, NULL, NULL),
(2, 222, 'V.', NULL, 'Raychoudhury', 'V. Raychoudhury', 0, NULL, NULL),
(2, 223, 'Kartik', NULL, 'Bhatia', 'Kartik Bhatia', 0, NULL, NULL),
(2, 224, 'A.', NULL, 'Maiya', 'A. Maiya', 0, NULL, NULL),
(2, 225, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(2, 226, 'Gambhire', NULL, 'S', 'Gambhire S', 0, NULL, NULL),
(2, 227, 'Mathur', NULL, 'Archana', 'Mathur Archana', 0, NULL, NULL),
(2, 228, 'Haoxiang', NULL, 'Yu', 'Haoxiang Yu', 0, NULL, NULL),
(2, 229, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(2, 230, 'Vaibhav', NULL, 'Ganatra', 'Vaibhav Ganatra', 0, NULL, NULL),
(2, 231, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(2, 232, 'D’Souza,', NULL, 'R.', 'D’Souza, R.', 0, NULL, NULL),
(2, 233, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(2, 234, 'Rohan', NULL, 'Kumar', 'Rohan Kumar', 0, NULL, NULL),
(2, 235, 'Dhruv', NULL, 'Nagpal', 'Dhruv Nagpal', 0, NULL, NULL),
(2, 236, 'Sravan', NULL, 'Danda', 'Sravan Danda', 0, NULL, NULL),
(2, 237, 'Sravan', NULL, 'Danda', 'Sravan Danda', 0, NULL, NULL),
(2, 238, 'Soroush', NULL, 'Shahi', 'Soroush Shahi', 0, NULL, NULL),
(2, 239, 'Rawan', NULL, 'Alharbi', 'Rawan Alharbi', 0, NULL, NULL),
(2, 240, 'Snigdha', NULL, 'Tiwari', 'Snigdha Tiwari', 0, NULL, NULL),
(2, 241, 'Adrian', NULL, 'Cornely', 'Adrian Cornely', 0, NULL, NULL),
(2, 242, 'Ajay', NULL, 'N', 'Ajay N', 0, NULL, NULL),
(2, 243, 'Surjya', NULL, 'Ghosh', 'Surjya Ghosh', 0, NULL, NULL),
(2, 244, 'Bivas', NULL, 'Mitra', 'Bivas Mitra', 0, NULL, NULL),
(2, 245, 'Gerard', 'Pons', 'Rodriguez', 'Gerard Pons Rodriguez', 0, NULL, NULL),
(2, 246, 'Surjya', NULL, 'Ghosh', 'Surjya Ghosh', 0, NULL, NULL),
(2, 247, 'Raja', NULL, 'Narasimhan', 'Raja Narasimhan', 0, NULL, NULL),
(2, 248, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 249, 'Adithya', NULL, 'Samavedhi', 'Adithya Samavedhi', 0, NULL, NULL),
(2, 250, 'Sujay', 'C', 'Sharma', 'Sujay C Sharma', 0, NULL, NULL),
(2, 251, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 252, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 253, 'Adithya', NULL, 'Samavedhi', 'Adithya Samavedhi', 0, NULL, NULL),
(2, 254, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 255, 'Animesh', NULL, 'Sasan', 'Animesh Sasan', 0, NULL, NULL),
(2, 256, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(2, 257, 'Shruti', NULL, 'Dongare', 'Shruti Dongare', 0, NULL, NULL),
(2, 258, 'Ahmad Maroof', NULL, 'Karimi', 'Ahmad Maroof Karimi', 0, NULL, NULL),
(2, 259, 'Jong Youl', NULL, 'Choi', 'Jong Youl Choi', 0, NULL, NULL),
(2, 260, 'Arnab Kumar', NULL, 'Paul', 'Arnab Kumar Paul', 0, NULL, NULL),
(2, 261, 'NEENA', NULL, 'GOVEAS', 'NEENA GOVEAS', 0, NULL, NULL),
(2, 262, 'Neena', NULL, 'Goveas', 'Neena Goveas', 0, NULL, NULL),
(2, 263, 'Jaskaran Singh', NULL, 'Bhatia', 'Jaskaran Singh Bhatia', 0, NULL, NULL),
(2, 264, 'Sujay C', NULL, 'Sharma', 'Sujay C Sharma', 0, NULL, NULL),
(2, 265, 'Basabdatta', 'Sen', 'Bhattacharya', 'Basabdatta Sen Bhattacharya', 0, NULL, NULL),
(2, 266, 'Basabdatta', 'Sen', 'Bhattacharya', 'Basabdatta Sen Bhattacharya', 0, NULL, NULL),
(2, 267, 'Taher', 'Yunus', 'Lilywala', 'Taher Yunus Lilywala', 0, NULL, NULL),
(2, 268, 'Basabdatta', 'Sen', 'Bhattacharya', 'Basabdatta Sen Bhattacharya', 0, NULL, NULL),
(2, 269, 'Harikrishnan', NULL, 'NB', 'Harikrishnan NB', 0, NULL, NULL),
(2, 270, 'Neena', NULL, 'Goveas', 'Neena Goveas', 0, NULL, NULL),
(2, 271, 'Neena', NULL, 'Goveas', 'Neena Goveas', 0, NULL, NULL),
(2, 272, 'Aditi', NULL, 'Kathpalia', 'Aditi Kathpalia', 0, NULL, NULL),
(2, 273, 'Nithin', NULL, 'Nagaraj', 'Nithin Nagaraj', 0, NULL, NULL),
(2, 274, 'Diptendu', NULL, 'Chatterjee', 'Diptendu Chatterjee', 0, NULL, NULL),
(2, 275, 'Louella', 'Mesquita', 'Colaco', 'Louella Mesquita Colaco', 0, NULL, NULL),
(2, 276, 'Amol', NULL, 'Pai', 'Amol Pai', 0, NULL, NULL),
(2, 277, 'Rajaswa', NULL, 'Patil', 'Rajaswa Patil', 0, NULL, NULL),
(2, 278, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(2, 279, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(2, 280, 'Siddhant', NULL, 'Dang', 'Siddhant Dang', 0, NULL, NULL),
(2, 281, 'Sayantani', NULL, 'Sarkar', 'Sayantani Sarkar', 0, NULL, NULL),
(2, 282, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(2, 283, 'Ashrut', NULL, 'Kumar', 'Ashrut Kumar', 0, NULL, NULL),
(2, 284, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(3, 1, 'Neena', NULL, 'Goveas', 'Neena Goveas', 0, NULL, NULL),
(3, 2, 'Pabitra', 'Mohan', 'Khilar', 'Pabitra Mohan Khilar', 0, NULL, NULL),
(3, 4, 'Lovekesh', NULL, 'Vig', 'Lovekesh Vig', 0, NULL, NULL),
(3, 5, 'Narayanan', NULL, 'Srinivasan', 'Narayanan Srinivasan', 0, NULL, NULL),
(3, 7, 'Lovekesh', NULL, 'Vig', 'Lovekesh Vig', 0, NULL, NULL),
(3, 8, 'Ramya', NULL, 'Hebbalaguppe', 'Ramya Hebbalaguppe', 0, NULL, NULL),
(3, 9, 'Lovekesh', NULL, 'Vig', 'Lovekesh Vig', 0, NULL, NULL),
(3, 11, 'S', NULL, 'Jaiswal', 'S Jaiswal', 0, NULL, NULL),
(3, 13, 'H', NULL, 'Sagar', 'H Sagar', 0, NULL, NULL),
(3, 14, 'Mukulika', NULL, 'Maity', 'Mukulika Maity', 0, NULL, NULL),
(3, 17, 'Raj', 'K', 'Jaiswal', 'Raj K Jaiswal', 0, NULL, NULL),
(3, 19, 'Atul', NULL, 'Rai', 'Atul Rai', 0, NULL, NULL),
(3, 20, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(3, 21, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(3, 22, 'Utkarsh', NULL, 'Yadav', 'Utkarsh Yadav', 0, NULL, NULL),
(3, 23, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(3, 24, 'Gautam', NULL, 'Shroff', 'Gautam Shroff', 0, NULL, NULL),
(3, 25, 'Lovekesh', NULL, 'Vig', 'Lovekesh Vig', 0, NULL, NULL),
(3, 26, 'Mrinal', NULL, 'Rawat', 'Mrinal Rawat', 0, NULL, NULL),
(3, 27, 'Archana', NULL, 'Mathur', 'Archana Mathur', 0, NULL, NULL),
(3, 28, 'Tejas', NULL, 'Prashanth', 'Tejas Prashanth', 0, NULL, NULL),
(3, 29, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(3, 30, 'Archana', NULL, 'Mathur', 'Archana Mathur', 0, NULL, NULL),
(3, 31, 'Suraj', NULL, 'Aralihalli', 'Suraj Aralihalli', 0, NULL, NULL),
(3, 32, 'Azhar', NULL, 'Shaikh', 'Azhar Shaikh', 0, NULL, NULL),
(3, 33, 'S.', NULL, 'Roy Dey', 'S. Roy Dey', 0, NULL, NULL),
(3, 34, 'Archana', NULL, 'Mathur', 'Archana Mathur', 0, NULL, NULL),
(3, 35, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(3, 45, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(3, 52, 'Shubhad', NULL, 'Mathur', 'Shubhad Mathur', 0, NULL, NULL),
(3, 55, 'Sriparna', NULL, 'Saha', 'Sriparna Saha', 0, NULL, NULL),
(3, 58, 'Varun', NULL, 'Yeligar', 'Varun Yeligar', 0, NULL, NULL),
(3, 59, 'Vinayak', NULL, 'Naik', 'Vinayak Naik', 0, NULL, NULL),
(3, 60, 'Ishita', NULL, 'Mediratta', 'Ishita Mediratta', 0, NULL, NULL),
(3, 61, 'Narayanan', NULL, 'Srinivasan', 'Narayanan Srinivasan', 0, NULL, NULL),
(3, 63, 'Bivas', NULL, 'Mitra', 'Bivas Mitra', 0, NULL, NULL),
(3, 65, 'Surjya', NULL, 'Ghosh', 'Surjya Ghosh', 0, NULL, NULL),
(3, 66, 'Dominique', NULL, 'Blouin', 'Dominique Blouin', 0, NULL, NULL),
(3, 68, 'Soumyadip', NULL, 'Bandyopadhyay', 'Soumyadip Bandyopadhyay', 0, NULL, NULL),
(3, 70, 'Soumyadip', NULL, 'Bandyopadhyay', 'Soumyadip Bandyopadhyay', 0, NULL, NULL),
(3, 71, 'Biju', 'K', 'Raveendran', 'Biju K Raveendran', 0, NULL, NULL),
(3, 72, 'Biju', 'K', 'Raveendran', 'Biju K Raveendran', 0, NULL, NULL),
(3, 73, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(3, 74, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 75, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 76, 'Piyush', NULL, 'Nikam', 'Piyush Nikam', 0, NULL, NULL),
(3, 89, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 90, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 95, 'Palash', NULL, 'Chaturvedi', 'Palash Chaturvedi', 0, NULL, NULL),
(3, 96, 'Ritvik', NULL, 'Rajvanshi', 'Ritvik Rajvanshi', 0, NULL, NULL),
(3, 97, 'Shivin', NULL, 'Thukral', 'Shivin Thukral', 0, NULL, NULL),
(3, 98, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 99, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 100, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 101, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 102, 'Azad', NULL, 'Nautiyal', 'Azad Nautiyal', 0, NULL, NULL),
(3, 103, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 104, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 105, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 106, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 107, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 108, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 109, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 110, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(3, 111, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(3, 113, 'Kajal', NULL, 'Parikh', 'Kajal Parikh', 0, NULL, NULL),
(3, 114, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(3, 116, 'Utkarsh', NULL, 'Yadav', 'Utkarsh Yadav', 0, NULL, NULL),
(3, 117, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(3, 118, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 124, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 125, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 126, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 127, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(3, 128, 'Jasleen', NULL, 'Dhillon', 'Jasleen Dhillon', 0, NULL, NULL),
(3, 130, 'Rakshit', NULL, 'Mittal', 'Rakshit Mittal', 0, NULL, NULL),
(3, 131, 'Tirtharaj', NULL, 'Dash', 'Tirtharaj Dash', 0, NULL, NULL),
(3, 132, 'Tirtharaj', NULL, 'Dash', 'Tirtharaj Dash', 0, NULL, NULL),
(3, 133, 'A.', NULL, 'Ahuja', 'A. Ahuja', 0, NULL, NULL),
(3, 134, 'L.', NULL, 'Vig', 'L. Vig', 0, NULL, NULL),
(3, 135, 'A.', NULL, 'Baskar', 'A. Baskar', 0, NULL, NULL),
(3, 136, 'H.', NULL, 'Pandey', 'H. Pandey', 0, NULL, NULL),
(3, 137, 'A.', NULL, 'Ahuja', 'A. Ahuja', 0, NULL, NULL),
(3, 138, 'L.', NULL, 'Vig', 'L. Vig', 0, NULL, NULL),
(3, 139, 'G.', NULL, 'Chhablani', 'G. Chhablani', 0, NULL, NULL),
(3, 140, 'Siddhant', NULL, 'Jain', 'Siddhant Jain', 0, NULL, NULL),
(3, 141, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 143, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(3, 144, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(3, 146, 'Nicole', NULL, 'Tobias', 'Nicole Tobias', 0, NULL, NULL),
(3, 147, 'Dzung', 'Tri', 'Nguyen', 'Dzung Tri Nguyen', 0, NULL, NULL),
(3, 148, 'David', NULL, 'Kotz', 'David Kotz', 0, NULL, NULL),
(3, 149, 'Grace', NULL, 'Chen', 'Grace Chen', 0, NULL, NULL),
(3, 150, 'Robert', NULL, 'Jackson', 'Robert Jackson', 0, NULL, NULL),
(3, 153, 'Swapna', NULL, 'Sasi', 'Swapna Sasi', 0, NULL, NULL),
(3, 155, 'Ishita', NULL, 'Mediratta', 'Ishita Mediratta', 0, NULL, NULL),
(3, 156, 'Sen Basabdatta', NULL, 'Bhattacharya', 'Sen Basabdatta Bhattacharya', 0, NULL, NULL),
(3, 158, 'Sen', 'Bhattacharya', 'B', 'Sen Bhattacharya B', 0, NULL, NULL),
(3, 159, 'Ella', NULL, 'Ciuperca', 'Ella Ciuperca', 0, NULL, NULL),
(3, 160, 'Jun', NULL, 'Chen', 'Jun Chen', 0, NULL, NULL),
(3, 161, 'Basabdatta', 'Sen', 'Bhattacharya', 'Basabdatta Sen Bhattacharya', 0, NULL, NULL),
(3, 163, 'Lipyeow', NULL, 'Lim', 'Lipyeow Lim', 0, NULL, NULL),
(3, 164, 'Vigneshwaran', NULL, 'Subbaraju', 'Vigneshwaran Subbaraju', 0, NULL, NULL),
(3, 165, 'Rajesh', NULL, 'Balan', 'Rajesh Balan', 0, NULL, NULL),
(3, 166, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(3, 167, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(3, 168, 'Vigneshwaran', NULL, 'Subbaraju', 'Vigneshwaran Subbaraju', 0, NULL, NULL),
(3, 169, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(3, 170, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(3, 172, 'Vigneshwaran', NULL, 'Subbaraju', 'Vigneshwaran Subbaraju', 0, NULL, NULL),
(3, 173, 'Abhishek', NULL, 'Mukherji', 'Abhishek Mukherji', 0, NULL, NULL),
(3, 174, 'A.', NULL, 'Misra', 'A. Misra', 0, NULL, NULL),
(3, 175, 'S.', NULL, 'Sen', 'S. Sen', 0, NULL, NULL),
(3, 176, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(3, 177, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(3, 178, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(3, 180, 'Sarah', NULL, 'Lord', 'Sarah Lord', 0, NULL, NULL),
(3, 181, 'Vigneshwaran', NULL, 'Subbaraju', 'Vigneshwaran Subbaraju', 0, NULL, NULL),
(3, 182, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(3, 183, 'Sarah', NULL, 'Lord', 'Sarah Lord', 0, NULL, NULL),
(3, 184, 'Ryan', NULL, 'Halter', 'Ryan Halter', 0, NULL, NULL),
(3, 185, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(3, 186, 'Carlos', 'A.', 'Coello Coello', 'Carlos A. Coello Coello', 0, NULL, NULL),
(3, 187, 'Saibal', NULL, 'Kar', 'Saibal Kar', 0, NULL, NULL),
(3, 189, 'Soma.', 'S.', 'Dhavala', 'Soma. S. Dhavala', 0, NULL, NULL),
(3, 190, 'Sumedh', NULL, 'Basarkod', 'Sumedh Basarkod', 0, NULL, NULL),
(3, 192, 'Dayasagar', NULL, 'BS', 'Dayasagar BS', 0, NULL, NULL),
(3, 193, 'Shubhad', NULL, 'Mathur', 'Shubhad Mathur', 0, NULL, NULL),
(3, 194, 'Aditya', NULL, 'Pandey', 'Aditya Pandey', 0, NULL, NULL),
(3, 195, 'Swati', 'Sampatrao', 'Gambhire', 'Swati Sampatrao Gambhire', 0, NULL, NULL),
(3, 196, 'Pavan', NULL, 'Chakraborty', 'Pavan Chakraborty', 0, NULL, NULL),
(3, 197, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(3, 198, 'Rizwan', NULL, 'Parveen', 'Rizwan Parveen', 0, NULL, NULL),
(3, 199, 'Neena', NULL, 'Goveas', 'Neena Goveas', 0, NULL, NULL),
(3, 200, 'Paulo', 'Lobato', 'Correia', 'Paulo Lobato Correia', 0, NULL, NULL),
(3, 201, 'Tanmay', 'Tulsidas', 'Verlekar', 'Tanmay Tulsidas Verlekar', 0, NULL, NULL),
(3, 202, 'Tanmay', 'Tulsidas', 'Verlekar', 'Tanmay Tulsidas Verlekar', 0, NULL, NULL),
(3, 203, 'Sravan', NULL, 'Danda', 'Sravan Danda', 0, NULL, NULL),
(3, 204, 'BS', NULL, 'Sagar', 'BS Sagar', 0, NULL, NULL),
(3, 205, 'Murtuza', NULL, 'Jadliwala', 'Murtuza Jadliwala', 0, NULL, NULL),
(3, 206, 'Bharath', NULL, 'Sridhar', 'Bharath Sridhar', 0, NULL, NULL),
(3, 207, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(3, 208, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 209, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(3, 216, 'Surjya', NULL, 'Ghosh', 'Surjya Ghosh', 0, NULL, NULL),
(3, 217, 'Ada', NULL, 'Ng', 'Ada Ng', 0, NULL, NULL),
(3, 218, 'Aditya', 'Suraj', 'Krishnan', 'Aditya Suraj Krishnan', 0, NULL, NULL),
(3, 219, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(3, 220, 'S.', NULL, 'Sarkar', 'S. Sarkar', 0, NULL, NULL),
(3, 221, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(3, 222, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(3, 223, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(3, 224, 'Soma.', 'S.', 'Dhavala', 'Soma. S. Dhavala', 0, NULL, NULL),
(3, 225, 'Sumedh', NULL, 'Basarkod', 'Sumedh Basarkod', 0, NULL, NULL),
(3, 226, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(3, 227, 'DAYASAGAR', NULL, 'B.S', 'DAYASAGAR B.S', 0, NULL, NULL),
(3, 228, 'Vaskar', NULL, 'Raychoudhury', 'Vaskar Raychoudhury', 0, NULL, NULL),
(3, 229, 'Pavan', NULL, 'Chakraborty', 'Pavan Chakraborty', 0, NULL, NULL),
(3, 230, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(3, 231, 'N.', NULL, 'Nagaraj', 'N. Nagaraj', 0, NULL, NULL),
(3, 232, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(3, 233, 'M.', NULL, 'Safonova', 'M. Safonova', 0, NULL, NULL),
(3, 234, 'Nrupesh', NULL, 'Surya', 'Nrupesh Surya', 0, NULL, NULL),
(3, 235, 'Vinayak', NULL, 'Naik', 'Vinayak Naik', 0, NULL, NULL),
(3, 236, 'Aditya', NULL, 'Challa', 'Aditya Challa', 0, NULL, NULL),
(3, 237, 'Daya Sagar', NULL, 'BS', 'Daya Sagar BS', 0, NULL, NULL),
(3, 238, 'Rawan', NULL, 'Alharbi', 'Rawan Alharbi', 0, NULL, NULL),
(3, 239, 'Yang', NULL, 'Gao', 'Yang Gao', 0, NULL, NULL),
(3, 240, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(3, 241, 'Faiza', NULL, 'Kalam', 'Faiza Kalam', 0, NULL, NULL),
(3, 242, 'Sayan', NULL, 'Sircar', 'Sayan Sircar', 0, NULL, NULL),
(3, 243, 'Pradipta', NULL, 'De', 'Pradipta De', 0, NULL, NULL),
(3, 244, 'Pradipta', NULL, 'De', 'Pradipta De', 0, NULL, NULL),
(3, 245, 'Shruti', NULL, 'Rao', 'Shruti Rao', 0, NULL, NULL),
(3, 246, 'Gerard', 'Pons', 'Rodriguez', 'Gerard Pons Rodriguez', 0, NULL, NULL),
(3, 247, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(3, 248, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 249, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(3, 250, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(3, 251, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 252, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 253, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(3, 254, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(3, 255, 'Sanjay', 'Kumar', 'Sahay', 'Sanjay Kumar Sahay', 0, NULL, NULL),
(3, 256, 'Debasis', NULL, 'Das', 'Debasis Das', 0, NULL, NULL),
(3, 257, 'Yanlin', NULL, 'Du', 'Yanlin Du', 0, NULL, NULL),
(3, 258, 'Arnab Kumar', NULL, 'Paul', 'Arnab Kumar Paul', 0, NULL, NULL),
(3, 259, 'Ahmad Maroof', NULL, 'Karimi', 'Ahmad Maroof Karimi', 0, NULL, NULL),
(3, 260, 'Feiyi', NULL, 'Wang', 'Feiyi Wang', 0, NULL, NULL),
(3, 263, 'Dev', NULL, 'Goel', 'Dev Goel', 0, NULL, NULL),
(3, 264, 'Sanjay', 'K.', 'Sahay', 'Sanjay K. Sahay', 0, NULL, NULL),
(3, 265, 'Hye-Kung', NULL, 'Cho', 'Hye-Kung Cho', 0, NULL, NULL),
(3, 267, 'Basabdatta', 'Sen', 'Bhattacharya', 'Basabdatta Sen Bhattacharya', 0, NULL, NULL),
(3, 268, 'Andrew', NULL, 'Gait', 'Andrew Gait', 0, NULL, NULL),
(3, 269, 'Nithin', NULL, 'Nagaraj', 'Nithin Nagaraj', 0, NULL, NULL),
(3, 271, 'Lucy', 'J', 'Gudino', 'Lucy J Gudino', 0, NULL, NULL),
(3, 272, 'Nithin', NULL, 'Nagaraj', 'Nithin Nagaraj', 0, NULL, NULL),
(3, 273, 'Harikrishnan', NULL, 'NB', 'Harikrishnan NB', 0, NULL, NULL),
(3, 274, 'Nithin', NULL, 'Nagaraj', 'Nithin Nagaraj', 0, NULL, NULL),
(3, 275, 'Biju', NULL, 'Raveendran', 'Biju Raveendran', 0, NULL, NULL),
(3, 276, 'Biju', 'K', 'Raveendran', 'Biju K Raveendran', 0, NULL, NULL),
(3, 277, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(3, 280, 'Mounil', 'B', 'Memaya', 'Mounil B Memaya', 0, NULL, NULL),
(3, 283, 'Rijul', NULL, 'Ganguly', 'Rijul Ganguly', 0, NULL, NULL),
(3, 284, 'Sharanya', NULL, 'Ranka', 'Sharanya Ranka', 0, NULL, NULL),
(4, 4, 'Rishab', NULL, 'Khincha', 'Rishab Khincha', 0, NULL, NULL),
(4, 7, 'Tirtharaj', NULL, 'Dash', 'Tirtharaj Dash', 0, NULL, NULL),
(4, 8, 'Srinidhi', NULL, 'Hegde', 'Srinidhi Hegde', 0, NULL, NULL),
(4, 9, 'Tirtharaj', NULL, 'Dash', 'Tirtharaj Dash', 0, NULL, NULL),
(4, 11, 'Vinayak', NULL, 'Naik', 'Vinayak Naik', 0, NULL, NULL),
(4, 13, 'C', NULL, 'Kumar', 'C Kumar', 0, NULL, NULL),
(4, 14, 'Vinayak', NULL, 'Naik', 'Vinayak Naik', 0, NULL, NULL),
(4, 19, 'Mounil', 'Binal', 'Memaya', 'Mounil Binal Memaya', 0, NULL, NULL),
(4, 20, 'Rahul', NULL, 'Thakur', 'Rahul Thakur', 0, NULL, NULL),
(4, 22, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(4, 26, 'Lovekesh', NULL, 'Vig', 'Lovekesh Vig', 0, NULL, NULL),
(4, 27, 'Rahul', NULL, 'Yedida', 'Rahul Yedida', 0, NULL, NULL),
(4, 29, 'Nithin', NULL, 'Nagaraj', 'Nithin Nagaraj', 0, NULL, NULL),
(4, 30, 'Kakoli', NULL, 'Bora', 'Kakoli Bora', 0, NULL, NULL),
(4, 31, 'Sumedh', NULL, 'Basarkod', 'Sumedh Basarkod', 0, NULL, NULL),
(4, 32, 'Rahul', NULL, 'Yedida', 'Rahul Yedida', 0, NULL, NULL),
(4, 33, 'V.', NULL, 'Raychoudhury', 'V. Raychoudhury', 0, NULL, NULL),
(4, 34, 'Rahul', NULL, 'Yedida', 'Rahul Yedida', 0, NULL, NULL),
(4, 45, 'Jayalakshmi', NULL, 'Jain', 'Jayalakshmi Jain', 0, NULL, NULL),
(4, 59, 'Kousik', NULL, 'Dutta', 'Kousik Dutta', 0, NULL, NULL),
(4, 60, 'Andrew', NULL, 'Gait', 'Andrew Gait', 0, NULL, NULL),
(4, 63, 'Pradipta', NULL, 'De', 'Pradipta De', 0, NULL, NULL),
(4, 65, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(4, 66, 'Soumyadip', NULL, 'Bandyopadhyay', 'Soumyadip Bandyopadhyay', 0, NULL, NULL),
(4, 71, 'Geeta', NULL, 'Patil', 'Geeta Patil', 0, NULL, NULL),
(4, 72, 'Sasikumar', NULL, 'Punnekkat', 'Sasikumar Punnekkat', 0, NULL, NULL),
(4, 73, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 76, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 95, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 96, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 97, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 102, 'Ameya', NULL, 'Phadnis', 'Ameya Phadnis', 0, NULL, NULL),
(4, 110, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 113, 'Prakhar', NULL, 'Yadav', 'Prakhar Yadav', 0, NULL, NULL),
(4, 116, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(4, 117, 'Jos\\\'{e}', NULL, 'Camacho', 'Jos\\\'{e} Camacho', 0, NULL, NULL),
(4, 127, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 128, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 130, 'Soumyadip', NULL, 'Bandyopadhyay', 'Soumyadip Bandyopadhyay', 0, NULL, NULL),
(4, 131, 'Lovekesh', NULL, 'Vig', 'Lovekesh Vig', 0, NULL, NULL),
(4, 132, 'Ramya', NULL, 'Hebblaguppe', 'Ramya Hebblaguppe', 0, NULL, NULL),
(4, 133, 'A.', NULL, 'Srinivasan', 'A. Srinivasan', 0, NULL, NULL),
(4, 134, 'A.', NULL, 'Roy', 'A. Roy', 0, NULL, NULL),
(4, 136, 'T.', NULL, 'Dash', 'T. Dash', 0, NULL, NULL),
(4, 137, 'A.', NULL, 'Srinivasan', 'A. Srinivasan', 0, NULL, NULL),
(4, 139, 'Y.', NULL, 'Bhartia', 'Y. Bhartia', 0, NULL, NULL),
(4, 140, 'T.', NULL, 'Dash', 'T. Dash', 0, NULL, NULL),
(4, 143, 'Rajesh', NULL, 'Balan', 'Rajesh Balan', 0, NULL, NULL),
(4, 144, 'Nabil', NULL, 'Alshurafa', 'Nabil Alshurafa', 0, NULL, NULL),
(4, 146, 'Ella', NULL, 'Ryan', 'Ella Ryan', 0, NULL, NULL),
(4, 147, 'Runsheng', NULL, 'Xu', 'Runsheng Xu', 0, NULL, NULL),
(4, 149, 'Tian', NULL, 'Hao', 'Tian Hao', 0, NULL, NULL),
(4, 150, 'Rui', NULL, 'Wang', 'Rui Wang', 0, NULL, NULL),
(4, 153, 'Sen Basabdatta', NULL, 'Bhattacharya', 'Sen Basabdatta Bhattacharya', 0, NULL, NULL),
(4, 155, 'Andrew', NULL, 'Gait', 'Andrew Gait', 0, NULL, NULL),
(4, 156, 'Teresa', NULL, 'Serrano-Gotarredona', 'Teresa Serrano-Gotarredona', 0, NULL, NULL),
(4, 158, 'Bose', NULL, 'J', 'Bose J', 0, NULL, NULL),
(4, 159, 'Basabdatta', 'Sen', 'Bhattacharya', 'Basabdatta Sen Bhattacharya', 0, NULL, NULL),
(4, 160, 'Elham', NULL, 'Zareian', 'Elham Zareian', 0, NULL, NULL),
(4, 161, 'Joy', NULL, 'Bose', 'Joy Bose', 0, NULL, NULL),
(4, 163, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(4, 164, 'Dipyaman', NULL, 'Banerjee', 'Dipyaman Banerjee', 0, NULL, NULL),
(4, 165, 'Lipyeow', NULL, 'Lim', 'Lipyeow Lim', 0, NULL, NULL),
(4, 166, 'Siva', 'Prasad', 'Katru', 'Siva Prasad Katru', 0, NULL, NULL),
(4, 167, 'Puneet', NULL, 'Gupta', 'Puneet Gupta', 0, NULL, NULL);
INSERT INTO `pubdtls` (`slno`, `pubhdrid`, `athrfirstname`, `athrmiddlename`, `athrlastname`, `fullname`, `inhouseflag`, `created_at`, `updated_at`) VALUES
(4, 168, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(4, 169, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(4, 170, 'Rajesh', 'Krishna', 'Balan', 'Rajesh Krishna Balan', 0, NULL, NULL),
(4, 172, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(4, 173, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(4, 174, 'Y.', NULL, 'Lee', 'Y. Lee', 0, NULL, NULL),
(4, 175, 'V.', NULL, 'Subbaraju', 'V. Subbaraju', 0, NULL, NULL),
(4, 177, 'Satyadip', NULL, 'Chakraborti', 'Satyadip Chakraborti', 0, NULL, NULL),
(4, 178, 'Rajesh', 'Krishna', 'Balan', 'Rajesh Krishna Balan', 0, NULL, NULL),
(4, 180, 'Stephanie', NULL, 'Lewia', 'Stephanie Lewia', 0, NULL, NULL),
(4, 181, 'Karan', NULL, 'Grover', 'Karan Grover', 0, NULL, NULL),
(4, 182, 'Youngki', NULL, 'Lee', 'Youngki Lee', 0, NULL, NULL),
(4, 183, 'Stephanie', NULL, 'Lewia', 'Stephanie Lewia', 0, NULL, NULL),
(4, 184, 'Jacob', NULL, 'Sorber', 'Jacob Sorber', 0, NULL, NULL),
(4, 185, 'Rajesh', NULL, 'Balan', 'Rajesh Balan', 0, NULL, NULL),
(4, 186, 'Anwesh', NULL, 'Bhattacharya', 'Anwesh Bhattacharya', 0, NULL, NULL),
(4, 187, 'Archana', NULL, 'Mathur', 'Archana Mathur', 0, NULL, NULL),
(4, 189, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(4, 190, 'Suraj', NULL, 'Aralihalli', 'Suraj Aralihalli', 0, NULL, NULL),
(4, 192, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(4, 194, 'Harshith Arun', NULL, 'Kumar', 'Harshith Arun Kumar', 0, NULL, NULL),
(4, 195, 'Sravan', NULL, 'Danda', 'Sravan Danda', 0, NULL, NULL),
(4, 196, 'Krishna Pratap', NULL, 'Singh', 'Krishna Pratap Singh', 0, NULL, NULL),
(4, 197, 'Swagatam', NULL, 'Das', 'Swagatam Das', 0, NULL, NULL),
(4, 198, 'Neena', NULL, 'Goveas', 'Neena Goveas', 0, NULL, NULL),
(4, 200, 'Luís', 'Ducla', 'Soares', 'Luís Ducla Soares', 0, NULL, NULL),
(4, 201, 'Paulo', 'Lobato', 'Correia', 'Paulo Lobato Correia', 0, NULL, NULL),
(4, 202, 'Raghavendra', NULL, 'Singh', 'Raghavendra Singh', 0, NULL, NULL),
(4, 203, 'BS', 'Daya', 'Sagar', 'BS Daya Sagar', 0, NULL, NULL),
(4, 204, 'Laurent', NULL, 'Najman', 'Laurent Najman', 0, NULL, NULL),
(4, 205, 'Shambhu', NULL, 'Upadhyaya', 'Shambhu Upadhyaya', 0, NULL, NULL),
(4, 207, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 208, 'Lokesh', NULL, 'Kumar', 'Lokesh Kumar', 0, NULL, NULL),
(4, 216, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(4, 217, 'Nabil', NULL, 'Alshurafa', 'Nabil Alshurafa', 0, NULL, NULL),
(4, 218, 'Aditya', NULL, 'Challa', 'Aditya Challa', 0, NULL, NULL),
(4, 219, 'Sriparna', NULL, 'Saha', 'Sriparna Saha', 0, NULL, NULL),
(4, 221, 'Janick', NULL, 'Edinger', 'Janick Edinger', 0, NULL, NULL),
(4, 222, 'S.', NULL, 'Kar', 'S. Kar', 0, NULL, NULL),
(4, 223, 'Margarita', NULL, 'Safonova', 'Margarita Safonova', 0, NULL, NULL),
(4, 224, 'S.', NULL, 'Saha', 'S. Saha', 0, NULL, NULL),
(4, 225, 'Suraj', NULL, 'Aralihalli', 'Suraj Aralihalli', 0, NULL, NULL),
(4, 227, 'Saha', NULL, 'S', 'Saha S', 0, NULL, NULL),
(4, 228, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(4, 229, 'Krishna Pratap', NULL, 'Singh', 'Krishna Pratap Singh', 0, NULL, NULL),
(4, 230, 'Archana', NULL, 'Mathur', 'Archana Mathur', 0, NULL, NULL),
(4, 232, 'S.', NULL, 'Dhavala', 'S. Dhavala', 0, NULL, NULL),
(4, 234, 'Manik', NULL, 'Mahajan', 'Manik Mahajan', 0, NULL, NULL),
(4, 235, 'Dipanjan', NULL, 'Chakraborty', 'Dipanjan Chakraborty', 0, NULL, NULL),
(4, 236, 'Daya Sagar', NULL, 'BS', 'Daya Sagar BS', 0, NULL, NULL),
(4, 237, 'Laurent', NULL, 'Najman', 'Laurent Najman', 0, NULL, NULL),
(4, 238, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(4, 239, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(4, 240, 'Sandip', NULL, 'Chakraborty', 'Sandip Chakraborty', 0, NULL, NULL),
(4, 241, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(4, 242, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(4, 243, 'Bivas', NULL, 'Mitra', 'Bivas Mitra', 0, NULL, NULL),
(4, 245, 'Abdallah', NULL, 'El Ali', 'Abdallah El Ali', 0, NULL, NULL),
(4, 246, 'Thomas', NULL, 'Roggla', 'Thomas Roggla', 0, NULL, NULL),
(4, 247, 'Mohit', NULL, 'Sweak', 'Mohit Sweak', 0, NULL, NULL),
(4, 249, 'Mohit', NULL, 'Sweak', 'Mohit Sweak', 0, NULL, NULL),
(4, 250, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 253, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 255, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 257, 'Nannan', NULL, 'Zhao', 'Nannan Zhao', 0, NULL, NULL),
(4, 258, 'Bing', NULL, 'Xie', 'Bing Xie', 0, NULL, NULL),
(4, 259, 'Feiyi', NULL, 'Wang', 'Feiyi Wang', 0, NULL, NULL),
(4, 263, 'Parthasarathy', NULL, 'PD', 'Parthasarathy PD', 0, NULL, NULL),
(4, 264, 'Mohit', NULL, 'Sewak', 'Mohit Sewak', 0, NULL, NULL),
(4, 265, 'Angela', NULL, 'Fargasso', 'Angela Fargasso', 0, NULL, NULL),
(4, 268, 'Andrew', NULL, 'Rowley', 'Andrew Rowley', 0, NULL, NULL),
(4, 275, 'Sasikumar', NULL, 'Punnekkat', 'Sasikumar Punnekkat', 0, NULL, NULL),
(4, 276, 'Sasikumar', NULL, 'Punnekkat', 'Sasikumar Punnekkat', 0, NULL, NULL),
(4, 277, 'Veeky', NULL, 'Baths', 'Veeky Baths', 0, NULL, NULL),
(4, 280, 'Sneha', 'L', 'Bhadouriya', 'Sneha L Bhadouriya', 0, NULL, NULL),
(4, 284, 'Shashank', NULL, 'Madhusudan', 'Shashank Madhusudan', 0, NULL, NULL),
(5, 4, 'Soundarya', NULL, 'Krishnan', 'Soundarya Krishnan', 0, NULL, NULL),
(5, 7, 'Ashwin', NULL, 'Srinivasan', 'Ashwin Srinivasan', 0, NULL, NULL),
(5, 8, 'Ashwin', NULL, 'Srinivasan', 'Ashwin Srinivasan', 0, NULL, NULL),
(5, 9, 'Ashwin', NULL, 'Srinivasan', 'Ashwin Srinivasan', 0, NULL, NULL),
(5, 13, 'A', NULL, 'Dogra', 'A Dogra', 0, NULL, NULL),
(5, 19, 'Sandhya', NULL, 'Mehrotra', 'Sandhya Mehrotra', 0, NULL, NULL),
(5, 26, 'Puneet', NULL, 'Agarwal', 'Puneet Agarwal', 0, NULL, NULL),
(5, 27, 'Sneha', 'H', 'R', 'Sneha H R', 0, NULL, NULL),
(5, 30, 'Simran', NULL, 'Makhija', 'Simran Makhija', 0, NULL, NULL),
(5, 31, 'T.S.B.', NULL, 'Sudarshan', 'T.S.B. Sudarshan', 0, NULL, NULL),
(5, 32, 'Sriparna', NULL, 'Saha', 'Sriparna Saha', 0, NULL, NULL),
(5, 45, 'Josiah', NULL, 'Hester', 'Josiah Hester', 0, NULL, NULL),
(5, 60, 'Sujith', NULL, 'Thomas', 'Sujith Thomas', 0, NULL, NULL),
(5, 102, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(5, 113, 'Hemant', NULL, 'Rathore', 'Hemant Rathore', 0, NULL, NULL),
(5, 117, 'David', NULL, 'Kotz', 'David Kotz', 0, NULL, NULL),
(5, 131, 'Gautam', NULL, 'Shroff', 'Gautam Shroff', 0, NULL, NULL),
(5, 132, 'Ashwin', NULL, 'Srinivasan', 'Ashwin Srinivasan', 0, NULL, NULL),
(5, 139, 'T.', NULL, 'Dash', 'T. Dash', 0, NULL, NULL),
(5, 143, 'Youngki', NULL, 'Lee', 'Youngki Lee', 0, NULL, NULL),
(5, 146, 'Travis', NULL, 'Masterson', 'Travis Masterson', 0, NULL, NULL),
(5, 147, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(5, 149, 'Jeffrey', NULL, 'Rogers', 'Jeffrey Rogers', 0, NULL, NULL),
(5, 150, 'Nabil', NULL, 'Alshurafa', 'Nabil Alshurafa', 0, NULL, NULL),
(5, 155, 'Sujith', NULL, 'Thomas', 'Sujith Thomas', 0, NULL, NULL),
(5, 159, 'Mary', NULL, 'Doyle-Kent', 'Mary Doyle-Kent', 0, NULL, NULL),
(5, 160, 'Basabdatta', 'Sen', 'Bhattacharya', 'Basabdatta Sen Bhattacharya', 0, NULL, NULL),
(5, 163, 'Rajesh', 'Krishna', 'Balan', 'Rajesh Krishna Balan', 0, NULL, NULL),
(5, 164, 'Archan', NULL, 'Misra', 'Archan Misra', 0, NULL, NULL),
(5, 166, 'Amrit', NULL, 'Kumar', 'Amrit Kumar', 0, NULL, NULL),
(5, 169, 'Rajesh', 'Krishna', 'Balan', 'Rajesh Krishna Balan', 0, NULL, NULL),
(5, 170, 'Youngki', NULL, 'Lee', 'Youngki Lee', 0, NULL, NULL),
(5, 172, 'Rajesh', 'Krishna', 'Balan', 'Rajesh Krishna Balan', 0, NULL, NULL),
(5, 174, 'R.K.', NULL, 'Balan', 'R.K. Balan', 0, NULL, NULL),
(5, 175, 'A.', NULL, 'Misra', 'A. Misra', 0, NULL, NULL),
(5, 177, 'Rajesh', 'Krishna', 'Balan', 'Rajesh Krishna Balan', 0, NULL, NULL),
(5, 178, 'Youngki', NULL, 'Lee', 'Youngki Lee', 0, NULL, NULL),
(5, 180, 'Byron', NULL, 'Lowens', 'Byron Lowens', 0, NULL, NULL),
(5, 181, 'Meera', NULL, 'Radhakrishnan', 'Meera Radhakrishnan', 0, NULL, NULL),
(5, 182, 'Rajesh', 'Krishna', 'Balan', 'Rajesh Krishna Balan', 0, NULL, NULL),
(5, 183, 'Byron', NULL, 'Lowens', 'Byron Lowens', 0, NULL, NULL),
(5, 184, 'David', NULL, 'Kotz', 'David Kotz', 0, NULL, NULL),
(5, 185, 'Youngki', NULL, 'Lee', 'Youngki Lee', 0, NULL, NULL),
(5, 186, 'Soma', 'S.', 'Dhavala', 'Soma S. Dhavala', 0, NULL, NULL),
(5, 187, 'Sriparna', NULL, 'Saha', 'Sriparna Saha', 0, NULL, NULL),
(5, 190, 'Soma', 'S', 'Dhavala', 'Soma S Dhavala', 0, NULL, NULL),
(5, 195, 'Snehanshu', NULL, 'Saha', 'Snehanshu Saha', 0, NULL, NULL),
(5, 201, 'Luís', 'Ducla', 'Soares', 'Luís Ducla Soares', 0, NULL, NULL),
(5, 217, 'Josiah', NULL, 'Hester', 'Josiah Hester', 0, NULL, NULL),
(5, 218, 'Sravan', NULL, 'Danda', 'Sravan Danda', 0, NULL, NULL),
(5, 221, 'Roger', 'O.', 'Smith', 'Roger O. Smith', 0, NULL, NULL),
(5, 222, 'Anusha.', NULL, 'K', 'Anusha. K', 0, NULL, NULL),
(5, 223, 'Santonu', NULL, 'Sarkar', 'Santonu Sarkar', 0, NULL, NULL),
(5, 225, 'Soma', 'S', 'Dhavala', 'Soma S Dhavala', 0, NULL, NULL),
(5, 228, 'Huy Tran', NULL, 'Quang', 'Huy Tran Quang', 0, NULL, NULL),
(5, 230, 'Rekha', NULL, 'Phadke', 'Rekha Phadke', 0, NULL, NULL),
(5, 232, 'S.', NULL, 'Das', 'S. Das', 0, NULL, NULL),
(5, 234, 'Vinayak', NULL, 'Naik', 'Vinayak Naik', 0, NULL, NULL),
(5, 238, 'Yang', NULL, 'Gao', 'Yang Gao', 0, NULL, NULL),
(5, 239, 'Aggelos', 'K', 'Katsaggelos', 'Aggelos K Katsaggelos', 0, NULL, NULL),
(5, 240, 'Surjya', NULL, 'Ghosh', 'Surjya Ghosh', 0, NULL, NULL),
(5, 241, 'Jennifer', NULL, 'Makelarski', 'Jennifer Makelarski', 0, NULL, NULL),
(5, 242, 'Surjya', NULL, 'Ghosh', 'Surjya Ghosh', 0, NULL, NULL),
(5, 245, 'Pablo', NULL, 'Cesar', 'Pablo Cesar', 0, NULL, NULL),
(5, 246, 'Abdallah', NULL, 'El Ali', 'Abdallah El Ali', 0, NULL, NULL),
(5, 257, 'Arnab Kumar', NULL, 'Paul', 'Arnab Kumar Paul', 0, NULL, NULL),
(5, 258, 'Suren', NULL, 'Byna', 'Suren Byna', 0, NULL, NULL),
(5, 263, 'Snigdha', NULL, 'Tiwari', 'Snigdha Tiwari', 0, NULL, NULL),
(5, 265, 'Ille', 'C.', 'Gebeshuber', 'Ille C. Gebeshuber', 0, NULL, NULL),
(5, 268, 'Christian', NULL, 'Brenninkmeijer', 'Christian Brenninkmeijer', 0, NULL, NULL),
(5, 280, 'Swati', NULL, 'Agarwal', 'Swati Agarwal', 0, NULL, NULL),
(6, 4, 'Adithya', NULL, 'Niranjan', 'Adithya Niranjan', 0, NULL, NULL),
(6, 13, 'Vinayak', NULL, 'Naik', 'Vinayak Naik', 0, NULL, NULL),
(6, 19, 'Rajesh', NULL, 'Mehrotra', 'Rajesh Mehrotra', 0, NULL, NULL),
(6, 26, 'Gautam', NULL, 'Shroff', 'Gautam Shroff', 0, NULL, NULL),
(6, 30, 'Margarita', NULL, 'Safonova', 'Margarita Safonova', 0, NULL, NULL),
(6, 31, 'Soma', 'S', 'Dhavala', 'Soma S Dhavala', 0, NULL, NULL),
(6, 45, 'Nabil', NULL, 'Alshurafa', 'Nabil Alshurafa', 0, NULL, NULL),
(6, 60, 'Andrew', NULL, 'Rowley', 'Andrew Rowley', 0, NULL, NULL),
(6, 131, 'Ashwin', NULL, 'Srinivasan', 'Ashwin Srinivasan', 0, NULL, NULL),
(6, 146, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(6, 147, 'Josiah', NULL, 'Hester', 'Josiah Hester', 0, NULL, NULL),
(6, 149, 'Ching-Hua', NULL, 'Chen', 'Ching-Hua Chen', 0, NULL, NULL),
(6, 150, 'Josiah', NULL, 'Hester', 'Josiah Hester', 0, NULL, NULL),
(6, 155, 'Andrew', NULL, 'Rowley', 'Andrew Rowley', 0, NULL, NULL),
(6, 163, 'Youngki', NULL, 'Lee', 'Youngki Lee', 0, NULL, NULL),
(6, 164, 'Nilanjan', NULL, 'Banerjee', 'Nilanjan Banerjee', 0, NULL, NULL),
(6, 166, 'Sai', NULL, 'Pawankumar', 'Sai Pawankumar', 0, NULL, NULL),
(6, 169, 'Youngki', NULL, 'Lee', 'Youngki Lee', 0, NULL, NULL),
(6, 175, 'R.K.', NULL, 'Balan', 'R.K. Balan', 0, NULL, NULL),
(6, 180, 'Kelly', NULL, 'Caine', 'Kelly Caine', 0, NULL, NULL),
(6, 181, 'Rajesh', 'K.', 'Balan', 'Rajesh K. Balan', 0, NULL, NULL),
(6, 183, 'Kelly', NULL, 'Caine', 'Kelly Caine', 0, NULL, NULL),
(6, 184, 'Tao', NULL, 'Wang', 'Tao Wang', 0, NULL, NULL),
(6, 186, 'Sriparna', NULL, 'Saha', 'Sriparna Saha', 0, NULL, NULL),
(6, 190, 'Sriparna', NULL, 'Saha', 'Sriparna Saha', 0, NULL, NULL),
(6, 221, 'Md Osman', NULL, 'Gani', 'Md Osman Gani', 0, NULL, NULL),
(6, 225, 'Sriparna', NULL, 'Saha', 'Sriparna Saha', 0, NULL, NULL),
(6, 238, 'Aggelos', 'K', 'Katsaggelos', 'Aggelos K Katsaggelos', 0, NULL, NULL),
(6, 239, 'Josiah', 'D', 'Hester', 'Josiah D Hester', 0, NULL, NULL),
(6, 241, 'Christopher', NULL, 'Colvin', 'Christopher Colvin', 0, NULL, NULL),
(6, 246, 'Pablo', NULL, 'Cesar', 'Pablo Cesar', 0, NULL, NULL),
(6, 257, 'Ali R.', NULL, 'Butt', 'Ali R. Butt', 0, NULL, NULL),
(6, 258, 'Philip', NULL, 'Carns', 'Philip Carns', 0, NULL, NULL),
(6, 263, 'Swaroop', NULL, 'Joshi', 'Swaroop Joshi', 0, NULL, NULL),
(6, 265, 'Ella', 'Magdalena', 'Ciuperca', 'Ella Magdalena Ciuperca', 0, NULL, NULL),
(6, 268, 'Donal', 'K.', 'Fellows', 'Donal K. Fellows', 0, NULL, NULL),
(6, 280, 'Sandhya', NULL, 'Mehrotra', 'Sandhya Mehrotra', 0, NULL, NULL),
(7, 4, 'Tirtharaj', NULL, 'Dash', 'Tirtharaj Dash', 0, NULL, NULL),
(7, 13, 'H', NULL, 'Acharya', 'H Acharya', 0, NULL, NULL),
(7, 26, 'Ashwin', NULL, 'Srinivasan', 'Ashwin Srinivasan', 0, NULL, NULL),
(7, 30, 'Surbhi', NULL, 'Agrawal', 'Surbhi Agrawal', 0, NULL, NULL),
(7, 60, 'Teresa', NULL, 'Serrano-Gotarredona', 'Teresa Serrano-Gotarredona', 0, NULL, NULL),
(7, 146, 'Ryan', NULL, 'Halter', 'Ryan Halter', 0, NULL, NULL),
(7, 147, 'Nabil', NULL, 'Alshurafa', 'Nabil Alshurafa', 0, NULL, NULL),
(7, 149, 'David', NULL, 'Kotz', 'David Kotz', 0, NULL, NULL),
(7, 150, 'Jeremy', NULL, 'Gummeson', 'Jeremy Gummeson', 0, NULL, NULL),
(7, 155, 'Teresa', NULL, 'Serrano-Gotarredona', 'Teresa Serrano-Gotarredona', 0, NULL, NULL),
(7, 164, 'Sumit', NULL, 'Mittal', 'Sumit Mittal', 0, NULL, NULL),
(7, 166, 'Sunil', 'Kumar', 'Vuppala', 'Sunil Kumar Vuppala', 0, NULL, NULL),
(7, 180, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(7, 181, 'Youngki', NULL, 'Lee', 'Youngki Lee', 0, NULL, NULL),
(7, 183, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(7, 184, 'Nicole', NULL, 'Tobias', 'Nicole Tobias', 0, NULL, NULL),
(7, 190, 'Raviprasad', NULL, 'Aduri', 'Raviprasad Aduri', 0, NULL, NULL),
(7, 225, 'Raviprasad', NULL, 'Aduri', 'Raviprasad Aduri', 0, NULL, NULL),
(7, 238, 'Nabil', NULL, 'Alshurafa', 'Nabil Alshurafa', 0, NULL, NULL),
(7, 239, 'Nabil', NULL, 'Alshurafa', 'Nabil Alshurafa', 0, NULL, NULL),
(7, 241, 'Danielle', NULL, 'Ward', 'Danielle Ward', 0, NULL, NULL),
(7, 258, 'Sarp', NULL, 'Oral', 'Sarp Oral', 0, NULL, NULL),
(7, 265, 'Galia', NULL, 'Marinova', 'Galia Marinova', 0, NULL, NULL),
(7, 268, 'Stephen', 'B.', 'Furber', 'Stephen B. Furber', 0, NULL, NULL),
(7, 280, 'Divya', NULL, 'Gupta', 'Divya Gupta', 0, NULL, NULL),
(8, 4, 'Ashwin', NULL, 'Srinivasan', 'Ashwin Srinivasan', 0, NULL, NULL),
(8, 13, 'S', NULL, 'Chakravarty', 'S Chakravarty', 0, NULL, NULL),
(8, 60, 'Basabdatta', NULL, 'Sen-Bhattacharya', 'Basabdatta Sen-Bhattacharya', 0, NULL, NULL),
(8, 146, 'Jacob', NULL, 'Sorber', 'Jacob Sorber', 0, NULL, NULL),
(8, 155, 'Sen Basabdatta', NULL, 'Bhattacharya', 'Sen Basabdatta Bhattacharya', 0, NULL, NULL),
(8, 166, 'Sanjoy', NULL, 'Paul', 'Sanjoy Paul', 0, NULL, NULL),
(8, 180, 'Ryan', NULL, 'Halter', 'Ryan Halter', 0, NULL, NULL),
(8, 183, 'Ryan', NULL, 'Halter', 'Ryan Halter', 0, NULL, NULL),
(8, 184, 'Josephine', NULL, 'Nordrum', 'Josephine Nordrum', 0, NULL, NULL),
(8, 241, 'Grace', NULL, 'Mirsky', 'Grace Mirsky', 0, NULL, NULL),
(8, 258, 'Feiyi', NULL, 'Wang', 'Feiyi Wang', 0, NULL, NULL),
(8, 265, 'Mary', NULL, 'Doyle-Kent', 'Mary Doyle-Kent', 0, NULL, NULL),
(8, 280, 'Rajesh', NULL, 'Mehrotra', 'Rajesh Mehrotra', 0, NULL, NULL),
(9, 4, 'Gautam', NULL, 'Shroff', 'Gautam Shroff', 0, NULL, NULL),
(9, 146, 'Diane', NULL, 'Gilbert-Diamond', 'Diane Gilbert-Diamond', 0, NULL, NULL),
(9, 180, 'David', NULL, 'Kotz', 'David Kotz', 0, NULL, NULL),
(9, 183, 'David', NULL, 'Kotz', 'David Kotz', 0, NULL, NULL),
(9, 184, 'Shang', NULL, 'Wang', 'Shang Wang', 0, NULL, NULL),
(9, 258, 'Jesse', NULL, 'Hanley', 'Jesse Hanley', 0, NULL, NULL),
(10, 146, 'David', NULL, 'Kotz', 'David Kotz', 0, NULL, NULL),
(10, 184, 'George', NULL, 'Halvorsen', 'George Halvorsen', 0, NULL, NULL),
(11, 184, 'Sougata', NULL, 'Sen', 'Sougata Sen', 0, NULL, NULL),
(12, 184, 'Ronald', NULL, 'Peterson', 'Ronald Peterson', 0, NULL, NULL),
(13, 184, 'Kofi', NULL, 'Odame', 'Kofi Odame', 0, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pubhdrs`
--

CREATE TABLE `pubhdrs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `categoryid` bigint(20) UNSIGNED DEFAULT NULL,
  `authortypeid` bigint(20) UNSIGNED DEFAULT NULL,
  `articletypeid` int(11) DEFAULT NULL,
  `nationality` int(11) DEFAULT NULL,
  `pubdate` date NOT NULL,
  `title` varchar(2500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confname` varchar(2500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `place` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rankingid` bigint(20) UNSIGNED DEFAULT NULL,
  `broadareaid` bigint(20) UNSIGNED DEFAULT NULL,
  `impactfactor` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `volume` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `issue` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pp` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `userid` bigint(20) UNSIGNED NOT NULL,
  `publisher` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `note` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted` tinyint(1) NOT NULL,
  `digitallibrary` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bibtexfile` varchar(1024) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pubhdrs`
--

INSERT INTO `pubhdrs` (`id`, `categoryid`, `authortypeid`, `articletypeid`, `nationality`, `pubdate`, `title`, `confname`, `place`, `rankingid`, `broadareaid`, `impactfactor`, `description`, `volume`, `issue`, `pp`, `userid`, `publisher`, `note`, `deleted`, `digitallibrary`, `bibtexfile`, `created_at`, `updated_at`) VALUES
(1, 8, 1, 1, 2, '2020-01-01', 'Image Processing for UAV Using Deep Convolutional Encoder–Decoder Networks with Symmetric Skip Connections on a System on Chip (SoC)', 'International Conference on Intelligent Computing and Smart Communication 2019', 'Springer, Singapore', NULL, 9, NULL, NULL, NULL, NULL, '1009-1015', 10, NULL, NULL, 0, 'ISBN 978-981-15-0633-8', '', '2020-12-20 21:05:44', '2020-12-20 21:05:44'),
(2, 7, 1, NULL, 2, '2020-01-21', 'Lightweight approach to automated fault diagnosis in WSNs', 'IET Networks', 'UK', 330, 9, NULL, NULL, NULL, NULL, NULL, 14, NULL, NULL, 0, '10.1049/iet-net.2019.0117', '', '2020-12-21 19:37:22', '2020-12-21 19:37:22'),
(3, 8, 1, 1, 2, '2020-07-29', 'Better learning of partially diagnostic features leads to less unidimensional categorization in supervised category learning', 'Proceedings of the 42nd Annual Conference of the Cognitive Science Society (pp. 3444--3450). Cognitive Science Society', 'Toronto, Canada', 332, 17, NULL, NULL, NULL, NULL, '3444--3450', 17, NULL, NULL, 1, NULL, '', '2020-12-21 19:39:43', '2020-12-21 19:52:26'),
(4, 8, 2, 2, 2, '2020-11-04', 'CovidDiagnosis: Deep Diagnosis of COVID-19 Patients Using Chest X-Rays', 'MICCAI-International Workshop on Thoracic Image Analysis', 'Lima, Peru', 248, 17, NULL, NULL, NULL, NULL, '61-73', 14, NULL, NULL, 0, 'https://doi.org/10.1007/978-3-030-62469-9_6', '', '2020-12-21 19:46:21', '2020-12-21 20:47:43'),
(5, 8, 1, 3, 2, '2020-06-29', 'Effect of a colour-based descriptor and stimuli presentation mode in unsupervised categorization', 'Proceedings of the 42nd Annual Conference of the Cognitive Science Society (p. 3531)', 'Toronto, Canada.', 332, 17, NULL, NULL, NULL, NULL, '3531', 17, NULL, NULL, 0, NULL, '', '2020-12-21 19:51:00', '2020-12-21 19:51:00'),
(6, 8, 1, 1, 2, '2020-07-29', 'Better learning of partially diagnostic features leads to less unidimensional categorization in supervised category learning', 'Proceedings of the 42nd Annual Conference of the Cognitive Science Society (pp. 3444--3450)', 'Toronto, Canada', 332, 17, NULL, NULL, NULL, NULL, '3444--3450', 17, NULL, NULL, 0, NULL, '', '2020-12-21 19:55:14', '2020-12-21 19:55:14'),
(7, 8, 2, 2, 2, '2020-10-02', 'A Case Study of Transfer of Lesion-Knowledge', 'MICCAI-International Workshop on Medical Image Learning with Less Labels and Imperfect Data', 'Lima, Peru', NULL, 17, NULL, NULL, NULL, NULL, '138-145', 14, NULL, NULL, 1, 'https://doi.org/10.1007/978-3-030-61166-8_15', '', '2020-12-21 20:25:48', '2020-12-21 20:49:19'),
(8, 8, 2, NULL, 2, '2020-10-02', 'An Empirical Study of Iterative Knowledge Distillation for Neural Network Compression', 'European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning', 'Bruges, Belgium', 326, 17, NULL, NULL, NULL, NULL, '217-222', 14, NULL, NULL, 0, 'ISBN 978-2-87587-074-2', '', '2020-12-21 20:33:41', '2020-12-21 20:33:41'),
(9, 8, 2, 2, 2, '2020-10-02', 'A Case Study of Transfer of Lesion-Knowledge', 'MICCAI-International Workshop on Medical Image Learning with Less Labels and Imperfect Data', 'Lima, Peru', NULL, 17, NULL, NULL, NULL, NULL, '138-145', 14, NULL, NULL, 0, 'https://doi.org/10.1007/978-3-030-61166-8_15', '', '2020-12-21 20:37:23', '2020-12-21 20:37:23'),
(10, 7, 1, NULL, 2, '2020-05-01', 'Position-based routing protocol using Kalman filter as a prediction module for vehicular ad hoc networks', 'Computers & Electrical Engineering', 'NA', 328, 9, '2.6', NULL, '83', '106599', NULL, 19, NULL, NULL, 1, 'https://doi.org/10.1016/j.compeleceng.2020.106599', '', '2020-12-21 23:32:59', '2020-12-22 20:07:31'),
(11, 8, 1, 1, 2, '2020-01-07', 'Predicting Human Response in Feature Binding Experiment Using EEG Data', 'Networked Healthcare Technology (NetHealth\'20)', 'India', 328, 9, NULL, NULL, NULL, NULL, NULL, 8, NULL, NULL, 0, NULL, '', '2020-12-21 23:54:50', '2020-12-21 23:54:50'),
(12, 8, 1, 1, 2, '2020-01-07', 'Use of Smartphone\'s Headset Microphone to Estimate the Rate of Respiration', 'Networked Healthcare Technology (NetHealth\'20)', 'India', 328, 9, NULL, NULL, NULL, NULL, NULL, 8, NULL, NULL, 0, NULL, '', '2020-12-21 23:56:06', '2020-12-21 23:56:06'),
(13, 8, 1, 2, 2, '2020-07-14', 'SiegeBreaker: An SDN Based Practical Decoy Routing System', 'Privacy Enhancing Technologies Symposium', 'Canada', 326, 9, NULL, NULL, NULL, NULL, NULL, 8, NULL, NULL, 0, NULL, '', '2020-12-21 23:59:22', '2020-12-21 23:59:22'),
(14, 8, 1, 2, 2, '2020-12-10', 'Adaptive ViFi: A Dynamic Protocol for IoT Nodes in Challenged WiFi Network Conditions', 'International Conference on Mobile Ad-Hoc and Smart Systems', 'India', 326, 9, NULL, NULL, NULL, NULL, NULL, 8, NULL, NULL, 0, NULL, '', '2020-12-22 00:01:00', '2020-12-22 00:01:00'),
(15, 8, 2, 2, 2, '2020-02-15', 'Single Image Intrinsic Decomposition Using Transfer Learning', '12th International Conference on Machine Learning and Computing', 'China', 248, 17, NULL, NULL, NULL, NULL, '418-425', 19, NULL, NULL, 0, NULL, '', '2020-12-22 19:52:10', '2020-12-22 19:52:10'),
(16, 8, 2, 2, 2, '2020-02-18', 'DDoSify: Server Workload Migration During DDOS Attack In NFV', '9th International Conference on Software and Computer Applications', 'Malaysia', 248, 9, NULL, NULL, NULL, NULL, '364-369', 19, NULL, NULL, 0, NULL, '', '2020-12-22 19:55:08', '2020-12-22 19:55:08'),
(17, 8, 2, 2, 2, '2020-08-14', 'Renewable Energy Firm’s Performance Analysis Using Machine Learning Approach', 'Procedia Computer Science, Elsevier', 'Belgium', 328, 17, NULL, NULL, NULL, NULL, '500-507', 19, NULL, NULL, 0, NULL, '', '2020-12-22 19:58:11', '2020-12-22 20:05:21'),
(18, 7, 1, NULL, 2, '2020-05-01', 'Position-based routing protocol using Kalman filter as a prediction module for vehicular ad hoc networks', 'Computers & Electrical Engineering', 'NA', 328, 9, '2.6', NULL, '83', NULL, '106599', 19, NULL, NULL, 0, NULL, '', '2020-12-22 20:10:32', '2020-12-22 20:10:32'),
(19, 7, 1, NULL, 2, '2020-12-08', 'Co-expression Network Analysis of Protein Phosphatase 2A (PP2A) Genes with Stress-Responsive Genes in Arabidopsis thaliana Reveals 13 Key Regulators', 'Scientific Reports, Nature Publishing Group', '-', 329, NULL, '4.576', NULL, '10', NULL, NULL, 23, NULL, NULL, 0, 'https://dx.doi.org/10.1038%2Fs41598-020-77746-z', '', '2020-12-29 00:27:33', '2020-12-29 00:27:33'),
(20, 8, 1, 2, 2, '2020-12-25', 'MeshSOS: An IoT Based Emergency Response System', 'In 54th The Hawaii International Conference on System Sciences', 'Hawaii', 332, 18, NULL, NULL, NULL, NULL, NULL, 23, NULL, NULL, 0, NULL, '', '2020-12-29 00:30:25', '2020-12-29 00:30:25'),
(21, 8, 1, 2, 2, '2020-05-08', 'BPGC at SemEval-2020 Task 11: Propaganda Detection in News Articles with Multi-Granularity Knowledge Sharing and Linguistic Features based Ensemble Learning', '14th International Workshop on Semantic Evaluation, Co-located with 28th International Conference on Computational Linguistics (COLING)', 'Barcelona, Spain', 332, 17, NULL, NULL, NULL, NULL, NULL, 23, NULL, NULL, 0, NULL, '', '2020-12-29 00:33:28', '2020-12-29 00:33:28'),
(22, 8, 1, 2, 2, '2020-05-20', 'Socio-Cellular Network: A Novel Social Assisted Cellular Communication Paradigm', 'The 91st Vehicular Technology Conference: VTC2020-Spring', 'Antwerp, Belgium', 326, 9, NULL, NULL, NULL, NULL, NULL, 23, NULL, NULL, 1, 'https://ieeexplore.ieee.org/document/9129642', '', '2020-12-29 00:38:10', '2020-12-29 00:38:10'),
(23, 8, 1, 2, 2, '2020-12-25', 'Distributed Vehicular Dynamic Spectrum Access for Platooning Environments.', 'IEEE 92md Vehicular Technology Conference VTC Spring', 'Helsinki, Finland', 326, 9, NULL, NULL, NULL, NULL, NULL, 23, NULL, NULL, 0, NULL, '', '2020-12-29 00:39:44', '2020-12-29 00:39:44'),
(24, 7, 1, NULL, 2, '2020-01-31', 'Constructing generative logical models for optimisation problems using domain knowledge', NULL, '-', 332, 17, NULL, NULL, NULL, NULL, '1371-1392', 9, NULL, NULL, 0, NULL, '', '2020-12-30 01:48:01', '2021-11-17 00:48:27'),
(25, 7, 1, NULL, NULL, '2020-01-01', 'Incorporating Symbolic Domain Knowledge into Graph Neural Networks', 'CoRR 2020', '-', NULL, 17, NULL, NULL, NULL, NULL, NULL, 9, NULL, NULL, 1, NULL, '', '2020-12-30 01:56:53', '2020-12-30 01:56:53'),
(26, 8, 1, 2, 2, '2020-01-01', 'Information Extraction from Document Images via FCA based Template Detection and Knowledge Graph Rule Induction', '2020 IEEE/CVF Conference on Computer Vision and Pattern Recognition, CVPR Workshops 2020', 'Seattle, WA, USA', 332, 17, NULL, NULL, NULL, NULL, '2377-2385', 9, NULL, NULL, 0, NULL, '', '2020-12-30 02:01:46', '2020-12-30 02:01:46'),
(27, 7, 1, NULL, 2, '2020-11-09', 'Springer - Evolution of Novel Activation Functions in Neural\r\nNetwork Training for Astronomy Data: Habitability Classification of Exoplanets', 'EPJ Special Topics', 'Germany', NULL, NULL, '1.8', NULL, '229', NULL, '2629–2738', 7, NULL, NULL, 0, '10.1140/epjst/e2020-000098-9', '', '2021-01-27 01:28:40', '2021-11-17 01:06:14'),
(28, 7, 1, NULL, 2, '2020-08-28', 'Springer - LipschitzLR: Using theoretically computed adaptive learning rates for fast convergence', 'Applied Intelligence', NULL, NULL, NULL, '3.325', NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, 'https://doi.org/10.1007/s10489- 020-01892-0', '', '2021-01-27 01:58:05', '2021-11-17 01:09:10'),
(29, 7, 1, NULL, 2, '2020-06-01', 'AIP- ChaosNet: A Chaos based Artificial Neural Network Architecture for Classification  (Editor’s collection)', 'Chaos: An Interdisciplinary Journal of Nonlinear Science', NULL, NULL, NULL, NULL, NULL, '29(11)', NULL, '113-125', 7, NULL, NULL, 0, NULL, '', '2021-01-27 02:12:24', '2021-11-17 01:55:14'),
(30, 7, 1, NULL, 2, '2020-01-01', 'Elsevier – CESSA Meets Machine Learning: From Earth Similarity to Habitability Classification of Exoplanets', 'Astronomy and Computing', NULL, NULL, NULL, '3.1', NULL, '30', NULL, NULL, 7, NULL, NULL, 0, NULL, '', '2021-01-27 02:51:38', '2021-11-17 01:57:47'),
(31, 8, 1, NULL, 2, '2020-07-24', 'LALR: Theoretical and Experimental validation of Lipschitz Adaptive Learning Rate in Regression and Neural Networks', 'International Joint Conference on Neural Networks', 'Glasgow, United Kingdom, United Kingdom', 332, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, '10.1109/IJCNN48605.2020.9207650', '', '2021-01-27 03:08:12', '2021-01-27 03:08:12'),
(32, 8, 1, NULL, 2, '2020-07-24', 'Parsimonious Computing: A Minority Training Regime for Effective Prediction in Large Microarray Expression Data Sets', 'International Joint Conference on Neural Networks', NULL, 332, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, '10.1109/IJCNN48605.2020.9207083', '', '2021-01-27 03:11:46', '2021-01-27 03:11:46'),
(33, 8, 1, NULL, 2, '2020-05-01', 'Recruitment Boosted Epidemiological Model for Qualitative Study of Scholastic Influence Network', 'SIAM Conference on Mathematics of\r\nData Science', 'Cincinnati, USA', 328, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, NULL, '', '2021-01-27 03:21:44', '2021-01-27 03:21:44'),
(34, 8, 1, NULL, 2, '2020-05-01', 'Evolution of Novel Activation Functions', 'SIAM Conference on Mathematics of Data Science', 'Cincinnati, USA', 328, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, NULL, '', '2021-01-27 03:23:53', '2021-01-27 03:23:53'),
(35, 8, 1, NULL, 2, '2020-09-05', 'RaFIDe: A Machine Learning based RFI free observation\r\nplanner for the SKA Era', 'URSI GASS', 'Rome, Italy', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, NULL, '', '2021-01-27 03:26:47', '2021-01-27 03:26:47'),
(45, 8, 1, 1, 2, '2021-09-21', 'HeatSight: Wearable Low-Power Omni Thermal Sensing', 'ACM International Symposium on Wearable Computers', NULL, 321, 18, NULL, NULL, NULL, NULL, NULL, 24, 'ACM', NULL, 0, '10.1145/3460421.3478811', NULL, '2021-11-12 05:11:25', '2021-11-12 05:11:25'),
(51, 8, 1, NULL, 2, '2021-10-09', 'Transforming medical resource utilization process to verifiable timed automata models in Cyber-Physical Systems', '18th International Conference on Distributed Computing and Internet Technology', 'India', 248, 18, NULL, NULL, NULL, NULL, NULL, 27, 'Springer LNCS', NULL, 0, NULL, NULL, '2021-11-12 06:01:34', '2021-11-12 06:01:34'),
(52, 8, 1, 2, 2, '2021-07-31', 'LipARELU: ARELU Networks aided by Lipschitz\r\nAcceleration', '2021 International Joint Conference on Neural Networks (IJCNN)', 'UK', 332, 17, NULL, NULL, NULL, NULL, '1--8', 26, NULL, NULL, 0, NULL, NULL, '2021-11-12 06:17:18', '2021-11-16 23:25:15'),
(55, 8, 1, 2, 2, '2021-07-31', 'Prediction of Protein-Protein Interactions using Deep\r\nMulti-Modal Representations', '2021 International Joint Conference on Neural Networks (IJCNN)', 'UK', 332, 17, NULL, NULL, NULL, NULL, NULL, 26, NULL, NULL, 0, NULL, NULL, '2021-11-12 06:44:15', '2021-11-16 23:24:52'),
(58, 8, 2, 1, 2, '2021-03-22', 'Towards Putting Deep Learning on the Wrist for Accurate Human Activity Recognition', 'Workshop on Sensing Systems and Applications Using Wrist Worn Smart Devices at IEEE International Conference on Pervasive Computing and Communications', 'Kassel, Germany', 248, 17, NULL, NULL, NULL, NULL, NULL, 8, 'IEEE', NULL, 0, '10.1109/PerComWorkshops51409.2021.9430979', NULL, '2021-11-12 06:55:27', '2021-11-12 06:55:27'),
(59, 8, 2, 2, 2, '2021-10-18', 'NEAT Activity Detection Using Smartwatch at Low Sampling Frequency', 'IEEE International Conference on Ubiquitous Intelligence and Computing', 'Atlanta, USA', 326, 17, NULL, NULL, NULL, NULL, NULL, 8, NULL, NULL, 0, NULL, NULL, '2021-11-12 07:01:17', '2021-11-12 07:01:17'),
(60, 8, 1, 2, 2, '2021-07-18', 'A Reduced-Scale Cortical Network with Izhikevich\'s Neurons on SpiNNaker', '2021 International Joint Conference on Neural Networks (IJCNN)', NULL, 332, 17, NULL, NULL, NULL, NULL, NULL, 17, NULL, NULL, 1, NULL, NULL, '2021-11-12 07:10:21', '2021-11-12 07:10:21'),
(61, 8, 1, 2, 2, '2021-07-26', 'Supervised category learning: When do participants use a partially diagnostic feature?', '43rd Annual Conference of the Cognitive Science Society 2021', NULL, 332, 17, NULL, NULL, '43', NULL, '1313--1319', 17, NULL, NULL, 0, NULL, NULL, '2021-11-12 07:14:25', '2021-11-12 07:14:25'),
(63, 8, 1, 1, 2, '2021-04-14', 'Exploring Smartphone Keyboard Interactions for Experience Sampling Method driven Probe Generation', 'ACM IUI (Intelligent User Interfaces)\r\n\r\nIUI \'21: 26th International Conference on Intelligent User Interfaces', NULL, 332, 18, NULL, NULL, NULL, NULL, '133 - 138', 29, 'ACM', NULL, 0, '10.1145/3397481.3450669', NULL, '2021-11-12 11:10:08', '2021-11-12 11:10:08'),
(64, 8, 1, 2, 2, '2021-11-05', 'Towards Autism Screening through Emotion-guided Eye Gaze Response', 'IEEE EMBC\r\n\r\n2021 43rd Annual International Conference of the\r\nIEEE Engineering in Medicine & Biology Society (EMBC)', NULL, 248, 17, NULL, NULL, NULL, NULL, NULL, 29, 'IEEE', NULL, 0, '978-1-7281-1178-0/21', NULL, '2021-11-12 11:14:31', '2022-02-10 01:40:10'),
(65, 8, 1, 2, 2, '2021-11-11', 'Exploring the challenges of using food journaling apps: A case-study with young adults', 'EAI MobiQuitous 2021 - 18th EAI International Conference on Mobile and Ubiquitous Systems: Computing, Networking and Services', NULL, 326, 18, NULL, NULL, NULL, NULL, NULL, 29, 'Springer', NULL, 0, 'To appear', NULL, '2021-11-12 11:22:40', '2021-11-12 11:22:40'),
(66, 8, 1, 1, 2, '2021-07-13', 'Towards an Approach for Translation Validation of Thread-level Parallelizing Transformations using Colored Petri Nets', 'ICSOFT', 'Paris', 326, 18, NULL, NULL, NULL, NULL, '533-541', 11, NULL, NULL, 0, '10.5220/0010581005330541', NULL, '2021-11-12 13:19:46', '2021-11-12 13:19:46'),
(68, 8, 1, 1, 2, '2021-12-09', 'PNPEq: Verification of Scheduled Conditional Behavior in Embedded Software using Petri Nets', 'APSEC', 'Thaipi', 326, 18, NULL, NULL, NULL, NULL, NULL, 11, NULL, NULL, 0, NULL, NULL, '2021-11-12 13:33:44', '2021-11-12 13:33:44'),
(69, 8, 1, 3, 2, '2020-06-25', 'Translation Validation of Scheduled Conditional Behavior using PN.', 'PNSE', 'Paris', 248, 19, NULL, NULL, '2907', NULL, '257-258', 11, 'CEUR', NULL, 0, NULL, NULL, '2021-11-12 13:38:41', '2021-11-12 13:38:41'),
(70, 8, 1, 3, 2, '2020-06-25', 'Validating Extended Feature Model Configurations using Petri Nets', 'Petri net based software engineering', 'Paris', 248, 19, NULL, NULL, '2907', NULL, '255-256', 11, 'CEUR', NULL, 0, NULL, NULL, '2021-11-12 13:42:13', '2021-11-12 13:42:13'),
(71, 8, 1, 2, 2, '2021-09-01', 'MOESIL: A Cache Coherency Protocol for Locked Mixed Criticality L1 Data Cache', '2021 IEEE/ACM 25th International Symposium on Distributed Simulation and Real Time Applications (DS-RT)', 'Valencia/Spain', 337, 18, NULL, NULL, NULL, NULL, '1-8', 30, 'IEEE', NULL, 0, '10.1109/DS-RT52167.2021.9576135', NULL, '2021-11-12 23:58:02', '2021-11-12 23:58:02'),
(72, 8, 1, 1, 2, '2021-12-22', 'pmcEDF: An Energy Efficient Procrastination Scheduler for  Multi-core Mixed Criticality Systems', '23rd IEEE International Conference on High Performance Computing and Communications (HPCC - 2021)', 'Haikou/Hainan', 326, 18, NULL, NULL, NULL, NULL, NULL, 30, NULL, NULL, 0, NULL, NULL, '2021-11-13 00:08:13', '2021-11-13 00:08:13'),
(73, 8, 1, NULL, 2, '2018-12-18', 'Malware detection using machine learning and deep learning', 'International Conference on Big Data Analytics (BDA)', NULL, 336, NULL, NULL, NULL, NULL, NULL, '402--411', 13, 'Springer', NULL, 0, NULL, 'pub.bib', '2021-11-13 00:11:07', '2022-01-11 07:42:17'),
(74, 8, 1, NULL, 2, '2018-06-27', 'Comparison of deep learning and the classical machine learning algorithm for the malware detection', '2018 19th IEEE/ACIS International Conference on Software Engineering, Artificial Intelligence, Networking and Parallel/Distributed Computing (SNPD)', NULL, 337, NULL, NULL, NULL, NULL, NULL, '293--296', 13, 'IEEE', NULL, 0, NULL, 'pub.bib', '2021-11-13 00:11:07', '2022-01-11 07:54:17'),
(75, 8, 1, NULL, 2, '2018-08-27', 'An investigation of a deep learning based malware detection system', 'Proceedings of the 13th International Conference on Availability, Reliability and Security (ARES)', NULL, 326, NULL, NULL, NULL, NULL, NULL, '1--5', 13, 'ACM', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:04:05', '2022-01-11 07:55:28'),
(76, 7, 1, NULL, 2, '2021-08-01', 'Robust Android Malware Detection System Against Adversarial Attacks Using Q-Learning', 'Information Systems Frontiers', NULL, 329, NULL, '6.191', NULL, '23', '4', '867-882', 13, 'Springer', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:04:05', '2022-01-11 07:52:40'),
(89, 7, 1, NULL, 2, '2020-01-01', 'An overview of deep learning architecture of deep neural networks and autoencoders', 'Journal of Computational and Theoretical Nanoscience', NULL, 336, NULL, '0.358', NULL, '17', '1', '182--188', 13, 'American Scientific Publishers', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:13:11', '2022-01-21 08:25:23'),
(90, 8, 1, NULL, 2, '2019-06-26', 'Evolution of malware and its detection techniques', 'Information and Communication Technology for Sustainable Development', NULL, 336, NULL, NULL, NULL, NULL, NULL, '139--150', 13, 'Springer', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:13:11', '2022-01-11 08:02:18'),
(95, 8, 1, NULL, 2, '2018-12-06', 'Android malicious application classification using clustering', 'International Conference on Intelligent Systems Design and Applications (ISDA)', NULL, 337, NULL, NULL, NULL, NULL, NULL, '659--667', 13, 'Springer', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:15:05', '2022-01-11 07:57:23'),
(96, 8, 1, NULL, 2, '2020-12-11', 'Identification of Significant Permissions for Efficient Android Malware Detection', 'International Conference on Broadband Communications, Networks and Systems', NULL, 326, NULL, NULL, NULL, NULL, NULL, '33--52', 13, 'Springer', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:15:54', '2022-01-11 08:03:39'),
(97, 8, 1, NULL, 2, '2020-12-11', 'Detection of Malicious Android Applications: Classical Machine Learning vs. Deep Neural Network Integrated with Clustering', 'International Conference on Broadband Communications, Networks and Systems', NULL, 326, NULL, NULL, NULL, NULL, NULL, '109--128', 13, 'Springer', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:15:54', '2022-01-11 08:05:00'),
(98, 8, 1, NULL, 2, '2020-10-08', 'Deepintent: implicitintent based android ids with e2e deep learning architecture', '2020 IEEE 31st Annual International Symposium on Personal, Indoor and Mobile Radio Communications', NULL, 326, NULL, NULL, NULL, NULL, NULL, '1--6', 13, 'IEEE', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:15:54', '2022-01-11 08:23:18'),
(99, 7, 1, NULL, NULL, '2021-01-01', 'DRLDO: A novel DRL based De-ObfuscationSystem for Defense against Metamorphic Malware', 'arXiv preprint arXiv:2102.00898', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 13, NULL, NULL, 1, NULL, 'pub.bib', '2021-11-13 01:15:54', '2021-11-13 02:33:55'),
(100, 8, 1, NULL, 2, '2020-11-10', 'Value-Approximation based Deep Reinforcement Learning Techniques: An Overview', '2020 IEEE 5th International Conference on Computing Communication and Automation (ICCCA)', NULL, 336, NULL, NULL, NULL, NULL, NULL, '379--384', 13, 'IEEE', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:16:14', '2022-01-11 08:06:50'),
(101, 8, 1, NULL, 2, '2020-11-16', 'Assessment of the Relative Importance of different hyper-parameters of LSTM for an IDS', '2020 IEEE REGION 10 CONFERENCE (TENCON)', NULL, 337, NULL, NULL, NULL, NULL, NULL, '414--419', 13, 'IEEE', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:16:14', '2022-01-11 08:07:54'),
(102, 8, 1, NULL, 2, '2020-01-01', 'Detection of Fake News Based on Domain Analysis and Social Network Psychology', 'International Conference on Hybrid Intelligent Systems', NULL, 337, NULL, NULL, NULL, NULL, NULL, '433--443', 13, NULL, NULL, 0, NULL, 'pub.bib', '2021-11-13 01:16:14', '2021-11-13 02:30:41'),
(103, 7, 1, NULL, NULL, '2022-01-01', 'Policy-Approximation Based Deep Reinforcement Learning Techniques: An Overview', 'Information and Communication Technology for Competitive Strategies (ICTCS 2020)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '493--507', 13, 'Springer', NULL, 1, NULL, 'pub.bib', '2021-11-13 01:22:02', '2021-11-13 01:22:02'),
(104, 8, 1, NULL, 2, '2021-10-04', 'DRo: A data-scarce mechanism to revolutionize the performance of DL-based Security Systems', '2021 IEEE 46th Conference on Local Computer Networks (LCN)', NULL, 332, NULL, NULL, NULL, NULL, NULL, '581--588', 13, 'IEEE', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:22:02', '2022-01-11 08:14:42'),
(105, 8, 1, NULL, NULL, '2021-01-01', 'DRo: A data-scarce mechanism to revolutionize the performance of DL-based Security Systems', '2021 IEEE 46th Conference on Local Computer Networks (LCN)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '581--588', 13, NULL, NULL, 1, NULL, 'pub.bib', '2021-11-13 01:22:02', '2021-11-13 02:35:14'),
(106, 8, 1, NULL, NULL, '2021-01-01', 'DRo: A data-scarce mechanism to revolutionize the performance of DL-based Security Systems', '2021 IEEE 46th Conference on Local Computer Networks (LCN)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '581--588', 13, NULL, NULL, 1, NULL, 'pub.bib', '2021-11-13 01:22:02', '2021-11-13 02:35:22'),
(107, 8, 1, NULL, NULL, '2021-01-01', 'DRo: A data-scarce mechanism to revolutionize the performance of DL-based Security Systems', '2021 IEEE 46th Conference on Local Computer Networks (LCN)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '581--588', 13, NULL, NULL, 1, NULL, 'pub.bib', '2021-11-13 01:22:02', '2021-11-13 02:35:24'),
(108, 8, 1, NULL, NULL, '2021-01-01', 'DRo: A data-scarce mechanism to revolutionize the performance of DL-based Security Systems', '2021 IEEE 46th Conference on Local Computer Networks (LCN)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '581--588', 13, NULL, NULL, 1, NULL, 'pub.bib', '2021-11-13 01:22:02', '2021-11-13 02:35:27'),
(109, 8, 1, NULL, NULL, '2021-01-01', 'DRo: A data-scarce mechanism to revolutionize the performance of DL-based Security Systems', '2021 IEEE 46th Conference on Local Computer Networks (LCN)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '581--588', 13, NULL, NULL, 1, NULL, 'pub.bib', '2021-11-13 01:22:02', '2021-11-13 02:35:36'),
(110, 8, 1, NULL, 2, '2021-07-18', 'Identification of Adversarial Android Intents using Reinforcement Learning', '2021 International Joint Conference on Neural Networks (IJCNN)', NULL, 332, NULL, NULL, NULL, NULL, NULL, '1--8', 13, 'IEEE', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:28:11', '2022-01-11 08:15:59'),
(111, 8, 1, 3, 2, '2021-05-18', 'Are Android Malware Detection Models Adversarially Robust?', 'Proceedings of the 20th International Conference on Information Processing in Sensor Networks', NULL, 321, NULL, NULL, NULL, NULL, NULL, '408--409', 13, 'ACM', NULL, 0, NULL, 'pub.bib', '2021-11-13 01:28:11', '2022-01-11 08:17:27'),
(112, 8, 1, 1, 2, '2021-01-01', 'Designing Adversarial Robust and Explainable Malware Detection System for Android based Smartphones: PhD Forum Abstract', 'Proceedings of the 20th International Conference on Information Processing in Sensor Networks (co-located with CPS-IoT Week 2021)', NULL, 321, NULL, NULL, NULL, NULL, NULL, '412--413', 13, NULL, NULL, 0, NULL, 'pub.bib', '2021-11-13 01:28:11', '2021-11-13 02:36:25'),
(113, 8, 1, NULL, 2, '2020-01-01', 'Movie Recommendation System Addressing Changes in User Preferences with Time', 'International Conference on Hybrid Intelligent Systems', NULL, 337, NULL, NULL, NULL, NULL, NULL, '473--483', 13, NULL, NULL, 0, NULL, 'pub.bib', '2021-11-13 01:28:11', '2021-11-13 02:31:32'),
(114, 8, 1, 3, 2, '2020-11-16', 'How robust are malware detection models for Android smartphones against adversarial attacks?', 'Proceedings of the 18th Conference on Embedded Networked Sensor Systems', NULL, 321, NULL, NULL, NULL, NULL, NULL, '683--684', 13, NULL, NULL, 0, NULL, 'pub.bib', '2021-11-13 01:28:11', '2022-01-11 08:09:33'),
(115, 8, 1, 1, 2, '2020-01-01', 'Adversarial attacks on malware detection models for smartphones using reinforcement learning: PhD forum abstract', 'Proceedings of the 18th Conference on Embedded Networked Sensor Systems', NULL, 321, NULL, NULL, NULL, NULL, NULL, '796--797', 13, NULL, NULL, 0, NULL, 'pub.bib', '2021-11-13 01:28:11', '2021-11-13 02:32:09'),
(116, 8, 1, NULL, 2, '2020-01-01', 'Socio-Cellular Network: A Novel Social Assisted Cellular Communication Paradigm', '2020 IEEE 91st Vehicular Technology Conference (VTC2020-Spring)', NULL, 326, NULL, NULL, NULL, NULL, NULL, '1--5', 13, NULL, NULL, 0, NULL, 'pub.bib', '2021-11-13 01:28:11', '2021-11-13 02:32:24'),
(117, 8, 1, NULL, 2, '2021-01-01', 'Recurring Verification of Interaction Authenticity within Bluetooth Networks', 'Proceedings of the 14th ACM Conference on Security and Privacy in Wireless and Mobile Networks', 'New York, NY, USA', 248, NULL, NULL, NULL, NULL, NULL, '192–203', 24, 'Association for Computing Machinery', NULL, 0, '10.1145/3448300.3468287', 'Travis2021Wisec.bib', '2021-11-13 01:47:53', '2022-02-10 01:46:01'),
(118, 7, 1, NULL, 2, '2021-02-01', 'DRLDO: A Novel DRL based De-obfuscation System for Defence Against Metamorphic Malware', 'Defence Science Journal', NULL, 328, NULL, '0.73', NULL, '71', '1', '55--65', 13, 'Defence Scientific Information & Documentation Centre', NULL, 0, NULL, 'pub.bib', '2021-11-13 02:43:08', '2022-01-11 07:49:18'),
(119, 8, 1, NULL, NULL, '2021-11-13', 'Emotion Recognition Using Multimodalities', 'Hybrid Intelligent Systems: 20th International Conference on Hybrid Intelligent Systems (HIS 2020), December 14--16, 2020', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '309', 13, NULL, NULL, 1, NULL, 'pub.bib', '2021-11-13 03:02:32', '2021-11-13 03:02:32'),
(120, 8, 1, NULL, NULL, '2021-11-13', 'Emotion Recognition Using Multimodalities', 'Hybrid Intelligent Systems: 20th International Conference on Hybrid Intelligent Systems (HIS 2020), December 14--16, 2020', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '309', 13, NULL, NULL, 1, NULL, 'pub.bib', '2021-11-13 03:05:16', '2021-11-13 03:10:18'),
(124, 8, 1, NULL, 2, '2021-07-27', 'Policy-Approximation Based Deep Reinforcement Learning Techniques: An Overview', 'Information and Communication Technology for Competitive Strategies (ICTCS 2020)', NULL, 336, NULL, NULL, NULL, NULL, NULL, '493--507', 13, 'Springer', NULL, 0, NULL, 'pub.bib', '2021-11-13 03:15:47', '2022-01-11 08:10:55'),
(125, 8, 1, NULL, 2, '2021-07-18', 'ADVERSARIALuscator: An Adversarial-DRL based Obfuscator and Metamorphic Malware Swarm Generator', '2021 International Joint Conference on Neural Networks (IJCNN)', NULL, 332, NULL, NULL, NULL, NULL, NULL, '1--9', 13, 'IEEE', NULL, 0, NULL, 'pub.bib', '2021-11-13 03:15:47', '2022-01-11 08:18:33'),
(126, 8, 1, NULL, 2, '2021-07-18', 'LSTM Hyper-Parameter Selection for Malware Detection: Interaction Effects and Hierarchical Selection Approach', '2021 International Joint Conference on Neural Networks (IJCNN)', NULL, 332, NULL, NULL, NULL, NULL, NULL, '1--9', 13, 'IEEE', NULL, 0, NULL, 'pub.bib', '2021-11-13 03:15:47', '2022-01-11 08:18:59'),
(127, 7, 1, NULL, 2, '2021-01-01', 'Robust Malware Detection Models: Learning from Adversarial Attacks and Defenses', 'Forensic Science International: Digital Investigation', NULL, 328, NULL, '2.395', NULL, '37', NULL, '301183', 13, 'Elsevier', NULL, 0, NULL, 'pub.bib', '2021-11-13 03:15:47', '2022-01-11 07:44:08'),
(128, 8, 1, NULL, 2, '2021-01-01', 'Designing Adversarial Attack and Defence for Robust Android Malware Detection Models', '2021 51st Annual IEEE/IFIP International Conference on Dependable Systems and Networks', NULL, 332, NULL, NULL, NULL, NULL, NULL, '29--32', 13, 'IEEE', NULL, 0, NULL, 'pub.bib', '2021-11-13 03:15:47', '2022-01-11 08:20:00'),
(129, 8, 1, 1, 2, '2021-03-22', 'Towards Robust Android Malware Detection Models using Adversarial Learning', '2021 IEEE International Conference on Pervasive Computing and Communications Workshops and other Affiliated Events', NULL, 332, NULL, NULL, NULL, NULL, NULL, '424--425', 13, 'IEEE', NULL, 0, NULL, 'pub.bib', '2021-11-13 03:15:47', '2022-01-11 08:21:08'),
(130, 8, 1, 1, 2, '2021-07-29', 'Virtual CS Education in India: Challenges and Opportunities', 'International Conference on Best Innovative Teaching Strategies, ICON-BITS 2021', 'India', 248, 19, NULL, NULL, NULL, NULL, NULL, 28, 'Macmillan', NULL, 0, NULL, NULL, '2021-11-14 09:40:58', '2021-11-14 09:40:58'),
(131, 8, 1, NULL, 2, '2021-01-01', 'Using Program Synthesis and Inductive Logic Programming to solve Bongard Problems', '10th International Workshop on Approaches and Applications of Inductive Programming (AAIP)', NULL, 248, NULL, NULL, NULL, NULL, NULL, NULL, 14, NULL, NULL, 0, NULL, 'td_pub_2021.bib', '2021-11-14 23:02:17', '2022-02-10 01:35:32'),
(132, 8, 1, NULL, 2, '2021-01-01', 'Empirical Study of Data-Free Iterative Knowledge Distillation', 'Artificial Neural Networks and Machine Learning -- ICANN', 'Cham', 326, NULL, NULL, NULL, NULL, NULL, '546--557', 14, 'Springer International Publishing', NULL, 0, NULL, 'td_pub_2021.bib', '2021-11-14 23:02:17', '2022-02-10 01:35:22'),
(133, 7, 1, NULL, 2, '2021-01-01', 'How to Tell Deep Neural Networks What We Know: A Review of Methods for Inclusion of Domain-Knowledge', 'arXiv', NULL, 329, NULL, NULL, NULL, NULL, NULL, NULL, 14, NULL, NULL, 0, NULL, 'td_pub_2021.bib', '2021-11-14 23:02:17', '2022-02-10 01:24:29'),
(134, 8, 1, NULL, 2, '2021-01-01', 'Using Domain-Knowledge to Assist Lead Discovery in Early-Stage Drug Design', 'bioRxiv', NULL, 326, NULL, NULL, NULL, NULL, NULL, NULL, 14, 'Cold Spring Harbor Laboratory', NULL, 0, '10.1101/2021.07.09.451519', 'td_pub_2021.bib', '2021-11-14 23:02:17', '2022-02-10 01:26:43'),
(135, 7, 1, NULL, 2, '2021-01-01', 'Inclusion of domain-knowledge into GNNs using mode-directed inverse entailment', 'arXiv', NULL, 329, NULL, NULL, NULL, NULL, NULL, NULL, 14, NULL, NULL, 0, NULL, 'td_pub_2021.bib', '2021-11-14 23:02:17', '2022-02-10 01:27:43'),
(136, 8, 1, NULL, 2, '2021-01-01', 'Superpixel-based domain-knowledge infusion in computer vision', 'arXiv', NULL, 248, NULL, NULL, NULL, NULL, NULL, NULL, 14, NULL, NULL, 0, NULL, 'td_pub_2021.bib', '2021-11-14 23:02:17', '2022-02-10 01:28:35'),
(137, 7, 1, NULL, 2, '2021-01-01', 'Incorporating domain knowledge into deep neural networks', 'arXiv', NULL, 248, NULL, NULL, NULL, NULL, NULL, NULL, 14, NULL, NULL, 0, NULL, 'td_pub_2021.bib', '2021-11-14 23:02:17', '2022-02-10 01:30:06'),
(138, 7, 1, NULL, 2, '2021-01-01', 'Incorporating symbolic domain knowledge into graph neural networks', 'Machine Learning', NULL, 329, NULL, NULL, NULL, '110', NULL, '1609--1636', 14, NULL, NULL, 0, '10.1007/s10994-021-05966-z', 'td_pub_2021.bib', '2021-11-14 23:02:17', '2022-02-10 01:30:48'),
(139, 8, 1, NULL, 2, '2021-01-01', '{LRG} at {S}em{E}val-2021 Task 4: Improving Reading Comprehension with Abstract Words using Augmentation, Linguistic Features and Voting', 'Proceedings of the 15th International Workshop on Semantic Evaluation (SemEval-2021)', 'Online', 248, NULL, NULL, NULL, NULL, NULL, '189--198', 14, 'Association for Computational Linguistics', NULL, 0, NULL, 'td_pub_2021.bib', '2021-11-14 23:02:17', '2022-02-10 01:34:50'),
(140, 7, 1, NULL, 2, '2021-01-01', 'Performance evaluation of deep neural networks for forecasting time-series with multiple structural breaks and high volatility', 'CAAI Transactions on Intelligence Technology', NULL, 329, NULL, NULL, NULL, 'n/a', NULL, NULL, 14, NULL, NULL, 0, 'https://doi.org/10.1049/cit2.12002', 'td_pub_2021.bib', '2021-11-14 23:02:17', '2022-02-10 01:31:22'),
(141, 8, 1, NULL, 2, '2020-09-10', 'DOOM: a novel adversarial-DRL-based op-code level metamorphic malware obfuscator for the enhancement of IDS', 'Adjunct Proceedings of the 2020 ACM International Joint Conference on Pervasive and Ubiquitous Computing and Proceedings of the 2020 ACM International Symposium on Wearable Computers', NULL, 321, NULL, NULL, NULL, NULL, NULL, '131--134', 7, 'ACM', NULL, 0, NULL, 'publication.bib', '2021-11-15 01:50:19', '2022-01-11 08:12:21'),
(142, 7, 1, NULL, 2, '2021-11-15', 'VibeRing: Using vibrations from a smart ring as an out-of-band channel for sharing secret keys', 'Pervasive and Mobile Computing', NULL, 329, 9, '3.453', NULL, NULL, NULL, '101505', 24, 'Elsevier', NULL, 0, 'https://doi.org/10.1016/j.pmcj.2021.101505', 'S1574119221001309.bi', '2021-11-15 03:36:01', '2022-02-10 01:46:15'),
(143, 7, 1, NULL, 2, '2020-01-01', 'Annapurna: An automated smartwatch-based eating detection and food journaling system', 'Pervasive and Mobile Computing', NULL, NULL, NULL, NULL, NULL, '68', NULL, NULL, 24, 'Elsevier', NULL, 0, '10.1016/j.pmcj.2020.101259', 'Sen2020Annapurna.bib', '2021-11-15 03:47:06', '2021-11-16 00:44:04'),
(144, 8, 1, NULL, 2, '2020-01-01', 'VibroScale: Turning Your Smartphone into a Weighing Scale', 'International Joint Conference on Pervasive and Ubiquitous Computing and International Symposium on Wearable Computers', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, 'Association for Computing Machinery, Inc', NULL, 0, '10.1145/3410530.3414397', 'Zhang2020VibroScale.', '2021-11-15 03:49:22', '2021-11-16 00:44:14'),
(145, 8, 1, NULL, 2, '2020-01-01', 'VibeRing: Using vibrations from a smart ring as an out-of-band channel for sharing secret keys', 'Proceedings of the International Conference on the Internet of Things', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, 0, '10.1145/3410992.3410995', 'Sen2020Vibering.bib', '2021-11-15 04:26:21', '2021-11-16 00:44:25'),
(146, 8, 1, NULL, 2, '2020-01-01', 'Measuring children\'s eating behavior with a wearable device', 'International Conference on Healthcare Informatics', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, 'IEEE', NULL, 0, '10.1109/ICHI48887.2020.9374304', 'Bi2020Children.bib', '2021-11-15 04:29:08', '2021-11-16 00:44:31'),
(147, 7, 1, NULL, 2, '2020-01-01', 'NeckSense: A Multi-Sensor Necklace for Detecting Eating Activities in Free-Living Conditions', 'Interactive, Mobile, Wearable and Ubiquitous Technologies', NULL, NULL, NULL, NULL, NULL, '37', NULL, NULL, 24, 'Association for Computing Machinery (ACM)', NULL, 0, '10.1145/3397313', 'Zhang2020NeckSense.b', '2021-11-15 08:43:21', '2021-11-16 00:44:52'),
(148, 8, 1, NULL, 2, '2019-01-01', 'Using Vibrations from a SmartRing as an Out-of-band Channel for Sharing Secret Keys', 'International Joint Conference on Pervasive and Ubiquitous Computing and International Symposium on Wearable Computers', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '198--201', 24, 'Association for Computing Machinery, Inc', NULL, 0, '10.1145/3341162.3343818', 'Sen2019Vibering.bib', '2021-11-15 08:44:12', '2021-11-16 00:43:45'),
(149, 7, 1, NULL, 2, '2020-01-01', 'Evaluating the Reproducibility of Physiological Stress Detection Models', 'Proc. ACM Interact. Mob. Wearable Ubiquitous Technol.', 'New York, NY, USA', NULL, NULL, NULL, NULL, '4', NULL, NULL, 24, 'Association for Computing Machinery', NULL, 0, '10.1145/3432220', 'Mishra2020Evaluating', '2021-11-15 08:46:43', '2021-11-16 00:45:04'),
(150, 8, 1, NULL, 2, '2020-01-01', 'Towards Battery-Free Body Sensor Networks', 'Proceedings of the 8th International Workshop on Energy Harvesting and Energy-Neutral Sensing Systems', 'New York, NY, USA', NULL, NULL, NULL, NULL, NULL, NULL, '79–81', 24, 'Association for Computing Machinery', NULL, 0, '10.1145/3417308.3430275', 'Sen2020Battery.bib', '2021-11-15 08:48:03', '2021-11-16 00:45:12'),
(151, 7, 1, NULL, 2, '2022-01-01', 'Phase entrainment by periodic stimuli in silico: A quantitative study', 'Neurocomputing', 'Online', NULL, 17, '5.7999', NULL, '469', NULL, '273-288', 7, 'Elsevier', NULL, 0, 'https://doi.org/10.1016/j.neucom.2021.10.077', 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2022-12-29 01:10:33'),
(152, 7, 1, NULL, 2, '2021-01-01', 'Book Review: Ranking: The Unwritten Rules of the Social Game We All Play', 'Frontiers in Psychology', NULL, 248, NULL, NULL, NULL, '12', NULL, '776', 7, NULL, NULL, 0, '10.3389/fpsyg.2021.605886', 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2022-02-10 01:37:21'),
(153, 8, 1, NULL, 2, '2021-01-01', 'Quantifying Synchronization in a Biologically Inspired Neural Network', '2021 International Joint Conference on Neural Networks (IJCNN)', NULL, 248, NULL, NULL, NULL, NULL, NULL, '1-6', 7, NULL, NULL, 0, '10.1109/IJCNN52387.2021.9533414', 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2022-02-10 01:37:26'),
(154, 8, 1, NULL, 2, '2021-01-01', 'On- and Off-centre Pathways in a Retino-Geniculate Spiking Neural Network on SpiNNaker', '2021 10th International IEEE/EMBS Conference on Neural Engineering (NER)', NULL, 248, NULL, NULL, NULL, NULL, NULL, '461-464', 7, NULL, NULL, 0, '10.1109/NER49283.2021.9441462', 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2022-02-10 01:37:32'),
(155, 8, 1, NULL, 2, '2021-01-01', 'A Reduced-Scale Cortical Network with Izhikevich\'s Neurons on SpiNNaker', '2021 International Joint Conference on Neural Networks (IJCNN)', NULL, 248, NULL, NULL, NULL, NULL, NULL, '1-8', 7, NULL, NULL, 0, '10.1109/IJCNN52387.2021.9534244', 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2022-02-10 01:38:03'),
(156, 8, 1, NULL, 2, '2021-01-01', 'Foveal-pit inspired filtering of DVS spike response', '2021 55th Annual Conference on Information Sciences and Systems (CISS)', NULL, 248, NULL, NULL, NULL, NULL, NULL, '1-6', 7, NULL, NULL, 0, '10.1109/CISS50987.2021.9400245', 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2022-02-10 01:38:11'),
(157, 8, 1, NULL, 2, '2021-01-01', 'Study of the thalamocortical dynamics in the visual pathway using in silico model', 'Bernstein Conference 2021 (Abstract)', NULL, 248, NULL, NULL, NULL, NULL, NULL, 'P029', 7, NULL, NULL, 0, '10.12751/nncn.bc2021.p029', 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2022-02-10 01:38:21'),
(158, 8, 1, NULL, 2, '2021-01-01', 'Sparse Distributed Memory using Spiking Neural Networks on Nengo', 'Bernstein Conference 2021 (Abstract)  ArXiv https://arxiv.org/abs/2109.03111', NULL, 248, NULL, NULL, NULL, NULL, NULL, 'P132', 7, NULL, NULL, 0, '10.12751/nncn.bc2021.p132', 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2022-02-10 01:38:26'),
(159, 8, 1, NULL, 2, '2021-01-01', 'The State of Play in Diversity and Inclusion in STEM – a Review of Empirical Evidence, Focusing on Gender', '20th IFAC Conference on Technology, Culture and International Stability (TECIS)', NULL, 248, NULL, NULL, NULL, '54', NULL, '570-575', 7, NULL, NULL, 0, '10.1016/j.ifacol.2021.10.510', 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2022-02-10 01:38:32'),
(160, 8, 1, NULL, 2, '2021-01-01', 'Bayesian Optimisation for a Biologically Inspired Population Neural Network', 'arXiv', NULL, 248, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, 'https://arxiv.org/abs/2104.05989', 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2022-02-10 01:38:38'),
(161, 7, 1, NULL, NULL, '2021-01-01', 'Sparse Distributed Memory using Spiking Neural Networks on Nengo', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 1, NULL, 'BSB-ResOutput-2021.b', '2021-11-16 03:44:19', '2021-11-17 00:15:07'),
(162, 8, 1, NULL, 2, '2014-01-01', 'Putting ‘pressure\' on mobile authentication', 'International Conference on Mobile Computing and Ubiquitous Networking', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '56--61', 24, 'IEEE', NULL, 0, '10.1109/ICMU.2014.6799058', 'Until2014.bib', '2021-11-16 04:17:06', '2021-11-16 06:02:29'),
(163, 8, 1, NULL, 2, '2014-01-01', 'Cloud-based query evaluation for energy-efficient mobile sensing', 'International Conference on Mobile Data Management', NULL, 326, NULL, NULL, NULL, '1', NULL, NULL, 24, NULL, NULL, 0, '10.1109/MDM.2014.33', 'Until2014.bib', '2021-11-16 04:17:06', '2021-11-16 06:03:46'),
(164, 8, 1, NULL, 2, '2014-01-01', 'Accommodating user diversity for in-store shopping behavior recognition', 'International Symposium on Wearable Computers', 'New York, New York, USA', NULL, NULL, NULL, NULL, NULL, NULL, '11--14', 24, 'ACM Press', NULL, 0, '10.1145/2634317.2634338', 'Until2014.bib', '2021-11-16 04:17:06', '2021-11-16 05:01:51'),
(165, 8, 1, NULL, 2, '2012-01-01', 'The case for cloud-enabled mobile sensing services', 'Proceedings of MCC workshop on Mobile cloud computing', 'New York, New York, USA', NULL, NULL, NULL, NULL, NULL, NULL, '53', 24, 'ACM Press', NULL, 0, '10.1145/2342509.2342521', 'Until2014.bib', '2021-11-16 04:17:06', '2021-11-16 04:31:16'),
(166, 8, 1, NULL, 2, '2009-01-01', 'ISense: A wireless sensor network based conference room management system', 'Workshop on Embedded Sensing Systems for Energy-Efficiency in Buildings', 'New York, New York, USA', NULL, NULL, NULL, NULL, NULL, NULL, '37--42', 24, 'ACM Press', NULL, 0, '10.1145/1810279.1810288', 'Until2014.bib', '2021-11-16 04:17:06', '2021-11-16 04:30:30'),
(167, 8, 1, NULL, 1, '2007-01-01', 'Random Walk on Random Graph based Outlier Detection in Wireless Sensor Networks', 'International Conference on Wireless Communication and Sensor Networks', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '45--49', 24, 'IEEE', NULL, 0, '10.1109/WCSN.2007.4475745', 'Until2014.bib', '2021-11-16 04:17:06', '2021-11-16 04:29:15'),
(168, 8, 1, NULL, 2, '2017-01-01', 'Inferring smartphone keypress via smartwatch inertial sensing', 'International Conference on Pervasive Computing and Communications Workshops', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, 0, '10.1109/PERCOMW.2017.7917646', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-16 04:45:55'),
(169, 7, 1, NULL, 2, '2017-01-01', 'Cloud-based query evaluation for energy-efficient mobile sensing', 'Pervasive and Mobile Computing', NULL, NULL, NULL, NULL, NULL, '38', NULL, '257--274', 24, NULL, NULL, 0, '10.1016/j.pmcj.2016.12.005', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-16 04:45:41'),
(170, 8, 1, NULL, 2, '2017-01-01', 'Experiences in Building a Real-World Eating Recogniser', 'International on Workshop on Physical Analytics', 'New York, New York, USA', NULL, NULL, NULL, NULL, NULL, NULL, '7--12', 24, 'ACM Press', NULL, 0, '10.1145/3092305.3092306', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-16 04:45:28'),
(171, 8, 1, NULL, 2, '2016-01-01', 'Pervasive physical analytics using multi-modal sensing', 'International Conference on Communication Systems and Networks', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, 0, '10.1109/COMSNETS.2016.7439998', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-16 04:46:52'),
(172, 8, 1, NULL, 2, '2016-01-01', 'IoT+Small Data: Transforming in-store shopping analytics {\\&} services', 'International Conference on Communication Systems and Networks', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, 0, '10.1109/COMSNETS.2016.7439946', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-16 04:46:40'),
(173, 8, 1, NULL, 2, '2016-01-01', 'Did you take a break today? Detecting playing foosball using your smartwatch', 'International Conference on Pervasive Computing and Communication Workshops', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, 0, '10.1109/PERCOMW.2016.7457165', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-16 04:46:19'),
(174, 8, 1, NULL, 2, '2016-01-01', 'Demo: Smartwatch based food diary & eating analytics', 'Annual International Conference on Mobile Systems, Applications, and Services', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, 0, '10.1145/2938559.2938569', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-17 04:41:31'),
(175, 8, 1, NULL, 2, '2016-01-01', 'Demo: Smartwatch based shopping gesture recognition}', 'International Conference on Mobile Systems, Applications, and Services', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, 0, '10.1145/2938559.2938572', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-17 04:42:11'),
(176, 7, 1, NULL, 2, '2016-01-01', 'MobiSys 2016', 'Pervasive Computing', NULL, NULL, NULL, NULL, NULL, '15', NULL, '85--88', 24, NULL, NULL, 0, '10.1109/MPRV.2016.62', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-17 04:43:26'),
(177, 8, 1, NULL, 2, '2015-01-01', 'Using infrastructure-provided context filters for efficient fine-grained activity sensing', 'International Conference on Pervasive Computing and Communications', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '87--94', 24, 'IEEE', NULL, 0, '10.1109/PERCOM.2015.7146513', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-16 05:01:39'),
(178, 8, 1, NULL, 2, '2015-01-01', 'The case for smartwatch-based diet monitoring', 'International Conference on Pervasive Computing and Communication Workshops', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '585--590', 24, 'IEEE', NULL, 0, '10.1109/PERCOMW.2015.7134103', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-16 04:47:18'),
(179, 8, 1, NULL, 2, '2015-01-01', 'Opportunities and challenges in multi-modal sensing for regular lifestyle tracking', 'International Conference on Pervasive Computing and Communication Workshops', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '225--227', 24, 'IEEE', NULL, 0, '10.1109/PERCOMW.2015.7134030', '2015-2017.bib', '2021-11-16 04:20:11', '2021-11-16 04:47:01'),
(180, 7, 1, NULL, 2, '2020-01-01', 'Continuous Detection of Physiological Stress with Commodity Hardware', 'ACM Transactions on Computing for Healthcare', NULL, NULL, NULL, NULL, NULL, '1', NULL, NULL, 24, NULL, NULL, 0, '10.1145/3361562', '2018-2019.bib', '2021-11-16 04:26:55', '2021-11-17 04:45:39'),
(181, 8, 1, NULL, 2, '2018-01-01', 'I4S: Capturing shopper\'s in-store interactions', 'International Symposium on Wearable Computers', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '156--159', 24, 'Association for Computing Machinery', NULL, 0, '10.1145/3267242.3267259', '2018-2019.bib', '2021-11-16 04:26:55', '2021-11-16 04:44:20'),
(182, 8, 1, NULL, 2, '2018-01-01', 'Smart monitoring via participatory BLE relaying', 'International Conference on Communication Systems and Networks', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, 'IEEE', NULL, 0, '10.1109/COMSNETS.2018.8328213', '2018-2019.bib', '2021-11-16 04:26:55', '2021-11-16 04:44:05'),
(183, 8, 1, NULL, 2, '2018-01-01', 'The case for a commodity hardware solution for stress detection', 'International Joint Conference on Pervasive and Ubiquitous Computing and International Symposium on Wearable Computers', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1717--1728', 24, 'ACM', NULL, 0, '10.1145/3267305.3267538', '2018-2019.bib', '2021-11-16 04:26:55', '2021-11-16 04:43:48'),
(184, 7, 1, NULL, 2, '2018-01-01', 'Auracle: Detecting Eating Episodes with an Ear-mounted Sensor', 'In Interactive, Mobile, Wearable and Ubiquitous Technologies (IMWUT)', NULL, NULL, NULL, NULL, NULL, '2', NULL, '1--27', 24, 'Association for Computing Machinery (ACM)', NULL, 0, '10.1145/3264902', '2018-2019.bib', '2021-11-16 04:26:55', '2021-11-16 04:43:29'),
(185, 8, 1, NULL, 2, '2018-01-01', 'Annapurna: Building a Real-World Smartwatch-Based Automated Food Journal', 'International Symposium on a World of Wireless, Mobile and Multimedia Networks', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 24, NULL, NULL, 0, '10.1109/WoWMoM.2018.8449755', '2018-2019.bib', '2021-11-16 04:26:55', '2021-11-16 04:42:57'),
(186, 7, 1, NULL, 2, '2021-01-01', 'AdaSwarm: Augmenting gradient-based optimizers in Deep Learning with Swarm Intelligence', 'IEEE Transactions on Emerging Topics in Computational Intelligence', NULL, 329, NULL, NULL, NULL, NULL, NULL, NULL, 7, 'IEEE', NULL, 0, NULL, NULL, '2021-11-16 04:40:53', '2022-02-10 01:47:29'),
(187, 7, 1, NULL, 2, '2021-01-01', 'Expert Habitat: A Colonization Conjecture for Exoplanetary Habitability via penalized multi-objective optimization based candidate validation', 'European Physical Journal-Special Topics', NULL, 330, NULL, NULL, NULL, NULL, NULL, NULL, 7, 'Springer', NULL, 0, NULL, NULL, '2021-11-16 04:48:39', '2022-02-10 01:47:46');
INSERT INTO `pubhdrs` (`id`, `categoryid`, `authortypeid`, `articletypeid`, `nationality`, `pubdate`, `title`, `confname`, `place`, `rankingid`, `broadareaid`, `impactfactor`, `description`, `volume`, `issue`, `pp`, `userid`, `publisher`, `note`, `deleted`, `digitallibrary`, `bibtexfile`, `created_at`, `updated_at`) VALUES
(188, 7, 1, NULL, 2, '2021-01-01', 'Beginning with machine learning: a comprehensive primer', 'The European Physical Journal Special Topics', NULL, 330, NULL, NULL, NULL, NULL, NULL, '1--82', 7, 'Springer Berlin Heidelberg', NULL, 0, NULL, NULL, '2021-11-16 04:52:50', '2022-02-10 01:48:06'),
(189, 7, 1, NULL, 2, '2021-01-01', 'Estimation and Applications of Quantiles in Deep Binary Classification', 'IEEE Transactions on Artificial Intelligence.', NULL, 329, NULL, NULL, NULL, NULL, NULL, NULL, 7, 'IEEE', NULL, 0, NULL, NULL, '2021-11-16 05:00:34', '2022-02-10 01:48:19'),
(190, 7, 1, NULL, 2, '2021-01-01', 'LipGene: Lipschitz continuity guided adaptive learning rates for fast convergence on Microarray Expression Data Sets', 'IEEE/ACM Transactions on Computational Biology and Bioinformatics', NULL, 329, NULL, NULL, NULL, NULL, NULL, NULL, 7, 'IEEE/ACM', NULL, 0, NULL, NULL, '2021-11-16 05:18:35', '2022-02-10 01:49:26'),
(191, 7, 1, NULL, 2, '2021-01-01', 'Measure or infer? Role of modeling and machine learning in modern astronomy', NULL, NULL, 330, NULL, NULL, NULL, NULL, NULL, NULL, 7, 'Springer Berlin Heidelberg', NULL, 0, NULL, NULL, '2021-11-16 05:20:08', '2022-02-10 01:49:42'),
(192, 7, 1, NULL, 2, '2021-01-01', 'ALIS: A novel metric in lineage-independent evaluation of scholars', 'Journal of Information Science', NULL, 329, NULL, NULL, NULL, NULL, NULL, NULL, 7, 'SAGE Publications Sage UK: London, England', NULL, 0, NULL, NULL, '2021-11-16 23:10:57', '2022-02-10 01:50:14'),
(193, 8, 1, NULL, 2, '2021-01-01', 'LipARELU: ARELU Networks aided by Lipschitz Acceleration', '2021 International Joint Conference on Neural Networks (IJCNN)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1--8', 7, 'IEEE', NULL, 1, NULL, NULL, '2021-11-16 23:14:24', '2021-11-16 23:18:28'),
(194, 8, 1, NULL, 2, '2021-01-01', 'DiffAct: A Unifying Framework for Activation Functions', '2021 International Joint Conference on Neural Networks (IJCNN)', NULL, 332, NULL, NULL, NULL, NULL, NULL, '1--8', 7, 'IEEE', NULL, 0, NULL, NULL, '2021-11-16 23:21:54', '2022-02-10 01:51:27'),
(195, 8, 1, NULL, 2, '2021-01-01', 'Semantic Influence Score: Tracing Beautiful Minds Through Knowledge Diffusion and Derivative Works', 'International Conference on Database and Expert Systems Applications', NULL, 326, NULL, NULL, NULL, NULL, NULL, '106--115', 7, 'Springer, Cham', NULL, 0, NULL, NULL, '2021-11-16 23:27:41', '2022-02-10 01:51:42'),
(196, 8, 1, NULL, 2, '2021-01-01', 'Implementation of Neural Network Regression Model for Faster Redshift Analysis on Cloud-Based Spark Platform', 'International Conference on Industrial, Engineering and Other Applications of Applied Intelligent Systems', NULL, 326, NULL, NULL, NULL, NULL, NULL, '591--602', 7, 'Springer, Cham', NULL, 0, NULL, NULL, '2021-11-16 23:29:46', '2022-02-10 01:52:18'),
(197, 8, 1, NULL, 2, '2021-01-01', 'd-BTAI: The Dynamic-Binary Tree Based Anomaly Identification Algorithm for Industrial Systems', 'International Conference on Industrial, Engineering and Other Applications of Applied Intelligent Systems', NULL, 326, NULL, NULL, NULL, NULL, NULL, '519--532', 7, 'Springer, Cham', NULL, 0, NULL, NULL, '2021-11-16 23:31:52', '2022-02-10 01:52:47'),
(198, 8, 1, 3, 2, '2020-07-08', 'ECG Signal Analysis on an Embedded Device for Sleep Apnea Detection', 'International Conference on Image and Signal Processing\r\n\r\nICISP 2020: Image and Signal Processing', NULL, NULL, NULL, NULL, NULL, 'LNCS, volume 12119', NULL, '377-384', 10, NULL, NULL, 0, NULL, NULL, '2021-11-17 04:34:24', '2021-11-17 04:34:24'),
(199, 8, 1, 3, 2, '2021-01-01', 'Network Community Analysis Based Enhancement of Online Discussion Forums', 'CODS COMAD 2021: 8th ACM IKDD CODS and 26th COMADJanuary 2021 Pages 438', NULL, 248, NULL, NULL, NULL, NULL, NULL, '438', 10, NULL, NULL, 0, 'https://doi.org/10.1145/3430984.3431066', NULL, '2021-11-17 04:38:50', '2022-02-10 01:39:29'),
(200, 7, 1, NULL, 2, '2021-01-01', 'A Spatiotemporal Deep Learning Approach for Automatic Pathological Gait Classification', 'Sensors', NULL, 330, NULL, NULL, NULL, '21', NULL, NULL, 31, NULL, NULL, 0, '10.3390/s21186202', 'sensors-v21-i18_2021', '2021-11-17 09:53:36', '2022-02-10 01:43:20'),
(201, 7, 1, NULL, 2, '2021-01-01', 'Remote Gait Type Classification System Using Markerless 2D Video', 'Diagnostics', NULL, 338, NULL, NULL, NULL, '11', NULL, NULL, 31, NULL, NULL, 0, '10.3390/diagnostics11101824', 'diagnostics-v11-i10_', '2021-11-17 09:54:12', '2022-02-10 01:42:51'),
(202, 8, 1, NULL, 2, '2021-01-01', 'Adapting Deep Neural Networks for Pedestrian-Detection to Low-Light Conditions Without Re-Training', 'Proceedings of the IEEE/CVF International Conference on Computer Vision', NULL, 321, NULL, NULL, NULL, NULL, NULL, '2535--2541', 31, NULL, NULL, 0, NULL, 'scholar.bib', '2021-11-17 09:59:32', '2022-02-10 01:43:36'),
(203, 7, 1, NULL, 2, '2021-01-01', 'Band Selection Using Dilation Distances', 'IEEE Geoscience and Remote Sensing Letters', NULL, 329, NULL, NULL, NULL, NULL, NULL, NULL, 15, 'IEEE', NULL, 0, NULL, 'publications.bib', '2022-01-08 05:17:27', '2022-02-10 01:44:36'),
(204, 7, 1, NULL, 2, '2021-01-01', 'A tutorial on applications of power watershed optimization to image processing', 'The European Physical Journal Special Topics', NULL, 330, NULL, NULL, NULL, '230', NULL, '2337--2361', 15, 'Springer', NULL, 0, NULL, 'publications.bib', '2022-01-08 05:17:27', '2022-02-10 01:45:04'),
(205, 7, 1, NULL, 2, '2021-08-08', 'Advances in Secure Knowledge Management in the Artificial Intelligence Era.', 'Information Systems Frontiers', NULL, 329, NULL, '6.191', NULL, '23', '4', '807', 12, 'Springer', NULL, 0, NULL, NULL, '2022-01-11 07:19:39', '2022-01-11 07:37:34'),
(206, 7, 1, NULL, 2, '2021-03-18', 'Privacy-Preserving Mutual Authentication and Key Agreement Scheme for Multi-Server Healthcare System', 'Information Systems Frontiers', NULL, 329, NULL, '6.191', NULL, '23', '4', '835', 12, 'Springer', NULL, 0, NULL, NULL, '2022-01-11 08:27:34', '2022-01-11 08:27:34'),
(207, 8, 1, NULL, 2, '2021-11-15', 'Are CNN based Malware Detection Models Robust? Developing Superior Models using Adversarial Attack and Defense', 'Proceedings of the 19th ACM Conference on Embedded Networked Sensor Systems', NULL, 321, NULL, NULL, NULL, NULL, NULL, '355-356', 12, 'ACM', NULL, 0, NULL, NULL, '2022-01-11 08:32:04', '2022-01-11 08:32:04'),
(208, 8, 1, NULL, 2, '2021-10-11', 'Duplicates in the Drebin Dataset and Reduction in the Accuracy of the Malware Detection Models', '26th IEEE Asia-Pacific Conference on Communications (APCC)', NULL, 337, NULL, NULL, NULL, NULL, NULL, '161-165', 12, 'IEEE', NULL, 0, NULL, NULL, '2022-01-11 08:35:24', '2022-01-11 08:35:24'),
(209, 8, 1, NULL, 2, '2019-09-09', 'Secure communication protocol for smart transportation based on vehicular cloud', 'ACM International Joint Conference on Pervasive and Ubiquitous Computing and Proceedings of the 2019 ACM International Symposium on Wearable Computers', NULL, 321, NULL, NULL, NULL, NULL, NULL, '372-376', 12, 'ACM', NULL, 0, NULL, NULL, '2022-01-11 08:39:37', '2022-01-11 08:39:37'),
(210, 8, 1, NULL, 2, '2020-03-06', 'Secure and Energy-Efficient Key-Agreement Protocol for Multi-Server Architecture', 'International Conference On Secure Knowledge Management In Artificial Intelligence Era', NULL, 336, NULL, NULL, NULL, NULL, NULL, '82-97', 12, 'Springer', NULL, 0, NULL, NULL, '2022-01-11 08:44:07', '2022-01-11 08:44:07'),
(211, 8, 1, NULL, 2, '2020-05-28', 'A Novel Spatial-Spectral Framework for the Classification of Hyperspectral Satellite Imagery', 'International Neural Networks Society, Proceedings of the 21st Engineering Applications of Neural Networks,', NULL, 248, NULL, NULL, NULL, '2', NULL, '227-239', 12, 'Springer', NULL, 0, NULL, NULL, '2022-01-11 08:50:22', '2022-01-11 08:50:22'),
(214, 7, 1, NULL, 1, '2022-10-04', 'xX', 'sSdas', 'asad', 321, 24, NULL, NULL, NULL, NULL, NULL, 7, 'asdad', NULL, 1, NULL, NULL, '2022-10-04 04:49:41', '2022-12-14 23:14:01'),
(215, 7, 1, NULL, 2, '2022-07-14', 'Accurate knowledge about feature diagnosticities leads to less preference for unidimensional strategy', 'Journal of Experimental Psychology : Learning, Memory and Cognition', 'USA', 329, 17, '3.14', NULL, NULL, NULL, NULL, 17, 'Journal of Experimental Psychology: Learning, Memory, and Cognition', NULL, 0, 'https://psycnet.apa.org/doi/10.1037/xlm0001151', NULL, '2022-12-12 04:14:55', '2022-12-12 04:14:55'),
(216, 8, 1, NULL, 1, '2022-01-03', 'A Comparative Study between ECG-based and PPG-based Heart Rate Monitors for Stress Detection', '2022 14th International Conference on COMmunication Systems & NETworkS workshop (COMSNETS workshop)', 'Bangalore', NULL, 18, NULL, NULL, NULL, NULL, NULL, 24, 'IEEE', NULL, 0, '10.1109/COMSNETS53615.2022.9668342', NULL, '2022-12-12 04:27:26', '2022-12-12 04:27:26'),
(217, 8, 1, 2, 2, '2022-03-21', 'ActiSight: Wearer Foreground Extraction Using a Practical RGB-Thermal Wearable', '2022 IEEE International Conference on Pervasive Computing and Communications (PerCom)', 'Pisa Italy', 321, 18, NULL, NULL, NULL, NULL, NULL, 24, 'IEEE', NULL, 0, '10.1109/PerCom53586.2022.9762385', NULL, '2022-12-12 04:30:38', '2022-12-12 04:30:38'),
(218, 7, 1, NULL, 2, '2022-09-05', 'ESW Edge Weights: Ensemble Stochastic Watershed Edge Weights for Hyperspectral Image Classification', 'IEEE Geoscience and Remote Sensing Letters', 'India', 329, 17, '5.3', NULL, '19', '1', '1-5', 25, 'IEEE', NULL, 0, '10.1109/LGRS.2022.3173793', NULL, '2022-12-12 22:09:14', '2022-12-12 22:09:14'),
(219, 7, 1, NULL, 2, '2022-08-01', 'Proposal of SVM Utility Kernel for Breast Cancer Survival\r\nEstimation', 'IEEE/ACM Transactions on Computational Biology and Bioinformatics', NULL, 329, NULL, '3.71', NULL, NULL, NULL, '35994556', 7, NULL, NULL, 0, '10.1109/TCBB.2022.3198879', NULL, '2022-12-14 23:35:20', '2022-12-14 23:35:20'),
(220, 7, 1, NULL, 2, '2022-09-01', 'Efficient Anomaly Identification in Temporal and Non-Temporal In-dustrial Data using Tree Based Approaches', 'Applied Intelligence', NULL, NULL, NULL, '5.44', NULL, NULL, NULL, NULL, 7, 'Springer Nature-I.F', NULL, 0, '10.1007/s10489-022-03940-3', NULL, '2022-12-14 23:39:48', '2022-12-14 23:39:48'),
(221, 7, 2, NULL, 2, '2022-09-01', 'Automated Surface Classification System using Vibration Patterns - A Case Study with Wheelchairs', 'The IEEE Transactions on Artificial Intelligence', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1 - 11', 7, NULL, NULL, 0, '10.1109/TAI.2022.3190828', NULL, '2022-12-14 23:44:24', '2022-12-14 23:44:24'),
(222, 7, 1, NULL, 2, '2022-07-01', 'CARE-Share: A Cooperative and Adaptive Ride Strategy for Distributed Taxi Ride Sharing', 'IEEE Transactions on Intelligent Transportation Systems', NULL, 329, NULL, '9.995', NULL, '23', '7', '7028-7044', 7, NULL, NULL, 0, '10.1109/TITS.2021.3066439', NULL, '2022-12-14 23:48:47', '2022-12-14 23:48:47'),
(223, 7, 1, NULL, 2, '2022-04-01', 'Postulating Exoplan-etary Habitability via a Novel Anomaly Detection Method', 'Monthly Notices of the Royal Astronomical Society', NULL, 329, NULL, '5.287', NULL, '510', '4', NULL, 7, NULL, NULL, 0, '6022–6032 https://doi.org/10.1093/mnras/stab3556', NULL, '2022-12-14 23:54:03', '2022-12-14 23:54:03'),
(224, 7, 1, NULL, 2, '2022-04-01', 'Estimation and Applications of Quan-tiles in Deep Binary Classification', 'IEEE Transactions on Artificial Intelligence', NULL, NULL, NULL, NULL, NULL, '3', '2', '275-286', 7, NULL, NULL, 0, '10.1109/TAI.2021.3115078', NULL, '2022-12-14 23:58:56', '2022-12-14 23:58:56'),
(225, 7, 1, NULL, 2, '2022-03-01', 'LipGene: Lipschitz continuity guided adaptive learning rates for fast con-vergence on Microarray Expression Data Sets’', 'IEEE/ACM Transactions on Computational Biology and Bioinformatics', NULL, 329, NULL, '3.71', NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, 'https://ieeexplore.ieee.org/document/9531348', NULL, '2022-12-15 00:02:31', '2022-12-15 00:02:31'),
(226, 7, 1, NULL, 2, '2022-05-01', 'NLRIS: Modeling and Analysis of Non-local Influence of Research Output of Institutions', 'J.Scientometric Research', NULL, 330, NULL, NULL, NULL, '11', '1', '1-10', 7, NULL, NULL, 0, '10.5530/jscires.8.1.x', NULL, '2022-12-15 00:19:34', '2022-12-15 00:19:34'),
(227, 7, 1, NULL, 2, '2022-03-01', 'ALIS: A Novel Metric in Lineage Independent Evaluation of Scholars', 'Journal of Information Science', NULL, 329, NULL, '6.8', NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, 'https://doi.org/10.1177/01655515211039188', NULL, '2022-12-15 00:22:48', '2022-12-15 00:22:48'),
(228, 8, 1, NULL, 2, '2022-10-15', 'Study of Heterogeneous User Behavior in Crowd Evacuation in Presence of Wheelchair Users', '20th International Conference on Practical Applications of Agents and Multiagent Systems PAAMS 2022', 'L’Aquila, Italy', NULL, NULL, NULL, NULL, NULL, NULL, '229-241', 7, NULL, NULL, 0, NULL, NULL, '2022-12-15 00:32:20', '2022-12-15 00:32:20'),
(229, 8, 1, NULL, 1, '2022-01-01', 'A fast and robust Photometric redshift forecasting method using Lipschitz adaptive learning rate', 'ICONIP 2022', 'IIT Indore, India', 326, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, NULL, NULL, '2022-12-15 00:37:53', '2022-12-15 00:37:53'),
(230, 8, 1, NULL, 1, '2022-01-01', 'p-LSTM: An explainable LSTM architecture for Glucose Level Prediction', 'ICONIP 2022', 'IIT Indore, India', 326, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, NULL, NULL, '2022-12-15 00:43:00', '2022-12-15 00:46:55'),
(231, 8, 1, NULL, 1, '2022-01-01', 'Fairly Constricted Multi-Objective Particle Swarm Optimization', 'ICONIP 2022', 'IIT Indore, India', 326, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, NULL, NULL, '2022-12-15 00:44:19', '2022-12-15 00:47:08'),
(232, 8, 1, NULL, 1, '2022-01-01', 'HMC-PSO: A Hamiltonian Monte Carlo and Particle Swarm Optimization-based optimizer', 'ICONIP 2022', 'IIT Indore, India', 326, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, NULL, NULL, '2022-12-15 00:46:00', '2022-12-15 00:47:16'),
(233, 8, 1, NULL, 2, '2022-07-01', 'A Novel Method for Image Improvement and Restoration in Optical Time Series', 'Proceedings of the International Astronomical Union', 'Spain', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 0, NULL, NULL, '2022-12-15 00:55:39', '2022-12-15 00:55:39'),
(234, 8, 2, 1, 2, '2022-03-16', 'A Cloud-based Architecture using Microservices for the IoT-based Applications', 'The 2nd International Workshop on Serverless To sErvE moRe at Scale (STEERS 2022) held in conjunction with the 22nd IEEE/ACM International Symposium on Cluster, Cloud and Internet Computing (CCGrid 2022)', 'italy', 332, 18, NULL, NULL, NULL, NULL, '893-898', 8, 'IEEE', NULL, 0, '10.1109/CCGrid54584.2022.00107', NULL, '2022-12-20 07:22:20', '2022-12-20 07:27:31'),
(235, 8, 2, 1, 2, '2022-10-17', 'Comparison of popular video conferencing apps using client-side measurements on different backhaul networks', 'The Twenty-Third International Symposium on Theory, Algorithmic Foundations, and Protocol Design for Mobile Networks and Mobile Computing', 'Republic of Korea', 332, 9, NULL, NULL, NULL, NULL, '241–246', 8, 'ACM', NULL, 0, '10.1145/3492866.3557734', NULL, '2022-12-20 07:26:32', '2022-12-20 07:27:42'),
(236, 7, 1, NULL, 2, '2022-03-23', 'A Theoretical Analysis of Granulometry-Based Roughness Measures on Cartosat DEMs', 'IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing', NULL, 329, 17, '4.715', NULL, '15', NULL, '2836 - 2844', 15, 'IEEE', NULL, 0, '10.1109/JSTARS.2022.3161667', NULL, '2022-12-21 07:12:45', '2022-12-21 07:12:45'),
(237, 7, 1, NULL, 2, '2021-10-06', 'Triplet-Watershed for Hyperspectral Image Classification', 'IEEE Transactions on Geoscience and Remote Sensing', NULL, 329, 17, '8.125', NULL, '60', NULL, NULL, 15, 'IEEE', NULL, 0, '10.1109/TGRS.2021.3113721', NULL, '2022-12-21 07:24:03', '2022-12-21 07:24:03'),
(238, 8, 1, 2, 2, '2022-03-21', 'Detecting Screen Presence with Activity-Oriented RGB Camera in Egocentric Videos', 'IEEE International Conference on Pervasive Computing and Communications Workshops and other Affiliated Events (PerCom Workshops)', 'Pisa, Italy', 248, 24, NULL, NULL, NULL, NULL, NULL, 24, 'IEEE', NULL, 0, '10.1109/PerComWorkshops53856.2022.9767433', NULL, '2022-12-22 04:00:25', '2022-12-22 04:00:25'),
(239, 8, 1, 2, 2, '2022-03-21', 'Impacts of Image Obfuscation on Fine-grained Activity Recognition in Egocentric Video', 'IEEE International Conference on Pervasive Computing and Communications Workshops and other Affiliated Events (PerCom Workshops)', 'Pisa, Italy', 248, 24, NULL, NULL, NULL, NULL, NULL, 24, 'IEEE', NULL, 0, '10.1109/PerComWorkshops53856.2022.9767447', NULL, '2022-12-22 04:03:17', '2022-12-22 04:03:17'),
(240, 8, 1, 2, 2, '2022-03-21', 'OCEAN: Towards Developing an Opportunistic Continuous Emotion Annotation Framework', 'IEEE International Conference on Pervasive Computing and Communications Workshops and other Affiliated Events (PerCom Workshops)', NULL, 248, 24, NULL, NULL, NULL, NULL, NULL, 24, 'IEEE', NULL, 0, '10.1109/PerComWorkshops53856.2022.9767359', NULL, '2022-12-22 04:05:38', '2022-12-22 04:05:38'),
(241, 7, 1, NULL, 2, '2022-06-14', 'Prediction of Diet Quality Based on Day-Level Meal Pattern: A Preliminary Analysis Using Decision Tree Modeling', 'Current Developments in Nutrition Suppiment', 'UK', 248, NULL, NULL, NULL, '6', 'Supplement_1', '417', 24, 'Oxford University Press', NULL, 0, 'https://doi.org/10.1093/cdn/nzac055.006', NULL, '2022-12-22 04:13:12', '2022-12-22 04:13:12'),
(242, 8, 1, 2, 2, '2022-11-07', 'AffectPro: Towards Constructing Affective Profile Combining Smartphone Typing Interaction and Emotion Self-reporting Pattern', 'International Conference on Multimodal Interaction', 'Bangalore, India', 326, 24, NULL, NULL, NULL, NULL, NULL, 24, 'ACM', NULL, 0, 'https://doi.org/10.1145/3536221.3556603', NULL, '2022-12-22 04:15:51', '2022-12-22 04:15:51'),
(243, 8, 1, 2, 2, '2022-04-25', 'Emotion Detection from Smartphone Keyboard Interactions: Role\r\nof Temporal vs Spectral Features', 'ACM/SIGAPP Symposium on Applied Computing (SAC ’22)', NULL, 326, 24, NULL, NULL, NULL, NULL, NULL, 29, 'ACM', NULL, 0, '10.1145/3477314.3507159', NULL, '2022-12-22 06:28:12', '2022-12-22 06:28:12'),
(244, 8, 1, 2, 2, '2022-10-18', 'ALOE: Active Learning based Opportunistic Experience Sampling for Smartphone Keyboard driven Emotion Self-report Collection', 'International Conference on Affective Computing and Intelligent Interaction (ACII)', NULL, 337, 24, NULL, NULL, NULL, NULL, NULL, 29, 'IEEE', NULL, 0, '10.1109/ACII55700.2022.9953819', NULL, '2022-12-22 06:34:26', '2022-12-22 06:34:26'),
(245, 8, 1, 3, 2, '2022-04-28', 'Exploring Emotion Responses toward Pedestrian Crossing\r\nActions for Designing In-vehicle Empathic Interfaces', '2022 CHI Conference on Human Factors in Computing Systems', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 29, 'ACM', NULL, 0, '10.1145/3491101.3519764', NULL, '2022-12-22 06:38:12', '2022-12-22 06:38:12'),
(246, 8, 1, 2, 2, '2022-09-17', 'Investigating Affective Responses toward In-Video Pedestrian Crossing Actions using Camera and Physiological Sensors', 'International Conference on Automotive User Interfaces and Interactive Vehicular Applications (AutomotiveUI ’22)', NULL, NULL, 24, NULL, NULL, NULL, NULL, NULL, 29, 'ACM', NULL, 0, '10.1145/3543174.3546842', NULL, '2022-12-22 06:42:15', '2022-12-22 06:42:15'),
(247, 8, 1, 2, 2, '2022-03-27', 'Image-based Android Malware Detection Models using Static and Dynamic Features', 'International Conference on Intelligent Systems Design and Applications', NULL, 337, 17, NULL, NULL, '418', NULL, '1292–1305', 12, 'Springer, LNNS', NULL, 0, 'https://doi.org/10.1007/978-3-030-96308-8_120', NULL, '2022-12-22 11:23:42', '2022-12-22 11:23:42'),
(248, 8, 1, 2, 2, '2022-05-06', 'X-Swarm: Adversarial DRL for Metamorphic Malware Swarm Generation.', 'International Conference on Pervasive Computing and Communication (PerCom-2022)', NULL, 321, 17, NULL, NULL, NULL, NULL, '169-174', 12, 'IEEE', NULL, 0, '10.1109/PerComWorkshops53856.2022.9767485', NULL, '2022-12-22 11:33:18', '2022-12-22 11:33:18'),
(249, 8, 1, NULL, 2, '2022-06-20', 'Are Malware Detection Models Adversarial Robust Against Evasion Attack.', 'INFOCOM-2022', NULL, 321, NULL, NULL, NULL, NULL, NULL, NULL, 12, 'IEEE', NULL, 0, '10.1109/INFOCOMWKSHPS54753.2022.9798221', NULL, '2022-12-22 11:36:44', '2022-12-22 11:36:44'),
(250, 7, 1, NULL, 2, '2022-11-09', 'Are Malware Detection Classifiers Adversarially Vulnerable to Actor-Critic based Evasion Attacks', 'EAI Endorsed Transactions on Scalable Information Systems', NULL, 336, 17, '0.2', NULL, '10', '1', 'e6', 12, 'https://doi.org/10.4108/eai.31-5-2022.174087', NULL, 0, 'https://doi.org/10.4108/eai.31-5-2022.174087', NULL, '2022-12-22 21:10:56', '2022-12-22 21:10:56'),
(251, 7, 1, NULL, 2, '2022-09-01', 'GreenForensics: Deep Hybrid Edge-Cloud Detection and Forensics System for Battery-Performance-Balance Conscious Devices', 'Forensic Science International: Digital Investigation', NULL, 329, 17, '1.805', NULL, '43', NULL, '301445', 12, 'ScienceDirect', NULL, 0, 'https://doi.org/10.1016/j.fsidi.2022.301445', NULL, '2022-12-23 07:51:34', '2022-12-23 07:51:34'),
(252, 7, 1, NULL, 2, '2022-09-01', 'Neural AutoForensics: Comparing Neural Sample Search and Neural Architecture Search for malware detection and forensics', 'Forensic Science International: Digital Investigation', NULL, 329, 17, '1.805', NULL, '43', NULL, NULL, 12, 'ScienceDirect', NULL, 0, 'https://doi.org/10.1016/j.fsidi.2022.301444', NULL, '2022-12-23 07:54:36', '2022-12-23 07:54:36'),
(253, 7, 1, NULL, 2, '2022-09-28', 'Towards Adversarially Superior Malware Detection Models: An Adversary-Aware Proactive Approach using Adversarial Attacks and Defenses.', 'Information Systems Frontiers', NULL, 329, 17, '5.261', NULL, NULL, NULL, NULL, 12, 'Springer', NULL, 0, 'https://doi.org/10.1007/s10796-022-10331-z', NULL, '2022-12-23 07:58:39', '2022-12-23 07:58:39'),
(254, 7, 1, NULL, 2, '2022-08-30', 'Deep Reinforcement Learning in the Advanced Cybersecurity Threat Detection and Protection', 'Information Systems Frontiers', NULL, 329, 17, '5.261', NULL, NULL, NULL, NULL, 12, 'Springer', NULL, 0, 'https://doi.org/10.1007/s10796-022-10333-x', NULL, '2022-12-23 08:01:10', '2022-12-23 08:01:10'),
(255, 7, 1, NULL, 2, '2022-12-01', 'Defending malware detection models against evasion based adversarial attacks', 'Pattern Recognition Letters', NULL, 329, NULL, '4.757', NULL, NULL, NULL, '119-125', 12, 'ScienceDirect', NULL, 0, 'https://doi.org/10.1016/j.patrec.2022.10.010', NULL, '2022-12-23 08:04:31', '2022-12-23 08:04:31'),
(256, 7, 2, NULL, 2, '2022-12-01', 'SAMPARK: Secure and Lightweight Communication Protocols for Smart Parking Management', 'Journal of Information Security and Applications', NULL, 329, 17, '4.96', NULL, '71', NULL, '103381', 12, 'ScienceDirect', NULL, 0, 'https://doi.org/10.1016/j.jisa.2022.103381', NULL, '2022-12-23 08:07:58', '2022-12-23 08:07:58'),
(257, 8, 1, 2, 2, '2022-05-16', 'SchedTune: A Heterogeneity-Aware GPU Scheduler for Deep Learning', 'IEEE International Symposium on Cluster, Cloud and Internet Computing (CCGrid)', 'Taormina, Italy', 332, 18, NULL, NULL, NULL, NULL, NULL, 34, 'IEEE', NULL, 0, 'https://doi.org/10.1109/CCGrid54584.2022.00079', NULL, '2022-12-23 10:08:37', '2022-12-23 10:08:37'),
(258, 8, 1, 2, 2, '2022-06-22', 'Access Patterns and Performance Behaviors of Multi-layer Supercomputer I/O Subsystems under Production Load', 'HPDC \'22: Proceedings of the 31st International Symposium on High-Performance Parallel and Distributed Computing', 'Minneapolis, USA', 332, 18, NULL, NULL, NULL, NULL, '43 - 55', 34, 'ACM', NULL, 0, 'https://doi.org/10.1145/3502181.3531461', NULL, '2022-12-23 10:13:44', '2022-12-23 10:13:44'),
(259, 8, 1, 2, 2, '2022-06-23', 'Machine Learning Assisted HPC Workload Trace Generation for Leadership Scale Storage Systems', 'HPDC \'22: Proceedings of the 31st International Symposium on High-Performance Parallel and Distributed Computing', 'Minneapolis, USA', 332, 18, NULL, NULL, NULL, NULL, '199-212', 34, 'ACM', NULL, 0, 'https://doi.org/10.1145/3502181.3531457', NULL, '2022-12-23 10:15:35', '2022-12-23 10:15:35'),
(260, 7, 1, NULL, 2, '2022-10-23', 'I/O performance analysis of machine learning workloads on leadership scale supercomputer', 'Performance Evaluation', NULL, 330, 18, NULL, NULL, '157-158', '102318', '1-18', 34, 'Elsevier', NULL, 0, 'https://doi.org/10.1016/j.peva.2022.102318', NULL, '2022-12-23 10:19:00', '2022-12-23 10:19:00'),
(261, 8, 1, 2, 2, '2022-12-03', 'P3: A task migration policy for optimal resource utilization and energy consumption', 'International conference on Data, Decision and Systems ICDDS', NULL, 336, 18, NULL, NULL, NULL, NULL, NULL, 32, NULL, NULL, 0, NULL, NULL, '2022-12-27 04:56:17', '2022-12-27 04:56:17'),
(262, 8, 1, 2, 2, '2022-03-12', 'P3: A task migration policy for optimal resource utilization and energy consumption', 'International Conference on Data, Decision, and Systems ICDDS', 'Bangalore', 336, 18, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, 1, NULL, NULL, '2022-12-27 04:57:29', '2022-12-27 04:58:11'),
(263, 8, 1, 3, 2, '2022-03-02', 'Inclusive Thinking Questionnaire: Preliminary Results', '53rd ACM Technical Symposium on Computer Science Education V. 2 (SIGCSE 2022)', 'Providence, Rhode Island, USA', 332, NULL, NULL, NULL, NULL, NULL, NULL, 35, 'ACM', NULL, 0, 'https://doi.org/10.1145/3478432.3499066', NULL, '2022-12-27 05:01:52', '2022-12-27 05:01:52'),
(264, 7, 1, NULL, 2, '2022-05-31', 'Are Malware Detection Classifiers Adversarially Vulnerable to Actor-Critic based Evasion Attacks?', 'EAI Endorsed Transactions on Scalable Information Systems', NULL, 336, 17, NULL, NULL, '10', '1', '1-13', 13, 'EAI', NULL, 1, '10.4108/eai.31-5-2022.174087', NULL, '2022-12-28 22:52:25', '2022-12-28 22:54:18'),
(265, 8, 1, 2, 2, '2022-10-28', 'Women in STEM: snapshots from a few Asian countries', 'Proceedings of the IFAC conference on Technology, Culture and International Stability (TECIS) 2022., IFAC-PapersOnLine', 'Kosovo', 336, NULL, NULL, NULL, '55', '39', '204-209', 33, 'Elsevier', NULL, 0, '10.1016/j.ifacol.2022.12.060', NULL, '2022-12-29 05:24:04', '2022-12-29 05:24:04'),
(266, 7, 1, NULL, 2, '2022-04-05', 'In silico Effects of Synaptic Connections in the Visual Thalamocortical Pathway', 'Frontiers in Medical Technology', 'Online', 248, 17, NULL, NULL, '4', '856412', '1-14', 33, 'Fronteiers, Switzerland (www.frontiers.in.org)', NULL, 0, '10.3389/fmedt.2022.856412', NULL, '2022-12-29 05:36:10', '2022-12-29 05:36:10'),
(267, 8, 1, 2, 2, '2022-07-22', 'Optimising hyperparameters in a population neural network of the visual thalamocortical pathway', 'IEEE International Joint Conference of Neural Networks (IJCNN)', 'Padua, Italy', 332, 17, NULL, NULL, NULL, NULL, '1-8', 33, 'IEEE', NULL, 0, '10.1109/IJCNN55064.2022.9892380', NULL, '2022-12-29 05:43:53', '2022-12-29 05:43:53'),
(268, 8, 1, 2, 2, '2022-11-24', 'Instrumental conditioning with neuromodulated plasticity on SpiNNaker', 'International Conference on Neural Information Processing (ICONIP)', 'Indore, India (virtual)', 326, 17, NULL, NULL, 'Lecture Notes in Computer Science: To be assigned', 'Lecture Notes in Computer Science: To be assigned', '1-12', 33, 'Springer', NULL, 0, 'not yet assigned', NULL, '2022-12-29 06:12:31', '2022-12-29 06:12:31'),
(269, 8, 1, 1, 2, '2022-09-30', 'Analysis of Logistic Map Based Neurons in Neuorchaos Learning Architectures for Data Classification', 'Meeting for the Dissemination and Research in the Study of Complex Systems and their Applications (EDIESCA 2022)', NULL, 336, 17, NULL, NULL, NULL, NULL, NULL, 37, NULL, NULL, 0, NULL, NULL, '2023-01-05 01:30:06', '2023-01-05 01:30:06'),
(270, 8, 1, 1, 2, '2022-08-31', 'Enhanced edge offloading using Reinforcement learning', '2022 International Conference on Connected Systems & Intelligence (CSI)', 'India', 336, 17, NULL, NULL, '1', '1', '1-9', 10, 'IEEE', NULL, 0, 'https://doi.org/10.1109/CSI54720.2022.9924023', NULL, '2023-01-05 02:32:52', '2023-01-05 02:32:52'),
(271, 8, 1, 1, 2, '2022-07-20', 'Evaluation of Offloading Points in the Device-Edge Environment', '2022 13th International Symposium on Communication Systems, Networks and Digital Signal Processing (CSNDSP)', 'Portugal', 336, 9, NULL, NULL, '1', '1', '1', 10, 'IEEE', NULL, 0, 'https://doi.org/10.1109/CSNDSP54353.2022.9908034', NULL, '2023-01-05 02:45:42', '2023-01-05 02:45:42'),
(272, 8, 1, 2, 2, '2022-10-31', 'Causality Preserving Chaotic Transformation and Classification using Neurochaos Learning', 'Neural Information Processing Systems, NeurIPS 2022', 'New Orlans, USA (virtual mode)', 321, 17, NULL, NULL, NULL, NULL, NULL, 37, NULL, NULL, 0, NULL, NULL, '2023-01-06 01:55:20', '2023-01-06 01:55:20'),
(273, 8, 1, 2, 2, '2022-09-30', 'Neurochaos Feature Transformation for Machine Learning', 'Meeting for the Dissemination and Research in the Study of Complex Systems and their Applications (EDIESCA 2022)', 'online', 336, 17, NULL, NULL, NULL, NULL, NULL, 37, NULL, NULL, 0, NULL, NULL, '2023-01-06 01:59:27', '2023-01-06 01:59:27'),
(274, 8, 1, 1, 2, '2022-12-16', 'Revisiting the XOR problem using Neurochaos Learning', 'Conference on Nonlinear Systems and Dynamics', 'Pune', 248, 17, NULL, NULL, NULL, NULL, NULL, 37, NULL, NULL, 0, NULL, NULL, '2023-01-06 02:01:47', '2023-01-06 02:01:47'),
(275, 7, 1, NULL, 2, '2022-03-01', 'TaskMUSTER: a comprehensive analysis of task parameters for mixed criticality automotive systems', 'Sādhanā', 'Springer India', 330, 18, NULL, NULL, '47', '1', '1-23', 30, 'Springer India', NULL, 0, NULL, NULL, '2023-01-08 12:32:15', '2023-01-08 12:32:15'),
(276, 8, 1, 2, 2, '2021-12-20', 'pmcEDF: An Energy Efficient Procrastination Scheduler for Multi-core Mixed Criticality Systems', 'IEEE 23rd Int Conf on High Performance Computing & Communications; 7th Int Conf on Data Science & Systems; 19th Int Conf on Smart City; 7th Int Conf on Dependability in Sensor, Cloud & Big Data Systems & Application (HPCC/DSS/SmartCity/DependSys)', NULL, 326, 18, NULL, NULL, NULL, NULL, '727-732', 30, 'IEEE', NULL, 0, NULL, NULL, '2023-01-08 12:42:07', '2023-01-08 12:42:07'),
(277, 8, 1, 2, 2, '2022-11-24', 'Probing Semantic Grounding in Language Models of Code with Representational Similarity Analysis', 'Advanced Data Mining and Applications', 'Australia', 326, 17, NULL, NULL, '13726', NULL, NULL, 23, 'Springer', NULL, 0, 'https://doi.org/10.1007/978-3-031-22137-8_29', NULL, '2023-01-20 04:31:14', '2023-01-20 04:31:14'),
(278, 8, 1, 2, 2, '2022-11-24', 'WDA: A Domain-Aware Database Schema Analysis for improving OBDA-based Event Log Extractions', 'The 18th International Conference on Advanced Data Mining and Applications (ADMA)', 'Australia', 326, 17, NULL, NULL, '13726', NULL, '297--309', 23, 'Springer', NULL, 0, 'https://doi.org/10.1007/978-3-031-22137-8_22', NULL, '2023-01-20 04:33:46', '2023-01-20 04:33:46'),
(279, 8, 1, 2, 2, '2022-11-24', 'Correcting Temporal Overlaps in Process Models Discovered from OLTP Databases', 'The 18th International Conference on Advanced Data Mining and Applications (ADMA)', 'Australia', 326, 17, NULL, NULL, '13726', NULL, '281--296', 23, 'Springer', NULL, 0, 'https://doi.org/10.1007/978-3-031-22137-8_21', NULL, '2023-01-20 04:35:14', '2023-01-20 04:35:14'),
(280, 7, 1, NULL, 2, '2022-03-18', 'Genome-wide analysis of AAAG and ACGT cis-elements in Arabidopsis thaliana reveals their involvement with genes downregulated under jasmonic acid response in an orientation independent manner', 'G3 Genes|Genomes|Genetics', NULL, 329, 17, '3.154', NULL, '12', '5', '1--15', 23, 'Oxford', NULL, 0, 'https://doi.org/10.1093/g3journal/jkac057', NULL, '2023-01-20 04:38:32', '2023-01-20 04:38:32'),
(281, 7, 1, NULL, 2, '2022-02-17', 'Topical analysis of migration coverage during lockdown in India by mainstream print media', 'PLoS ONE', 'USA', 329, 17, '3.24', NULL, '17', '2', '1--19', 23, 'Public Library of Science San Francisco', NULL, 0, 'https://doi.org/10.1371/journal.pone.0263787', NULL, '2023-01-20 04:40:34', '2023-01-20 04:40:34'),
(282, 8, 1, 2, 2, '2022-02-10', 'Clustering and Transmit Power Control for Social Assisted D2D Cellular Networks', 'The 19th IEEE Consumer Communications and Networking Conference (CCNC)', 'Las Vegas', 326, 9, NULL, NULL, NULL, NULL, '871--876', 23, 'IEEE', NULL, 0, 'https://doi.org/10.1109/CCNC49033.2022.9700595', NULL, '2023-01-20 04:41:52', '2023-01-20 04:41:52'),
(283, 8, 1, 2, 2, '2022-12-31', 'Mining Railway Grievances on Twitter for Efficient E-Governance in India', 'IEEE International Conference on Big Data (IEEE BigData 2022)', 'Osaka, Japan', 326, 17, NULL, NULL, NULL, NULL, '1969--1978', 23, 'IEEE', NULL, 0, NULL, NULL, '2023-01-20 04:43:17', '2023-01-20 04:43:17'),
(284, 8, 1, 2, 2, '2022-12-31', 'A Transfer Learning Framework For Annotating Implementation-Specific Corpus', 'The 9th IEEE International Conference on Data Science and Advanced Analytics (DSAA)', 'Online', 332, 17, NULL, NULL, NULL, NULL, NULL, 23, 'IEEE', NULL, 0, NULL, NULL, '2023-01-20 04:44:43', '2023-01-20 04:44:43');

-- --------------------------------------------------------

--
-- Table structure for table `pubuserdetails`
--

CREATE TABLE `pubuserdetails` (
  `pubid` bigint(20) UNSIGNED NOT NULL,
  `userid` bigint(20) UNSIGNED NOT NULL,
  `type` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_date` date DEFAULT NULL,
  `updated_time` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pubuserdetails`
--

INSERT INTO `pubuserdetails` (`pubid`, `userid`, `type`, `updated_date`, `updated_time`) VALUES
(4, 14, 'update', '2020-12-22', '07:47:43'),
(17, 19, 'update', '2020-12-23', '07:05:21'),
(10, 19, 'update', '2020-12-23', '07:06:35'),
(24, 9, 'update', '2020-12-30', '07:19:50'),
(27, 7, 'update', '2021-01-27', '07:20:10'),
(27, 7, 'update', '2021-01-27', '07:21:01'),
(27, 7, 'update', '2021-01-28', '05:42:08'),
(27, 7, 'update', '2021-01-28', '05:42:20'),
(28, 7, 'update', '2021-01-28', '05:43:24'),
(29, 7, 'update', '2021-01-28', '05:43:56'),
(30, 7, 'update', '2021-01-28', '05:44:33'),
(29, 7, 'update', '2021-01-28', '05:45:00'),
(73, 7, 'update', '2021-11-13', '06:02:27'),
(74, 7, 'update', '2021-11-13', '06:02:41'),
(73, 13, 'update', '2021-11-13', '06:28:46'),
(74, 13, 'update', '2021-11-13', '06:29:16'),
(73, 13, 'update', '2021-11-13', '07:54:31'),
(74, 13, 'update', '2021-11-13', '07:55:02'),
(75, 13, 'update', '2021-11-13', '07:56:52'),
(95, 13, 'update', '2021-11-13', '07:57:26'),
(76, 13, 'update', '2021-11-13', '07:58:13'),
(89, 13, 'update', '2021-11-13', '07:59:10'),
(90, 13, 'update', '2021-11-13', '07:59:33'),
(96, 13, 'update', '2021-11-13', '07:59:47'),
(97, 13, 'update', '2021-11-13', '07:59:59'),
(100, 13, 'update', '2021-11-13', '08:00:11'),
(101, 13, 'update', '2021-11-13', '08:00:27'),
(102, 13, 'update', '2021-11-13', '08:00:41'),
(113, 13, 'update', '2021-11-13', '08:01:32'),
(114, 13, 'update', '2021-11-13', '08:01:56'),
(115, 13, 'update', '2021-11-13', '08:02:09'),
(116, 13, 'update', '2021-11-13', '08:02:24'),
(104, 13, 'update', '2021-11-13', '08:04:54'),
(110, 13, 'update', '2021-11-13', '08:05:54'),
(111, 13, 'update', '2021-11-13', '08:06:10'),
(112, 13, 'update', '2021-11-13', '08:06:25'),
(98, 13, 'update', '2021-11-13', '08:06:42'),
(118, 13, 'update', '2021-11-13', '08:47:12'),
(125, 13, 'update', '2021-11-13', '08:47:28'),
(126, 13, 'update', '2021-11-13', '08:48:02'),
(127, 13, 'update', '2021-11-13', '08:48:21'),
(76, 13, 'update', '2021-11-13', '08:48:41'),
(128, 13, 'update', '2021-11-13', '08:48:58'),
(129, 13, 'update', '2021-11-13', '08:49:15'),
(124, 13, 'update', '2021-11-13', '08:54:06'),
(124, 13, 'update', '2021-11-13', '08:54:35'),
(142, 24, 'update', '2021-11-15', '09:08:13'),
(148, 7, 'update', '2021-11-16', '06:13:45'),
(143, 7, 'update', '2021-11-16', '06:14:04'),
(144, 7, 'update', '2021-11-16', '06:14:14'),
(145, 7, 'update', '2021-11-16', '06:14:25'),
(146, 7, 'update', '2021-11-16', '06:14:31'),
(147, 7, 'update', '2021-11-16', '06:14:52'),
(149, 7, 'update', '2021-11-16', '06:15:04'),
(150, 7, 'update', '2021-11-16', '06:15:12'),
(117, 7, 'update', '2021-11-16', '06:15:30'),
(152, 7, 'update', '2021-11-16', '09:15:25'),
(153, 7, 'update', '2021-11-16', '09:16:51'),
(154, 7, 'update', '2021-11-16', '09:17:37'),
(155, 7, 'update', '2021-11-16', '09:18:21'),
(156, 7, 'update', '2021-11-16', '09:19:22'),
(157, 7, 'update', '2021-11-16', '09:19:52'),
(159, 7, 'update', '2021-11-16', '09:20:17'),
(158, 7, 'update', '2021-11-16', '09:35:26'),
(151, 7, 'update', '2021-11-16', '09:41:36'),
(167, 24, 'update', '2021-11-16', '09:59:15'),
(166, 24, 'update', '2021-11-16', '10:00:30'),
(166, 24, 'update', '2021-11-16', '10:00:42'),
(165, 24, 'update', '2021-11-16', '10:01:06'),
(165, 24, 'update', '2021-11-16', '10:01:16'),
(55, 7, 'update', '2021-11-16', '10:03:05'),
(180, 24, 'update', '2021-11-16', '10:12:26'),
(185, 24, 'update', '2021-11-16', '10:12:57'),
(184, 24, 'update', '2021-11-16', '10:13:29'),
(183, 24, 'update', '2021-11-16', '10:13:48'),
(182, 24, 'update', '2021-11-16', '10:14:05'),
(181, 24, 'update', '2021-11-16', '10:14:20'),
(170, 24, 'update', '2021-11-16', '10:15:28'),
(169, 24, 'update', '2021-11-16', '10:15:41'),
(168, 24, 'update', '2021-11-16', '10:15:55'),
(176, 24, 'update', '2021-11-16', '10:16:02'),
(173, 24, 'update', '2021-11-16', '10:16:19'),
(172, 24, 'update', '2021-11-16', '10:16:40'),
(171, 24, 'update', '2021-11-16', '10:16:52'),
(179, 24, 'update', '2021-11-16', '10:17:01'),
(178, 24, 'update', '2021-11-16', '10:17:18'),
(188, 7, 'update', '2021-11-16', '10:24:53'),
(177, 24, 'update', '2021-11-16', '10:31:39'),
(164, 24, 'update', '2021-11-16', '10:31:51'),
(191, 7, 'update', '2021-11-16', '10:50:38'),
(191, 7, 'update', '2021-11-16', '10:51:36'),
(191, 7, 'update', '2021-11-16', '10:52:17'),
(162, 24, 'update', '2021-11-16', '11:32:29'),
(163, 24, 'update', '2021-11-16', '11:33:46'),
(52, 7, 'update', '2021-11-17', '04:48:15'),
(55, 7, 'update', '2021-11-17', '04:54:52'),
(52, 7, 'update', '2021-11-17', '04:55:15'),
(160, 7, 'update', '2021-11-17', '05:42:50'),
(158, 7, 'update', '2021-11-17', '05:57:03'),
(160, 7, 'update', '2021-11-17', '05:57:51'),
(24, 7, 'update', '2021-11-17', '06:13:37'),
(24, 7, 'update', '2021-11-17', '06:18:27'),
(27, 7, 'update', '2021-11-17', '06:36:14'),
(28, 7, 'update', '2021-11-17', '06:39:10'),
(29, 7, 'update', '2021-11-17', '07:25:14'),
(30, 7, 'update', '2021-11-17', '07:27:47'),
(118, 7, 'update', '2021-11-17', '07:35:23'),
(191, 7, 'update', '2021-11-17', '07:37:15'),
(191, 7, 'update', '2021-11-17', '07:37:38'),
(131, 7, 'update', '2021-11-17', '09:36:21'),
(132, 7, 'update', '2021-11-17', '09:37:25'),
(133, 7, 'update', '2021-11-17', '09:40:19'),
(134, 7, 'update', '2021-11-17', '09:41:39'),
(135, 7, 'update', '2021-11-17', '09:47:35'),
(136, 7, 'update', '2021-11-17', '09:48:12'),
(137, 7, 'update', '2021-11-17', '09:48:29'),
(138, 7, 'update', '2021-11-17', '09:52:03'),
(139, 7, 'update', '2021-11-17', '09:55:35'),
(140, 7, 'update', '2021-11-17', '10:03:33'),
(141, 7, 'update', '2021-11-17', '10:04:18'),
(142, 7, 'update', '2021-11-17', '10:06:23'),
(152, 7, 'update', '2021-11-17', '10:10:28'),
(174, 7, 'update', '2021-11-17', '10:11:31'),
(175, 7, 'update', '2021-11-17', '10:12:11'),
(176, 7, 'update', '2021-11-17', '10:13:26'),
(180, 7, 'update', '2021-11-17', '10:15:39'),
(200, 7, 'update', '2022-01-06', '06:28:06'),
(201, 7, 'update', '2022-01-06', '06:30:34'),
(202, 7, 'update', '2022-01-06', '06:30:51'),
(205, 12, 'update', '2022-01-11', '13:07:34'),
(73, 12, 'update', '2022-01-11', '13:12:17'),
(127, 12, 'update', '2022-01-11', '13:14:08'),
(118, 12, 'update', '2022-01-11', '13:19:18'),
(76, 12, 'update', '2022-01-11', '13:22:40'),
(74, 12, 'update', '2022-01-11', '13:24:17'),
(75, 12, 'update', '2022-01-11', '13:25:28'),
(95, 12, 'update', '2022-01-11', '13:27:23'),
(89, 12, 'update', '2022-01-11', '13:29:37'),
(90, 12, 'update', '2022-01-11', '13:32:18'),
(96, 12, 'update', '2022-01-11', '13:33:39'),
(97, 12, 'update', '2022-01-11', '13:35:00'),
(100, 12, 'update', '2022-01-11', '13:36:50'),
(101, 12, 'update', '2022-01-11', '13:37:54'),
(114, 12, 'update', '2022-01-11', '13:39:33'),
(124, 12, 'update', '2022-01-11', '13:40:55'),
(141, 12, 'update', '2022-01-11', '13:42:21'),
(104, 12, 'update', '2022-01-11', '13:44:42'),
(110, 12, 'update', '2022-01-11', '13:45:59'),
(111, 12, 'update', '2022-01-11', '13:47:27'),
(125, 12, 'update', '2022-01-11', '13:48:33'),
(126, 12, 'update', '2022-01-11', '13:48:59'),
(128, 12, 'update', '2022-01-11', '13:50:00'),
(129, 12, 'update', '2022-01-11', '13:51:08'),
(98, 12, 'update', '2022-01-11', '13:53:18'),
(89, 12, 'update', '2022-01-21', '13:55:23'),
(133, 7, 'update', '2022-02-10', '06:54:29'),
(134, 7, 'update', '2022-02-10', '06:56:43'),
(135, 7, 'update', '2022-02-10', '06:57:43'),
(136, 7, 'update', '2022-02-10', '06:58:35'),
(137, 7, 'update', '2022-02-10', '07:00:06'),
(138, 7, 'update', '2022-02-10', '07:00:48'),
(140, 7, 'update', '2022-02-10', '07:01:22'),
(139, 7, 'update', '2022-02-10', '07:04:50'),
(132, 7, 'update', '2022-02-10', '07:05:22'),
(131, 7, 'update', '2022-02-10', '07:05:32'),
(152, 7, 'update', '2022-02-10', '07:07:21'),
(153, 7, 'update', '2022-02-10', '07:07:26'),
(154, 7, 'update', '2022-02-10', '07:07:32'),
(155, 7, 'update', '2022-02-10', '07:08:03'),
(156, 7, 'update', '2022-02-10', '07:08:11'),
(157, 7, 'update', '2022-02-10', '07:08:21'),
(158, 7, 'update', '2022-02-10', '07:08:26'),
(159, 7, 'update', '2022-02-10', '07:08:32'),
(160, 7, 'update', '2022-02-10', '07:08:38'),
(199, 7, 'update', '2022-02-10', '07:09:29'),
(64, 7, 'update', '2022-02-10', '07:10:10'),
(201, 7, 'update', '2022-02-10', '07:12:51'),
(200, 7, 'update', '2022-02-10', '07:13:20'),
(202, 7, 'update', '2022-02-10', '07:13:36'),
(203, 7, 'update', '2022-02-10', '07:14:36'),
(204, 7, 'update', '2022-02-10', '07:15:04'),
(117, 7, 'update', '2022-02-10', '07:16:01'),
(142, 7, 'update', '2022-02-10', '07:16:15'),
(186, 7, 'update', '2022-02-10', '07:17:29'),
(187, 7, 'update', '2022-02-10', '07:17:46'),
(188, 7, 'update', '2022-02-10', '07:18:06'),
(189, 7, 'update', '2022-02-10', '07:18:19'),
(190, 7, 'update', '2022-02-10', '07:19:26'),
(191, 7, 'update', '2022-02-10', '07:19:42'),
(192, 7, 'update', '2022-02-10', '07:20:14'),
(194, 7, 'update', '2022-02-10', '07:21:27'),
(195, 7, 'update', '2022-02-10', '07:21:42'),
(196, 7, 'update', '2022-02-10', '07:22:18'),
(197, 7, 'update', '2022-02-10', '07:22:47'),
(230, 7, 'update', '2022-12-15', '06:16:55'),
(231, 7, 'update', '2022-12-15', '06:17:08'),
(232, 7, 'update', '2022-12-15', '06:17:16'),
(234, 8, 'update', '2022-12-20', '12:57:31'),
(235, 8, 'update', '2022-12-20', '12:57:42'),
(247, 12, 'update', '2022-12-23', '13:15:29'),
(248, 12, 'update', '2022-12-23', '13:16:11'),
(249, 12, 'update', '2022-12-23', '13:16:28'),
(250, 12, 'update', '2022-12-23', '13:16:44'),
(208, 12, 'update', '2022-12-23', '13:41:33'),
(104, 12, 'update', '2022-12-23', '13:41:49'),
(76, 12, 'update', '2022-12-23', '13:42:43'),
(124, 12, 'update', '2022-12-23', '13:42:56'),
(126, 12, 'update', '2022-12-23', '13:43:11'),
(125, 12, 'update', '2022-12-23', '13:43:33'),
(110, 12, 'update', '2022-12-23', '13:43:47'),
(111, 12, 'update', '2022-12-23', '13:44:11'),
(129, 12, 'update', '2022-12-23', '13:44:26'),
(206, 12, 'update', '2022-12-23', '13:44:39'),
(118, 12, 'update', '2022-12-23', '13:44:53'),
(128, 12, 'update', '2022-12-23', '13:45:05'),
(127, 12, 'update', '2022-12-23', '13:45:22'),
(207, 12, 'update', '2022-12-23', '13:47:24'),
(205, 12, 'update', '2022-12-23', '13:47:37'),
(97, 12, 'update', '2022-12-23', '13:47:53'),
(96, 12, 'update', '2022-12-23', '13:48:21'),
(114, 12, 'update', '2022-12-23', '13:48:35'),
(101, 12, 'update', '2022-12-23', '13:48:48'),
(100, 12, 'update', '2022-12-23', '13:49:00'),
(98, 12, 'update', '2022-12-23', '13:49:14'),
(141, 12, 'update', '2022-12-23', '13:49:28'),
(211, 12, 'update', '2022-12-23', '13:49:40'),
(210, 12, 'update', '2022-12-23', '13:49:58'),
(89, 12, 'update', '2022-12-23', '13:50:09'),
(209, 12, 'update', '2022-12-23', '13:50:31'),
(90, 12, 'update', '2022-12-23', '13:50:42'),
(73, 12, 'update', '2022-12-23', '13:50:56'),
(95, 12, 'update', '2022-12-23', '13:51:16'),
(75, 12, 'update', '2022-12-23', '13:51:28'),
(74, 12, 'update', '2022-12-23', '13:51:44'),
(151, 33, 'update', '2022-12-29', '06:40:33'),
(269, 7, 'update', '2023-01-06', '04:51:36');

-- --------------------------------------------------------

--
-- Table structure for table `rankings`
--

CREATE TABLE `rankings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ranking` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rankings`
--

INSERT INTO `rankings` (`id`, `ranking`, `created_at`, `updated_at`) VALUES
(248, 'Others', '2020-07-24 03:02:05', '2020-07-24 03:02:05'),
(321, 'Core A*', '2020-08-26 03:25:08', '2020-08-26 03:25:08'),
(326, 'Core B', '2020-08-26 23:42:13', '2020-08-26 23:42:13'),
(328, 'SCI', '2020-09-15 00:52:19', '2020-09-15 00:52:19'),
(329, 'SCIMAGO Q1', '2020-09-15 00:52:39', '2020-09-15 00:52:39'),
(330, 'SCIMAGO Q2', '2020-10-23 04:27:28', '2020-10-23 04:27:28'),
(332, 'Core A', NULL, NULL),
(336, 'Scopus', '2021-11-14 23:42:45', '2021-11-14 23:42:45'),
(337, 'Core C', '2021-11-14 23:43:37', '2021-11-14 23:43:37'),
(338, 'SCIMAGO Q3', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `userregistrations`
--

CREATE TABLE `userregistrations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `userid` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `campusid` bigint(20) UNSIGNED NOT NULL,
  `departmentid` bigint(20) UNSIGNED NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `userregistrations`
--

INSERT INTO `userregistrations` (`id`, `userid`, `campusid`, `departmentid`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(11, 'test123', 2, 4, '$2y$10$wPO5Bcr4vuncGu0rZTVTxOiwwZ4VeEmp3.oE/2pEZdw3tZZ/xWZ3O', NULL, '2020-10-23 00:11:01', '2020-10-23 00:11:01');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `google_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(191) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(191) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_original` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `google_id`, `name`, `email`, `email_verified_at`, `password`, `avatar`, `avatar_original`, `remember_token`, `created_at`, `updated_at`) VALUES
(7, '117396629326134053075', 'Neha Bipin Naik', 'nehan@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh6.googleusercontent.com/-N5SoqL5dqfQ/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuckJDbzE6ol-gK3hZpqM53ChOdztaA/s96-c/photo.jpg', 'https://lh6.googleusercontent.com/-N5SoqL5dqfQ/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuckJDbzE6ol-gK3hZpqM53ChOdztaA/s96-c/photo.jpg', NULL, '2020-11-25 23:16:31', '2020-11-25 23:16:31'),
(8, '105344646020903585601', 'Vinayak Naik', 'vinayak@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GgeOBnBxGomNDSYcFd5GblGZPoA9vLr8NkejQfu=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GgeOBnBxGomNDSYcFd5GblGZPoA9vLr8NkejQfu=s96-c', NULL, '2020-12-19 15:52:09', '2020-12-19 15:52:09'),
(9, '112196717037723705921', 'Computer Sc. & I.S. Office', 'csis.office@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/-Rbb4Szxyk0M/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuclhO0jccEBGKRkibK1j0BgCwVp7jQ/s96-c/photo.jpg', 'https://lh3.googleusercontent.com/-Rbb4Szxyk0M/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuclhO0jccEBGKRkibK1j0BgCwVp7jQ/s96-c/photo.jpg', NULL, '2020-12-20 18:00:05', '2020-12-20 18:00:05'),
(10, '108614930120870575515', 'Neena Goveas', 'neena@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GgGckyBsbhnwIOtW9oCaMJvBnoAfRMD1Mv0bAv4dg=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GgGckyBsbhnwIOtW9oCaMJvBnoAfRMD1Mv0bAv4dg=s96-c', NULL, '2020-12-20 19:53:15', '2020-12-20 19:53:15'),
(11, '106338963609389113505', 'Soumyadip Bandyopadhyay', 'soumyadipb@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GikJVvOyNjfOEa3M5J-6-gEw52hXdzrHmkz5StXSQ=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GikJVvOyNjfOEa3M5J-6-gEw52hXdzrHmkz5StXSQ=s96-c', NULL, '2020-12-20 20:45:14', '2020-12-20 20:45:14'),
(12, '118273853412958493525', 'Sanjay Kumar Sahay', 'ssahay@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GjwJNoRtZJe1JWjLrw1tnqvIl5MqGjej0o8dtW6Mw=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GjwJNoRtZJe1JWjLrw1tnqvIl5MqGjej0o8dtW6Mw=s96-c', NULL, '2020-12-20 22:19:50', '2020-12-20 22:19:50'),
(13, '111778873346492546189', 'Hemant Rathore', 'hemantr@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/-udYNyPdD7YY/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmhc135qSpaw2OZMo-TF4YRR4oqZA/s96-c/photo.jpg', 'https://lh3.googleusercontent.com/-udYNyPdD7YY/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmhc135qSpaw2OZMo-TF4YRR4oqZA/s96-c/photo.jpg', NULL, '2020-12-20 22:39:44', '2020-12-20 22:39:44'),
(14, '115375516415741930235', 'Tirtharaj Dash', 'tirtharaj@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GjJjT5d08pGZZfE1Fvyjyg5yKgqXEnmP3e0Gp-u2g=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GjJjT5d08pGZZfE1Fvyjyg5yKgqXEnmP3e0Gp-u2g=s96-c', NULL, '2020-12-20 22:56:31', '2020-12-20 22:56:31'),
(15, '111103267545712699233', 'Danda Sravan', 'dandas@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GhmF2FmZeXDFUrJrEOiNmQK1kxVydphrdloWJUg=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GhmF2FmZeXDFUrJrEOiNmQK1kxVydphrdloWJUg=s96-c', NULL, '2020-12-21 03:05:00', '2020-12-21 03:05:00'),
(16, '111221152687073615832', 'Kanchan Manna', 'kanchanm@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh4.googleusercontent.com/-hBLX3tcNb4s/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmU2xW_Tr_uKGI0_hSoAKiXdYRnKw/s96-c/photo.jpg', 'https://lh4.googleusercontent.com/-hBLX3tcNb4s/AAAAAAAAAAI/AAAAAAAAAAA/AMZuucmU2xW_Tr_uKGI0_hSoAKiXdYRnKw/s96-c/photo.jpg', NULL, '2020-12-21 14:50:35', '2020-12-21 14:50:35'),
(17, '117008660563332754602', 'Sujith Thomas', 'sujitht@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GifC_fc0sk8pSgETZ-LsGyhEhW51TMXU6tS2DG2=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GifC_fc0sk8pSgETZ-LsGyhEhW51TMXU6tS2DG2=s96-c', NULL, '2020-12-21 16:33:07', '2020-12-21 16:33:07'),
(18, '110699123104851684458', 'Ramprasad S. Joshi', 'rsj@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GiDmY61tSUb2MmjNugpW1cyesXKl_XPMGyFUZk65A=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GiDmY61tSUb2MmjNugpW1cyesXKl_XPMGyFUZk65A=s96-c', NULL, '2020-12-21 16:51:24', '2020-12-21 16:51:24'),
(19, '103828444953545563094', 'Raj Kumar Jaiswal', 'rajj@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh6.googleusercontent.com/-O8tefNkjBDc/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuckjYUSl-qq0g50eTR87hPlFqQm89A/s96-c/photo.jpg', 'https://lh6.googleusercontent.com/-O8tefNkjBDc/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuckjYUSl-qq0g50eTR87hPlFqQm89A/s96-c/photo.jpg', NULL, '2020-12-21 19:29:35', '2020-12-21 19:29:35'),
(20, '108469398427761706197', 'Ravindra Kumar Jangir', 'ravindrajangir@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GidapPiOfKK6FY8fejXXCxSYX-g0uO0p9-fOKvnEQ=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GidapPiOfKK6FY8fejXXCxSYX-g0uO0p9-fOKvnEQ=s96-c', NULL, '2020-12-21 22:06:24', '2020-12-21 22:06:24'),
(21, '104413992366685476168', 'Baiju Krishnan', 'baijuk@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GiX3-Vwg19YOJc_-EEchRoPOZLmWeEC6Wod5xhsUQ=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GiX3-Vwg19YOJc_-EEchRoPOZLmWeEC6Wod5xhsUQ=s96-c', NULL, '2020-12-22 18:40:08', '2020-12-22 18:40:08'),
(22, '106402616139062699440', 'Shreenivas A Naik', 'shreenivasn@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/-hZ8kYLD85Rc/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuclS-KRr5-DjhAHHoyY-YVBxDsMgIw/s96-c/photo.jpg', 'https://lh3.googleusercontent.com/-hZ8kYLD85Rc/AAAAAAAAAAI/AAAAAAAAAAA/AMZuuclS-KRr5-DjhAHHoyY-YVBxDsMgIw/s96-c/photo.jpg', NULL, '2020-12-22 18:49:54', '2020-12-22 18:49:54'),
(23, '116605258274397699792', 'Swati Agarwal', 'swatia@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GjpjE47iW8Kx2X6I-Hc_u4cAg-brvP3-o632vht=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GjpjE47iW8Kx2X6I-Hc_u4cAg-brvP3-o632vht=s96-c', NULL, '2020-12-29 00:23:54', '2020-12-29 00:23:54'),
(24, '112473494686078073063', 'Sougata Sen', 'sougatas@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GjRQH16E2z2HHhGjoeRCYgusp6k_SFxL7f_NCkh=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GjRQH16E2z2HHhGjoeRCYgusp6k_SFxL7f_NCkh=s96-c', NULL, '2021-11-12 05:00:47', '2021-11-12 05:00:47'),
(25, '108700383973671502824', 'Aditya Challa', 'adityac@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a/AATXAJy8iYT4QzzFCi1E77UCWtw2gXFJRC6cDufFgQ2Y=s96-c', 'https://lh3.googleusercontent.com/a/AATXAJy8iYT4QzzFCi1E77UCWtw2gXFJRC6cDufFgQ2Y=s96-c', NULL, '2021-11-12 05:48:44', '2021-11-12 05:48:44'),
(26, '112195061987509081532', 'Snehanshu Saha', 'snehanshus@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GjygEdfZbGTqle8My8sGQ5lC7wzFYBihgNRl71asQ=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GjygEdfZbGTqle8My8sGQ5lC7wzFYBihgNRl71asQ=s96-c', NULL, '2021-11-12 05:49:39', '2021-11-12 05:49:39'),
(27, '115970371796385917367', 'Rizwan Parveen', 'rizwanp@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GgTwjENzrDOp58JmUzkuc-B4a1az1HccIyQ5q7o=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GgTwjENzrDOp58JmUzkuc-B4a1az1HccIyQ5q7o=s96-c', NULL, '2021-11-12 05:53:49', '2021-11-12 05:53:49'),
(28, '104189303667437507793', 'Pritam Bhattacharya', 'pritamb@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GjTiG5mQSWGLYZ9rCX4CGEQmykeZM0X0Tdqfsry=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GjTiG5mQSWGLYZ9rCX4CGEQmykeZM0X0Tdqfsry=s96-c', NULL, '2021-11-12 07:42:01', '2021-11-12 07:42:01'),
(29, '100438075124973310073', 'Surjya Ghosh', 'surjyag@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a/AATXAJy8WGLDL0DgxxaGQmBTGU_8t7WGGBvoFWB3Abxa=s96-c', 'https://lh3.googleusercontent.com/a/AATXAJy8WGLDL0DgxxaGQmBTGU_8t7WGGBvoFWB3Abxa=s96-c', NULL, '2021-11-12 11:04:34', '2021-11-12 11:04:34'),
(30, '100671376625869491962', 'Dr. Biju K Raveendran', 'biju@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a-/AOh14GiuQ2eHSBoC7Y-u39lIHobK6TXNYohdjaXhEFDX=s96-c', 'https://lh3.googleusercontent.com/a-/AOh14GiuQ2eHSBoC7Y-u39lIHobK6TXNYohdjaXhEFDX=s96-c', NULL, '2021-11-12 23:14:00', '2021-11-12 23:14:00'),
(31, '117842694339347132556', 'Tanmay Tulsidas Verlekar', 'tanmayv@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a/AATXAJznu175b3CgR7YdJiUe_6i4JfyXK1_03wELXfQp=s96-c', 'https://lh3.googleusercontent.com/a/AATXAJznu175b3CgR7YdJiUe_6i4JfyXK1_03wELXfQp=s96-c', NULL, '2021-11-17 09:47:13', '2021-11-17 09:47:13'),
(32, '116092564797059482214', 'Shubhangi K Gawali', 'shubhangi@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a/AEdFTp4ZL2Laf9R9AZlx6t6Rsb6Ka_QmefLLOTI3HBtSeQ=s96-c', 'https://lh3.googleusercontent.com/a/AEdFTp4ZL2Laf9R9AZlx6t6Rsb6Ka_QmefLLOTI3HBtSeQ=s96-c', NULL, '2022-12-15 23:36:43', '2022-12-15 23:36:43'),
(33, '116089411451470202533', 'Basabdatta Bhattacharya', 'basabdattab@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a/AEdFTp7mzDc28WI8JmumqKQrtZpAiMy2tcrEs11LJ9qs=s96-c', 'https://lh3.googleusercontent.com/a/AEdFTp7mzDc28WI8JmumqKQrtZpAiMy2tcrEs11LJ9qs=s96-c', NULL, '2022-12-18 10:35:39', '2022-12-18 10:35:39'),
(34, '114049219141851416547', 'Arnab Kumar Paul', 'arnabp@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a/AEdFTp52Hk_S4M1bDRaphzRUBDF0vhnzeb2oAZC4woWQ=s96-c', 'https://lh3.googleusercontent.com/a/AEdFTp52Hk_S4M1bDRaphzRUBDF0vhnzeb2oAZC4woWQ=s96-c', NULL, '2022-12-23 10:00:39', '2022-12-23 10:00:39'),
(35, '103666114738912779398', 'Swaroop Joshi', 'swaroopj@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a/AEdFTp6Wtt507h10K9IWkK1ciHAUAFaLs4crSuIoRMVe=s96-c', 'https://lh3.googleusercontent.com/a/AEdFTp6Wtt507h10K9IWkK1ciHAUAFaLs4crSuIoRMVe=s96-c', NULL, '2022-12-27 04:56:07', '2022-12-27 04:56:07'),
(36, '102956089307624581340', 'A Baskar', 'abaskar@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a/AEdFTp4D3Nj60Iz4YYY1Rmc9JsGw93MFFXv4mRSu6WN_1A=s96-c', 'https://lh3.googleusercontent.com/a/AEdFTp4D3Nj60Iz4YYY1Rmc9JsGw93MFFXv4mRSu6WN_1A=s96-c', NULL, '2022-12-27 05:37:14', '2022-12-27 05:37:14'),
(37, '115621229392951643735', 'Harikrishnan N B', 'harikrishnannb@goa.bits-pilani.ac.in', NULL, NULL, 'https://lh3.googleusercontent.com/a/AEdFTp4f1SygC3tuM6_Zlf8h4XWue1qtBSOtyfj4kVrS=s96-c', 'https://lh3.googleusercontent.com/a/AEdFTp4f1SygC3tuM6_Zlf8h4XWue1qtBSOtyfj4kVrS=s96-c', NULL, '2023-01-04 23:56:13', '2023-01-04 23:56:13');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `articletypes`
--
ALTER TABLE `articletypes`
  ADD PRIMARY KEY (`articleid`),
  ADD UNIQUE KEY `articletypes_id_index` (`articleid`);

--
-- Indexes for table `authortypes`
--
ALTER TABLE `authortypes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `authirtypes_id_index` (`id`);

--
-- Indexes for table `broadareas`
--
ALTER TABLE `broadareas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `broadareas_id_index` (`id`);

--
-- Indexes for table `campuses`
--
ALTER TABLE `campuses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `campuses_id_index` (`id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `categories_id_index` (`id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `departments_id_index` (`id`),
  ADD KEY `departments_campusid_foreign` (`campusid`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `impactfactors`
--
ALTER TABLE `impactfactors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `impactfactors_id_index` (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`);

--
-- Indexes for table `productprices`
--
ALTER TABLE `productprices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `productprices_product_id_foreign` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pubdtls`
--
ALTER TABLE `pubdtls`
  ADD PRIMARY KEY (`slno`,`pubhdrid`),
  ADD KEY `pubdtls_slno_index` (`slno`),
  ADD KEY `pubdtls_pubhdrid_foreign` (`pubhdrid`);

--
-- Indexes for table `pubhdrs`
--
ALTER TABLE `pubhdrs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pubhdrs_pubhdrid_index` (`id`),
  ADD KEY `pubhdrs_categoryid_foreign` (`categoryid`),
  ADD KEY `pubhdrs_authortypeid_foreign` (`authortypeid`),
  ADD KEY `pubhdrs_rankingid_foreign` (`rankingid`),
  ADD KEY `pubhdrs_broadareaid_foreign` (`broadareaid`),
  ADD KEY `article_foreign` (`articletypeid`),
  ADD KEY `user_foreign` (`userid`);

--
-- Indexes for table `pubuserdetails`
--
ALTER TABLE `pubuserdetails`
  ADD KEY `pubuserdetails_pubid_index` (`pubid`) USING BTREE,
  ADD KEY `userid_foreign` (`userid`);

--
-- Indexes for table `rankings`
--
ALTER TABLE `rankings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rankings_id_index` (`id`);

--
-- Indexes for table `userregistrations`
--
ALTER TABLE `userregistrations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `userregistrations_userid_unique` (`userid`),
  ADD UNIQUE KEY `userregistrations_id_index` (`id`),
  ADD KEY `userregistrations_campusid_foreign` (`campusid`),
  ADD KEY `userregistrations_departmentid_foreign` (`departmentid`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `articletypes`
--
ALTER TABLE `articletypes`
  MODIFY `articleid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `authortypes`
--
ALTER TABLE `authortypes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `broadareas`
--
ALTER TABLE `broadareas`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `campuses`
--
ALTER TABLE `campuses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT for table `pubhdrs`
--
ALTER TABLE `pubhdrs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=285;

--
-- AUTO_INCREMENT for table `rankings`
--
ALTER TABLE `rankings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=340;

--
-- AUTO_INCREMENT for table `userregistrations`
--
ALTER TABLE `userregistrations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `departments`
--
ALTER TABLE `departments`
  ADD CONSTRAINT `departments_campusid_foreign` FOREIGN KEY (`campusid`) REFERENCES `campuses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pubhdrs`
--
ALTER TABLE `pubhdrs`
  ADD CONSTRAINT `user_foreign` FOREIGN KEY (`userid`) REFERENCES `users` (`id`);

--
-- Constraints for table `pubuserdetails`
--
ALTER TABLE `pubuserdetails`
  ADD CONSTRAINT `pubuserdetails_pubid_foreign` FOREIGN KEY (`pubid`) REFERENCES `pubhdrs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `userid_foreign` FOREIGN KEY (`userid`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `userregistrations`
--
ALTER TABLE `userregistrations`
  ADD CONSTRAINT `userregistrations_campusid_foreign` FOREIGN KEY (`campusid`) REFERENCES `campuses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `userregistrations_departmentid_foreign` FOREIGN KEY (`departmentid`) REFERENCES `departments` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
