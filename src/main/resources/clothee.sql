-- Drop existing tables if needed
DROP TABLE IF EXISTS messages, cart, reviews, shipping, payments, order_items, orders, products, categories, users;

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
    FOREIGN KEY (user_id) REFERENCES users(id)
);


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


-- Create shipping table
CREATE TABLE shipping (
    id INT AUTO_INCREMENT PRIMARY KEY,
    shipping_date DATETIME,
    shipping_status VARCHAR(100),
    shipping_address VARCHAR(255),
    order_id INT,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);



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



-- Create messages table
CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

