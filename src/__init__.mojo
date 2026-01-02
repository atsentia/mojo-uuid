"""
Mojo UUID Library

Pure Mojo UUID generation (v4 random, v7 time-ordered).
RFC 4122 and RFC 9562 compliant.

Example:
    from mojo_uuid import UUID, uuid4, uuid7

    var id = uuid4()
    print(str(id))  # "550e8400-e29b-41d4-a716-446655440000"

    var id7 = uuid7()  # Time-ordered, good for databases
"""

from .uuid import UUID, uuid4, uuid7
