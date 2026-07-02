SELECT
    districts.name AS district_name,
    AVG(expenditures.per_pupil_expenditure) AS per_pupil_expend
FROM districts
JOIN expenditures
    ON districts.id = expenditures.district_id
WHERE districts.state = 'MA'
GROUP BY districts.name
ORDER BY per_pupil_expend DESC
LIMIT 10;
