// Go Fiber Benchmark (Prime State)
package main

import (
	"fmt"
	"os"
	"time"

	"github.com/gofiber/fiber/v2"
)

func main() {
	app := fiber.New(fiber.Config{
		DisableStartupMessage: true,
	})

	app.Get("/", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"message":   "Hello from Go (Fiber)",
			"timestamp": time.Now().UnixMilli(),
		})
	})

	port := 3002
	fmt.Printf("Go (Fiber) running on http://localhost:%d\n", port)
	fmt.Printf("PID: %d\n", os.Getpid())

	app.Listen(fmt.Sprintf(":%d", port))
}
