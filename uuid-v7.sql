/**
 * Creates a version 7 UUID from an origin unique identifier.
 * A version 7 UUID is a timestamp-based UUID, which is 
 * a combination of a timestamp and a random number.
 * The timestamp is the number of milliseconds since the
 * Unix epoch (January 1, 1970, 00:00:00.000 GMT).
 * The random number is the last 8 bytes of the origin
 * UUID.
 * @param origin The origin UUID.
 * @return The new UUID.
 */
CREATE FUNCTION [dbo].[uuid7](@origin AS uniqueidentifier) 
RETURNS uniqueidentifier 
AS 
BEGIN
    DECLARE @uuid BINARY(16);
    DECLARE @timestampMs BIGINT;
    DECLARE @randomPart VARBINARY(8);
    DECLARE @currentTimestamp datetimeoffset;

    -- Get the current timestamp in milliseconds since the Unix epoch.
    SET @currentTimestamp = SYSDATETIMEOFFSET();
    SET @timestampMs = DATEDIFF_BIG(MILLISECOND, '1970-01-01T00:00:00.000', @currentTimestamp);

    -- Get the last 8 bytes of the origin UUID.
    SET @randomPart = CONVERT(BINARY(8), @origin);

    -- Split the timestamp into 4 bytes for the high bits, 2 bytes for the mid bits,
    -- and the last 8 bytes for the random part.
    DECLARE @highBits BIGINT = @timestampMs >> 16;
    DECLARE @highBitsSwapped BINARY(4) = CAST(
        ((@highBits & 0xFF000000) >> 24) | 
        ((@highBits & 0x00FF0000) >> 8) | 
        ((@highBits & 0x0000FF00) << 8) | 
        ((@highBits & 0x000000FF) << 24) AS BINARY(4)
    );

    DECLARE @midBits BINARY(2) = CONVERT(BINARY(2), (@timestampMs & 0xFFFF));

    -- Set the version and variant bits.
    DECLARE @variantAndVersionPart INT = CAST(SUBSTRING(@randomPart, 1, 4) AS INT);
    DECLARE @variantAndVersionResult INT = (@variantAndVersionPart & 0xFFF0FFFF) | 0x00007000;
    DECLARE @versionedPart BINARY(2) = CAST(@variantAndVersionResult AS BINARY(2));

    DECLARE @variantPart INT = CAST(SUBSTRING(@randomPart, 1, 4) AS INT);
    DECLARE @variantResult INT = (@variantPart & 0x3FFF) | 0x8000;
    DECLARE @variant BINARY(2) = CAST(@variantResult AS BINARY(2));

    -- Assemble the UUID.
    DECLARE @randomBits BINARY(8) = CONVERT(BINARY(8), RIGHT(@randomPart, 8));

    SET @uuid = CONVERT(uniqueidentifier, @highBitsSwapped + @midBits + @versionedPart + @variant + @randomBits);
    RETURN @uuid;
END;

