CREATE SCHEMA IF NOT EXISTS marts;

CREATE TABLE IF NOT EXISTS marts.bandcamp_sales(
id BIGSERIAL NOT NULL,
created_at timestamp DEFAULT current_timestamp NOT NULL,
utc_datetime TIMESTAMP NOT NULL,  
utc_date DATE NOT NULL DEFAULT NOW(),
country VARCHAR(250), 
slug_type CHAR(1), 
item_price FLOAT, 
item_description TEXT, 
amount_paid FLOAT, 
artist_name VARCHAR(250),
currency VARCHAR(35), 
album_title TEXT, 
amount_paid_usd FLOAT
)PARTITION BY RANGE(utc_date);

CREATE INDEX country_index ON marts.bandcamp_sales(country);
CREATE INDEX slug_type_index on marts.bandcamp_sales(slug_type);

CREATE TABLE marts.bandcamp_sales_2020_09 PARTITION OF marts.bandcamp_sales
FOR VALUES FROM ('2020-09-01') TO ('2020-10-01');
CREATE TABLE marts.bandcamp_sales_2020_10 PARTITION OF marts.bandcamp_sales
FOR VALUES FROM ('2020-10-01') TO ('2020-11-01');