# eepy
Eepy is an esoteric programming language. It has six opcodes:


|  Character | Action                         |
| ---------- | ------------------------------ |
| Z          | Increments instruction pointer |
| z          | Decreases  instruction pointer |
| ż (U+017C) | Increments data pointer        |
| Ž (U+017D) | Decreases  data pointer        |
| ℤ (U+2124) | Output ASCII of data pointer   |

The instruction pointer, and the data pointer is a unsigned 8-bit
integer. Thus making `IP=256` would cause an infinite loop due
to `IP` looping back to 0.
