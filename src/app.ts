import express, { NextFunction, Request, Response } from "express";
import { getLastTripEntryIdAndTimeStamp, makeFloorDirty, recordTripResult } from './databaseFunctions'
import { Calculations } from "./calculations";

import dotenv from "dotenv";
import { Pool } from "pg";

dotenv.config();

const app = express();
const calculations: any = new Calculations();
var bodyParser = require('body-parser');
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(bodyParser.json())

export const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT || "5432")
});

async function connectToDB() {
  try {
    await pool.connect();
    console.log('Connected to the database');
  } catch (error) {
    console.error('Error connecting to the database:', error);
    throw error;
  }
}

connectToDB()

app.get("/test", (req: Request, res: Response, next: NextFunction) => {
  res.send("hi");
});

app.post('/tibber-developer-test/enter-path', async function (req, res) {
  try {
    const start_time = new Date().getTime();
    const start_date = new Date(start_time);
    const start_formattedDate = `${start_date.toLocaleDateString()} ${start_date.toLocaleTimeString()} seconds => ${start_date.getSeconds()}`;

    console.log("START TIME: " + start_formattedDate)
    var num_of_unique_areas_cleaned: number = 0

    await makeFloorDirty();
    await calculations.processCommands(req.body);

    const total_num_of_commands = await calculations.getTotalNumberOfCommands();
    num_of_unique_areas_cleaned = await calculations.getNumberOfUniqueAreasCleaned();

    const end_time = new Date().getTime()
    const end_date = new Date(end_time);
    const end_formattedDate = `${end_date.toLocaleDateString()} ${end_date.toLocaleTimeString()} seconds => ${end_date.getSeconds()}`;

    console.log("END TIME: " + end_formattedDate)

    const seconds_passed = end_time.valueOf() / 1000 - start_time.valueOf() / 1000
    console.log("SECONDS PASSED: " + seconds_passed)

    await recordTripResult(total_num_of_commands, num_of_unique_areas_cleaned, seconds_passed)
    const lastTripEntry = await getLastTripEntryIdAndTimeStamp()

    res.send({
      'id': lastTripEntry?.id,
      'timestamp': lastTripEntry?.timestamp,
      'commands': total_num_of_commands,
      'result': num_of_unique_areas_cleaned,
      'duration': seconds_passed
    });

  } catch (err: unknown) {
    console.log(err);
    if (err instanceof Error) {
      res.json(err.message);
    }
  }

});

app.listen(process.env.PORT, () => {
  console.log(`Server is running at ${process.env.PORT}`);
});
