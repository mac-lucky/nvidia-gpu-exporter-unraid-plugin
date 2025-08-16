# XML Validation Fixes Applied

## Issues Fixed

The XML validation errors were caused by unescaped special characters in the embedded bash scripts within the CDATA sections. In XML, certain characters have special meaning and must be escaped:

### Characters That Needed Escaping:

1. **`&` → `&amp;`** - Ampersand used in bash redirections like `2>&1`
2. **`>` → `&gt;`** - Greater than symbol used in bash redirections like `> /dev/null`

### Specific Fixes Applied:

#### In Both `nvidia-gpu-exporter.plg` and `nvidia-gpu-exporter-local.plg`:

1. **Bash redirections in control script functions**:

   - `2>&1` → `2&gt;&amp;1`
   - `> /dev/null` → `&gt; /dev/null`
   - `> /var/log/nvidia-gpu-exporter.log` → `&gt; /var/log/nvidia-gpu-exporter.log`
   - `> $PIDFILE` → `&gt; $PIDFILE`

2. **Background process operators**:

   - `&` at end of commands → `&amp;`

3. **Error suppression redirections**:

   - `2>/dev/null` → `2&gt;/dev/null`

4. **PHP shell_exec calls**:
   - `shell_exec("command 2>&1")` → `shell_exec("command 2&gt;&amp;1")`

### Lines Fixed:

#### nvidia-gpu-exporter.plg:

- Line 31: Pre-install script redirection
- Line 57, 74, 78, 96: kill command redirections in start/stop/status functions
- Line 66: nohup command with background operator and redirections
- Line 337: PHP shell_exec redirection
- Line 373: Remove script redirection

#### nvidia-gpu-exporter-local.plg:

- Same line numbers and patterns as main plugin file

### Validation Result:

✅ **Both XML files now pass validation**:

```bash
xmllint --noout nvidia-gpu-exporter.plg         # No errors
xmllint --noout nvidia-gpu-exporter-local.plg   # No errors
```

### Why This Matters:

- **Unraid Plugin Installation**: Unraid's plugin system validates XML before processing
- **Proper XML Parsing**: Ensures all embedded scripts are correctly interpreted
- **Installation Success**: Prevents "Invalid URL / Server error response" due to malformed XML

The plugin should now install successfully without XML parsing errors.
