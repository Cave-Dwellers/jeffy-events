class_name JEP_UUID extends RefCounted

## UUID generation class; modified version of https://github.com/binogure-studio/godot-uuid/,
## which is licensed under MIT

## 16 random bytes with the bytes on index 6 and 8 modified
static func uuidbin(rng : RandomNumberGenerator = null) -> Array[int]:
	var uuid : Array[int] = []
	uuid.resize(16)
	
	if !rng:
		rng = RandomNumberGenerator.new()
		rng.seed = Time.get_unix_time_from_system()
	
	for i in range(16):
		# Random byte
		uuid[i] = rng.randi() & 0xFF
		
		match i:
			6: 
				# High byte
				uuid[i] &= 0x0F
				uuid[i] |= 0x40
			8:
				# Clock byte
				uuid[i] &= 0x3F
				uuid[i] |= 0x80
	return uuid

static func v4() -> StringName:
	return uuidbin_to_str(uuidbin())
	
static func v4_rng(rng: RandomNumberGenerator) -> StringName:
	return uuidbin_to_str(uuidbin(rng))

static func uuidbin_to_str(b : Array[int]) -> StringName:
	var low : String = "%02x%02x%02x%02x" % [b[0], b[1], b[2], b[3]]
	var mid : String = "%02x%02x" % [b[4], b[5]]
	var high : String = "%02x%02x" % [b[6], b[7]]
	var clock_low : String = "%02x%02x" % [b[8], b[9]]
	var clock_high : String = "%02x%02x%02x%02x%02x%02x" % [b[10], b[11], b[12], b[13], b[14], b[15]]
	
	return &"%s-%s-%s-%s-%s" % [low, mid, high, clock_low, clock_high]
