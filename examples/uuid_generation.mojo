"""
Example: UUID Generation

Demonstrates:
- UUID v4 (random)
- UUID v7 (time-ordered)
- UUID parsing and validation
"""

from mojo_uuid import UUID, uuid4, uuid7


fn uuid_v4_example():
    """UUID v4: Random UUIDs."""
    print("=== UUID v4 (Random) ===")

    # Generate random UUIDs
    var id1 = uuid4()
    var id2 = uuid4()
    var id3 = uuid4()

    print("UUID v4 #1: " + str(id1))
    print("UUID v4 #2: " + str(id2))
    print("UUID v4 #3: " + str(id3))

    # Properties
    print("\nVersion: 4 (random)")
    print("Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx")
    print("Use case: General-purpose unique identifiers")
    print("")


fn uuid_v7_example():
    """UUID v7: Time-ordered UUIDs."""
    print("=== UUID v7 (Time-Ordered) ===")

    # Generate time-ordered UUIDs
    var id1 = uuid7()
    var id2 = uuid7()
    var id3 = uuid7()

    print("UUID v7 #1: " + str(id1))
    print("UUID v7 #2: " + str(id2))
    print("UUID v7 #3: " + str(id3))

    print("\nVersion: 7 (time-ordered)")
    print("Format: timestamp-based with random suffix")
    print("Properties:")
    print("  - Lexicographically sortable")
    print("  - Time-ordered (newer IDs sort after older)")
    print("  - Great for database primary keys")
    print("")


fn uuid_comparison():
    """Compare UUID versions."""
    print("=== UUID v4 vs v7 ===")

    print("UUID v4 (Random):")
    print("  + Completely random")
    print("  + No timestamp leakage")
    print("  - Not sortable by creation time")
    print("  - Database index fragmentation")

    print("\nUUID v7 (Time-Ordered):")
    print("  + Sortable by creation time")
    print("  + Better database performance")
    print("  + Includes millisecond timestamp")
    print("  - Reveals creation time")

    print("\nRecommendation:")
    print("  - API keys, tokens: uuid4()")
    print("  - Database PKs: uuid7()")
    print("")


fn uuid_parsing_example():
    """Parse and validate UUIDs."""
    print("=== UUID Parsing ===")

    # Parse from string
    var id_str = "550e8400-e29b-41d4-a716-446655440000"
    var parsed = UUID.parse(id_str)

    if parsed.is_ok():
        var uuid = parsed.value()
        print("Parsed: " + str(uuid))
        print("Valid: True")
        print("Version: " + String(uuid.version()))
    else:
        print("Invalid UUID")

    # Invalid UUID
    var bad = UUID.parse("not-a-uuid")
    print("Invalid parse: " + String(bad.is_err()))
    print("")


fn uuid_operations():
    """UUID operations and properties."""
    print("=== UUID Operations ===")

    var id = uuid4()

    # String conversion
    print("String: " + str(id))

    # Bytes (16 bytes)
    var bytes = id.bytes()
    print("Bytes: 16 bytes (binary)")

    # Comparison
    var id2 = uuid4()
    var same = id == id
    var different = id == id2
    print("Same ID comparison: " + String(same))
    print("Different ID comparison: " + String(different))

    # Nil UUID
    var nil = UUID.nil()
    print("Nil UUID: " + str(nil))
    print("Is nil: " + String(nil.is_nil()))
    print("")


fn batch_generation():
    """Generate UUIDs in batch."""
    print("=== Batch Generation ===")

    print("Generating 5 UUIDs...")
    for i in range(5):
        var id = uuid4()
        print("  " + str(id))

    print("\nFor high-volume generation:")
    print("  - uuid4() uses crypto-random source")
    print("  - uuid7() uses timestamp + random")
    print("")


fn main():
    print("mojo-uuid: UUID Generation (RFC 4122 & 9562)\n")

    uuid_v4_example()
    uuid_v7_example()
    uuid_comparison()
    uuid_parsing_example()
    uuid_operations()
    batch_generation()

    print("=" * 50)
    print("Quick reference:")
    print("  uuid4() - Random, general purpose")
    print("  uuid7() - Time-ordered, database PKs")
