package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"

	"github.com/ARM-auto-place/db-migrations/pkg/migrations"
)

func main() {

	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stdout})

	migrationDir := os.Getenv("MIGRATION_DIR")
	if migrationDir == "" {
		log.Error().Msg("MIGRATION_DIR is empty")
		os.Exit(2)
	}

	required := []string{
		"TEST_PG_USER",
		"TEST_PG_PASSWORD",
		"TEST_PG_DB",
		"TEST_PG_HOST",
		"TEST_PG_PORT",
		"TEST_PG_IMAGE",
		"TEST_PG_VERSION",
	}
	for _, k := range required {
		if os.Getenv(k) == "" {
			log.Error().Msgf("missing env: %s", k)
			os.Exit(2)
		}
	}

	log.Debug().Msg("TEST_PG_USER: " + os.Getenv("TEST_PG_USER"))
	log.Debug().Msg("TEST_PG_PASSWORD: " + os.Getenv("TEST_PG_PASSWORD"))
	log.Debug().Msg("TEST_PG_DB: " + os.Getenv("TEST_PG_DB"))
	log.Debug().Msg("TEST_PG_HOST: " + os.Getenv("TEST_PG_HOST"))
	log.Debug().Msg("TEST_PG_PORT: " + os.Getenv("TEST_PG_PORT"))
	log.Debug().Msg("TEST_PG_VERSION: " + os.Getenv("TEST_PG_VERSION"))
	log.Debug().Msg("TEST_PG_IMAGE: " + os.Getenv("TEST_PG_IMAGE"))
	log.Debug().Msg("MIGRATION_DIR: " + migrationDir)

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	log.Info().Msg("Starting Postgres container")
	connParam, container, err := migrations.CreatePostgresTestContainer(ctx)
	if err != nil {
		log.Error().Err(err).Msg("failed to start postgres container")
		os.Exit(1)
	}
	defer func() {
		_ = container.Terminate(context.Background())
	}()

	log.Info().Msg("Postgres container started, opening connection")
	nodes := []migrations.DatabaseConnectionParams{*connParam}

	connections, err := migrations.OpenConnections(nodes)
	if err != nil {
		log.Error().Err(err).Msg("failed to open connections")
		os.Exit(1)
	}

	_, _ = connections[0].Exec("CREATE SCHEMA IF NOT EXISTS migrations;")

	log.Info().Msg("Running migrations")
	if err := migrations.StartNodesMigration(nodes, migrationDir); err != nil {
		log.Error().Err(err).Msg("migrations failed")
		os.Exit(1)
	}

	log.Info().Msg(fmt.Sprintf("Migrations executed successfully (%s)", migrationDir))
}
