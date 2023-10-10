CREATE TABLE merchants (
	mid	INT(4) NOT NULL,
	name	VARCHAR(100),
	city	VARCHAR(100),
	state	VARCHAR(100),
    PRIMARY KEY (mid)
);

CREATE TABLE products (
	pid		INT(4) NOT NULL,
	name		VARCHAR(100),
	category	VARCHAR(100),
    	description	VARCHAR(600),
    PRIMARY KEY (pid),
    CONSTRAINT name_constraint CHECK (name IN ('Printer', 'Ethernet Adapter', 'Desktop', 'Hard Drive', 'Laptop', 'Router', 'Network Card', 'Super Drive', 'Monitor')),
    CONSTRAINT category_constraint CHECK (category IN ('Peripheral', 'Networking', 'Computer'))
);

CREATE TABLE sell (
   mid					INT(4) NOT NULL,
   pid					INT(4) NOT NULL,
   price				NUMERIC(10,2),
   quantity_available			INT(4),
   FOREIGN KEY(mid) REFERENCES merchants(mid),
   FOREIGN KEY(pid) REFERENCES products(pid),
   CONSTRAINT price_constraint  CHECK (price BETWEEN 0 AND 100000),
   CONSTRAINT quantity_available_constraint  CHECK (quantity_available BETWEEN 0 AND 1000)
);

CREATE TABLE orders (
	oid			INT(4) NOT NULL,
	shipping_method		VARCHAR(200),
	shipping_cost		NUMERIC(6,2),
    PRIMARY KEY (oid),
    CONSTRAINT shipping_method_constraint CHECK (shipping_method IN ('UPS', 'FedEx', 'USPS')),
    CONSTRAINT shipping_cost_constraint  CHECK (shipping_cost BETWEEN 0 AND 500)
);
    
CREATE TABLE contain (
	oid		INT(4) NOT NULL,
	pid		INT(4) NOT NULL,
   FOREIGN KEY(oid) REFERENCES orders(oid),
   FOREIGN KEY(pid) REFERENCES products(pid)
);

CREATE TABLE customers (
	cid		INT(4) NOT NULL,
	fullname	VARCHAR(100),
	city		VARCHAR(100),
	state		VARCHAR(100),
    PRIMARY KEY (cid)
);
    
CREATE TABLE place (
   cid			INT(4) NOT NULL,
   oid			INT(4) NOT NULL,
   order_date		date,
   FOREIGN KEY(cid) REFERENCES customers(cid),
   FOREIGN KEY(oid) REFERENCES orders(oid)
);
