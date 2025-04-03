--Amazon Project

--category table
CREATE TABLE category
(
category_id int PRIMARY KEY,
category_name VARCHAR(20)
);

--customer TABLE
CREATE TABLE customers
(
customer_id INT PRIMARY KEY,
first_name VARCHAR(20),
last_name VARCHAR(20),
state VARCHAR(20),
address VARCHAR(5) DEFAULT 'Unknown'
);

--seller table
CREATE TABLE sellers
(
seller_id INT PRIMARY KEY,
seller_name VARCHAR(25),
origin VARCHAR(5)
);

--products table
CREATE TABLE products
(
product_id INT PRIMARY KEY,
product_name VARCHAR(50),
price FLOAT,
cogs FLOAT,
category_id INT,--FK
CONSTRAINT product_fk_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

--orders table
CREATE TABLE orders
(
order_id INT PRIMARY KEY,
order_date DATE,
customer_id INT,--fk
seller_id INT,--fk
order_status VARCHAR(15),
CONSTRAINT orders_fk_customers FOREIGN KEY (customer_id) references customers(customer_id),
CONSTRAINT orders_fk_sellers FOREIGN KEY (seller_id) references sellers(seller_id)
);

--order_items
CREATE TABLE order_items
(
order_item_id INT PRIMARY KEY,
order_id INT, --fk
product_id INT, --fk
quantity INT,
price_per_unit FLOAT,
CONSTRAINT order_items_fk_orders FOREIGN KEY (order_id) references orders(order_id),
CONSTRAINT order_items_fk_products FOREIGN KEY (product_id) references products(product_id)
);

--payment TABLE
CREATE TABLE payments
(
payment_id INT PRIMARY KEY,
order_id INT, --FK
payment_date DATE,
payment_status VARCHAR(20),
CONSTRAINT payments_fk_orders foreign key (order_id) references orders(order_id)
);

--shipping table
CREATE TABLE shippings
(shipping_id INT PRIMARY KEY,
order_id INT, --FK
shipping_date DATE,
return_date DATE,
shipping_providers VARCHAR(15),
delivery_status VARCHAR(15),
CONSTRAINT shipping_fk_orders foreign key (order_id) references orders(order_id)
);

--inventory table
CREATE TABLE inventory
(
inventory_id INT PRIMARY KEY,
product_id INT, --fk
stock INT,
warehouse_id INT,
last_stock_date DATE,
CONSTRAINT inventory_fk_products FOREIGN KEY (product_id) references products(product_id)
);


