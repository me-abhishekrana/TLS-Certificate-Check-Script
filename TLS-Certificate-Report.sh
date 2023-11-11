#!/bin/bash

# Define an array of websites to check
websites=("www.nixcraft.com") # Add more URLs as needed, separated by spaces.

# Specify the SSL port
SSL_PORT_ADDRESS="443"

# Specify the output HTML file
output_file="ssl_certificate_results.html"
current_date_time=$(date "+%A - %Y-%m-%d %H:%M:%S")
echo $current_date_time
# Get the current date and time
# Initialize the HTML file with a header and a table structure
cat > "$output_file" <<EOF
<html>
<head>
  <title>SSL Certificate Expiry Date Report</title>
</head>
<body>
  <h1>TLS Certificate Report</h1>
  <p>Report generated on: $current_date_time</p>
<table border="1">
  <tr>
    <th>Endpoint</th>
    <th>Expiration Date</th>
    <th>Remaining Days</th>
  </tr>
EOF
# Loop through the array and check each website
for website in "${websites[@]}"; do
  expiration_date=$(echo | openssl s_client -connect "${website}:${SSL_PORT_ADDRESS}" -servername "${website}" 2> /dev/null | openssl x509 -noout -dates | grep "notAfter" | cut -d'=' -f2)
  
  # Convert the expiration date to a timestamp for comparison
  expiration_timestamp=$(date -d "$expiration_date" +%s)
  
  # Get the current timestamp
  current_timestamp=$(date +%s)
  
  # Calculate the number of seconds until expiration
  seconds_until_expiration=$((expiration_timestamp - current_timestamp))
  
  # Calculate the number of days until expiration
  days_until_expiration=$((seconds_until_expiration / 86400))
  
  # Set default status color to green
  status_color="green"

# Check the number of days until expiration and update status color
if [ "$days_until_expiration" -le 0 ]; then
  status_color="red"
elif [ "$days_until_expiration" -le 50 ]; then
  status_color="orange"
else
  status_color="green"
fi

  # Append the results to the HTML table with different status colors
  echo "<tr><td>$website</td><td>$expiration_date</td><td style=\"background-color: $status_color;\">$days_until_expiration days</td></tr>" >> "$output_file"
done

# Close the HTML file
cat >> "$output_file" <<EOF
</table>
</body>
</html>
EOF
