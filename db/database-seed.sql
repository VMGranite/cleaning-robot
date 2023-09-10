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
FROM (
    SELECT x, y
    FROM (
        SELECT -10 AS x
        UNION ALL SELECT -9
        UNION ALL SELECT -8
        UNION ALL SELECT -7
        UNION ALL SELECT -6
        UNION ALL SELECT -5
        UNION ALL SELECT -4
        UNION ALL SELECT -3
        UNION ALL SELECT -2
        UNION ALL SELECT -1
        UNION ALL SELECT 0
        UNION ALL SELECT 1
        UNION ALL SELECT 2
        UNION ALL SELECT 3
        UNION ALL SELECT 4
        UNION ALL SELECT 5
        UNION ALL SELECT 6
        UNION ALL SELECT 7
        UNION ALL SELECT 8
        UNION ALL SELECT 9
        UNION ALL SELECT 10
    ) AS x_values
    CROSS JOIN (
        SELECT -10 AS y
        UNION ALL SELECT -9
        UNION ALL SELECT -8
        UNION ALL SELECT -7
        UNION ALL SELECT -6
        UNION ALL SELECT -5
        UNION ALL SELECT -4
        UNION ALL SELECT -3
        UNION ALL SELECT -2
        UNION ALL SELECT -1
        UNION ALL SELECT 0
        UNION ALL SELECT 1
        UNION ALL SELECT 2
        UNION ALL SELECT 3
        UNION ALL SELECT 4
        UNION ALL SELECT 5
        UNION ALL SELECT 6
        UNION ALL SELECT 7
        UNION ALL SELECT 8
        UNION ALL SELECT 9
        UNION ALL SELECT 10
    ) AS y_values
) AS grid;