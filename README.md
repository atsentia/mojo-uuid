# mojo-uuid

Pure Mojo UUID generation (v4 random, v7 time-ordered).

## Features

- **UUID v4** - Random UUIDs (RFC 4122)
- **UUID v7** - Time-ordered UUIDs (RFC 9562)
- **String Formatting** - Standard UUID string representation
- **Database Friendly** - v7 UUIDs sort chronologically

## Installation

```bash
pixi add mojo-uuid
```

## Quick Start

### UUID v4 (Random)

```mojo
from mojo_uuid import UUID, uuid4

var id = uuid4()
print(str(id))  # "550e8400-e29b-41d4-a716-446655440000"

# Generate multiple
for i in range(5):
    print(str(uuid4()))
```

### UUID v7 (Time-ordered)

```mojo
from mojo_uuid import uuid7

# Time-ordered UUIDs are great for database primary keys
var id1 = uuid7()
var id2 = uuid7()
var id3 = uuid7()

# These will sort chronologically
print(str(id1))
print(str(id2))
print(str(id3))
```

### Working with UUIDs

```mojo
from mojo_uuid import UUID

var id = uuid4()

# Get string representation
var s = str(id)

# Get bytes
var bytes = id.bytes()

# Compare UUIDs
var id2 = uuid4()
if id != id2:
    print("Different UUIDs")
```

## API Reference

| Function | Description |
|----------|-------------|
| `uuid4()` | Generate random UUID (v4) |
| `uuid7()` | Generate time-ordered UUID (v7) |
| `str(uuid)` | Get string representation |
| `uuid.bytes()` | Get raw bytes |

## UUID Versions

| Version | Use Case |
|---------|----------|
| **v4** | General purpose, random |
| **v7** | Database keys, time-sortable |

## Testing

```bash
mojo run tests/test_uuid.mojo
```

## License

Apache 2.0

## Part of mojo-contrib

This library is part of [mojo-contrib](https://github.com/atsentia/mojo-contrib), a collection of pure Mojo libraries.
