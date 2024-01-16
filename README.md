# eepy
Eepy is an esoteric programming language written in 100%
i386 assembly. It has three opcodes:


|  Character | Action                         |
| ---------- | ------------------------------ |
| ż (U+017C) | Increments data pointer        |
| Ž (U+017D) | Decreases  data pointer        |
| ℤ (U+2124) | Output ASCII of data pointer   |

The instruction pointer, and the data pointer is a unsigned 8-bit
integer. Thus making `IP=256` would cause an infinite loop due
to `IP` looping back to 0.


# Programs

## `eepy` in Eepy
```
żżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżżℤℤ
żżżżżżżżżżżℤ
żżżżżżżżżℤ
```