extends Node

## Centralized color definitions for assembly/disassembly visual feedback
## Access via GameColors singleton (autoload)

# Assembly (forward progress) - Soft Green
const COLOR_ASSEMBLE := Color(0.4, 0.75, 0.5, 1.0)

# Disassembly (go back) - Soft Red  
const COLOR_DISASSEMBLE := Color(0.85, 0.5, 0.45, 1.0)

# Neutral (holding/transitioning) - Gray
const COLOR_NEUTRAL := Color(0.8, 0.8, 0.8, 1.0)

# Outline-specific versions (with alpha for shell shader)
const OUTLINE_ASSEMBLE := Color(0.4, 0.75, 0.5, 0.25)
const OUTLINE_DISASSEMBLE := Color(0.85, 0.5, 0.45, 0.25)
const OUTLINE_NEUTRAL := Color(0.8, 0.8, 0.8, 0.25)
