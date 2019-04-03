# Alerting

### Default Baseline Alerts
Several baseline alerts are configured by this repository https://github.com/EBSCOIS/platform.infrastructure.baseline-alerts. The following alerts will now be implicitly added to every micro service that is deployed to the mesh. Below is an explanation for each alert and what it monitors.

Alerts are automatically forwarded to Opsgenie. Any cluster designated as "test" or "sandbox" have their alerts sent to https://app.sandbox.opsgenie.com. All other clusters are configured to send their alerts to https://app.opsgenie.com.


#### Error Alerts
Alert Name | Alert Description
---------- | -----------------
Service Error Rate Exceeding 10% | Fires if a service is throwing more than 10% errors for 5 minutes
Service Error Increase Detected | Fires if there is an increase in the error rate in the past 5 minutes that 40% higher than the error rate from the past hour and the service is receiving at least 1 request per second
Instance Error Increase Detected | Fires if there is an instance with an error rate that is 2 standard deviations above the average for the service and the service is receiving at least 1 request per second


#### Latency Alerts
Alert Name | Alert Description
---------- | -----------------
Service Latency over 5 seconds | Fires if a service response time is greater than 5 seconds
Service Latency Increase Detected | Fires if there is an increase in the service latency in the past 5 minutes that 40% higher than the latency from the past hour and the service is receiving at least 1 request per second
Instance Latency Increase Detected | Fires if there is an instance with latency that is 2 standard deviations above the average for the service and the service is receiving at least 1 request per second
