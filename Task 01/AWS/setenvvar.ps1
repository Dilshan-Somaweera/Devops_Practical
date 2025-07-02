# Load .env variables into environment variables
Get-Content .env | ForEach-Object {
    if ($_ -match "^\s*([^#].+?)\s*=\s*(.+)\s*$") {
      $key, $value = $matches[1], $matches[2]
      [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
  }
  
  # Run terraform command
  terraform plan
  