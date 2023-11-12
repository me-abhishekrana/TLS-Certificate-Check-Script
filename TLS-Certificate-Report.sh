pipeline {
    agent any
    stages {
        stage('tls-check') {
            steps {
                script {
                    sh '''#!/bin/bash

                    # Define an array of websites to check
                    websites=("example.com" "example.org" "example.net")
                    # Specify the SSL port
                    SSL_PORT_ADDRESS="443"

                    output_file="ssl_certificate_results.html"
                    current_date_time=$(date "+%A - %Y-%m-%d %H:%M:%S")
                    echo $current_date_time

                    # Get the current date and time
                    # Initialize the HTML file with a header and a table structure
                    cat > "$output_file" <<EOF
                    <html>
                    <head>
                        <title>SSL Certificate Expiry Date Report</title>
                        <style>
                            .orange {
                                background-color: orange;
                            }
                        </style>
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
                        echo "Checking website: $website"

                        # Add debugging output
                        openssl_output=$(openssl s_client -connect "${website}:${SSL_PORT_ADDRESS}" -servername "${website}" 2>&1)
                        echo "OpenSSL Output:"
                        echo "$openssl_output"

                        # Check if the openssl command was successful
                        if [[ $? -ne 0 ]]; then
                            echo "Error in openssl command. Check openssl_errors.log for details."
                            echo "$openssl_output" > openssl_errors.log
                            continue  # Skip to the next iteration
                        fi

                        expiration_date=$(echo "$openssl_output" | openssl x509 -noout -dates | grep "notAfter" | cut -d'=' -f2)

                        # Convert the expiration date to a timestamp for comparison
                        expiration_timestamp=$(date -d "$expiration_date" +%s)

                        # Get the current timestamp
                        current_timestamp=$(date +%s)

                        # Calculate the number of seconds until expiration
                        seconds_until_expiration=$((expiration_timestamp - current_timestamp))

                        # Calculate the number of days until expiration
                        days_until_expiration=$((seconds_until_expiration / 86400))

                        # Check if expiration is less than or equal to 90 days
                        if [ "$days_until_expiration" -le 90 ]; then
                            # Determine the CSS class based on remaining days
                            css_class="orange"
                            if [ "$days_until_expiration" -lt 50 ]; then
                                css_class="red"
                            fi

                            # Append the results to the HTML table with the CSS class
                            echo "<tr><td>$website</td><td>$expiration_date</td><td style='background-color: $css_class;'>$days_until_expiration</td></tr>" >> "$output_file"
                        fi
                    done

                    # Close the HTML file
                    cat >> "$output_file" <<EOF
                        </table>
                    </body>
                    </html>
EOF
                    '''
                }
            }
        }
    }
}
