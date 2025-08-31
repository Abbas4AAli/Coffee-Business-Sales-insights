CREATE TABLE city
(
	city_id INT PRIMARY KEY,
	city_name VARCHAR(15),
	population INT,
	estimated_rent INT,
	city_rank INT
);


CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,
	customer_name VARCHAR(30),
	city_id INT,
	CONSTRAINT FK_customers_city_id FOREIGN KEY (city_id) REFERENCES city(city_id)

);

CREATE TABLE products
(
	product_id int PRIMARY KEY,
	product_name VARCHAR(50),
	price int
);
 

CREATE TABLE SALES 
(
	sale_id INT PRIMARY KEY,
	sale_date DATE,
	product_id int,
	customer_id INT,
	total int,
	rating int,
	CONSTRAINT FK_SALES_products_id FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT FK_SALES_customers_id FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);







