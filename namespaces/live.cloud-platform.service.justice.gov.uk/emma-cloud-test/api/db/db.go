package db

import (
	"database/sql"
	"fmt"

	_ "github.com/mattn/go-sqlite3" // SQLite driver
)

// Todo represents a todo in the database
type Todo struct {
	ID        string `json:"id"`
	Item      string `json:"item"`
	Completed bool   `json:"completed"`
}

// CreateDB initializes the SQLite database and returns a database connection.
func CreateDB() (*sql.DB, error) {
	// Open a database connection
	db, err := sql.Open("sqlite3", "./local.db") // Your SQLite database file
	if err != nil {
		return nil, err
	}

	// Create the todos table if it doesn't exist
	err = CreateTable(db)
	if err != nil {
		return nil, err
	}

	return db, nil
}

// CreateTable creates the todos table if it doesn't exist
func CreateTable(db *sql.DB) error {
	createTableSQL := `CREATE TABLE IF NOT EXISTS todos (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		item TEXT,
		completed BOOLEAN
	);`
	_, err := db.Exec(createTableSQL)
	return err
}

// AddTodo inserts a new todo into the database
func AddTodo(db *sql.DB, item string) (Todo, error) {
	insertSQL := `INSERT INTO todos (item, completed) VALUES (?, ?)`
	result, err := db.Exec(insertSQL, item, false) // false means not completed
	if err != nil {
		return Todo{}, err
	}

	// Get the inserted todo's ID
	id, err := result.LastInsertId()
	if err != nil {
		return Todo{}, err
	}

	// Return the new todo
	newTodo := Todo{ID: fmt.Sprintf("%d", id), Item: item, Completed: false}
	return newTodo, nil
}

// GetTodos retrieves all todos from the database
func GetTodos(db *sql.DB) ([]Todo, error) {
	rows, err := db.Query("SELECT id, item, completed FROM todos")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var todos []Todo
	for rows.Next() {
		var todo Todo
		err := rows.Scan(&todo.ID, &todo.Item, &todo.Completed)
		if err != nil {
			return nil, err
		}
		todos = append(todos, todo)
	}
	return todos, nil
}

// GetTodoByID retrieves a todo by its ID
func GetTodoByID(db *sql.DB, id string) (*Todo, error) {
	var todo Todo
	err := db.QueryRow("SELECT id, item, completed FROM todos WHERE id = ?", id).Scan(&todo.ID, &todo.Item, &todo.Completed)
	if err != nil {
		return nil, err
	}
	return &todo, nil
}

// ToggleTodoStatus toggles the completed status of a todo
func ToggleTodoStatus(db *sql.DB, id string) error {
	_, err := db.Exec("UPDATE todos SET completed = NOT completed WHERE id = ?", id)
	return err
}
