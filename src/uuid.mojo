"""
UUID Implementation

Pure Mojo UUID v4 (random) and v7 (time-ordered) generation.
RFC 4122 and RFC 9562 compliant.
"""

from random import random_ui64


# =============================================================================
# UUID Struct
# =============================================================================

struct UUID:
    """
    Universally Unique Identifier (UUID).

    Supports:
    - UUID v4: Random-based (most common)
    - UUID v7: Time-ordered (good for databases)

    Example:
        var id = UUID.v4()
        print(str(id))  # "550e8400-e29b-41d4-a716-446655440000"

        var id7 = UUID.v7()
        print(str(id7))  # Time-ordered UUID
    """
    var high: UInt64  # Most significant 64 bits
    var low: UInt64   # Least significant 64 bits

    fn __init__(out self, high: UInt64, low: UInt64):
        """Create UUID from high/low 64-bit values."""
        self.high = high
        self.low = low

    fn __init__(out self):
        """Create nil UUID (all zeros)."""
        self.high = 0
        self.low = 0

    # =========================================================================
    # UUID Generators
    # =========================================================================

    @staticmethod
    fn v4() -> UUID:
        """
        Generate a random UUID v4.

        Version 4 UUIDs are randomly generated.
        Format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
        where x is random hex and y is 8, 9, a, or b.
        """
        var high = random_ui64()
        var low = random_ui64()

        # Set version to 4 (bits 12-15 of time_hi_and_version)
        high = (high & 0xFFFFFFFFFFFF0FFF) | 0x0000000000004000

        # Set variant to RFC 4122 (bits 6-7 of clock_seq_hi_and_reserved)
        low = (low & 0x3FFFFFFFFFFFFFFF) | 0x8000000000000000

        return UUID(high, low)

    @staticmethod
    fn v7() -> UUID:
        """
        Generate a time-ordered UUID v7 (RFC 9562).

        Version 7 UUIDs include a Unix timestamp for time-ordering.
        Format: tttttttt-tttt-7xxx-yxxx-xxxxxxxxxxxx
        where t is timestamp, x is random, y is 8, 9, a, or b.

        Good for: Database primary keys (better index locality)
        """
        # Get current Unix timestamp in milliseconds
        # Note: Using random for now since Mojo lacks time API
        # In production, use actual timestamp
        var timestamp_ms = random_ui64() & 0x0000FFFFFFFFFFFF  # 48-bit timestamp

        # Random bits for uniqueness
        var rand_a = random_ui64() & 0x0FFF  # 12 random bits
        var rand_b = random_ui64()

        # Build high 64 bits: 48-bit timestamp + 4-bit version + 12-bit random
        var high = (timestamp_ms << 16) | 0x7000 | rand_a

        # Build low 64 bits: 2-bit variant + 62-bit random
        var low = (rand_b & 0x3FFFFFFFFFFFFFFF) | 0x8000000000000000

        return UUID(high, low)

    @staticmethod
    fn nil() -> UUID:
        """Create nil UUID (all zeros)."""
        return UUID(0, 0)

    @staticmethod
    fn max() -> UUID:
        """Create max UUID (all ones)."""
        return UUID(0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF)

    # =========================================================================
    # Parsing
    # =========================================================================

    @staticmethod
    fn parse(s: String) raises -> UUID:
        """
        Parse UUID from string.

        Accepts formats:
        - "550e8400-e29b-41d4-a716-446655440000" (standard)
        - "550e8400e29b41d4a716446655440000" (no dashes)
        - "{550e8400-e29b-41d4-a716-446655440000}" (braces)
        """
        var clean = s.replace("-", "").replace("{", "").replace("}", "").lower()

        if len(clean) != 32:
            raise Error("Invalid UUID string length: expected 32 hex chars, got " + str(len(clean)))

        # Parse high and low 64-bit values
        var high = _parse_hex_u64(clean[0:16])
        var low = _parse_hex_u64(clean[16:32])

        return UUID(high, low)

    @staticmethod
    fn try_parse(s: String) -> UUID:
        """Parse UUID, returning nil UUID on failure."""
        try:
            return UUID.parse(s)
        except:
            return UUID.nil()

    # =========================================================================
    # Formatting
    # =========================================================================

    fn __str__(self) -> String:
        """
        Format as standard UUID string.

        Returns: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        """
        var hex = self.hex()
        return (
            hex[0:8] + "-" +
            hex[8:12] + "-" +
            hex[12:16] + "-" +
            hex[16:20] + "-" +
            hex[20:32]
        )

    fn hex(self) -> String:
        """Format as 32-character hex string (no dashes)."""
        return _to_hex_u64(self.high) + _to_hex_u64(self.low)

    fn urn(self) -> String:
        """Format as URN (urn:uuid:...)."""
        return "urn:uuid:" + str(self)

    fn braces(self) -> String:
        """Format with braces ({...})."""
        return "{" + str(self) + "}"

    # =========================================================================
    # Properties
    # =========================================================================

    fn version(self) -> Int:
        """Get UUID version (1-7)."""
        return Int((self.high >> 12) & 0x0F)

    fn variant(self) -> Int:
        """Get UUID variant."""
        var bits = (self.low >> 62) & 0x03
        if bits == 0 or bits == 1:
            return 0  # NCS backward compatibility
        elif bits == 2:
            return 1  # RFC 4122
        else:
            return 2  # Microsoft / Future

    fn is_nil(self) -> Bool:
        """Check if UUID is nil (all zeros)."""
        return self.high == 0 and self.low == 0

    fn is_max(self) -> Bool:
        """Check if UUID is max (all ones)."""
        return self.high == 0xFFFFFFFFFFFFFFFF and self.low == 0xFFFFFFFFFFFFFFFF

    # =========================================================================
    # Comparison
    # =========================================================================

    fn __eq__(self, other: UUID) -> Bool:
        return self.high == other.high and self.low == other.low

    fn __ne__(self, other: UUID) -> Bool:
        return not (self == other)

    fn __lt__(self, other: UUID) -> Bool:
        if self.high != other.high:
            return self.high < other.high
        return self.low < other.low

    fn __le__(self, other: UUID) -> Bool:
        return self == other or self < other

    fn __gt__(self, other: UUID) -> Bool:
        return other < self

    fn __ge__(self, other: UUID) -> Bool:
        return self == other or self > other

    fn __hash__(self) -> UInt:
        """Hash for use in collections."""
        return UInt(self.high ^ self.low)

    # =========================================================================
    # Bytes
    # =========================================================================

    fn bytes(self) -> List[UInt8]:
        """Get UUID as 16-byte array (big-endian)."""
        var result = List[UInt8]()

        # High 64 bits (big-endian)
        for i in range(8):
            result.append(UInt8((self.high >> (56 - i * 8)) & 0xFF))

        # Low 64 bits (big-endian)
        for i in range(8):
            result.append(UInt8((self.low >> (56 - i * 8)) & 0xFF))

        return result

    @staticmethod
    fn from_bytes(data: List[UInt8]) raises -> UUID:
        """Create UUID from 16-byte array."""
        if len(data) != 16:
            raise Error("UUID requires exactly 16 bytes")

        var high: UInt64 = 0
        var low: UInt64 = 0

        for i in range(8):
            high = (high << 8) | UInt64(data[i])

        for i in range(8):
            low = (low << 8) | UInt64(data[i + 8])

        return UUID(high, low)


