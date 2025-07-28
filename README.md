# DBMS
🎫 VANSHIT Support Ticket System
A comprehensive customer support ticket management system built with Java JDBC and MySQL.

📋 Overview
This system manages customer support tickets with features like:

Ticket Creation & Management 📝
Agent Assignment & Workload Management 👥
Message Communication 💬
SLA Monitoring ⏰
Escalation Handling 🚨
Customer Feedback ⭐
Performance Analytics 📊
🏗️ Database Schema
Core Entities
CUSTOMER 👤
Customer information and contact details
Unique email constraint
Creation timestamp tracking
AGENT 🛠️
Support agent profiles
Availability status
Performance metrics tracking
CATEGORY 📂
Ticket categories (Technical, Billing, General)
Category descriptions
SLA associations
TICKET 🎫
Main ticket entity with priority levels
Status tracking (open → in_progress → resolved → closed)
Agent assignment and timestamps
Full audit trail
MESSAGE 💬
Ticket communication history
Customer and agent messages
Chronological ordering
Supporting Entities
SLA ⏰
Service Level Agreements per category
Response and resolution time limits
Premium/VIP/Standard tiers
ESCALATION 🚨
Ticket escalation tracking
Escalation reasons and timestamps
FEEDBACK ⭐
Customer satisfaction ratings (1-5 scale)
Comments and feedback tracking
AGENT_METRICS 📊
Performance tracking
Resolution rates and handling times
TICKET_HISTORY 📜
Complete audit trail
Status and priority change tracking
🚀 Quick Start
Prerequisites
Java 8 or higher
MySQL 5.7 or higher
MySQL JDBC Driver
Setup
Create Database
CREATE DATABASE support_ticket_system;
Run Schema
mysql -u root -p support_ticket_system < support_ticket_schema.sql
Build Project
chmod +x build.sh
./build.sh
Run Demo
java -cp vanshit-support-ticket.jar:mysql-connector-java-8.0.33.jar SupportTicketDemo
🔧 Configuration
Update database connection in SupportTicketDB.java:

private static final String DB_URL = "jdbc:mysql://localhost:3306/support_ticket_system";
private static final String USER = "root";
private static final String PASS = "your_password";
📚 API Reference
Core Functions
Customer Management
// Create customer
boolean createCustomer(String name, String phoneNumber, String email)

// Get customer feedback summary
List<Map<String, Object>> getCustomerFeedbackSummary()
Agent Management
// Create agent
boolean createAgent(String name, String email)

// Assign agent to category
boolean assignAgentToCategory(int agentId, int categoryId)

// Get agent workload
List<Map<String, Object>> getAgentWorkload()

// Get agent performance metrics
List<Map<String, Object>> getAgentPerformanceMetrics()
Ticket Management
// Create ticket
boolean createTicket(int customerId, int categoryId, String title, String description, String priority)

// Assign ticket to agent
boolean assignTicketToAgent(int ticketId, int agentId)

// Update ticket status
boolean updateTicketStatus(int ticketId, String status)

// Get tickets by status
List<Map<String, Object>> getTicketsByStatus(String status)
Communication
// Add message to ticket
boolean addMessage(int ticketId, String senderType, int senderId, String content)

// Get ticket messages
List<Map<String, Object>> getTicketMessages(int ticketId)
SLA & Escalation
// Create SLA
boolean createSLA(int categoryId, int maxResponseTime, int maxResolutionTime, String slaName)

// Escalate ticket
boolean escalateTicket(int ticketId, String reason)

// Get escalated tickets
List<Map<String, Object>> getEscalatedTickets()

// Get SLA violations
List<Map<String, Object>> getSLAViolations()
Feedback
// Submit feedback
boolean submitFeedback(int ticketId, int customerId, int agentId, int rating, String comments)
🎯 Business Logic
Priority Levels
low - General inquiries
medium - Standard issues
high - Urgent problems
urgent - Critical issues
Ticket Status Flow
open - New ticket created
in_progress - Agent working on it
resolved - Issue resolved
closed - Ticket closed
SLA Types
Standard - Regular support
Premium - Priority support
VIP - High-priority support
Agent Assignment Logic
Agents assigned to specific categories
Workload balancing
Availability checking
Performance-based assignment
📊 Key Features
1. Multi-Category Support 📂
Technical Support
Billing Issues
General Inquiries
Custom categories
2. Intelligent Agent Assignment 🎯
Category-based assignment
Workload balancing
Performance tracking
Availability management
3. SLA Monitoring ⏰
Response time tracking
Resolution time monitoring
Automatic violation detection
Escalation triggers
4. Communication Tracking 💬
Full message history
Customer-agent conversations
Timestamp tracking
Message threading
5. Performance Analytics 📈
Agent performance metrics
Customer satisfaction scores
Resolution time analysis
Workload distribution
6. Audit Trail 📜
Complete ticket history
Status change tracking
Priority change logging
Escalation history
🔍 Sample Queries
Get Open Tickets
SELECT t.*, c.name as customer_name, cat.name as category_name
FROM TICKET t
JOIN CUSTOMER c ON t.customer_id = c.customer_id
JOIN CATEGORY cat ON t.category_id = cat.category_id
WHERE t.status = 'open'
ORDER BY t.priority DESC, t.created_at ASC;
Agent Workload
SELECT a.name, COUNT(t.ticket_id) as active_tickets
FROM AGENT a
LEFT JOIN TICKET t ON a.agent_id = t.agent_id 
    AND t.status IN ('open', 'in_progress')
WHERE a.is_available = TRUE
GROUP BY a.agent_id, a.name
ORDER BY active_tickets DESC;
SLA Violations
SELECT t.ticket_id, t.title, 
       TIMESTAMPDIFF(HOUR, t.created_at, NOW()) as hours_overdue
FROM TICKET t
JOIN CATEGORY c ON t.category_id = c.category_id
JOIN SLA s ON c.category_id = s.category_id
WHERE t.status IN ('open', 'in_progress')
  AND TIMESTAMPDIFF(HOUR, t.created_at, NOW()) > s.max_response_time;
🛠️ Technical Details
Database Design
Normalization: 3NF compliance
Indexing: Optimized for common queries
Constraints: Foreign keys and check constraints
Triggers: Automatic timestamp updates
Performance Optimizations
Strategic indexing on frequently queried columns
Composite indexes for multi-column queries
Efficient joins for complex queries
Connection pooling ready
Security Features
Parameterized queries (SQL injection prevention)
Input validation
Error handling
Connection management
📁 Project Structure
VANSHIT/
├── SupportTicketDB.java      # Main JDBC implementation
├── SupportTicketDemo.java    # Demo application
├── support_ticket_schema.sql # Database schema
├── build.sh                  # Build script
├── manifest.txt              # JAR manifest
├── README.md                 # This file
└── vanshit-support-ticket.jar # Compiled JAR
🎉 Demo Features
The demo showcases:

Schema Creation - Database setup
Sample Data - Test data insertion
Core Functions - All CRUD operations
Query Functions - Analytics and reporting
Error Handling - Robust error management
🔧 Troubleshooting
Common Issues
Database Connection Failed

Check MySQL service is running
Verify credentials in SupportTicketDB.java
Ensure database exists
Compilation Errors

Ensure Java 8+ is installed
Check MySQL JDBC driver is present
Verify all source files are in directory
Runtime Errors

Check database schema is created
Verify sample data is inserted
Review error messages for specific issues
📞 Support
For issues or questions:

Check the troubleshooting section
Review error messages
Verify database setup
Test with demo application
VANSHIT Support Ticket System - Professional-grade customer support management! 🎫✨
