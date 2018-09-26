
------QUERIES------

---------------------------------------------------------------------------------------------------------------
---A QUERY WHICH GIVES A SUMMARY OF CHILDREN THAT GAVE AN EXAM FOR EACH GRADE CONDUCTED IN A PARTICULAR YEAR---
---------------------------------------------------------------------------------------------------------------

SELECT EXAM_GRADE,COUNT(CHILD_ID) AS ATTENDING_BY
FROM EXAM E LEFT JOIN CHILD_EXAM CE 
ON (E.EXAM_ID = CE.EXAM_ID)
WHERE EXTRACT(YEAR FROM E.EXAM_DATE)= &YEAR
GROUP BY EXAM_GRADE
ORDER BY ATTENDING_BY DESC;

---------------------------------------------------------------------------------------------------------------
------A QUERY TO PROVIDE THE DETAILS OF THE DONORS WHO HAVE NOT DONATED FROM SPECIFIED NUMBER OF DAYS.---------
---------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW DON AS
SELECT DT.DONOR_REG_ID, D.DONOR_NAME, D.DONOR_CONTACT_NUMBER,CEIL(SYSDATE - MAX(DONATION_DATE))DAYS
FROM DONATION DT JOIN DONOR D ON DT.DONOR_REG_ID = D.DONOR_REG_ID
GROUP BY DT.DONOR_REG_ID, D.DONOR_NAME,D.DONOR_CONTACT_NUMBER;

SELECT DONOR_NAME,DONOR_REG_ID,DONOR_CONTACT_NUMBER,DAYS "DAYS SINCE LAST DONATION"
FROM DON
WHERE DAYS > &DAYS_AFTER_LAST_DONATION
ORDER BY DAYS DESC ; 

---------------------------------------------------------------------------------------------------------------
-----FOR EACH STUDENT WHOSE STUDENT ID IS ENTERED, TO OUTPUT THE DONOR WITH THE LEAST POSSIBLE DONATION   -----
-----AMOUNT WHICH IS NOT YET ASSIGNED TO ANY OTHER STUDENT AND IS AVAILABLE TO INDEPENDENTLY FULFILL THE  ----- 
-----STUDENT FEE REQUIREMENT. IN CASE, MORE THAN ONE USERS HAVE THE SAME AMOUNT, OUTPUT THE ONE WHOSE     -----
-----DONATION HAS BEEN LEAST USED.                                                                        -----
---------------------------------------------------------------------------------------------------------------

SELECT D.DONOR_REG_ID, D.DONOR_REMAINING_AMOUNT
FROM DONOR D
WHERE D.DONOR_REMAINING_AMOUNT = (SELECT MIN(D1.DONOR_REMAINING_AMOUNT) 
                                FROM DONOR D1
                                WHERE D1.DONOR_REMAINING_AMOUNT >= (SELECT S.STUDENT_AMOUNT_REQUIRED
                                                                    FROM STUDENT S
                                                                    WHERE STUDENT_ID = '&STUDENT_ID'))
AND ROWNUM =1
ORDER BY DONOR_MONTHLY_DONATION DESC ;

---------------------------------------------------------------------------------------------------------------
------A QUERY TO OUTPUT ALL THE STUDENTS WHO HAVE RECEIVED A DONATION BUT HAVE NOT UPDATED THE NGO YET --------
------ABOUT THE PAYMENT OF THE FEE AND THE RESPECTIVE AMOUNT.                                           --------
---------------------------------------------------------------------------------------------------------------
SELECT DISTINCT DONOR_STUDENT_STUDENT_ID
FROM DONOR_STUDENT
WHERE  DONOR_STUDENT.RECEIPT_UPDATE_DATE < DONOR_STUDENT.DISBURSEMENT_DATE;

---------------------------------------------------------------------------------------------------------------
----QUERY TO LIST ALL THE VOLUNTEERS WHO HAVE PENDING UPDATES THAT NEED TO BE MADE TO THE DONOR ABOUT     -----
----RECEIPT OF THE DONATIONS THAT HAVE BEEN MADE.                                                         -----
---------------------------------------------------------------------------------------------------------------
SELECT VOLUNTEER_NAME
FROM VOLUNTEER V JOIN STUDENT S
ON( V.VOLUNTEER_ID = S.VOLUNTEER_ID)
JOIN DONOR_STUDENT DS
ON(  DS. DONOR_STUDENT_STUDENT_ID = S.STUDENT_ID)
WHERE DS.DONOR_NOTIFIED_DATE < DS.RECEIPT_UPDATE_DATE;
