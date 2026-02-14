---
sidebar_position: 2
---

# Java & Jython Support

The LSP provides full type-aware completions for Java/Jython development in Ignition, covering 26 packages with 146 classes from the standard Java library and Ignition SDK.

## Why This Matters

Ignition scripts run on **Jython** (Python implemented in Java), which means you can:
- Import and use any Java class
- Extend Java classes in Python
- Call Java methods with full type safety
- Use Java libraries alongside Python code

Generic Python editors don't understand this Java interop, leaving you with zero autocomplete for Java classes. ignition-nvim solves this.

## How It Works

### Import Completions

Type `from java.` to see available packages:

```python
from java.util import ArrayList, HashMap
from java.io import File, BufferedReader
from java.awt import Color, Font
from javax.swing import JButton, JFrame
```

The LSP provides completions for:
- Package names (`java.util`, `javax.swing`, etc.)
- Class names within packages
- Import aliases (`from java.util import ArrayList as AL`)

### Class Member Completions

After importing, get completions for all methods and fields:

```python
from java.util import ArrayList

list = ArrayList()
list.  # <- Type '.' to see: add(), remove(), size(), clear(), etc.
```

### Static Method Completions

Access static methods and constants directly:

```python
from java.lang import Math, System

Math.  # <- See: sqrt(), pow(), PI, E, etc.
System.  # <- See: currentTimeMillis(), getProperty(), etc.
```

### Constructor Completions

Get parameter hints when constructing objects:

```python
from java.io import File

f = File(  # <- See constructor signatures with parameter names
```

## Supported Packages

### Standard Java Libraries

#### java.lang
Core Java classes (String, Integer, Math, System, Thread, etc.)

**Common Classes:**
- `String` - String manipulation
- `Integer`, `Double`, `Long` - Number wrappers
- `Math` - Mathematical operations
- `System` - System properties and operations
- `Thread` - Threading and concurrency
- `Object` - Base class methods

**Example:**
```python
from java.lang import Math, String

# Use Math constants and methods
area = Math.PI * radius ** 2
max_value = Math.max(10, 20)

# String utilities
formatted = String.format("Value: %d", 42)
```

#### java.util
Collections, data structures, and utilities (ArrayList, HashMap, Date, etc.)

**Common Classes:**
- `ArrayList` - Dynamic arrays
- `HashMap` - Key-value maps
- `HashSet` - Unique value sets
- `Date` - Date/time handling (legacy)
- `UUID` - Unique identifiers
- `Collections` - Collection utilities
- `Arrays` - Array utilities

**Example:**
```python
from java.util import ArrayList, HashMap

# Type-safe collections
tags = ArrayList()
tags.add("Motor1/Speed")
tags.add("Motor1/Status")

# Key-value storage
config = HashMap()
config.put("server", "localhost")
config.put("port", 7806)
```

#### java.util.logging
Logging framework (Logger, Level, Handler)

**Common Classes:**
- `Logger` - Main logging interface
- `Level` - Log levels (INFO, WARNING, SEVERE, etc.)
- `ConsoleHandler` - Console output
- `FileHandler` - File output

**Example:**
```python
from java.util.logging import Logger

logger = Logger.getLogger("MyScript")
logger.info("Script started")
logger.warning("Tag quality is bad")
logger.severe("Critical error occurred")
```

#### java.io
File I/O operations (File, FileInputStream, BufferedReader, etc.)

**Common Classes:**
- `File` - File and directory paths
- `FileInputStream`, `FileOutputStream` - Byte streams
- `BufferedReader`, `BufferedWriter` - Buffered text I/O
- `PrintWriter` - Formatted text output

**Example:**
```python
from java.io import File, BufferedReader, FileReader

file = File("/path/to/config.txt")
if file.exists():
    reader = BufferedReader(FileReader(file))
    line = reader.readLine()
    reader.close()
```

#### java.net
Networking (URL, URLConnection, InetAddress)

**Common Classes:**
- `URL` - URL parsing and connections
- `URLConnection` - HTTP connections
- `InetAddress` - IP address handling
- `Socket` - Low-level networking

**Example:**
```python
from java.net import URL, URLConnection

url = URL("https://api.example.com/data")
connection = url.openConnection()
stream = connection.getInputStream()
```

### Java GUI Frameworks

#### javax.swing
Swing GUI components (JFrame, JButton, JTable, etc.)

