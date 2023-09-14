import { pool } from './app';

export async function isAreaCleaned(input_x: number, input_y: number): Promise<boolean> {
    try {
        const partition_name = getDesignatedPartition(input_x, input_y)
        const data = await pool.query(`SELECT is_cleaned FROM ${partition_name} WHERE x = $1 AND y = $2`, [input_x, input_y]);
        return data.rows[0].is_cleaned;

    } catch (error) {
        console.error('Error fetching data:', error);
        throw error;
    }
}

export async function updateAreaToClean(input_x: number, input_y: number): Promise<void> {
    try {
        const partition_name = getDesignatedPartition(input_x, input_y)
        await pool.query(`UPDATE ${partition_name} SET is_cleaned = TRUE, updated_at = NOW() WHERE x = $1 AND y = $2`, [input_x, input_y]);
        console.log('is_cleaned set to true.');
    } catch (error) {
        console.error('Error updating data:', error);
        throw error;
    }
}

export async function makeFloorDirty(): Promise<void> {
    try {
        var full_query = ""
        for (let i = 1; i <= 4; i++) {
            var query = "UPDATE grid_coordinates_partition" + i + " SET is_cleaned = FALSE, updated_at = NOW();"
            full_query += query
        }
        await pool.query(full_query);
        console.log('The Floor is dirty!');
    } catch (error) {
        console.error('Error updating data:', error);
        throw error;
    }
}

export async function recordTripResult(num_of_commands: number, num_of_unique_areas_cleaned: number, seconds_passed: number): Promise<void> {
    try {
        await pool.query(
            `INSERT INTO unique_areas_cleaned (commands, result, duration) 
            VALUES ($1, $2, $3);`,
            [num_of_commands, num_of_unique_areas_cleaned, seconds_passed]);
    } catch (error) {
        console.error('Error setting trip information:', error);
        throw error;
    }
}

export async function getLastTripEntryIdAndTimeStamp(): Promise<{ id: string; timestamp: string } | null> {
    try {
        const data = await pool.query('SELECT * FROM unique_areas_cleaned ORDER BY timestamp DESC LIMIT 1;');

        const lastTripEntry = {
            id: data.rows[0].id,
            timestamp: data.rows[0].timestamp,
        };

        return lastTripEntry
    } catch (error) {
        console.error('Error fetching data:', error);
        throw error;
    }
}

function getDesignatedPartition(input_x: number, input_y: number): string {
    var partition_name = 'grid_coordinates_partition';
    if (input_x >= 0 && input_y >= 0) {
        return partition_name + '1';
    } else if (input_x >= 0 && input_y <= -1) {
        return partition_name + '2';
    } else if (input_x <= -1 && input_y <= -1) {
        return partition_name + '3';
    } else if (input_x <= -1 && input_y >= 0) {
        return partition_name + '4';
    } else {
        console.log('This is an invalid partition option.');
        return 'INVALID TABLE NAME';
    }
}