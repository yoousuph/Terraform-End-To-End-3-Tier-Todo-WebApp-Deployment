SELECT GET_LOCK('todo-db-init', 60);

CREATE DATABASE IF NOT EXISTS ${db_name};

USE ${db_name};

CREATE TABLE IF NOT EXISTS todos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    task VARCHAR(50) NOT NULL UNIQUE,
    createdOn DATETIME NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'Pending'
);

INSERT IGNORE INTO todos(task, createdOn, status)
VALUES
('Buy Cake', NOW(), 'Pending'),
('Learn Terraform', NOW(), 'Done'),
('Write Python script', NOW(), 'Pending'),
('Finish Terraform project', NOW(), 'In progress'),
('Study Node.js APIs', NOW(), 'Done');

SELECT RELEASE_LOCK('todo-db-init');
