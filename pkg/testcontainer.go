package migrations

import (
	"context"
	"fmt"
	"os"
	"strconv"

	"github.com/testcontainers/testcontainers-go"

	_ "github.com/lib/pq"
	"github.com/moby/moby/api/types/network"
	"github.com/testcontainers/testcontainers-go/wait"
)

func CreatePostgresTestContainer(ctx context.Context) (*DatabaseConnectionParams, testcontainers.Container, error) {
	tUser := os.Getenv("TEST_PG_USER")
	tPassword := os.Getenv("TEST_PG_PASSWORD")
	tDB := os.Getenv("TEST_PG_DB")
	tHost := os.Getenv("TEST_PG_HOST")
	tPort := os.Getenv("TEST_PG_PORT")
	tImage := os.Getenv("TEST_PG_IMAGE")
	tVersion := os.Getenv("TEST_PG_VERSION")
	env := map[string]string{
		"POSTGRES_USER":     tUser,
		"POSTGRES_PASSWORD": tPassword,
		"POSTGRES_DB":       tDB,
	}
	dbURL := func(host string, port network.Port) string {
		// for local replace docker to localhost
		return "postgres://" + tUser + ":" + tPassword + "@" + tHost + ":" + port.Port() + "/" + tDB + "?sslmode=disable"
	}
	req := testcontainers.GenericContainerRequest{
		ContainerRequest: testcontainers.ContainerRequest{
			Image:        tImage + ":" + tVersion, // "harbor.wildberries.ru/docker-hub-proxy/library/postgres:14.4",
			ExposedPorts: []string{tPort},
			Cmd:          []string{"postgres", "-c", "fsync=off"},
			Env:          env,
			WaitingFor:   wait.ForSQL(tPort, "postgres", dbURL),
		},
		Started: true,
	}
	container, err := testcontainers.GenericContainer(ctx, req)
	if err != nil {
		return nil, container, fmt.Errorf("failed to start container: %w", err)
	}

	host, _ := container.Host(ctx)
	mappedPort, _ := container.MappedPort(ctx, tPort)
	containerPort, _ := strconv.Atoi(mappedPort.Port())
	dbConnParams := DatabaseConnectionParams{
		Host:     host,
		Port:     containerPort,
		Database: tDB,
		User:     tUser,
		Password: tPassword,
	}
	return &dbConnParams, container, nil
}
