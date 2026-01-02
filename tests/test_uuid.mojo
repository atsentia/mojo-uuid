"""
UUID Tests
"""

from mojo_uuid import UUID, uuid4, uuid7


fn test_uuid_v4() raises:
    """Test UUID v4 generation."""
    var id1 = uuid4()
    var id2 = uuid4()

    # Version should be 4
    if id1.version() != 4:
        raise Error("UUID v4 version mismatch: expected 4, got " + str(id1.version()))

    # Variant should be 1 (RFC 4122)
    if id1.variant() != 1:
        raise Error("UUID v4 variant mismatch: expected 1, got " + str(id1.variant()))

    # UUIDs should be unique
    if id1 == id2:
        raise Error("UUID v4 collision detected")

    print("✓ UUID v4 generation works")


fn test_uuid_v7() raises:
    """Test UUID v7 generation."""
    var id1 = uuid7()
    var id2 = uuid7()

    # Version should be 7
    if id1.version() != 7:
        raise Error("UUID v7 version mismatch: expected 7, got " + str(id1.version()))

    # Variant should be 1 (RFC 4122)
    if id1.variant() != 1:
        raise Error("UUID v7 variant mismatch: expected 1, got " + str(id1.variant()))

    # UUIDs should be unique
    if id1 == id2:
        raise Error("UUID v7 collision detected")

    print("✓ UUID v7 generation works")


fn test_uuid_nil() raises:
    """Test nil UUID."""
    var nil = UUID.nil()

    if not nil.is_nil():
        raise Error("Nil UUID should be nil")

    if nil.high != 0 or nil.low != 0:
        raise Error("Nil UUID should have all zeros")

    var s = str(nil)
    if s != "00000000-0000-0000-0000-000000000000":
        raise Error("Nil UUID string mismatch: " + s)

    print("✓ Nil UUID works")


fn test_uuid_max() raises:
    """Test max UUID."""
    var max_uuid = UUID.max()

    if not max_uuid.is_max():
        raise Error("Max UUID should be max")

    if max_uuid.high != 0xFFFFFFFFFFFFFFFF or max_uuid.low != 0xFFFFFFFFFFFFFFFF:
        raise Error("Max UUID should have all ones")

    var s = str(max_uuid)
    if s != "ffffffff-ffff-ffff-ffff-ffffffffffff":
        raise Error("Max UUID string mismatch: " + s)

    print("✓ Max UUID works")


fn test_uuid_formatting() raises:
    """Test UUID string formatting."""
    var id = uuid4()

    # Standard format (36 chars with dashes)
    var standard = str(id)
    if len(standard) != 36:
        raise Error("Standard format should be 36 chars, got " + str(len(standard)))

    # Hex format (32 chars, no dashes)
    var hex = id.hex()
    if len(hex) != 32:
        raise Error("Hex format should be 32 chars, got " + str(len(hex)))

    # URN format
    var urn = id.urn()
    if not urn.startswith("urn:uuid:"):
        raise Error("URN should start with 'urn:uuid:'")

    # Braces format
    var braces = id.braces()
    if not braces.startswith("{") or not braces.endswith("}"):
        raise Error("Braces format should be wrapped in {}")

    print("✓ UUID formatting works")


fn test_uuid_parsing() raises:
    """Test UUID parsing."""
    var original = uuid4()
    var s = str(original)

    # Parse standard format
    var parsed = UUID.parse(s)
    if parsed != original:
        raise Error("Parsed UUID doesn't match original")

    # Parse without dashes
    var hex = original.hex()
    var parsed2 = UUID.parse(hex)
    if parsed2 != original:
        raise Error("Parsed hex UUID doesn't match original")

    # Parse with braces
    var braces = original.braces()
    var parsed3 = UUID.parse(braces)
    if parsed3 != original:
        raise Error("Parsed braces UUID doesn't match original")

    print("✓ UUID parsing works")


fn test_uuid_comparison() raises:
    """Test UUID comparison operators."""
    var a = UUID(0, 1)
    var b = UUID(0, 2)
    var c = UUID(1, 0)

    if not (a < b):
        raise Error("a should be < b")

    if not (b < c):
        raise Error("b should be < c")

    if not (a <= a):
        raise Error("a should be <= a")

    if not (c > a):
        raise Error("c should be > a")

    if not (c >= c):
        raise Error("c should be >= c")

    print("✓ UUID comparison works")


fn test_uuid_bytes() raises:
    """Test UUID byte conversion."""
    var id = uuid4()

    # Convert to bytes
    var bytes = id.bytes()
    if len(bytes) != 16:
        raise Error("UUID bytes should be 16, got " + str(len(bytes)))

    # Convert back from bytes
    var restored = UUID.from_bytes(bytes)
    if restored != id:
        raise Error("Restored UUID doesn't match original")

    print("✓ UUID bytes conversion works")


fn main() raises:
    print("Running UUID tests...\n")

    test_uuid_v4()
    test_uuid_v7()
    test_uuid_nil()
    test_uuid_max()
    test_uuid_formatting()
    test_uuid_parsing()
    test_uuid_comparison()
    test_uuid_bytes()

    print("\n✅ All UUID tests passed!")
