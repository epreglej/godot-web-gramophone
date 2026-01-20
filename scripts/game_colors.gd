extends Node

## Centralized color definitions for assembly/disassembly visual feedback
## Access via GameColors singleton (autoload)

# Assembly (forward progress) - Vibrant Green
const COLOR_ASSEMBLE := Color(0.2, 1.0, 0.3, 1.0)

# Disassembly (go back) - Vibrant Red  
const COLOR_DISASSEMBLE := Color(1.0, 0.3, 0.2, 1.0)

# Neutral (holding/transitioning) - Gray
const COLOR_NEUTRAL := Color(0.8, 0.8, 0.8, 1.0)

# Outline-specific versions (with alpha for shell shader)
const OUTLINE_ASSEMBLE := Color(0.2, 1.0, 0.3, 0.35)
const OUTLINE_DISASSEMBLE := Color(1.0, 0.3, 0.2, 0.35)
const OUTLINE_NEUTRAL := Color(0.8, 0.8, 0.8, 0.25)
