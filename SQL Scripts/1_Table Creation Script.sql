DROP TABLE EXAM_SETTER
CASCADE CONSTRAINTS
PURGE;

DROP TABLE EXAM
CASCADE CONSTRAINTS
PURGE;

DROP TABLE ENTRANCE_EXAM
CASCADE CONSTRAINTS
PURGE;

DROP TABLE VOLUNTEER
CASCADE CONSTRAINTS
PURGE;

DROP TABLE CHILD
CASCADE CONSTRAINTS
PURGE;

DROP TABLE CHILD_EXAM
CASCADE CONSTRAINTS
PURGE;

DROP TABLE SCHOOL
CASCADE CONSTRAINTS
PURGE
;
DROP TABLE FEE
CASCADE CONSTRAINTS
PURGE;

DROP TABLE STUDENT
CASCADE CONSTRAINTS
PURGE;

DROP TABLE DONOR
CASCADE CONSTRAINTS
PURGE;


DROP TABLE DONATION
CASCADE CONSTRAINTS
PURGE;

DROP TABLE DONOR_STUDENT
CASCADE CONSTRAINTS
PURGE;

DROP SEQUENCE REGULAR;

CREATE TABLE VOLUNTEER(
        VOLUNTEER_ID                INT             PRIMARY KEY,
        VOLUNTEER_NAME              VARCHAR2(50)    NOT NULL,
        VOLUNTEER_PHONE_NUMBER      INT             NOT NULL CHECK(VOLUNTEER_PHONE_NUMBER BETWEEN 7000000000 AND 9999999999),
        VOLUNTEER_DOOR_NO           VARCHAR2(10),
        VOLUNTEER_STREET            VARCHAR2(30),
        VOLUNTEER_LOCALITY          VARCHAR2(40),
        VOLUNTEER_MAIL_ID           VARCHAR2(50)    NOT NULL CHECK(VOLUNTEER_MAIL_ID LIKE '%_@__%.__%')
            );
            
CREATE TABLE SCHOOL(
        SCHOOL_ID                       INT           PRIMARY KEY,
        SCHOOL_NAME                     VARCHAR2(50)  NOT NULL,
        SCHOOL_LOCALITY                 VARCHAR2(30)  NOT NULL,
        SCHOOL_ADMIN_NAME               VARCHAR2(50)  NOT NULL,
        SCHOOL_ADMIN_PHONE              INT           NOT NULL CHECK (SCHOOL_ADMIN_PHONE BETWEEN 7000000000 AND 9999999999),
        SCHOOL_ADMIN_EMAIL              VARCHAR2(30)  NOT NULL
); 

CREATE TABLE FEE(
        FEE_ID                          INT           PRIMARY KEY,  
        SCHOOL_ID                       INT           NOT NULL,
        FEE_GRADE                       INT           NOT NULL CHECK(FEE_GRADE BETWEEN 1 AND 10) ,
        FEE_AMOUNT                      INT           NOT NULL,
CONSTRAINT FK_E_S FOREIGN KEY (SCHOOL_ID) REFERENCES SCHOOL(SCHOOL_ID)
);

CREATE TABLE EXAM_SETTER(
        EXAM_SETTER_ID              INT             PRIMARY KEY,
        EXAM_SETTER_NAME            VARCHAR2(50)    NOT NULL,
        EXAM_SETTER_PHONE_NUMBER    INT             NOT NULL CHECK(EXAM_SETTER_PHONE_NUMBER BETWEEN 7000000000 AND 9999999999),
        EXAM_SETTER_MAIL_ID         VARCHAR2(50)    CHECK(EXAM_SETTER_MAIL_ID LIKE '%_@__%.__%')
        );
                
CREATE TABLE EXAM(
        EXAM_ID                     INT             PRIMARY KEY,
        EXAM_GRADE                  INT             NOT NULL ,
        EXAM_DATE                   DATE            NOT NULL,
        EXAM_QUALIFICATION_MARK     NUMBER(3)       NOT NULL CHECK(EXAM_QUALIFICATION_MARK BETWEEN 0 AND 100)
        );

CREATE TABLE ENTRANCE_EXAM(
        ENTRANCE_EXAM_ID            INT             PRIMARY KEY,
        EXAM_SETTER_ID              INT             NOT NULL,
        EXAM_ID                     INT             NOT NULL,
        CONSTRAINT FK_EE_E FOREIGN KEY (EXAM_ID) REFERENCES EXAM(EXAM_ID),
        CONSTRAINT FK_EE_ES FOREIGN KEY (EXAM_SETTER_ID) REFERENCES EXAM_SETTER(EXAM_SETTER_ID)
        );
        
