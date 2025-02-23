# Storage Management System

## Introduction
This project implements a **storage management system** for a minimalist operating system. It supports two different memory models: **one-dimensional memory** and **two-dimensional memory**.

## Features
- **One-dimensional memory**
  - Fixed storage capacity: **8MB**, divided into **8kB blocks**
  - Each file requires at least **two consecutive blocks**
  - Implemented operations:
    - `ADD`: Store a file in memory
    - `GET`: Retrieve the file location
    - `DELETE`: Remove a file from memory
    - `DEFRAGMENTATION`: Reorganize storage to remove gaps

## Input Format
- The first line contains the number of operations **O**.
- Each operation follows a specific format:
  - `1` - **ADD**
    - Next line: **N** (number of files to add)
    - Next 2N lines: **file descriptor** and **file size in kB**
  - `2` - **GET**
    - Next line: **file descriptor**
  - `3` - **DELETE**
    - Next line: **file descriptor**
  - `4` - **DEFRAGMENTATION** (only for one-dimensional memory)

### Example Input
```
4
1
5
1 124
4 350
121 75
254 1024
70 30
2
121
3
4
4
```

### Example Output
```
1: (0, 15)
4: (16, 59)
121: (60, 69)
254: (70, 197)
70: (198, 201)
(60, 69)
1: (0, 15)
121: (60, 69)
254: (70, 197)
70: (198, 201)
1: (0, 15)
121: (16, 25)
254: (26, 153)
70: (154, 157)
```

- **Two-dimensional memory**
  - Organized as a **matrix** of blocks (8MB × 8MB)
  - Files are stored in **continuous rows**
  - Implemented operations:
    - `ADD`
    - `GET`
    - `DELETE`

