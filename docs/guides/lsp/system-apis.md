---
sidebar_position: 1
---

# System API Completions

The LSP provides comprehensive completions for all Ignition `system.*` modules — 14 modules with 239+ functions covering the entire Ignition scripting API.

## How It Works

Type `system.` in any Python script to trigger module completions. After selecting a module, typing `.` again shows all available functions with full signatures and documentation.

```python
# Type 'system.' to see all modules
system.tag.readBlocking(...)
system.db.runPrepQuery(...)
system.perspective.sendMessage(...)
```

## Available Modules

### system.tag

Tag read/write operations, browsing, and quality codes.

**Common Functions:**
- `readBlocking(tagPaths)` - Read tag values synchronously
- `writeBlocking(tagPaths, values)` - Write tag values synchronously
- `readAsync(tagPaths, callback)` - Read tag values asynchronously
- `browse(path, filter)` - Browse tag tree structure
- `exists(tagPath)` - Check if a tag exists
- `getConfiguration(basePath, recursive)` - Get tag configuration

**Use Cases:**
- Reading/writing PLC data
- Tag system browsing and discovery
- Tag configuration management

### system.db

Database operations, transactions, and named queries.

**Common Functions:**
- `runQuery(query, database)` - Execute a SQL query
- `runPrepQuery(query, args, database)` - Execute parameterized query
- `runUpdateQuery(query, database)` - Execute UPDATE/INSERT/DELETE
- `runNamedQuery(path, params)` - Execute a named query
- `beginTransaction(database)` - Start a database transaction
- `closeTransaction(transactionId)` - Commit a transaction

**Use Cases:**
- Reading from databases
- Storing historical data
- Transaction management
- Prepared statements for SQL injection prevention

### system.perspective

Perspective session control, component messaging, and page navigation.

**Common Functions:**
- `sendMessage(messageType, payload, scope, sessionId)` - Send message to clients
- `navigate(page, sessionId)` - Navigate to a different page
- `download(filename, data, contentType)` - Trigger file download
- `login(sessionId, username, password)` - Programmatic login
- `logout(sessionId)` - Programmatic logout
- `getSessionInfo(sessionId)` - Get session properties

**Use Cases:**
- Component communication
- Page navigation
- File downloads from scripts
- Session management

### system.util

Utility functions for timers, threading, exports, and system operations.

**Common Functions:**
- `invokeLater(function, delay)` - Schedule delayed execution
- `invokeAsynchronous(function)` - Run function in background thread
- `sendRequest(project, messageHandler, payload)` - Send message to gateway
- `getSystemFlags()` - Get system information
- `getGlobals()` - Access global namespace
- `modifyTranslation(locale, term, translation)` - Add translations

**Use Cases:**
- Background processing
- Delayed execution
- Inter-scope communication
- System information

### system.alarm

Alarm management, querying, and acknowledgment.

**Common Functions:**
- `queryJournal(startDate, endDate, filters)` - Query alarm journal
- `acknowledge(alarmEvents, notes)` - Acknowledge alarms
- `queryStatus(priority, state, source)` - Query active alarms
- `createRosterNotification(roster, message)` - Send notifications

**Use Cases:**
- Alarm history queries
- Alarm acknowledgment workflows
- Active alarm monitoring

### system.dataset

Dataset creation, manipulation, and conversion.

**Common Functions:**
- `toDataSet(headers, data)` - Create dataset from lists
- `addRow(dataset, rowIndex, row)` - Add row to dataset
- `deleteRow(dataset, rowIndex)` - Remove row from dataset
- `setValue(dataset, rowIndex, columnName, value)` - Update cell value
- `toPyDataSet(dataset)` - Convert to Python-friendly format

**Use Cases:**
- Building datasets for tables
- Dataset manipulation
- Data format conversion

### system.date

Date/time manipulation, formatting, and parsing.

**Common Functions:**
- `now()` - Get current timestamp
- `format(date, format)` - Format date as string
- `parse(dateString, format)` - Parse string to date
- `addDays(date, days)` - Add/subtract days
- `setTime(date, hour, minute, second)` - Set time components
- `midnight(date)` - Get midnight of given date

**Use Cases:**
- Date calculations
- Date formatting for reports
- Timestamp comparisons

### system.file

File I/O operations, CSV/JSON handling.

**Common Functions:**
- `readFileAsString(filepath)` - Read entire file as string
- `writeFile(filepath, data)` - Write string to file
- `readFileAsBytes(filepath)` - Read file as byte array
- `openFile(filter, extension)` - Show file picker dialog
- `saveFile(filename, filter, data)` - Show save dialog

**Use Cases:**
- Configuration file reading
- CSV/JSON data import/export
- File system operations

### system.gui

GUI interactions (Vision client scope only).

**Common Functions:**
- `messageBox(message, title, options)` - Show message dialog
- `confirm(message, title, showCancel)` - Show confirmation dialog
- `inputBox(message, defaultValue)` - Show input prompt
- `errorBox(message, title)` - Show error dialog
- `getParentWindow(event)` - Get window from event

**Use Cases:**
- User prompts and confirmations
- Error notifications
- Input collection

### system.nav

Navigation functions (Vision client only).

**Common Functions:**
- `openWindow(path, params)` - Open Vision window
- `closeWindow(window)` - Close window
- `swapWindow(window, path, params)` - Replace window content
- `centerWindow(window)` - Center window on screen
- `getWindowNames()` - Get all open window names

**Use Cases:**
- Window management
- Screen navigation
- Multi-window applications

### system.net

HTTP requests, email, and webhooks.

**Common Functions:**
- `httpGet(url, params, headers)` - Make GET request
- `httpPost(url, data, headers)` - Make POST request
- `sendEmail(smtp, from, to, subject, body)` - Send email
- `openURL(url)` - Open URL in browser

**Use Cases:**
- REST API integration
- Email notifications
- External system communication

### system.opc

OPC operations, browsing, and read/write.

**Common Functions:**
- `browseServer(opcServer, nodeId)` - Browse OPC nodes
- `readValue(opcServer, itemPath)` - Read OPC value
- `writeValue(opcServer, itemPath, value)` - Write OPC value
- `getServerState(opcServer)` - Get OPC server status

**Use Cases:**
- OPC UA/DA integration
- Direct PLC communication
- Industrial protocol handling

### system.security

Authentication, authorization, and user roles.

**Common Functions:**
- `getUsername()` - Get current username
- `getRoles()` - Get current user's roles
- `validateUser(username, password)` - Check credentials
- `isScreenLocked()` - Check screen lock status
- `setPassword(username, password)` - Update user password

**Use Cases:**
- User authentication
- Role-based security
- Password management

### system.user

User management, sessions, and preferences.

**Common Functions:**
- `getUser(username)` - Get user object
- `addUser(source, user)` - Create new user
- `editUser(source, user)` - Modify user
- `removeUser(source, username)` - Delete user
- `getUsers(source)` - List all users

**Use Cases:**
- User administration
- User property management
- Session tracking

## Completion Features

Each completion includes:

- **Full signature** - Parameter names and types
- **Description** - What the function does
- **Scope** - Client, Gateway, or Designer
- **Return type** - What the function returns
- **Parameter docs** - Description of each parameter

## Hover Documentation

Press `K` (or your LSP hover keybind) over any `system.*` function to see:

- Complete function signature
- Detailed description
- Parameter documentation
- Return value information
- Scope availability
- Deprecation warnings (if applicable)

## Go-to-Definition

Use LSP go-to-definition (typically `gd`) on any `system.*` function to jump to its API definition in the database, showing the complete documentation.
