# Veronica's Cleaning Robot Microservice #
## To run the project locally: ##
1. Open your terminal and navigate to the project folder
1. Run `npm i`
1. Run `docker-compose up --build`

## To access the database: ##
1. Visit the following url in your browser: <br>
`http://localhost:16543/`
1. Login with the following credentials: <br>
    - Username: `test@email.com` <br>
    - Password: `pass`
1. Select **Add New Server**
1. In the **General** tab input the following: <br>
    - Name: `tibber` 
1. In the **Connection** tab input the following: <br>
    - Host name/address: `db`
    - Port: `5432`
    - Maintenance database: `postgres`
    - Username: `postgres`
    - Password: `password`
    - Save Password: `TRUE`
1. Click the **Save** button

## To see HTTP test: ## 
1. Visit the following url in your browser: <br>
`http://localhost:5001/test`

## Create POST request via Postman ## 
1. Download Postman
1. Create POST with following URL: <br>
`http://localhost:5001/tibber-developer-test/enter-path`
1. In **Headers** tab, add field with:
Key: `Content-Type` <br>
Value: `application/json`
1. In **Body** tab, add **raw JSON** body with the following JSON format: <br>
    >{
        "start": {
            "x": 0,
            "y": 0
        },
        "commands": [
            {
                "direction": "north",
                "steps": 2
            },
            {
                "direction": "south",
                "steps": 1
            },
            {
                "direction": "west",
                "steps": 2
            }
        ]
    }
1. Click the **Send** button
1. You should receive a JSON body like:
    >{
        "id": 10,
        "timestamp": "2023-09-10T03:03:30.555Z",
        "commands": 3,
        "result": 5,
        "duration": 3.059000015258789
    }