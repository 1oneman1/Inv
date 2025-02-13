-- Create Users Table
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'warehouse_keeper', 'manager', 'assigned_user')),
    full_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Categories Table
CREATE TABLE Categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT REFERENCES Categories(category_id) ON DELETE CASCADE,
    CONSTRAINT unique_category_name_parent UNIQUE (category_name, parent_category_id)
);

-- Create Products Table
CREATE TABLE Products (
    product_id SERIAL PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    category_id INT REFERENCES Categories(category_id) ON DELETE CASCADE,
    specs JSONB,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Suppliers Table
CREATE TABLE Suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_type VARCHAR(20) NOT NULL CHECK (supplier_type IN ('local', 'worldwide', 'internal')),
    contact_info VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Inventory Table
CREATE TABLE Inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES Products(product_id) ON DELETE CASCADE,
    serial_number VARCHAR(100) UNIQUE,
    supplier_id INT REFERENCES Suppliers(supplier_id) ON DELETE CASCADE,
    received_date DATE NOT NULL,
    reference_number VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('available', 'assigned', 'used_in_manufacturing', 'destroyed', 'decomposed')),
    assigned_user_id INT REFERENCES Users(user_id) ON DELETE SET NULL,
    assigned_date DATE,
    manufactured_product_id INT REFERENCES Inventory(inventory_id) ON DELETE SET NULL,
    decomposed_date DATE,
    destroyed_date DATE,
    manufactured_date DATE,
    notes VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_assigned_date CHECK ((assigned_user_id IS NOT NULL AND assigned_date IS NOT NULL) OR (assigned_user_id IS NULL AND assigned_date IS NULL))
);

-- Create InternalEntities Table
CREATE TABLE InternalEntities (
    internal_entity_id SERIAL PRIMARY KEY,
    entity_name VARCHAR(100) NOT NULL,
    entity_info VARCHAR(255)
);

-- Create UserEntities Table
CREATE TABLE UserEntities (
    user_entity_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    internal_entity_id INT REFERENCES InternalEntities(internal_entity_id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT unique_user_entity UNIQUE (user_id, internal_entity_id)
);

-- Create Trigger Function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Trigger for inventory
CREATE TRIGGER update_inventory_updated_at
BEFORE UPDATE ON Inventory
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();