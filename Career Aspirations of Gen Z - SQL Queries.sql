/*1. What percentage of male and female Genz wants to go to office every day? (Use join function & don't take merged datasets)*/

SELECT * FROM
(SELECT CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM personalized_info WHERE LOWER(Gender) LIKE 'male%'),2),'%') 
AS male_office_everyday
FROM learning_aspirations l JOIN personalized_info p 
ON l.ResponseID = p.ResponseID
WHERE LOWER(l.PreferredWorkingEnvironment) LIKE 'every day office environment'
AND LOWER(p.Gender) LIKE 'male%') males
JOIN
(SELECT CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM personalized_info WHERE LOWER(Gender) LIKE 'female%'),2),'%')
 AS female_office_everyday
FROM learning_aspirations l JOIN personalized_info p 
ON l.ResponseID = p.ResponseID
WHERE LOWER(l.PreferredWorkingEnvironment) LIKE 'every day office environment'
AND LOWER(p.Gender) LIKE 'female%') females;

/*2. What percentage of Genz's who have chosen their career in business operations are most likely to be 
influenced by their parents? (Use join function & don't take merged datasets)*/

SELECT CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(ResponseID) FROM personalized_info),2), '%') AS business_ops_parents
FROM learning_aspirations
WHERE LOWER(ClosestAspirationalCareer) LIKE 'business operations%'
AND LOWER(CareerInfluenceFactor) LIKE 'my parents';

/*3. What percentage of Genz prefer opting for higher studies, give a gender wise approach? 
(Use join function & don't take merged datasets)*/

SELECT * FROM(
SELECT CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(ResponseID) FROM personalized_info WHERE LOWER(Gender) LIKE 'male%'),2), '%')
AS higher_edu_male
FROM learning_aspirations l JOIN personalized_info p 
ON l.ResponseID = p.ResponseID
WHERE LOWER(HigherEducationAbroad) LIKE 'yes%'
AND LOWER(p.Gender) LIKE 'male%') males
JOIN
(SELECT CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(ResponseID) FROM personalized_info WHERE LOWER(Gender) LIKE 'female%'),2), '%')
AS higher_edu_female
FROM learning_aspirations l JOIN personalized_info p 
ON l.ResponseID = p.ResponseID
WHERE LOWER(HigherEducationAbroad) LIKE 'yes%'
AND LOWER(p.Gender) LIKE 'female%') females;

/*4. What percentage of Genz are willing and not willing to work for a company whose mission is 
misaligned with their public actions or even their products? 
(give gender based split) (Use join function & don't take merged datasets)*/

SELECT * FROM(
SELECT CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(ResponseID) FROM personalized_info WHERE LOWER(Gender) LIKE 'male%'),2), '%')
AS misaligned_mission_yes_male
FROM mission_aspirations m JOIN personalized_info p 
ON m.ResponseID = p.ResponseID
WHERE LOWER(Gender) LIKE 'male%'
AND LOWER(MisalignedMissionLikelihood) LIKE 'will work for them') male_yes
JOIN
(SELECT CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(ResponseID) FROM personalized_info WHERE LOWER(Gender) LIKE 'male%'),2), '%')
AS misaligned_mission_no_male
FROM mission_aspirations m JOIN personalized_info p 
ON m.ResponseID = p.ResponseID
WHERE LOWER(Gender) LIKE 'male%'
AND LOWER(MisalignedMissionLikelihood) LIKE 'will not work for them') male_no
JOIN
(SELECT CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(ResponseID) FROM personalized_info WHERE LOWER(Gender) LIKE 'female%'),2), '%')
AS misaligned_mission_yes_female
FROM mission_aspirations m JOIN personalized_info p 
ON m.ResponseID = p.ResponseID
WHERE LOWER(Gender) LIKE 'female%'
AND LOWER(MisalignedMissionLikelihood) LIKE 'will work for them') female_yes
JOIN
(SELECT CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(ResponseID) FROM personalized_info WHERE LOWER(Gender) LIKE 'female%'),2), '%')
AS misaligned_mission_no_female
FROM mission_aspirations m JOIN personalized_info p 
ON m.ResponseID = p.ResponseID
WHERE LOWER(Gender) LIKE 'female%'
AND LOWER(MisalignedMissionLikelihood) LIKE 'will not work for them') female_no;

/*5. What is the most suitable suitable working environment according to female genzs?*/

WITH work_environment_gender AS 
(SELECT p.Gender, l.PreferredWorkingEnvironment, COUNT(p.ResponseID) AS work_environment_count
FROM personalized_info p JOIN learning_aspirations l 
ON p.ResponseID = l.ResponseID
GROUP BY p.Gender, l.PreferredWorkingEnvironment)
 
