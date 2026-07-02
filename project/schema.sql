-- Enable foreign key support
PRAGMA foreign_keys = ON;

-- Create the Department table
CREATE TABLE IF NOT EXISTS departments (
    department_id INTEGER PRIMARY KEY AUTOINCREMENT,
    department_name TEXT NOT NULL,
    office_location TEXT NOT NULL
);

-- Create an index for quick lookups by  department_name
CREATE INDEX idx_departments_department_name ON departments (department_name);

-- Create the Lecturers table
CREATE TABLE IF NOT EXISTS lecturers (
    lecturer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE CHECK(email LIKE '%@%.%'),
    phone_number TEXT NOT NULL UNIQUE,
    department_id INTEGER NOT NULL,
    hire_date TEXT NOT NULL CHECK(hire_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Create an index for quick lookups by lecturer_name
CREATE INDEX idx_lecturers_lecturer_name ON lecturers (first_name, last_name);

-- Create the Student table
CREATE TABLE IF NOT EXISTS students (
    student_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    gender TEXT CHECK(gender IN ('Male', 'Female')) NOT NULL,
    date_of_birth TEXT NOT NULL CHECK(date_of_birth GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    email TEXT NOT NULL UNIQUE CHECK(email LIKE '%@%.%'),
    phone_number TEXT NOT NULL UNIQUE,
    home_address TEXT NOT NULL,
    department_id INTEGER NOT NULL,
    admission_date TEXT NOT NULL CHECK(admission_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    matric_number TEXT NOT NULL UNIQUE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Create an index for quick lookups by names
CREATE INDEX idx_student_name ON students (first_name, last_name);

-- Create the Courses table
CREATE TABLE IF NOT EXISTS courses (
    course_id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_title TEXT NOT NULL UNIQUE,
    course_code TEXT NOT NULL UNIQUE CHECK(course_code GLOB '[A-Z][A-Z][A-Z][0-9][0-9][0-9]'),
    credit_unit INTEGER NOT NULL CHECK(credit_unit > 0),
    department_id INTEGER NOT NULL,
    lecturer_id INTEGER NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (lecturer_id) REFERENCES lecturers(lecturer_id)
);

-- Create an index for quick lookups by course_code
CREATE INDEX idx_courses_course_code ON courses (course_code);

-- Create the Enrollments table
CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    semester TEXT CHECK(semester IN ('First', 'Second')) NOT NULL,
    session TEXT NOT NULL CHECK(session GLOB '[0-9][0-9][0-9][0-9]/[0-9][0-9][0-9][0-9]'),
    enrollment_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE(student_id, course_id, semester, session)
);

-- Create an index for quick lookups by semester
CREATE INDEX idx_enrollments_semester ON enrollments (semester);

-- Create the Result table
CREATE TABLE IF NOT EXISTS results (
    result_id INTEGER PRIMARY KEY AUTOINCREMENT,
    enrollment_id INTEGER NOT NULL UNIQUE,
    score INTEGER CHECK(score BETWEEN 0 AND 100) NOT NULL,

    grade TEXT GENERATED ALWAYS AS (
        CASE
            WHEN score >= 70 THEN 'A'
            WHEN score >= 60 THEN 'B'
            WHEN score >= 50 THEN 'C'
            WHEN score >= 45 THEN 'D'
            WHEN score >= 40 THEN 'E'
            ELSE 'F'
        END
    ) STORED,

    remark TEXT GENERATED ALWAYS AS (
        CASE
            WHEN score >= 70 THEN 'Excellent'
            WHEN score >= 60 THEN 'Good'
            WHEN score >= 50 THEN 'Average'
            WHEN score >= 45 THEN 'Pass'
            WHEN score >= 40 THEN 'Weak Pass'
            ELSE 'Fail'
        END
    ) STORED,

    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
);

-- Create an index for quick lookups by score
CREATE INDEX idx_results_score ON results (score);

-- Create an index for quick lookups by grade
CREATE INDEX idx_results_grade ON results (grade);

-- Create the Attendance Table
CREATE TABLE IF NOT EXISTS attendances (
    attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    enrollment_id INTEGER NOT NULL,
    attendance_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP CHECK(attendance_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
    attendance_status TEXT CHECK(attendance_status IN ('Present', 'Absent')) NOT NULL,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
);

-- Create an index for quick lookups by student_id
CREATE INDEX idx_attendances_enrollment_id ON attendances (enrollment_id);

-- Create an index for quick lookups by attendance_status
CREATE INDEX idx_attendances_attendance_status ON attendances (attendance_status);

-- Create the Attendance Table
CREATE TABLE IF NOT EXISTS fees (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    enrollment_id INTEGER NOT NULL,
    amount_paid NUMERIC NOT NULL CHECK(amount_paid > 0),
    payment_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method TEXT CHECK(
    payment_method IN ('Cash', 'Bank Transfer', 'Credit Card')) NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id) ON DELETE CASCADE
);

-- Create an index for quick lookups by student_id
CREATE INDEX idx_fees_student_id ON fees (student_id);

-- Create an index for quick lookups by amount_paid
CREATE INDEX idx_fees_amount_paid ON fees (amount_paid);

-- Create the Attendance Table
CREATE TABLE IF NOT EXISTS guardians (
    guardian_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INTEGER NOT NULL,
    guardian_name TEXT NOT NULL,
    relationship TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    home_address TEXT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- Create an index for quick lookups by guardian_name
CREATE INDEX idx_guardians_guardian_name ON guardians (guardian_name);


-- Creating View
-- To view all students detials
/*
CREATE VIEW v_all_student_details AS
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
*/

-- Student course view
CREATE VIEW v_student_courses AS
SELECT
    s.student_id, s.first_name, s.last_name,
    c.course_title, c.course_code, c.credit_unit,
    l.first_name AS lecturer_first_name, l.last_name AS lecturer_last_name
FROM
    students s
LEFT JOIN
    enrollments e ON s.student_id = e.student_id
LEFT JOIN
    courses c ON e.course_id = c.course_id
LEFT JOIN
    lecturers l ON c.lecturer_id = l.lecturer_id;

-- Student result view
CREATE VIEW v_student_results AS
SELECT
    s.student_id, s.first_name, s.last_name,
    c.course_title, c.course_code,
    r.score, r.grade, r.remark
FROM
    students s
LEFT JOIN
    enrollments e ON s.student_id = e.student_id
LEFT JOIN
    courses c ON e.course_id = c.course_id
LEFT JOIN
    results r ON e.enrollment_id = r.enrollment_id;

-- Department student count view
CREATE VIEW v_department_student_count AS
SELECT
    d.department_name,
    COUNT(s.student_id) AS student_count
FROM
    departments d
LEFT JOIN
    students s ON d.department_id = s.department_id
GROUP BY
    d.department_name;

-- Student fee payment view
CREATE VIEW v_student_fee_payments AS
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    f.amount_paid,
    f.payment_date,
    f.payment_method,
    e.semester,
    e.session
FROM students s
LEFT JOIN fees f
    ON s.student_id = f.student_id
LEFT JOIN enrollments e
    ON f.enrollment_id = e.enrollment_id;

-- Student guardian view
CREATE VIEW v_student_guardians AS
SELECT
    s.student_id, s.first_name, s.last_name,
    g.guardian_name, g.relationship, g.phone_number AS guardian_phone_number, g.home_address AS guardian_home_address
FROM
    students s
LEFT JOIN
    guardians g ON s.student_id = g.student_id;

-- Student enrollment view
CREATE VIEW v_student_enrollments AS
SELECT
    s.student_id, s.first_name, s.last_name,
    c.course_title, c.course_code, c.credit_unit,
    e.semester, e.session, e.enrollment_date
FROM
    students s
LEFT JOIN
    enrollments e ON s.student_id = e.student_id
LEFT JOIN
    courses c ON e.course_id = c.course_id;

-- Student attendance view
CREATE VIEW v_student_attendance AS
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    c.course_title,
    c.course_code,
    a.attendance_date,
    a.attendance_status 
FROM students s
LEFT JOIN enrollments e
    ON s.student_id = e.student_id
LEFT JOIN courses c
    ON e.course_id = c.course_id
LEFT JOIN attendances a
    ON e.enrollment_id = a.enrollment_id;

-- View to list all students with their courses and lecturers
CREATE VIEW v_students_courses_lecturers AS
SELECT
    s.student_id,
    s.first_name,
    s.last_name,
    c.course_title,
    l.first_name || ' ' || l.last_name AS lecturer_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
JOIN lecturers l ON c.lecturer_id = l.lecturer_id;


--Adding Values
-- Wizzy DATA
-- Insert Wizzy data into departments table
INSERT INTO departments (department_id, department_name, office_location) VALUES
(1, 'Computer Science', 'Block A'),
(2, 'Mathematics', 'Block B'),
(3, 'Accounting', 'Block C'),
(4, 'Physics', 'Block D'),
(5, 'Chemistry', 'Block E'),
(6, 'Biology', 'Block F'),
(7, 'Economics', 'Block G'),
(8, 'English', 'Block H'),
(9, 'Political Science', 'Block I'),
(10, 'Statistics', 'Block J');

-- Insert Wizzy data into lecturers table
INSERT INTO lecturers (first_name, last_name, email, phone_number, department_id, hire_date) VALUES
('James', 'Walker', 'james.w@email.com', '07011111111', 1, '2018-06-12'),
('Patricia', 'Hall', 'patricia.h@email.com', '07022222222', 2, '2019-02-20'),
('Robert', 'Allen', 'robert.a@email.com', '07033333333', 3, '2017-09-14'),
('Linda', 'Young', 'linda.y@email.com', '07044444444', 4, '2016-01-18'),
('Joseph', 'King', 'joseph.k@email.com', '07055555555', 5, '2020-03-11'),
('Susan', 'Wright', 'susan.w@email.com', '07066666666', 6, '2021-07-09'),
('Charles', 'Scott', 'charles.s@email.com', '07077777777', 7, '2015-11-25'),
('Karen', 'Green', 'karen.g@email.com', '07088888888', 8, '2018-04-17'),
('Matthew', 'Baker', 'matthew.b@email.com', '07099999999', 9, '2019-12-30'),
('Nancy', 'Adams', 'nancy.a@email.com', '07100000000', 10, '2022-05-05');

-- Insert Wizzy data into students table
INSERT INTO students (first_name, last_name, gender, date_of_birth, email, phone_number, home_address, admission_date, department_id, matric_number) VALUES
('John', 'Doe', 'Male', '2002-03-15', 'john.doe@email.com', '08011111111', 'Lagos', '2024-01-10', 1, "2024001"),
('Mary', 'Johnson', 'Female', '2001-07-20', 'mary.j@email.com', '08022222222', 'Abuja', '2024-01-10', 2, "2024002"),
('David', 'Smith', 'Male', '2003-01-11', 'david.s@email.com', '08033333333', 'Enugu', '2024-01-10', 3, "2024003"),
('Grace', 'Brown', 'Female', '2002-05-09', 'grace.b@email.com', '08044444444', 'Kano', '2024-01-10', 4, "2024004"),
('Michael', 'Wilson', 'Male', '2001-12-30', 'michael.w@email.com', '08055555555', 'Ibadan', '2024-01-10', 5, "2024005"),
('Sarah', 'Davis', 'Female', '2003-08-14', 'sarah.d@email.com', '08066666666', 'Port Harcourt', '2024-01-10', 6, "2024006"),
('Daniel', 'Miller', 'Male', '2002-09-17', 'daniel.m@email.com', '08077777777', 'Benin', '2024-01-10', 7, "2024007"),
('Esther', 'Taylor', 'Female', '2001-06-25', 'esther.t@email.com', '08088888888', 'Jos', '2024-01-10', 8, "2024008"),
('Samuel', 'Anderson', 'Male', '2002-10-12', 'samuel.a@email.com', '08099999999', 'Owerri', '2024-01-10', 9, "2024009"),
('Ruth', 'Thomas', 'Female', '2003-02-05', 'ruth.t@email.com', '08100000000', 'Uyo', '2024-01-10', 10, "2024010");')


-- Insert Wizzy data into courses table
INSERT INTO courses (course_title, course_code, credit_unit, department_id, lecturer_id) VALUES
('Introduction to Computer Science', 'CSC101', 3, 1, 1),
('Calculus I', 'MTH101', 4, 2, 2),
('Financial Accounting', 'ACC101', 3, 3, 3),
('General Physics', 'PHY101', 4, 4, 4),
('Organic Chemistry', 'CHM101', 3, 5, 5),
('Cell Biology', 'BIO101', 4, 6, 6),
('Microeconomics', 'ECO101', 3, 7, 7),
('English Literature', 'ENG101', 3, 8, 8),
('International Relations', 'POL101', 3, 9, 9),
('Probability and Statistics', 'STA101', 4, 10, 10);


-- Insert Wizzy data into enrollments table
INSERT INTO enrollments (student_id, course_id, semester, session, enrollment_date) VALUES
(1, 1, 'First', '2024/2025', '2024-01-15'),
(2, 2, 'First', '2024/2025', '2024-01-15'),
(3, 3, 'First', '2024/2025', '2024-01-15'),
(4, 4, 'First', '2024/2025', '2024-01-15'),
(5, 5, 'First', '2024/2025', '2024-01-15'),
(6, 6, 'First', '2024/2025', '2024-01-15'),
(7, 7, 'First', '2024/2025', '2024-01-15'),
(8, 8, 'First', '2024/2025', '2024-01-15'),
(9, 9, 'First', '2024/2025', '2024-01-15'),
(10, 10, 'First', '2024/2025', '2024-01-15');

-- Insert Wizzy data into results table
INSERT INTO results (enrollment_id, score) VALUES
(1, 85),
(2, 78),
(3, 92),
(4, 65),
(5, 88),
(6, 72),
(7, 80),
(8, 60),
(9, 90),
(10, 75);

-- Insert Wizzy data into attendances table
INSERT INTO attendances (enrollment_id, attendance_date, attendance_status) VALUES
(1, '2024-02-01', 'Present'),
(2, '2024-02-01', 'Absent'),
(3, '2024-02-01', 'Present'),
(4, '2024-02-01', 'Present'),
(5, '2024-02-01', 'Absent'),
(6, '2024-02-01', 'Present'),
(7, '2024-02-01', 'Present'),
(8, '2024-02-01', 'Absent'),
(9, '2024-02-01', 'Present'),
(10, '2024-02-01', 'Present');

-- Insert Wizzy data into fees table
INSERT INTO fees (student_id,  enrollment_id, amount_paid, payment_date, payment_method) VALUES
(1, 1, 50000, '2024-02-10', 'Credit Card'),
(2, 2, 45000, '2024-02-12', 'Bank Transfer'),
(3, 3, 55000, '2024-02-15', 'Cash'),
(4, 4, 40000, '2024-02-18', 'Credit Card'),
(5, 5, 60000, '2024-02-20', 'Bank Transfer'),
(6, 6, 48000, '2024-02-22', 'Cash'),
(7, 7, 52000, '2024-02-25', 'Credit Card'),
(8, 8, 47000, '2024-02-28', 'Bank Transfer'),
(9, 9, 53000, '2024-03-01', 'Cash'),
(10, 10, 49000, '2024-03-05', 'Credit Card');


-- Insert Wizzy data into guardians table
INSERT INTO guardians (student_id, guardian_name, relationship, phone_number, home_address) VALUES
(1, 'Jane Doe', 'Mother', '08011111111', 'Lagos'),
(2, 'Robert Johnson', 'Father', '08022222222', 'Abuja'),
(3, 'Emily Smith', 'Mother', '08033333333', 'Enugu'),
(4, 'Michael Brown', 'Father', '08044444444', 'Kano'),
(5, 'Sarah Wilson', 'Mother', '08055555555', 'Ibadan'),
(6, 'David Davis', 'Father', '08066666666', 'Port Harcourt'),
(7, 'Laura Miller', 'Mother', '08077777777', 'Benin'),
(8, 'James Taylor', 'Father', '08088888888', 'Jos'),
(9, 'Linda Anderson', 'Mother', '08099999999', 'Owerri'),
(10, 'Richard Thomas', 'Father', '08100000000', 'Uyo');