CREATE TABLE CHILD(
        CHILD_ID                    INT           PRIMARY KEY,
        CHILD_NAME                  VARCHAR2(50)  NOT NULL,
        CHILD_AGE                   NUMBER        NOT NULL,
        CHILD_GENDER                CHAR(1)       NOT NULL CHECK (UPPER(CHILD_GENDER) IN ('M','F')),
        CHILD_DOOR_NO               VARCHAR2(10)  NOT NULL,
        CHILD_STREET                VARCHAR2(30)  NOT NULL,
        CHILD_LOCALITY              VARCHAR2(40)  NOT NULL,
        CHILD_CONTACT_NUMBER        INT           NOT NULL CHECK (CHILD_CONTACT_NUMBER BETWEEN 7000000000 AND 9999999999),
        CHILD_UPDATED               CHAR(1)       DEFAULT 'N'
);

CREATE TABLE CHILD_EXAM(
        CHILD_EXAM_ID               INT           PRIMARY KEY,                         
        EXAM_ID                     INT           NOT NULL,
        CHILD_ID                    INT           NOT NULL,
        CHILD_EXAM_MARKS            NUMBER(3)     NOT NULL CHECK(CHILD_EXAM_MARKS BETWEEN 0 AND 100),
CONSTRAINT FK_CE_E FOREIGN KEY (EXAM_ID) REFERENCES EXAM(EXAM_ID),    
CONSTRAINT FK_CE_C FOREIGN KEY (CHILD_ID) REFERENCES CHILD(CHILD_ID)
);
/
ALTER TABLE CHILD_EXAM
ADD CHILD_EXAM_Q_STATUS CHAR ;

UPDATE CHILD_EXAM
SET CHILD_EXAM_Q_STATUS = (CASE WHEN CHILD_EXAM_MARKS > (SELECT EXAM_QUALIFICATION_MARK
                                                        FROM EXAM 
                                                        WHERE CHILD_EXAM.EXAM_ID = EXAM.EXAM_ID) THEN 'Y'
                   ELSE 'N' END) ;

CREATE TABLE DONOR (
        DONOR_REG_ID                    INT              PRIMARY KEY,
        DONOR_NAME                      VARCHAR2(40)     NOT NULL,
        DONOR_REGISTERED_DATE           DATE             NOT NULL,
        DONOR_MONTHLY_DONATION          NUMBER(30,2)     NOT NULL,
        DONOR_REMAINING_AMOUNT          NUMBER(30,2)     DEFAULT -1,
        DONOR_DOOR_NO                   VARCHAR2(10)     NOT NULL,
        DONOR_STREET                    VARCHAR2(30)     NOT NULL,
        DONOR_LOCALITY                  VARCHAR2(40)     NOT NULL,
        DONOR_CONTACT_NUMBER            INT              NOT NULL    CHECK(DONOR_CONTACT_NUMBER BETWEEN 7000000000 AND 9999999999),
        DONOR_EMAIL                     VARCHAR2(50)     CHECK(DONOR_EMAIL LIKE '%_@__%.__%')     
        );

CREATE TABLE STUDENT(
        STUDENT_ID                      CHAR(8)       PRIMARY KEY,
        EXAM_ID                         INT           NOT NULL,
        VOLUNTEER_ID                    INT,
        FEE_ID                          INT,
        STUDENT_NAME                    VARCHAR2(50)  NOT NULL,
        STUDENT_AGE                     INT           NOT NULL,
        STUDENT_GENDER                  CHAR(1)       NOT NULL CHECK (UPPER(STUDENT_GENDER) IN ('M','F')),
        STUDENT_DOOR_NO                 VARCHAR2(10)  NOT NULL,
        STUDENT_STREET                  VARCHAR2(30)  NOT NULL,
        STUDENT_LOCALITY                VARCHAR2(40)  NOT NULL,
        STUDENT_PHONE                   INT           NOT NULL CHECK(STUDENT_PHONE BETWEEN 7000000000 AND 9999999999),
        STUDENT_AMOUNT_REQUIRED         DECIMAL(30,2),  
CONSTRAINT FK_S_FE FOREIGN KEY (FEE_ID) REFERENCES FEE(FEE_ID),
CONSTRAINT FK_S_V FOREIGN KEY (VOLUNTEER_ID) REFERENCES VOLUNTEER(VOLUNTEER_ID),
CONSTRAINT FK_S_EX FOREIGN KEY (EXAM_ID) REFERENCES EXAM(EXAM_ID)
);