SELECT PreferredWorkingEnvironment AS female_most_preferred
FROM work_environment_gender
WHERE work_environment_count = (SELECT MAX(work_environment_count) FROM work_environment_gender WHERE Gender LIKE 'Female%');

/*6. What is the percentage of Males who expected a salary 5 years > 50k and also work under employers 
who appreciates learning but doesn't enable a learning environment?*/

SELECT CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(ResponseID) FROM personalized_info WHERE LOWER(Gender) LIKE 'male%'),2), '%') 
AS male_percent
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID
JOIN manager_aspirations ma
ON p.ResponseID = ma.ResponseID
WHERE LOWER(Gender) LIKE 'male%'
AND PreferredEmployer LIKE 'Employers who appreciates learning but doesn''t enables an learning environment'
AND ExpectedSalary5Years NOT LIKE '30k to 50k';

/*7. Find out the correlation between gender about their preferred work setup? (google about finding the correlation formula)*/

SELECT ROUND(SQRT((chi_square_sum / total_count) / (LEAST(gender_count, team_pref_count) - 1)),3) AS cramers_v
FROM 
( SELECT SUM((observed - expected) * (observed - expected) / expected) AS chi_square_sum,
COUNT(*) AS total_count, COUNT(DISTINCT Gender) AS gender_count, COUNT(DISTINCT PreferredWorkSetup) AS team_pref_count
FROM 
(SELECT Gender, PreferredWorkSetup, COUNT(*) AS observed,
(SUM(COUNT(*)) OVER (PARTITION BY Gender) * SUM(COUNT(*)) OVER (PARTITION BY PreferredWorkSetup)) / total_count AS expected
FROM personalized_info p JOIN manager_aspirations m
ON p.ResponseID = m.ResponseID
CROSS JOIN 
(SELECT COUNT(*) AS total_count FROM master_table) total_counts
WHERE Gender IS NOT NULL AND PreferredWorkSetup IS NOT NULL
GROUP BY Gender, PreferredWorkSetup) AS observed_expected
) AS chi_square_values;


/*8. Calculate the total number of Female who aspire to work in their Closest Aspirational Career 
and have a No Social Impact Likelihood of "1 to 5".*/

SELECT COUNT(p.ResponseID) AS female_aspirational_nosocialimpact
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID
JOIN learning_aspirations l
ON p.ResponseID = l.ResponseID
WHERE LOWER(Gender) LIKE 'female%'
AND ClosestAspirationalCareer IS NOT NULL
AND NoSocialImpactLikelihood BETWEEN 1 AND 5;

/*9. Retrieve the Male who are interested in Higher Education Abroad and have a Career Influence Factor of "My Parents".*/

SELECT p.ResponseID, Gender, HigherEducationAbroad, CareerInfluenceFactor
FROM personalized_info p JOIN learning_aspirations l
ON p.ResponseID = l.ResponseID
WHERE LOWER(Gender) LIKE 'male%'
AND LOWER(CareerInfluenceFactor) LIKE 'my parents'
AND LOWER(HigherEducationAbroad) LIKE 'yes%';

/*10. Determine the percentage of gender who have a No Social Impact Likelihood of "8 to 10" 
among those who are interested in Higher Education Abroad*/

SELECT * FROM 
(SELECT CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM personalized_info WHERE LOWER(Gender) LIKE 'male%'),3), '%') AS male_percent
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID
JOIN learning_aspirations l
ON p.ResponseID = l.ResponseID
WHERE LOWER(Gender) LIKE 'male%'
AND NoSocialImpactLikelihood BETWEEN 8 AND 10
AND LOWER(HigherEducationAbroad) LIKE 'yes%') males
JOIN
(SELECT CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM personalized_info WHERE LOWER(Gender) LIKE 'female%'),3), '%') AS female_percent
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID
JOIN learning_aspirations l
ON p.ResponseID = l.ResponseID
WHERE LOWER(Gender) LIKE 'female%'
AND NoSocialImpactLikelihood BETWEEN 8 AND 10
AND LOWER(HigherEducationAbroad) LIKE 'yes%') females;

/*11. Give a detailed split of the GenZ preferences to work with Teams, Data should include Male, 
Female, and overall in counts and also the overall in %*/

