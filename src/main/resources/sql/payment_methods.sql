-- Create payment_methods table
CREATE TABLE IF NOT EXISTS payment_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    card_type VARCHAR(50) NOT NULL,
    card_name VARCHAR(100) NOT NULL,
    card_number VARCHAR(4) NOT NULL, -- Last 4 digits only for security
    expiry_date VARCHAR(5) NOT NULL,
    billing_address VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_zip VARCHAR(20),
    billing_country VARCHAR(100),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Add index for faster lookups
CREATE INDEX idx_payment_methods_user_id ON payment_methods(user_id);
