---
title: API Reference
description: Complete API documentation
---

This page contains the complete API reference for the project.

## Core API

### `initialize(options)`

Initialize the project with the given options.

**Parameters:**
- `options` (Object): Configuration options
  - `debug` (boolean): Enable debug mode
  - `config` (string): Path to config file

**Returns:** Promise<void>

**Example:**
```javascript
await initialize({
  debug: true,
  config: './config.json'
});
```

## Configuration

### Configuration File

The project uses a JSON configuration file:

```json
{
  "version": "1.0.0",
  "settings": {
    "feature": true
  }
}
```

## Error Handling

All API methods throw errors that should be caught:

```javascript
try {
  await initialize(options);
} catch (error) {
  console.error('Initialization failed:', error);
}
```