SELECT males.PreferredWorkSetup, males.preference_count_male, males.preference_percent_male,
females.preference_count_female, females.preference_percent_female, 
overall.preference_count_overall, preference_percent_overall 
FROM
(SELECT PreferredWorkSetup, COUNT(p.ResponseID) AS preference_count_overall, 
CONCAT(ROUND((100.0*COUNT(p.ResponseID)/(SELECT COUNT(*) FROM personalized_info)),3), '%') AS preference_percent_overall
FROM personalized_info p JOIN manager_aspirations m
ON p.ResponseID = m.ResponseID
GROUP BY PreferredWorkSetup) overall
LEFT JOIN
(SELECT PreferredWorkSetup, Gender, COUNT(p.ResponseID) AS preference_count_male, 
CONCAT(ROUND((100.0*COUNT(p.ResponseID)/(SELECT COUNT(*) FROM personalized_info WHERE LOWER(Gender) LIKE 'male%')),3), '%')
AS preference_percent_male
FROM personalized_info p JOIN manager_aspirations m
ON p.ResponseID = m.ResponseID
WHERE LOWER(Gender) LIKE 'male%'
GROUP BY PreferredWorkSetup, Gender) males
ON overall.PreferredWorkSetup = males.PreferredWorkSetup
LEFT JOIN
(SELECT PreferredWorkSetup, Gender, COUNT(p.ResponseID) AS preference_count_female, 
CONCAT(ROUND((100.0*COUNT(p.ResponseID)/(SELECT COUNT(*) FROM personalized_info WHERE LOWER(Gender) LIKE 'female%')),3), '%') 
AS preference_percent_female
FROM personalized_info p JOIN manager_aspirations m
ON p.ResponseID = m.ResponseID
WHERE LOWER(Gender) LIKE 'female%'
GROUP BY PreferredWorkSetup, Gender) females
ON overall.PreferredWorkSetup = females.PreferredWorkSetup
ORDER BY PreferredWorkSetup DESC;

/*12. Give a detailed breakdown of WorkLikelihood3Years for each gender*/

SELECT males.WorkLikelihood3Years, male_count, male_percent, female_count, female_percent FROM
(SELECT WorkLikelihood3Years, Gender, COUNT(p.ResponseID) AS male_count,
CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM personalized_info WHERE LOWER(Gender) LIKE 'male%'),3), '%') AS male_percent
FROM personalized_info p JOIN manager_aspirations m
ON p.ResponseID = m.ResponseID
WHERE LOWER(Gender) LIKE 'male%'
GROUP BY WorkLikelihood3Years, Gender) males
RIGHT JOIN
(SELECT WorkLikelihood3Years, Gender, COUNT(p.ResponseID) AS female_count,
CONCAT(ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM personalized_info WHERE LOWER(Gender) LIKE 'female%'),3), '%') AS female_percent
FROM personalized_info p JOIN manager_aspirations m
ON p.ResponseID = m.ResponseID
WHERE LOWER(Gender) LIKE 'female%'
GROUP BY WorkLikelihood3Years, Gender) females
ON males.WorkLikelihood3Years = females.WorkLikelihood3Years;

/*13. Give a detailed breakdown of WorkLikelihood3Years for each country*/

SELECT WorkLikelihood3Years, CurrentCountry, COUNT(p.ResponseID) AS count_work_likelihood,
CONCAT(ROUND(100.0*COUNT(p.ResponseID)/(SELECT COUNT(*) FROM personalized_info),3), '%') AS percent_work_likelihood
FROM personalized_info p JOIN manager_aspirations m
ON p.ResponseID = m.ResponseID
WHERE CurrentCountry NOT LIKE 'Your Current Country.'
GROUP BY WorkLikelihood3Years, CurrentCountry
ORDER BY CurrentCountry;

/*14. What is the Average starting Salary Expectations at 3 year mark for each gender*/

WITH step1 AS (SELECT p.ResponseID, Gender, CASE WHEN ExpectedSalary3Years LIKE '>50k' THEN 0 ELSE SUBSTRING_INDEX(ExpectedSalary3Years, ' ', 1) END AS starting_bar, 
CASE WHEN ExpectedSalary3Years LIKE '>50k' THEN TRIM(LEADING '>' FROM ExpectedSalary3Years) 
ELSE SUBSTRING_INDEX(ExpectedSalary3Years, ' ', -1) END AS higher_bar
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID),

step2 AS (SELECT ResponseID, Gender, TRIM(TRAILING 'k' FROM LOWER(starting_bar)) AS starting_salary, 
TRIM(TRAILING 'k' FROM LOWER(higher_bar)) AS higher_salary
FROM step1
WHERE starting_bar IS NOT NULL AND Gender IS NOT NULL)

