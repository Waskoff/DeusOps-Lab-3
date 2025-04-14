package main

import (
    "fmt"
    "os"
)

func main() {
    // Читаем переменную окружения GREETING. Если она не задана, используем значение по умолчанию.
    greeting := os.Getenv("GREETING")
    if greeting == "" {
        greeting = "Hello, World!"
    }
    fmt.Println(greeting)
}
