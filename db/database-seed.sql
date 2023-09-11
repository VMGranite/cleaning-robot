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

-- Populate an X,Y grid from -10 to 10
INSERT INTO grid_coordinates (x, y)
SELECT x, y
FROM generate_series(-10, 10) AS x
CROSS JOIN generate_series(-10, 10) AS y;