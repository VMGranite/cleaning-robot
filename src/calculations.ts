import { isAreaCleaned, updateAreaToClean } from './databaseFunctions'
// import { isAreaCleaned, updateAreaToClean } from './databaseFunctionsForPartitionedTables'

export class Calculations {
    private current_x_location: number = 0
    private current_y_location: number = 0
    private num_of_unique_areas_cleaned: number = 0
    private total_num_of_commands: number = 0

    delay(ms: number) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    async processCommands(requestBody: any): Promise<void> {
        console.log(requestBody)
        const start_location_x = requestBody.start["x"]
        const start_location_y = requestBody.start["y"]
        this.current_x_location = start_location_x
        this.current_y_location = start_location_y
        this.num_of_unique_areas_cleaned = 0
        this.total_num_of_commands = 0

        if (typeof start_location_x != 'number' || typeof start_location_y != 'number') {
            console.log("Start Coordinates are invalid. Must contain numbers.")
            return;
        }

        const commands = requestBody.commands

        await this.cleanArea(start_location_x, start_location_y)

        for (const value of commands) {
            const direction = value.direction;
            const steps = value.steps;

            switch (direction) {
                case "north": {
                    this.go_north(steps)
                    break;
                }
                case "south": {
                    this.go_south(steps)
                    break;
                }
                case "east": {
                    this.go_east(steps)
                    break;
                }
                case "west": {
                    this.go_west(steps)
                    break;
                }
                default: {
                    console.log("Invalid direction type: " + direction)
                    break;
                }
            }
            await this.delay(1000);
            this.total_num_of_commands++;
        };
    }

    private async go_north(steps: number): Promise<void> {
        while (steps > 0) {
            this.current_y_location++
            console.log(`North => X (${this.current_x_location}) | Y (${this.current_y_location})`)
            await this.cleanArea(this.current_x_location, this.current_y_location)
            steps--;
        }
    }

    private async go_south(steps: number): Promise<void> {
        while (steps > 0) {
            this.current_y_location--
            console.log(`South => X (${this.current_x_location}) | Y (${this.current_y_location})`)
            await this.cleanArea(this.current_x_location, this.current_y_location)
            steps--;
        }
    }

    private async go_east(steps: number): Promise<void> {
        while (steps > 0) {
            this.current_x_location++
            console.log(`East => X (${this.current_x_location}) | Y (${this.current_y_location})`)
            await this.cleanArea(this.current_x_location, this.current_y_location)
            steps--;
        }
    }

    private async go_west(steps: number): Promise<void> {
        while (steps > 0) {
            this.current_x_location--
            console.log(`West => X (${this.current_x_location}) | Y (${this.current_y_location})`)
            await this.cleanArea(this.current_x_location, this.current_y_location)
            steps--;
        }
    }

    private async cleanArea(x: number, y: number): Promise<void> {
        try {
            const is_cleaned = await isAreaCleaned(x, y)

            if (is_cleaned == true) {
                console.log("Area is already clean.")
            } else if (is_cleaned == false) {
                this.num_of_unique_areas_cleaned++
                await updateAreaToClean(x, y)
            }
        } catch (error) {
            console.error('Error cleaning area:', error);
            throw error;
        }
    }

    async getNumberOfUniqueAreasCleaned(): Promise<number> {
        return this.num_of_unique_areas_cleaned
    }

    async getTotalNumberOfCommands(): Promise<number> {
        return this.total_num_of_commands
    }
}