# Release History

### 0.33.0 / 2019-10-23

#### Features

* Update Ruby dependency to minimum of 2.4 ([#4206](https://www.github.com/googleapis/google-cloud-ruby/issues/4206))

### 0.32.0 / 2019-10-03

#### Features

* Additions to the content matcher for uptime check
  * Add recursive argument to GroupServiceClient#delete_group method.
  * Add AlertPolicy#validity
  * Remove UptimeCheckConfig#is_internal (BREAKING CHANGE)
  * Add UptimeCheckConfig::HttpCheck#validate_ssl
  * Add InternalChecker::State module and constants:
      * Add InternalChecker::State::CREATING
      * Add InternalChecker::State::RUNNING
  * Add ContentMatcher::ContentMatcherOption module and constants:
      * Add ContentMatcher::ContentMatcherOption::CONTAINS_STRING
      * Add ContentMatcher::ContentMatcherOption::NOT_CONTAINS_STRING
      * Add ContentMatcher::ContentMatcherOption::MATCHES_REGEX
      * Add ContentMatcher::ContentMatcherOption::NOT_MATCHES_REGEX
  * Add UptimeCheckConfig::ContentMatcher:: ContentMatcherOption module and constants:
      * Add UptimeCheckConfig::ContentMatcher:: ContentMatcherOption::CONTAINS_STRING
      * Add UptimeCheckConfig::ContentMatcher:: ContentMatcherOption::NOT_CONTAINS_STRING
      * Add UptimeCheckConfig::ContentMatcher:: ContentMatcherOption::MATCHES_REGEX
      * Add UptimeCheckConfig::ContentMatcher:: ContentMatcherOption::NOT_MATCHES_REGEX
  * Update documentation

### 0.31.0 / 2019-08-23

#### Features

* Add NotificationChannel verification
  * Add NotificationChannelServiceClient#send_notification_channel_verification_code
  * Add NotificationChannelServiceClient#get_notification_channel_verification_code
  * Add NotificationChannelServiceClient#verify_notification_channel

#### Documentation

* Update documentation

### 0.30.0 / 2019-07-08

* Support overriding service host and port.

### 0.29.5 / 2019-06-11

* Add documentation for MetricDescriptor#launch_stage and
  MonitoredResourceDescriptor#launch_stage
* Deprecate MetricDescriptor:: MetricDescriptorMetadata#launch_stage
* Add VERSION constant

### 0.29.4 / 2019-04-29

* Add AUTHENTICATION.md guide.
* Update generated documentation.
* Update generated code examples.
* Extract gRPC header values from request.

### 0.29.3 / 2019-02-01

* Update network configuration.
* Update documentation.

### 0.29.2 / 2018-09-20

* Update Monitoring generated files.
  * Add MetricDescriptorMetadata.
* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.29.1 / 2018-09-10

* Update documentation.

### 0.29.0 / 2018-08-21

* Move Credentials location:
  * Add Google::Cloud::Monitoring::V3::Credentials
  * Remove Google::Cloud::Monitoring::Credentials
* Update documentation.

### 0.28.0 / 2018-04-19

* Refresh generated client and documentation for updated V3 Monitoring API.

### 0.27.0 / 2017-12-19

* Update google-gax dependency to 1.0.

### 0.26.1 / 2017-11-15

* Fix Credentials environment variable names.

### 0.26.0 / 2017-11-14

* Update generated GAPIC code and documentation.
* Updated `google-gax` (`grpc`, `google-protobuf`), `googleauth` dependencies.

### 0.25.0 / 2017-07-11

* Update GAPIC configuration to exclude `UNAVAILABLE` errors from automatic retry.
* Update README.
* Update gem spec homepage links.

### 0.24.0 / 2017-03-31

* Updated documentation
* Automatic retry on `UNAVAILABLE` errors

### 0.23.2 / 2017-03-03

* Update GRPC header value sent to the Monitoring API.

### 0.23.1 / 2017-03-01

* Update GRPC header value sent to the Monitoring API.

### 0.23.0 / 2017-02-21

* Fix GRPC retry bug
* The client_config data structure has replaced retry_codes/retry_codes_def with retry_codes
* Update GRPC/Protobuf/GAX dependencies

### 0.22.0 / 2017-01-27

* Change class names in low-level API (GAPIC)
* Add LICENSE to package

### 0.21.0 / 2016-10-20

* First release
