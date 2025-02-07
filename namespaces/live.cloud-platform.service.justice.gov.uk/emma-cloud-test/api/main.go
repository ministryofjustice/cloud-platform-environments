package main

import (
	"database/sql"
	"example/api/db"
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "todoapp",
	Short: "A simple CLI and HTTP server for managing todos",
	Run: func(cmd *cobra.Command, args []string) {
		// Default behavior if no subcommand is provided
		fmt.Println("You need to specify a subcommand (e.g., 'serve', 'add', 'list')")
	},
}

var serveCmd = &cobra.Command{
	Use:   "serve",
	Short: "Starts the HTTP server",
	Run: func(cmd *cobra.Command, args []string) {
		// Start the HTTP server
		startServer()
	},
}

var addCmd = &cobra.Command{
	Use:   "add",
	Short: "Add a new todo",
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) < 1 {
			fmt.Println("Please provide a todo item to add")
			return
		}
		item := args[0]
		addTodoCLI(item)
	},
}

var listCmd = &cobra.Command{
	Use:   "list",
	Short: "List all todos",
	Run: func(cmd *cobra.Command, args []string) {
		listTodosCLI()
	},
}

func init() {
	// Define the subcommands for CLI
	rootCmd.AddCommand(serveCmd)
	rootCmd.AddCommand(addCmd)
	rootCmd.AddCommand(listCmd)
}

func main() {
	// Run the Cobra CLI
	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}

// startServer starts the Gin HTTP server
func startServer() {
	// Set up the database connection
	dbConn, err := db.CreateDB()
	if err != nil {
		log.Fatal("Error setting up the database: ", err)
	}

	// Create a new Gin router
	router := gin.Default()

	// Define your API routes
	router.GET("/todos", func(c *gin.Context) {
		getTodos(c, dbConn)
	})

	router.POST("/todo", func(c *gin.Context) {
		addTodo(c, dbConn)
	})

	router.GET("/todo/:id", func(c *gin.Context) {
		getTodo(c, dbConn)
	})

	router.PATCH("/todo/:id", func(c *gin.Context) {
		toggleToDoStatus(c, dbConn)
	})

	// Start the server
	router.Run(":8080")
}

// getTodos handles GET requests to retrieve all todos
func getTodos(c *gin.Context, dbConn *sql.DB) {
	todos, err := db.GetTodos(dbConn)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not retrieve todos"})
		return
	}
	c.JSON(http.StatusOK, todos)
}

// addTodo handles POST requests to add a new todo
func addTodo(c *gin.Context, dbConn *sql.DB) {
	var newTodo db.Todo
	if err := c.BindJSON(&newTodo); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid input"})
		return
	}

	todo, err := db.AddTodo(dbConn, newTodo.Item)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not add todo"})
		return
	}

	c.JSON(http.StatusCreated, todo)
}

// getTodo handles GET requests to retrieve a todo by ID
func getTodo(c *gin.Context, dbConn *sql.DB) {
	id := c.Param("id")
	todo, err := db.GetTodoByID(dbConn, id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Todo not found"})
		return
	}
	c.JSON(http.StatusOK, todo)
}

// toggleToDoStatus toggles the completed status of a todo
func toggleToDoStatus(c *gin.Context, dbConn *sql.DB) {
	id := c.Param("id")
	err := db.ToggleTodoStatus(dbConn, id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Could not toggle status"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Status toggled"})
}

// CLI function to add a todo from the command line
func addTodoCLI(item string) {
	dbConn, err := db.CreateDB()
	if err != nil {
		fmt.Println("Error connecting to the database:", err)
		return
	}

	// Add the todo to the database
	todo, err := db.AddTodo(dbConn, item)
	if err != nil {
		fmt.Println("Error adding todo:", err)
		return
	}

	fmt.Printf("Todo added: %v\n", todo)
}

// CLI function to list all todos from the command line
func listTodosCLI() {
	dbConn, err := db.CreateDB()
	if err != nil {
		fmt.Println("Error connecting to the database:", err)
		return
	}

	// Get all todos from the database
	todos, err := db.GetTodos(dbConn)
	if err != nil {
		fmt.Println("Error fetching todos:", err)
		return
	}

	if len(todos) == 0 {
		fmt.Println("No todos found.")
		return
	}

	// Print the todos in the CLI
	for _, todo := range todos {
		fmt.Printf("%s: %s (Completed: %v)\n", todo.ID, todo.Item, todo.Completed)
	}
}
