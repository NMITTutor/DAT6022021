-- This is an example of a cut down game system
-- Can you figure out what the game is?
-- Put comments in describing the SQL and its purpose.
--
DROP DATABASE if exists sapodb ;
CREATE DATABASE sapodb;
USE sapodb; -- REPLACE sapodb WITH YOUR DATABASE NAME

DROP USER if exists 'sapo'@'localhost';

CREATE USER 'sapo'@'localhost' IDENTIFIED BY '53211';
GRANT ALL ON sapodb.* TO 'sapo'@'localhost';

DROP TABLE IF EXISTS tblClickTarget;
CREATE TABLE tblClickTarget(
   UserName varchar(50) PRIMARY KEY,
   `Password` varchar(50) NOT NULL,
   Attempts INT DEFAULT 0,
   LOCKED_OUT BOOL DEFAULT FALSE,
   X INT DEFAULT 100 , Y INT DEFAULT 100, 
   Strength INT DEFAULT 10
);
-- The CREATE TABLE and all other table specific DML could be put
-- into a PROCEDURE. I would expect you to do that for your Milestone One.
INSERT tblClickTarget( UserName, `Password`)
VALUES ('ToddC','12345'),
       ('Zorro','1357') ;

DROP PROCEDURE IF EXISTS Login;

DELIMITER $$

CREATE PROCEDURE Login( IN pUserName VARCHAR(50), IN pPassword  VARCHAR(50))
COMMENT 'Check login'
BEGIN
    DECLARE numAttempts INT DEFAULT 0;
    
	-- 'Check for valid login', 
    -- if valid then select message "Logged in" and reset Attempts to 0, 
    IF EXISTS ( SELECT * 
                FROM tblClickTarget
                WHERE 
                  UserName = pUserName AND
                  `Password` = pPassword 
                  ) 
	THEN
		UPDATE tblClickTarget 
        SET Attempts = 0
        WHERE
           UserName = pUserName;
           
		SELECT 'Logged In' as Message;
    
    ELSE 
    -- else add to Attempts ,
        IF EXISTS(SELECT * FROM tblClickTarget WHERE UserName = pUserName) THEN 
        
			SELECT Attempts 
			INTO numAttempts
			FROM tblClickTarget
			WHERE 
			   UserName = pUserName;
			
			SET numAttempts = numAttempts + 1;
			
			IF numAttempts > 5 THEN 
			-- if Attempts > 5 then set lockout  to true and select message 'locked out' 
				UPDATE tblClickTarget 
				SET LOCKED_OUT = True
				WHERE 
					 UserName = pUserName ;
					 
				 SELECT 'Locked Out' AS Message;
				 
			ELSE
			-- else select message 'Bad  password'
                 UPDATE tblClickTarget
                 SET Attempts = numAttempts
                 WHERE 
                    UserName = pUserName;
                    
				 SELECT 'Invalid user name and password';
			END IF;
      ELSE 
		SELECT 'Invalid user name and password';
      END IF;

    
    END IF;
                  
END $$
DELIMITER ;

call Login('ToddC','1234');
call Login('ToddC','1234');
call Login('ToddC','1234');
call Login('ToddC','1234');
call Login('ToddC','1234');
call Login('ToddC','1234');

call Login('ToddC', '12345') ;

SELECT UserName, Attempts 
FROM tblClickTarget;