SELECT Gender, ROUND(AVG(starting_salary),3) AS starting_avg_3years
FROM step2
GROUP BY Gender;

/*15. What is the average starting salary expectations at 5 year mark for each gender*/

WITH step1 AS 
(SELECT p.ResponseID, Gender, 
CASE WHEN ExpectedSalary5Years LIKE '>151k%' THEN 0 ELSE SUBSTRING_INDEX(ExpectedSalary5Years, ' ', 1) END AS starting_bar, 
CASE WHEN ExpectedSalary5Years LIKE '>151k%' THEN TRIM(LEADING '>' FROM ExpectedSalary5Years) 
ELSE SUBSTRING_INDEX(ExpectedSalary5Years, ' ', -1) END AS higher_bar
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID),

step2 AS (SELECT ResponseID, Gender, TRIM(TRAILING 'k' FROM LOWER(starting_bar)) AS starting_salary, TRIM(TRAILING 'k\r' FROM higher_bar) AS higher_salary
FROM step1
WHERE starting_bar IS NOT NULL AND Gender IS NOT NULL)

SELECT Gender, ROUND(AVG(starting_salary),3) AS starting_avg_5years
FROM step2
GROUP BY Gender;

/*16. What is the average Higher Bar salary expectations at 3 year mark for each gender*/

WITH step1 AS (SELECT p.ResponseID, Gender, CASE WHEN ExpectedSalary3Years LIKE '>50k' THEN 0 ELSE SUBSTRING_INDEX(ExpectedSalary3Years, ' ', 1) END AS starting_bar, 
CASE WHEN ExpectedSalary3Years LIKE '>50k' THEN TRIM(LEADING '>' FROM ExpectedSalary3Years) 
ELSE SUBSTRING_INDEX(ExpectedSalary3Years, ' ', -1) END AS higher_bar
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID),

step2 AS (SELECT ResponseID, Gender, TRIM(TRAILING 'k' FROM LOWER(starting_bar)) AS starting_salary, 
TRIM(TRAILING 'k' FROM LOWER(higher_bar)) AS higher_salary
FROM step1
WHERE starting_bar IS NOT NULL AND Gender IS NOT NULL)

SELECT Gender, ROUND(AVG(higher_salary),3) AS higher_avg_3years
FROM step2
GROUP BY Gender;

/*17. What is the average Higher Bar salary expectations at 5 year mark for each gender*/

WITH step1 AS 
(SELECT p.ResponseID, Gender, 
CASE WHEN ExpectedSalary5Years LIKE '>151k%' THEN 0 ELSE SUBSTRING_INDEX(ExpectedSalary5Years, ' ', 1) END AS starting_bar, 
CASE WHEN ExpectedSalary5Years LIKE '>151k%' THEN TRIM(LEADING '>' FROM ExpectedSalary5Years) 
ELSE SUBSTRING_INDEX(ExpectedSalary5Years, ' ', -1) END AS higher_bar
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID),

step2 AS (SELECT ResponseID, Gender, TRIM(TRAILING 'k' FROM LOWER(starting_bar)) AS starting_salary, 
TRIM(TRAILING 'k\r' FROM higher_bar) AS higher_salary
FROM step1
WHERE starting_bar IS NOT NULL AND Gender IS NOT NULL)

SELECT Gender, ROUND(AVG(higher_salary),3) AS higher_avg_5years
FROM step2
GROUP BY Gender;

/*18. What is the average starting salary expectations at 3 year mark for each gender and each country*/

WITH step1 AS (SELECT p.ResponseID, Gender, CurrentCountry, 
CASE WHEN ExpectedSalary3Years LIKE '>50k' THEN 0 ELSE SUBSTRING_INDEX(ExpectedSalary3Years, ' ', 1) END AS starting_bar, 
CASE WHEN ExpectedSalary3Years LIKE '>50k' THEN TRIM(LEADING '>' FROM ExpectedSalary3Years) 
ELSE SUBSTRING_INDEX(ExpectedSalary3Years, ' ', -1) END AS higher_bar
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID),

step2 AS (SELECT ResponseID, Gender, CurrentCountry, TRIM(TRAILING 'k' FROM LOWER(starting_bar)) AS starting_salary, 
TRIM(TRAILING 'k' FROM LOWER(higher_bar)) AS higher_salary
FROM step1
WHERE starting_bar IS NOT NULL AND Gender IS NOT NULL)

SELECT CurrentCountry, Gender, ROUND(AVG(starting_salary),3) AS starting_avg_3years
FROM step2
GROUP BY Gender, CurrentCountry
ORDER By CurrentCountry;