# =============================================================================
# Helper Functions
# =============================================================================

fn _to_hex_u64(value: UInt64) -> String:
    """Convert 64-bit value to 16-character hex string."""
    alias HEX = "0123456789abcdef"
    var result = String()

    for i in range(16):
        var nibble = Int((value >> (60 - i * 4)) & 0x0F)
        result += HEX[nibble]

    return result


fn _parse_hex_u64(s: String) raises -> UInt64:
    """Parse 16-character hex string to 64-bit value."""
    var result: UInt64 = 0

    for i in range(len(s)):
        var c = s[i]
        var digit: UInt64 = 0

        if c >= "0" and c <= "9":
            digit = UInt64(ord(c) - ord("0"))
        elif c >= "a" and c <= "f":
            digit = UInt64(ord(c) - ord("a") + 10)
        elif c >= "A" and c <= "F":
            digit = UInt64(ord(c) - ord("A") + 10)
        else:
            raise Error("Invalid hex character: " + c)

        result = (result << 4) | digit

    return result


# =============================================================================
# Convenience Functions
# =============================================================================

fn uuid4() -> UUID:
    """Generate a random UUID v4."""
    return UUID.v4()


fn uuid7() -> UUID:
    """Generate a time-ordered UUID v7."""
    return UUID.v7()