**Common Classes:**
- `JFrame` - Top-level windows
- `JButton`, `JLabel` - Basic components
- `JTable` - Data tables
- `JPanel` - Container panels

**Example:**
```python
from javax.swing import JButton
from java.awt.event import ActionListener

class ButtonHandler(ActionListener):
    def actionPerformed(self, event):
        print("Button clicked!")

button = JButton("Click Me")
button.addActionListener(ButtonHandler())
```

#### java.awt
AWT graphics (Color, Font, Graphics, etc.)

**Common Classes:**
- `Color` - RGB colors
- `Font` - Text fonts
- `Dimension` - Width/height
- `Point` - X/Y coordinates

**Example:**
```python
from java.awt import Color, Font

red = Color(255, 0, 0)
header_font = Font("Arial", Font.BOLD, 24)
```

### Database & Time

#### java.sql
JDBC database connectivity (Connection, PreparedStatement, ResultSet)

**Common Classes:**
- `Connection` - Database connections
- `PreparedStatement` - Parameterized queries
- `ResultSet` - Query results
- `DriverManager` - Connection management

**Example:**
```python
from java.sql import DriverManager

conn = DriverManager.getConnection("jdbc:mysql://localhost/db")
stmt = conn.prepareStatement("SELECT * FROM tags WHERE id = ?")
stmt.setInt(1, 42)
rs = stmt.executeQuery()
```

#### java.time
Modern date/time API (LocalDateTime, Instant, Duration)

**Common Classes:**
- `LocalDateTime` - Date and time without timezone
- `Instant` - Timestamp
- `Duration` - Time spans
- `ZonedDateTime` - Timezone-aware dates

**Example:**
```python
from java.time import LocalDateTime, Duration

now = LocalDateTime.now()
later = now.plusHours(2)
duration = Duration.between(now, later)
```

### Security & Crypto

#### java.security
Security operations (MessageDigest, SecureRandom)

**Common Classes:**
- `MessageDigest` - Hashing (MD5, SHA-256)
- `SecureRandom` - Cryptographic random
- `KeyStore` - Certificate management

**Example:**
```python
from java.security import MessageDigest

md5 = MessageDigest.getInstance("MD5")
md5.update("password".encode())
hash_bytes = md5.digest()
```

#### javax.crypto
Encryption/decryption (Cipher, KeyGenerator)

**Common Classes:**
- `Cipher` - Encryption/decryption
- `KeyGenerator` - Key generation
- `SecretKey` - Symmetric keys

### Ignition SDK

#### com.inductiveautomation.ignition.common
Common Ignition utilities and types

**Common Classes:**
- `BasicDataset` - Dataset implementation
- `QualityCode` - Tag quality codes
- `TypeUtilities` - Type conversion helpers

**Example:**
```python
from com.inductiveautomation.ignition.common import BasicDataset

headers = ["Name", "Value"]
data = [["Tag1", 100], ["Tag2", 200]]
dataset = BasicDataset(headers, data)
```

#### com.inductiveautomation.ignition.gateway
Gateway-scoped SDK functions

## Completion Features

Each Java completion includes:

- **Full method signature** with parameter types
- **Return type** information
- **Static/instance** method distinction
- **JavaDoc** documentation where available
- **Deprecation** warnings
- **Parameter snippets** for quick filling

## Type Detection

The LSP tracks Java types through:
- Import statements (`from java.util import ArrayList`)
- Variable assignments (`list = ArrayList()`)
- Return types from method calls
- Class member access patterns

This enables **context-aware completions** based on the actual type of each variable.

## Inline Qualified Names

You can use Java classes without imports:

```python
# No import needed
thread = java.lang.Thread(runnable)
file = java.io.File("/tmp/data.txt")
```

The LSP provides completions for these inline qualified names too.

## Tips

### Prefer java.time over java.util.Date

```python
# Old (java.util.Date)
from java.util import Date
date = Date()

# Modern (java.time)
from java.time import LocalDateTime
date = LocalDateTime.now()
```

### Use java.util.logging for Better Logs

```python
from java.util.logging import Logger

logger = Logger.getLogger("ScriptName")
logger.info("Informational message")
logger.warning("Warning message")  # Better than print()
```

### Type Hints for Better Completions

```python
from java.util import ArrayList
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from java.lang import String

def process(items):  # type: (ArrayList) -> None
    for item in items:
        # LSP knows items is ArrayList
        item.  # <- Get ArrayList method completions
```
