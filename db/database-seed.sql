CREATE TABLE unique_areas_cleaned (
    id SERIAL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    commands INT,
    result INT,
    duration DECIMAL,
    CONSTRAINT unique_areas_cleaned_pkey PRIMARY KEY(id)
);
-- Grid Range x: 0 to 10 and y: 0 to 10
CREATE TABLE grid_coordinates_partition1 (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    x INT,
    y INT,
    is_cleaned BOOLEAN DEFAULT false,
    CHECK (x >= 0 AND x <= 10 AND y >= 0 AND y <= 10) 
);

-- Grid Range x: 0 to 10 and y: -10 to -1
CREATE TABLE grid_coordinates_partition2 (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    x INT,
    y INT,
    is_cleaned BOOLEAN DEFAULT false,
    CHECK (x >= 0 AND x <= 10 AND y >= -10 AND y <= -1) 
);

-- Grid Range x: -10 to -1 and y: -10 to -1
CREATE TABLE grid_coordinates_partition3 (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    x INT,
    y INT,
    is_cleaned BOOLEAN DEFAULT false,
    CHECK (x >= -10 AND x <= -1 AND y >= -10 AND y <= -1) 
);

-- Grid Range x: -10 to -1 and y: 0 to 10
CREATE TABLE grid_coordinates_partition4 (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    x INT,
    y INT,
    is_cleaned BOOLEAN DEFAULT false,
    CHECK (x >= -10 AND x <= -1 AND y >= 0 AND y <= 10) 
);

-- Populate  partition 1 with Quadrant 1 X Y Grid Coordinates
DO $$ 
BEGIN
    FOR x_val IN 0..10 LOOP
        FOR y_val IN 0..10 LOOP
            INSERT INTO grid_coordinates_partition1(x,y) VALUES (x_val, y_val);
        END LOOP;
    END LOOP;
    COMMIT;
END $$;

-- Populate  partition 2 with Quadrant 2 X Y Grid Coordinates
DO $$ 
BEGIN
    FOR x_val IN 0..10 LOOP
        FOR y_val IN -10..-1 LOOP
            INSERT INTO grid_coordinates_partition2(x,y) VALUES (x_val, y_val);
        END LOOP;
    END LOOP;
    COMMIT;
END $$;

-- Populate partition 3 with Quadrant 3 X Y Grid Coordinates
DO $$ 
BEGIN
    FOR x_val IN -10..-1 LOOP
        FOR y_val IN -10..-1 LOOP
            INSERT INTO grid_coordinates_partition3(x,y) VALUES (x_val, y_val);
        END LOOP;
    END LOOP;
    COMMIT;
END $$;

-- Populate partition 4 with Quadrant 4 X Y Grid Coordinates
DO $$ 
BEGIN
    FOR x_val IN -10..-1 LOOP
        FOR y_val IN 0..10 LOOP
            INSERT INTO grid_coordinates_partition4(x,y) VALUES (x_val, y_val);
        END LOOP;
    END LOOP;
    COMMIT;
END $$;