/*19. What is the average starting salary expectations at 5 year mark for each gender and each country*/

WITH step1 AS 
(SELECT p. ResponseID, Gender, CurrentCountry, 
CASE WHEN ExpectedSalary5Years LIKE '>151k%' THEN 0 ELSE SUBSTRING_INDEX(ExpectedSalary5Years, ' ', 1) END AS starting_bar, 
CASE WHEN ExpectedSalary5Years LIKE '>151k%' THEN TRIM(LEADING '>' FROM ExpectedSalary5Years) 
ELSE SUBSTRING_INDEX(ExpectedSalary5Years, ' ', -1) END AS higher_bar
FROM personalized_info p JOIN mission_aspirations m),

step2 AS (SELECT ResponseID, Gender, CurrentCountry, TRIM(TRAILING 'k' FROM LOWER(starting_bar)) AS starting_salary, 
TRIM(TRAILING 'k\r' FROM higher_bar) AS higher_salary
FROM step1
WHERE starting_bar IS NOT NULL AND Gender IS NOT NULL)

SELECT CurrentCountry, Gender, ROUND(AVG(starting_salary),3) AS starting_avg_5years
FROM step2
GROUP BY Gender, CurrentCountry
ORDER BY CurrentCountry;

/*20. What is the average higher bar salary expectations at 3 year mark for each gender and each country*/

WITH step1 AS (SELECT p.ResponseID, Gender, CurrentCountry, 
CASE WHEN ExpectedSalary3Years LIKE '>50k' THEN 0 ELSE SUBSTRING_INDEX(ExpectedSalary3Years, ' ', 1) END AS starting_bar, 
CASE WHEN ExpectedSalary3Years LIKE '>50k' THEN TRIM(LEADING '>' FROM ExpectedSalary3Years) 
ELSE SUBSTRING_INDEX(ExpectedSalary3Years, ' ', -1) END AS higher_bar
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID),

step2 AS (SELECT ResponseID, Gender, CurrentCountry, TRIM(TRAILING 'k' FROM LOWER(starting_bar)) AS starting_salary, 
TRIM(TRAILING 'k' FROM LOWER(higher_bar)) AS higher_salary
FROM step1
WHERE starting_bar IS NOT NULL AND Gender IS NOT NULL)

SELECT CurrentCountry, Gender, ROUND(AVG(higher_salary),3) AS higher_avg_3years
FROM step2
GROUP BY Gender, CurrentCountry
ORDER By CurrentCountry;

/*21. What is the average higher bar salary expectations at 5 year mark for each gender and each country*/

WITH step1 AS 
(SELECT p.ResponseID, Gender, CurrentCountry, 
CASE WHEN ExpectedSalary5Years LIKE '>151k%' THEN 0 ELSE SUBSTRING_INDEX(ExpectedSalary5Years, ' ', 1) END AS starting_bar, 
CASE WHEN ExpectedSalary5Years LIKE '>151k%' THEN TRIM(LEADING '>' FROM ExpectedSalary5Years) 
ELSE SUBSTRING_INDEX(ExpectedSalary5Years, ' ', -1) END AS higher_bar
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID),

step2 AS (SELECT ResponseID, Gender, CurrentCountry, TRIM(TRAILING 'k' FROM LOWER(starting_bar)) AS starting_salary, 
TRIM(TRAILING 'k\r' FROM higher_bar) AS higher_salary
FROM step1
WHERE starting_bar IS NOT NULL AND Gender IS NOT NULL)

SELECT CurrentCountry, Gender, ROUND(AVG(higher_salary),3) AS higher_avg_5years
FROM step2
GROUP BY Gender, CurrentCountry
ORDER BY CurrentCountry;

/*22. Give a detailed breakdown of the possibility of GenZ working for an organization if the Mission is Misaligned for 
each country*/

SELECT MisalignedMissionLikelihood, CurrentCountry, COUNT(p.ResponseID) AS count_misalaigned_mission_likelihood,
CONCAT(ROUND(100.0*COUNT(p.ResponseID)/(SELECT COUNT(ResponseID) FROM personalized_info),3), '%') 
AS percent_misaligned_mission_likelihood
FROM personalized_info p JOIN mission_aspirations m
ON p.ResponseID = m.ResponseID
WHERE CurrentCountry NOT LIKE 'Your Current Country.' AND CurrentCountry NOT LIKE ''
GROUP BY MisalignedMissionLikelihood, CurrentCountry
ORDER BY CurrentCountry;
