-- Customer Support Ticket System Database Schema
-- VANSHIT Project

-- Create database
CREATE DATABASE IF NOT EXISTS support_ticket_system;
USE support_ticket_system;

-- CUSTOMER table
CREATE TABLE IF NOT EXISTS CUSTOMER (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- AGENT table
CREATE TABLE IF NOT EXISTS AGENT (
    agent_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CATEGORY table
CREATE TABLE IF NOT EXISTS CATEGORY (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- AGENT_CATEGORY table (Many-to-many relationship)
CREATE TABLE IF NOT EXISTS AGENT_CATEGORY (
    agent_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (agent_id, category_id),
    FOREIGN KEY (agent_id) REFERENCES AGENT(agent_id),
    FOREIGN KEY (category_id) REFERENCES CATEGORY(category_id)
);

-- TICKET table (Main entity)
CREATE TABLE IF NOT EXISTS TICKET (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    category_id INT NOT NULL,
    agent_id INT,
    priority ENUM('low', 'medium', 'high', 'urgent') NOT NULL DEFAULT 'medium',
    title VARCHAR(500) NOT NULL,
    description TEXT,
    status ENUM('open', 'in_progress', 'resolved', 'closed') NOT NULL DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    assigned_at TIMESTAMP NULL,
    resolved_at TIMESTAMP NULL,
    closed_at TIMESTAMP NULL,
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (category_id) REFERENCES CATEGORY(category_id),
    FOREIGN KEY (agent_id) REFERENCES AGENT(agent_id)
);

-- MESSAGE table (Ticket communication)
CREATE TABLE IF NOT EXISTS MESSAGE (
    message_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    sender_type ENUM('CUSTOMER', 'AGENT') NOT NULL,
    sender_id INT NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES TICKET(ticket_id)
);

-- SLA table (Service Level Agreements)
CREATE TABLE IF NOT EXISTS SLA (
    sla_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT NOT NULL,
    max_response_time INT NOT NULL COMMENT 'in hours',
    max_resolution_time INT NOT NULL COMMENT 'in hours',
    sla_name ENUM('Standard', 'Premium', 'VIP') NOT NULL,
    FOREIGN KEY (category_id) REFERENCES CATEGORY(category_id)
);

-- ESCALATION table (Ticket escalations)
CREATE TABLE IF NOT EXISTS ESCALATION (
    escalation_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT UNIQUE NOT NULL,
    escalated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (ticket_id) REFERENCES TICKET(ticket_id)
);

-- FEEDBACK table (Customer feedback)
CREATE TABLE IF NOT EXISTS FEEDBACK (
    feedback_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    agent_id INT NOT NULL,
    rating INT NOT NULL COMMENT '1-5 scale for radio buttons',
    comments TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES TICKET(ticket_id),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMER(customer_id),
    FOREIGN KEY (agent_id) REFERENCES AGENT(agent_id),
    CHECK (rating >= 1 AND rating <= 5)
);

-- AGENT_METRICS table (Performance tracking)
CREATE TABLE IF NOT EXISTS AGENT_METRICS (
    agent_id INT PRIMARY KEY,
    total_tickets_resolved INT DEFAULT 0,
    resolution_rate DECIMAL(5,2) DEFAULT 0.00,
    avg_handling_time INT DEFAULT 0 COMMENT 'in hours',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (agent_id) REFERENCES AGENT(agent_id)
);

-- TICKET_HISTORY table (Audit trail)
CREATE TABLE IF NOT EXISTS TICKET_HISTORY (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    ticket_id INT NOT NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    priority ENUM('low', 'medium', 'high', 'urgent') NOT NULL DEFAULT 'medium',
    status ENUM('open', 'in_progress', 'resolved', 'closed') NOT NULL DEFAULT 'open',
    FOREIGN KEY (ticket_id) REFERENCES TICKET(ticket_id)
);

-- Indexes for performance optimization
CREATE INDEX idx_ticket_customer_category_status ON TICKET(customer_id, category_id, status);
CREATE INDEX idx_ticket_created_at ON TICKET(created_at);
CREATE INDEX idx_ticket_status_created ON TICKET(status, created_at);
CREATE INDEX idx_ticket_agent ON TICKET(agent_id);
CREATE INDEX idx_message_ticket_sent ON MESSAGE(ticket_id, sent_at);
CREATE INDEX idx_sla_category ON SLA(category_id);
CREATE INDEX idx_escalation_ticket ON ESCALATION(ticket_id);
CREATE INDEX idx_feedback_ticket ON FEEDBACK(ticket_id);
CREATE INDEX idx_feedback_rating ON FEEDBACK(rating);
CREATE INDEX idx_feedback_agent ON FEEDBACK(agent_id);
CREATE INDEX idx_agent_metrics_resolution_rate ON AGENT_METRICS(resolution_rate);
CREATE INDEX idx_ticket_history_ticket_changed ON TICKET_HISTORY(ticket_id, changed_at);

-- Triggers for automatic updates
DELIMITER //

-- Trigger to log ticket status changes
CREATE TRIGGER log_ticket_status_change
AFTER UPDATE ON TICKET
FOR EACH ROW
BEGIN
    IF NEW.status != OLD.status OR NEW.priority != OLD.priority THEN
        INSERT INTO TICKET_HISTORY (ticket_id, priority, status)
        VALUES (NEW.ticket_id, NEW.priority, NEW.status);
    END IF;
END//

-- Trigger to update resolved_at when status changes to resolved
CREATE TRIGGER update_resolved_at
AFTER UPDATE ON TICKET
FOR EACH ROW
BEGIN
    IF NEW.status = 'resolved' AND OLD.status != 'resolved' THEN
        UPDATE TICKET SET resolved_at = NOW() WHERE ticket_id = NEW.ticket_id;
    END IF;
END//

-- Trigger to update closed_at when status changes to closed
CREATE TRIGGER update_closed_at
AFTER UPDATE ON TICKET
FOR EACH ROW
BEGIN
    IF NEW.status = 'closed' AND OLD.status != 'closed' THEN
        UPDATE TICKET SET closed_at = NOW() WHERE ticket_id = NEW.ticket_id;
    END IF;
END//

DELIMITER ;

-- Sample data for testing
INSERT INTO CUSTOMER (name, phone_number, email) VALUES
('John Doe', '555-0101', 'john@example.com'),
('Jane Smith', '555-0102', 'jane@example.com'),
('Bob Wilson', '555-0103', 'bob@example.com');

INSERT INTO AGENT (name, email) VALUES
('Agent Alice', 'alice@support.com'),
('Agent Bob', 'bob@support.com'),
('Agent Carol', 'carol@support.com');

INSERT INTO CATEGORY (name, description) VALUES
('Technical Support', 'Hardware and software issues'),
('Billing', 'Payment and subscription issues'),
('General Inquiry', 'General questions and information');

INSERT INTO AGENT_CATEGORY (agent_id, category_id) VALUES
(1, 1), -- Alice to Technical Support
(2, 2), -- Bob to Billing
(3, 3), -- Carol to General Inquiry
(1, 3); -- Alice also to General Inquiry

INSERT INTO SLA (category_id, max_response_time, max_resolution_time, sla_name) VALUES
(1, 4, 24, 'Standard'),  -- Technical Support: 4hr response, 24hr resolution
(2, 2, 8, 'Premium'),    -- Billing: 2hr response, 8hr resolution
(3, 8, 48, 'Standard');  -- General: 8hr response, 48hr resolution 