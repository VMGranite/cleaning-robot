CREATE TABLE unique_areas_cleaned (
    id SERIAL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    commands INT,
    result INT,
    duration DECIMAL,
    CONSTRAINT unique_areas_cleaned_pkey PRIMARY KEY(id)
);

CREATE TABLE grid_coordinates (
    id SERIAL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    x INT,
    y INT,
    is_cleaned BOOLEAN DEFAULT false,
    CONSTRAINT grid_coordinates_pkey PRIMARY KEY(id)
);

-- Child table for the range x: -100000 to -1 and y: -100000 to -1
CREATE TABLE grid_coordinates_partition1 (
    CHECK (x >= -100000 AND x <= -1 AND y >= -100000 AND y <= -1)
) INHERITS (grid_coordinates);

-- Child table for the range x: 0 to 100000 and y: 0 to 100000
CREATE TABLE grid_coordinates_partition2 (
    CHECK (x >= 0 AND x <= 100000 AND y >= 0 AND y <= 100000)
) INHERITS (grid_coordinates);

CREATE OR REPLACE FUNCTION insert_grid_coordinate()
RETURNS TRIGGER AS $$
BEGIN
    IF (NEW.x >= -100000 AND NEW.x <= -1 AND NEW.y >= -100000 AND NEW.y <= -1) THEN
        INSERT INTO grid_coordinates_partition1 VALUES (NEW.*);
    ELSIF (NEW.x >= 0 AND NEW.x <= 100000 AND NEW.y >= 0 AND NEW.y <= 100000) THEN
        INSERT INTO grid_coordinates_partition2 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'Invalid x and y range';
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger that calls the insert_grid_coordinate function before INSERT
CREATE TRIGGER insert_grid_coordinate_trigger
    BEFORE INSERT ON grid_coordinates
    FOR EACH ROW
    EXECUTE FUNCTION insert_grid_coordinate();

-- Create a trigger function to update the updated_at column on UPDATE
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger that calls the update_updated_at function after UPDATE
CREATE TRIGGER grid_coordinates_update_trigger
BEFORE UPDATE ON grid_coordinates
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

-- Populate the first partition (-100,000 to -1)
DO $$ 
DECLARE
    x_val INT;
    y_val INT;
BEGIN
    FOR x_val IN -100000..-1 LOOP
        FOR y_val IN -100000..-1 LOOP
            INSERT INTO grid_coordinates (x, y)
            VALUES (x_val, y_val);
        END LOOP;
    END LOOP;
END $$;

-- Populate the second partition (0 to 100,000)
DO $$ 
DECLARE
    x_val INT;
    y_val INT;
BEGIN
    FOR x_val IN 0..100000 LOOP
        FOR y_val IN 0..100000 LOOP
            INSERT INTO grid_coordinates (x, y)
            VALUES (x_val, y_val);
        END LOOP;
    END LOOP;
END $$;