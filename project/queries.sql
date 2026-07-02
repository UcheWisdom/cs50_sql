-- Enable foreign key support
PRAGMA foreign_keys = ON;

-- Insert data into departments table
INSERT INTO departments (department_id, department_name, office_location) VALUES
(11, 'Engineering', 'Block k');

-- Insert data into lecturers table
INSERT INTO lecturers (first_name, last_name, email, phone_number, department_id, hire_date) VALUES
('Jame', 'Walke', 'james.L@mail.com', '08111111123', 11, '2020-01-16');

-- Insert data into students table
INSERT INTO students (first_name, last_name, gender, date_of_birth, email, phone_number, home_address, admission_date, department_id, matric_number) VALUES
('Jane', 'Smith', 'Female', '2001-07-22', 'jane.s@email.com', '08022222223', 'Abuja', '2024-01-10', 11, "2024011");

-- Insert data into courses table
INSERT INTO courses (course_title, course_code, credit_unit, department_id, lecturer_id) VALUES
('Digital Electronics', 'COM112', 4, 11, 11);

-- Insert data into enrollments table
INSERT INTO enrollments (student_id, course_id, semester, session, enrollment_date) VALUES
(11, 11, 'First', '2024/2025', '2024-01-15');


-- Insert data into results table
INSERT INTO results (enrollment_id, score) VALUES
(11, 90);

-- Insert data into attendances table
INSERT INTO attendances (enrollment_id, attendance_date, attendance_status) VALUES
(11, '2024-02-15', 'Present');

-- Insert data into fees table
INSERT INTO fees (student_id,  enrollment_id, amount_paid, payment_date, payment_method) VALUES
(11, 11, 50000, '2024-02-10', 'Credit Card');

-- Insert data into guardians table
INSERT INTO guardians (student_id, guardian_name, relationship, phone_number, home_address) VALUES
(11, 'Jana Doe', 'Mother', '08011112111', 'Lagos');

-- Retrieve students detials with their department, courses, lecturers, results, attendance, fees, and guardians
SELECT
    s.student_id, s.first_name, s.last_name, s.gender, s.date_of_birth, s.email, s.phone_number, s.home_address, s.department_id, s.admission_date, s.matric_number,
    d.department_name, d.office_location,
    c.course_title, c.course_code, c.credit_unit,
    l.first_name AS lecturer_first_name, l.last_name AS lecturer_last_name, l.email AS lecturer_email, l.phone_number AS lecturer_phone_number, l.hire_date AS lecturer_hire_date,
    e.semester, e.session, e.enrollment_date,
    r.score, r.grade, r.remark,
    a.attendance_date, a.attendance_status,
    f.amount_paid, f.payment_date, f.payment_method,
    g.guardian_name, g.relationship, g.phone_number AS guardian_phone_number, g.home_address AS guardian_home_address
FROM
    students s
LEFT JOIN
    departments d ON s.department_id = d.department_id
LEFT JOIN
    enrollments e ON s.student_id = e.student_id
LEFT JOIN
    courses c ON e.course_id = c.course_id
LEFT JOIN
    lecturers l ON c.lecturer_id = l.lecturer_id
LEFT JOIN
    results r ON e.enrollment_id = r.enrollment_id
LEFT JOIN
    attendances a ON e.enrollment_id = a.enrollment_id
LEFT JOIN
    fees f ON e.enrollment_id = f.enrollment_id
LEFT JOIN
    guardians g ON s.student_id = g.student_id;


-- Update a lecturer's email
UPDATE lecturers
SET email = 'new.email@example.com'
WHERE lecturer_id = 1;

-- Delete a student record
-- DELETE FROM students
-- WHERE student_id = 11;


-- SHOW ALL TABLES
SELECT * FROM students;

SELECT * FROM lecturers;

SELECT * FROM departments;

SELECT * FROM courses;

SELECT * FROM enrollments;

SELECT * FROM results;

SELECT * FROM attendances;

SELECT * FROM fees;

SELECT * FROM guardians;


