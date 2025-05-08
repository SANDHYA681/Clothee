-- Drop existing tables if needed
DROP TABLE IF EXISTS messages, wishlist, cart, reviews, shipping, payments, order_items, orders, products, categories, users;

-- Create users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'user',
    is_admin BOOLEAN NOT NULL DEFAULT FALSE,
    profile_image VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO users (first_name, last_name, email, password, phone, role, is_admin, profile_image) VALUES
('Sandhya', 'Timsina', 's@gmail.com', '123456', '1234567890', 'admin', TRUE, 'profiles/sandhya.jpg'),

-- Create categories table
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO categories (name, description) VALUES
('Men', 'Men''s clothing and accessories'),
('Women', 'Women''s clothing and accessories'),
('Kids', 'Children''s clothing and accessories'),
('Accessories', 'Fashion accessories for all');

-- Create products table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    category VARCHAR(50) NOT NULL,
    type VARCHAR(50),
    image_url VARCHAR(255),
    featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO products (name, description, price, stock, category, type, image_url, featured) VALUES
('Men''s Classic T-Shirt', 'A comfortable cotton t-shirt for everyday wear.', 19.99, 100, 'Men', 'T-Shirts', 'images/products/men/tshirt1.jpg', TRUE),
('Women''s Summer Dress', 'A light and flowy dress perfect for summer days.', 39.99, 50, 'Women', 'Dresses', 'images/products/women/dress1.jpg', TRUE),
('Kids'' Denim Jeans', 'Durable denim jeans for active children.', 24.99, 75, 'Kids', 'Jeans', 'images/products/kids/jeans1.jpg', FALSE),
('Leather Belt', 'A classic leather belt to complete any outfit.', 29.99, 60, 'Accessories', 'Belts', 'images/products/accessories/belt1.jpg', TRUE),
('Men''s Formal Shirt', 'A crisp formal shirt for professional settings.', 49.99, 80, 'Men', 'Shirts', 'images/products/men/shirt1.jpg', TRUE),
('Women''s Jeans', 'Comfortable and stylish jeans for women.', 44.99, 65, 'Women', 'Jeans', 'images/products/women/jeans1.jpg', FALSE),
('Kids'' T-Shirt', 'Colorful and fun t-shirts for children.', 14.99, 90, 'Kids', 'T-Shirts', 'images/products/kids/tshirt1.jpg', TRUE),
('Sunglasses', 'Stylish sunglasses for UV protection.', 59.99, 40, 'Accessories', 'Eyewear', 'images/products/accessories/sunglasses1.jpg', TRUE);

-- Create orders table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    total_price DECIMAL(10, 2),
    order_placed_date DATETIME,
    status VARCHAR(100),
    user_id INT,
    shipping_address TEXT,
    payment_method VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO orders (total_price, order_placed_date, status, user_id, shipping_address, payment_method) VALUES
(69.98, '2025-04-21 10:30:00', 'Processing', 1, 'Ram Bahadur, 123 Main St, Kathmandu, Nepal', 'Credit Card');

-- Create order_items table
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    image_url VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

INSERT INTO order_items (order_id, product_id, product_name, price, quantity, image_url) VALUES
(1, 1, 'Men''s Classic T-Shirt', 19.99, 2, 'images/products/men/tshirt1.jpg'),
(1, 4, 'Leather Belt', 29.99, 1, 'images/products/accessories/belt1.jpg');

-- Create payments table
CREATE TABLE payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    payment_date DATETIME,
    payment_method VARCHAR(100),
    status VARCHAR(50),
    amount DECIMAL(10, 2),
    order_id INT,
    user_id INT,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO payments (payment_date, payment_method, status, amount, order_id, user_id) VALUES
('2025-04-21 10:35:00', 'Credit Card', 'Completed', 69.98, 1, 1);

-- Create shipping table
CREATE TABLE shipping (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shipping_address TEXT,
    shipping_date DATETIME,
    shipping_status VARCHAR(100),
    order_id INT,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

INSERT INTO shipping (shipping_address, shipping_date, shipping_status, order_id) VALUES
('Kathmandu, Nepal', '2025-04-22 09:00:00', 'Shipped', 1);

-- Create reviews table
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rating INT,
    comment TEXT,
    reviewed_date DATETIME,
    user_id INT,
    product_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO reviews (rating, comment, reviewed_date, user_id, product_id) VALUES
(5, 'Great quality shirt!', '2025-04-23 12:00:00', 1, 1);

-- Create cart table
CREATE TABLE cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quantity INT NOT NULL DEFAULT 1,
    added_date DATETIME,
    user_id INT,
    product_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO cart (quantity, added_date, user_id, product_id) VALUES
(2, '2025-04-21 08:30:00', 3, 2);



-- Create messages table
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO messages (name, email, subject, message, is_read) VALUES
('John Doe', 'johndoe@example.com', 'Product Inquiry', 'Can I get more details about the T-shirt?', FALSE),
('Jane Doe', 'janedoe@example.com', 'Shipping Issue', 'My order hasn''t been delivered yet.', FALSE),
('Alice Smith', 'alicesmith@example.com', 'Account Issue', 'I forgot my password, can you help?', TRUE);

--