------------------------------------------------------------------------
-------------CREATING AN AUTO INDEXING SCRIPT FOR STUDENT ID------------
------------------------------------------------------------------------
CREATE SEQUENCE REGULAR
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER STU_ID 
BEFORE INSERT ON STUDENT 
FOR EACH ROW 
BEGIN
      IF INSERTING AND :NEW.STUDENT_ID IS NULL THEN
      SELECT CONCAT('MAA-',LPAD(REGULAR.NEXTVAL,4,'0')) INTO :NEW.STUDENT_ID FROM SYS.DUAL;
    END IF;
END;
/
ALTER TRIGGER STU_ID ENABLE;

----------------------------------
------END OF AUTO-INDEXING--------
----------------------------------

-------------------------------------------------------------------------------------------
---------UPDATING THE STUDENT TABLE BASED ON THE QUALIFICATION MARK FROM THE EXAM----------
-------------------------------------------------------------------------------------------  
CREATE OR REPLACE VIEW STUDENT_VIEW AS
SELECT C.CHILD_ID, CE.EXAM_ID, C.CHILD_NAME, C.CHILD_AGE, C.CHILD_GENDER, C.CHILD_DOOR_NO, C.CHILD_STREET, C.CHILD_LOCALITY,C.CHILD_CONTACT_NUMBER
FROM CHILD C JOIN CHILD_EXAM CE
ON(C.CHILD_ID = CE.CHILD_ID);

INSERT INTO STUDENT (STUDENT_NAME, STUDENT_AGE, STUDENT_GENDER,STUDENT_DOOR_NO,STUDENT_STREET,STUDENT_LOCALITY,STUDENT_PHONE,EXAM_ID)
SELECT CHILD_NAME, CHILD_AGE, CHILD_GENDER, CHILD_DOOR_NO, CHILD_STREET, CHILD_LOCALITY,CHILD_CONTACT_NUMBER,EXAM_ID FROM STUDENT_VIEW 
WHERE CHILD_ID IN  (SELECT CHILD_id 
 FROM CHILD
 WHERE (CHILD_ID IN (SELECT CHILD_ID 
                  FROM CHILD_EXAM 
                  WHERE (CHILD_EXAM_Q_STATUS = 'Y'))) 
AND (CHILD_UPDATED = 'N'));   
                  
UPDATE CHILD
SET CHILD_UPDATED = 'Y';

-------------------------------------
-------END OF STUDENT INSERTION------
-------------------------------------

CREATE TABLE DONATION (
        DONATION_ID                     INT              PRIMARY KEY,
        DONOR_REG_ID                    INT              NOT NULL,
        DONATION_AMOUNT                 INT              NOT NULL,
        DONATION_MODE                   VARCHAR(10)      NOT NULL     CHECK (UPPER(DONATION_MODE) IN ('CASH', 'CHECK', 'TRANSFER')), 
        DONATION_DATE                   DATE             NOT NULL,
CONSTRAINT FK_D_D FOREIGN KEY(DONOR_REG_ID) REFERENCES DONOR(DONOR_REG_ID)
);

CREATE TABLE DONOR_STUDENT (
        DONOR_STUDENT_ID                INT             PRIMARY KEY,
        DONOR_STUDENT_DONOR_ID          INT             NOT NULL,
        DONOR_STUDENT_STUDENT_ID        CHAR(8)         NOT NULL,
        DONOR_STUDENT_AMOUNT            INT             NOT NULL,
        DISBURSEMENT_DATE               DATE            DEFAULT  TO_DATE('1/1/1900','MM-DD-YYYY')        NOT NULL,
        RECEIPT_UPDATE_DATE             DATE            DEFAULT  TO_DATE('1/1/1900','MM-DD-YYYY')        NOT NULL,
        DONOR_NOTIFIED_DATE             DATE            DEFAULT  TO_DATE('1/1/1900','MM-DD-YYYY')        NOT NULL,
CONSTRAINT FK_DS_S FOREIGN KEY (DONOR_STUDENT_STUDENT_ID) REFERENCES STUDENT(STUDENT_ID), 
CONSTRAINT FK_DS_D FOREIGN KEY (DONOR_STUDENT_DONOR_ID) REFERENCES DONOR(DONOR_REG_ID));

------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------END OF CREATION OF TABLES -----------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
---------EACH TIME A NEW SURVEY IS MADE FOR UNDER-PRIVLEDGED CHILDREN AND AN EXAM IS CONDCTED------
----------THE STUDENT TABLE NEEDS TO BE UPDATED BASED ON THE QUALIFICATION MARK FROM THE EXAM------
---------------------------------------------------------------------------------------------------