/*
DROP PROCEDURE IF EXISTS AddUserName;
DELIMITER $$
CREATE PROCEDURE AddUserName(IN pUserName VARCHAR(50))
BEGIN
  IF EXISTS (SELECT * 
     FROM tblClickTarget
     WHERE Username = pUserName) THEN
  BEGIN
     SELECT 'NAME EXISTS' AS MESSAGE;
  END;
  ELSE 
     INSERT INTO tblClickTarget(UserName,X,Y)
     VALUE (pUserName, 100,100); -- Need to check the X,Y location
     SELECT 'ADDED USER NAME' AS MESSAGE;
  END IF;
  
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS PlayerQuit;
DELIMITER $$
CREATE PROCEDURE PlayerQuit(pUserName VARCHAR(50))
BEGIN
	IF EXISTS ( SELECT * FROM tblClickTarget WHERE UserName = pUserName) THEN
     DELETE FROM tblClickTarget WHERE UserName = pUserName;
     SELECT 'QUIT' AS MESSAGE;
	ELSE
     SELECT 'PLAYER DOES NOT EXIST' AS MESSAGE;
	END IF;
END$$ -- PlayerQuit

DROP PROCEDURE IF EXISTS HitFrom$$
CREATE PROCEDURE HitFrom(pUserName varchar (50), pX integer, pY integer)
BEGIN
   IF EXISTS (SELECT * FROM tblClickTarget WHERE Username = pUserName) THEN
   BEGIN
      -- Target area is within 10 of the click at (X,Y)
      SELECT count(*) 
      FROM tblClickTarget
      WHERE 
        (pX >=  X - 10 AND pX <= X + 10 ) AND
        (pY >= Y - 10 AND pY <= Y + 10) AND 
        Username <> pUserName
	  INTO @HitCount;
      
      UPDATE tblClickTarget
      SET Strength = Strength + @HitCount
      WHERE 
            (NOT @HitCount IS NULL AND @HitCount <> 0 ) AND
            Username = pUsername;
            
	 UPDATE tblClickTarget
     Set Strength = Strength -1
     WHERE
        (pX >=  X - 10 AND pX <= X + 10 ) AND
        (pY >= Y - 10 AND pY <= Y + 10) AND 
        Username <> pUserName;
      
      DELETE FROM tblClickTarget
      WHERE Strength <= 0;
      
      SELECT 'PLAYED ' AS MESSAGE;
   END;
   ELSE
    SELECT 'PLAYER GONE' AS MESSAGE;
   END IF;
END$$



DROP PROCEDURE IF EXISTS GetAllPlayers$$
CREATE PROCEDURE GetAllPlayers()
BEGIN
	SELECT UserName, Strength, X, Y
    FROM tblClickTarget ;
END$$
DELIMITER $$
DROP PROCEDURE IF EXISTS Move$$
CREATE PROCEDURE Move(pMaxX INT, pMaxY INT)
BEGIN
  -- MOVES +/- 10 pixels, this might be boring, 
  -- also it does not check it the target
  -- moves out of bounds, presumes MinX and MinY are 0.
  SET @newX = ROUND(RAND() * 20) - 10;
  SET @newY = ROUND(RAND() * 20) - 10;
  
 SELECT count(*)
 FROM tblClickTarget 
 WHERE
      ((X + @newX) >= 0 AND (X + @newX) <= pMaxX) AND
      ((Y + @newY) >= 0 AND (Y + @newY) <= pMaxY)
 INTO @Count;
  
  UPDATE tblClickTarget
  SET 
      X =  X + @newX , 
      Y =  Y +  @newY 
  WHERE
     ((X + @newX) >= 0 AND (X + @newX) <= pMaxX) AND
	((Y + @newY) >= 0 AND (Y + @newY) <= pMaxY);
     
  SELECT CONCAT('Move Updated ' , @Count, ' click target positions. Within bounds  [',0,',',0,',',pMaxX,',',pMaXY,']') as Message; 
END$$

--
-- TESTING AREA

-- This procedure is "work in progress" 
DROP PROCEDURE IF EXISTS TestPlay$$
CREATE PROCEDURE TestPlay(pNumberOfPlayers INT)
BEGIN
      DECLARE counter INT DEFAULT 0;
       REPEAT
		 SET @NewName = CONCAT('Asterix', counter);
         CALL AddUserName(@NewName);
         SET counter = counter + 1;
       UNTIL counter > pNumberOfPlayers
       END REPEAT ;
END$$

DELIMITER ;
-- Call TestPlay(100);

Call AddUserName('Asterix');
Call AddUserName('Obelix');
Call AddUserName('Obelix');
Call HitFrom('Asterix',95,110);
Call HitFrom('Asterix',1,1);
Call HitFrom('Obelix',95,110);
Call HitFrom('Obelix',95,100);

Call GetAllPlayers();
CALL Move(1024,1024);

-- SELECT * 
-- FROM tblClickTarget;
Call GetAllPlayers();

-- Call PlayerQuit('Asterix');
*/