package migrations

import (
	"context"
	"os"
	"testing"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/stretchr/testify/assert"

	_ "github.com/lib/pq"
)

func Test_node_migrations(t *testing.T) {
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stdout})
	log.Debug().Msg("TEST_PG_USER: " + os.Getenv("TEST_PG_USER"))
	log.Debug().Msg("TEST_PG_PASSWORD: " + os.Getenv("TEST_PG_PASSWORD"))
	log.Debug().Msg("TEST_PG_DB:: " + os.Getenv("TEST_PG_DB"))
	log.Debug().Msg("TEST_PG_HOST:: " + os.Getenv("TEST_PG_HOST"))
	log.Debug().Msg("TEST_PG_PORT:: " + os.Getenv("TEST_PG_PORT"))
	log.Debug().Msg("TEST_PG_VERSION:: " + os.Getenv("TEST_PG_VERSION"))
	log.Debug().Msg("MIGRATION_DIR:: " + os.Getenv("MIGRATION_DIR"))
	log.Debug().Msg("Starting Postgres container")

	// Given
	connParam, container, err := CreatePostgresTestContainer(context.Background())
	assert.NoError(t, err)
	log.Debug().Msg("Postgres container started")
	ctx := context.Background()
	defer container.Terminate(ctx)

	// When
	log.Debug().Msg("Starting migrations")
	nodes := []DatabaseConnectionParams{*connParam}
	connections, err := OpenConnections(nodes)
	assert.NoError(t, err)
	connections[0].Exec("CREATE SCHEMA IF NOT EXISTS migrations;")
	err = StartNodesMigration(nodes, os.Getenv("MIGRATION_DIR"))

	if err == nil {
		log.Debug().Msg("Migrations executed successfully")
	}
	// Then
	assert.NoError(t, err)
}
