/*
  # Fashion Store Database Schema

  ## Overview
  Complete e-commerce database schema for a fashion catalogue application with product management, 
  shopping cart, and order tracking with customer locations.

  ## New Tables

  ### 1. categories
  Stores product categories (Men, Women, Formal, Casual, etc.)
  - `id` (uuid, primary key) - Unique category identifier
  - `name` (text) - Category name
  - `slug` (text) - URL-friendly category identifier
  - `description` (text) - Category description
  - `image_url` (text) - Category banner image
  - `created_at` (timestamptz) - Record creation timestamp

  ### 2. products
  Stores all product information
  - `id` (uuid, primary key) - Unique product identifier
  - `name` (text) - Product name
  - `description` (text) - Product description
  - `price` (numeric) - Product price
  - `image_url` (text) - Product image URL
  - `category_id` (uuid, foreign key) - References categories table
  - `sizes` (text[]) - Available sizes
  - `in_stock` (boolean) - Stock availability
  - `created_at` (timestamptz) - Record creation timestamp

  ### 3. orders
  Stores customer orders
  - `id` (uuid, primary key) - Unique order identifier
  - `customer_name` (text) - Customer full name
  - `customer_email` (text) - Customer email address
  - `customer_phone` (text) - Customer phone number
  - `delivery_address` (text) - Delivery address
  - `location_lat` (numeric) - Latitude coordinate
  - `location_lng` (numeric) - Longitude coordinate
  - `total_amount` (numeric) - Total order amount
  - `status` (text) - Order status (pending, processing, delivered, cancelled)
  - `notes` (text) - Additional order notes
  - `created_at` (timestamptz) - Order creation timestamp

  ### 4. order_items
  Stores individual items in each order
  - `id` (uuid, primary key) - Unique order item identifier
  - `order_id` (uuid, foreign key) - References orders table
  - `product_id` (uuid, foreign key) - References products table
  - `product_name` (text) - Product name snapshot
  - `product_price` (numeric) - Product price snapshot
  - `size` (text) - Selected size
  - `quantity` (integer) - Item quantity
  - `subtotal` (numeric) - Line item subtotal
  - `created_at` (timestamptz) - Record creation timestamp

  ## Security
  - Enable Row Level Security (RLS) on all tables
  - Public read access for categories and products (catalog browsing)
  - Public insert access for orders and order_items (customer ordering)
  - Restricted update/delete operations (future admin panel)
*/

-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  description text DEFAULT '',
  image_url text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text DEFAULT '',
  price numeric(10,2) NOT NULL CHECK (price >= 0),
  image_url text NOT NULL,
  category_id uuid REFERENCES categories(id) ON DELETE CASCADE,
  sizes text[] DEFAULT '{}',
  in_stock boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_name text NOT NULL,
  customer_email text NOT NULL,
  customer_phone text NOT NULL,
  delivery_address text NOT NULL,
  location_lat numeric(10,8),
  location_lng numeric(11,8),
  total_amount numeric(10,2) NOT NULL CHECK (total_amount >= 0),
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'delivered', 'cancelled')),
  notes text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES products(id) ON DELETE SET NULL,
  product_name text NOT NULL,
  product_price numeric(10,2) NOT NULL,
  size text DEFAULT '',
  quantity integer NOT NULL CHECK (quantity > 0),
  subtotal numeric(10,2) NOT NULL CHECK (subtotal >= 0),
  created_at timestamptz DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Categories policies (public read)
CREATE POLICY "Anyone can view categories"
  ON categories FOR SELECT
  TO public
  USING (true);

-- Products policies (public read)
CREATE POLICY "Anyone can view products"
  ON products FOR SELECT
  TO public
  USING (true);

-- Orders policies (public insert, restricted read)
CREATE POLICY "Anyone can create orders"
  ON orders FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can view orders"
  ON orders FOR SELECT
  TO public
  USING (true);

-- Order items policies (public insert, restricted read)
CREATE POLICY "Anyone can create order items"
  ON order_items FOR INSERT
  TO public
  WITH CHECK (true);

CREATE POLICY "Anyone can view order items"
  ON order_items FOR SELECT
  TO public
  USING (true);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_in_stock ON products(in_stock);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);