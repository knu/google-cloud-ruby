# Release History

### 0.6.0 / 2019-10-23

#### Features

* Update Ruby dependency to minimum of 2.4 ([#4206](https://www.github.com/googleapis/google-cloud-ruby/issues/4206))

### 0.5.2 / 2019-10-15

#### Performance Improvements

* Update network configuration

### 0.5.1 / 2019-08-23

#### Documentation

* Update documentation

### 0.5.0 / 2019-07-08

* Support overriding service host and port.

### 0.4.0 / 2019-06-11

* Add #import_instance and #export_instance
* Add Instance#persistence_iam_identity
* Add Instance::State::IMPORTING
* Update documentation to REDIS_4_0 for Instance#redis_version
* Add VERSION constant

### 0.3.0 / 2019-04-29

* Add Instance#persistence_iam_identity attribute.
* Add CloudRedisClient#failover_instance.
* Add ListInstancesResponse#unreachable.
* Add AUTHENTICATION.md guide.
* Update generated documentation for common types.
* Update generated documentation.
* Extract gRPC header values from request.

### 0.2.3 / 2018-09-20

* Update documentation.
  * Change documentation URL to googleapis GitHub org.

### 0.2.2 / 2018-09-12

* Add V1 Client.

### 0.2.1 / 2018-09-10

* Update documentation.

### 0.2.0 / 2018-08-21

* Move Credentials location:
  * Add Google::Cloud::Redis::V1beta1::Credentials
  * Remove Google::Cloud::Redis::Credentials
* Update dependencies.
* Update documentation.

### 0.1.0 / 2018-05-09

This gem contains the Google Cloud Redis service implementation for the `google-cloud` gem.
