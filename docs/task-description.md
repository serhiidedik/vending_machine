## Instructions:

This task should be implemented as a CLI application using Ruby programming language (no
db needed, all prerequisites data can be stored in the hash, yml, or another similar
structure). What we’re looking for in your code is readability and easy maintenance. We want to
see code that reveals its intent to the reader and follows best practices. To give you one hint, we
strongly believe that the application will benefit from a well structured OOP approach ;)
You also have to make sure the code really works and use any tool or technique you need to
accomplish this. We expect to see a couple of Unit tests around as well.

## Application:

Design a simplified version of the vending machine that meets the following requirements:
- Once the product is selected and the appropriate amount of coins is inserted, it should
  return the product.
- It should return change (coins) if inserted too much.
- Change should be returned with the minimum amount of coins possible.
- It should notify the customer when the selected product is out of stock.
- It should return inserted coins in case it does not have enough change

## Initial Input:

The vending machine should be initialized with the following inventory:

| Product Name | Price | Quantity |
|--------------|-------|----------|
| Coca Cola    | 2.00  | 10       |
| Sprite       | 2.50  | 10       |
| Fanta        | 2.25  | 10       |
| Orange Juice | 3.00  | 10       |
| Water        | 3.25  | 0        |

The vending machine should be initialized with the following set of coins in till:

| Value | Quantity |
|-------|----------|
| 5.00  | 5        |
| 3.00  | 5        |
| 2.00  | 5        |
| 1.00  | 5        |
| 0.50  | 5        |
| 0.25  | 5        |
