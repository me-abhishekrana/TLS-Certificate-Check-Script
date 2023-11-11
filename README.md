This Bash script is designed to check the SSL certificate expiration dates for a list of websites and generate an HTML report with a color-coded table indicating the status of each certificate based on the number of days until expiration.

Here's a breakdown of the script:

1. Define Websites and Variables:
An array named websites is defined with the URLs to be checked.
The SSL port is specified as SSL_PORT_ADDRESS.
The output HTML file is specified as output_file.
The current date and time are captured in current_date_time.