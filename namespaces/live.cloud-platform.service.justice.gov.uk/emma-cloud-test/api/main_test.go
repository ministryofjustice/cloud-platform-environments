package main

import (
	"database/sql"
	"encoding/json"
	"example/api/db"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

// Setup a test database
func setupTestDB() *sql.DB {
	// Create a temporary in-memory SQLite database for testing
	dbConn, err := sql.Open("sqlite3", ":memory:") // Using in-memory database
	if err != nil {
		panic(err)
	}

	// Create the table in the test database
	err = db.CreateTable(dbConn)
	if err != nil {
		panic(err)
	}

	return dbConn
}

// Test the /todos endpoint (GET request)
func TestGetTodos(t *testing.T) {
	// Setup the test database
	dbConn := setupTestDB()
	defer dbConn.Close()

	// Insert sample todos into the database
	_, err := dbConn.Exec("INSERT INTO todos (item, completed) VALUES (?, ?)", "Test Todo 1", false)
	if err != nil {
		t.Fatal("Failed to insert sample todo:", err)
	}

	// Initialize Gin router
	router := gin.Default()
	router.GET("/todos", func(c *gin.Context) {
		getTodos(c, dbConn)
	})

	// Create a request and record the response
	req, _ := http.NewRequest("GET", "/todos", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	// Assert the status code and response body
	assert.Equal(t, http.StatusOK, w.Code)

	var todos []db.Todo
	err = json.Unmarshal(w.Body.Bytes(), &todos)
	assert.NoError(t, err)
	assert.Len(t, todos, 1) // We inserted 1 todo, so the response should contain 1 todo
}
